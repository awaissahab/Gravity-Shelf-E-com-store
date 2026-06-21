import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

/**
 * Handle Stripe webhook events
 */
export const handleStripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature']!;
  
  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      functions.config().stripe.webhook_secret
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return res.status(400).send(`Webhook Error: ${err}`);
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
      break;
      
    case 'payment_intent.payment_failed':
      await handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
      break;
      
    case 'charge.refunded':
      await handleRefund(event.data.object as Stripe.Charge);
      break;
      
    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

/**
 * Create a payment intent for merchant subscription or deal boost
 */
export const createPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { amount, currency = 'usd', description, metadata } = data;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      description,
      metadata: {
        userId: context.auth.uid,
        ...metadata,
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Process merchant subscription
 */
export const createSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { priceId, tier } = data;

  try {
    // Create or get customer
    let customerId = await getOrCreateCustomerId(context.auth.uid);

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent'],
    });

    // Update user's subscription status
    await admin.firestore().collection('users').doc(context.auth.uid).update({
      subscriptionTier: tier,
      subscriptionStatus: 'active',
      subscriptionId: subscription.id,
      subscriptionExpiry: admin.firestore.Timestamp.fromMillis(
        subscription.current_period_end * 1000
      ),
    });

    return {
      subscriptionId: subscription.id,
      clientSecret: (subscription.latest_invoice as any)?.payment_intent?.client_secret,
    };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

async function handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
  const userId = paymentIntent.metadata?.userId;
  const type = paymentIntent.metadata?.type;

  if (!userId) return;

  const db = admin.firestore();

  // Record successful payment
  await db.collection('payments').add({
    userId,
    paymentIntentId: paymentIntent.id,
    amount: paymentIntent.amount / 100,
    currency: paymentIntent.currency,
    status: 'succeeded',
    type,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // If it's a subscription, update user
  if (type === 'subscription') {
    const tier = paymentIntent.metadata?.tier || 'basic';
    await db.collection('users').doc(userId).update({
      subscriptionTier: tier,
      subscriptionStatus: 'active',
    });
  }
}

async function handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
  const userId = paymentIntent.metadata?.userId;
  
  if (!userId) return;

  const db = admin.firestore();

  // Record failed payment
  await db.collection('payments').add({
    userId,
    paymentIntentId: paymentIntent.id,
    amount: paymentIntent.amount / 100,
    currency: paymentIntent.currency,
    status: 'failed',
    failureReason: paymentIntent.last_payment_error?.message,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function handleRefund(charge: Stripe.Charge) {
  const paymentIntentId = typeof charge.payment_intent === 'string' 
    ? charge.payment_intent 
    : charge.payment_intent?.id;

  if (!paymentIntentId) return;

  const db = admin.firestore();

  // Find the payment record
  const payments = await db.collection('payments')
    .where('paymentIntentId', '==', paymentIntentId)
    .limit(1)
    .get();

  if (!payments.empty) {
    const doc = payments.docs[0];
    await doc.ref.update({
      status: 'refunded',
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

async function getOrCreateCustomerId(userId: string): Promise<string> {
  const db = admin.firestore();
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data();

  if (userData?.stripeCustomerId) {
    return userData.stripeCustomerId;
  }

  // Get user email
  const authUser = await admin.auth().getUser(userId);
  
  // Create Stripe customer
  const customer = await stripe.customers.create({
    email: authUser.email,
    metadata: { firebaseUserId: userId },
  });

  // Save customer ID
  await db.collection('users').doc(userId).update({
    stripeCustomerId: customer.id,
  });

  return customer.id;
}
