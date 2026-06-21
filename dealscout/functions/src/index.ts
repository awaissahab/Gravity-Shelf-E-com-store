import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();
const db = admin.firestore();

/**
 * Get nearby deals based on user location
 */
export const getNearbyDeals = functions.https.onCall(async (data, context) => {
  const { latitude, longitude, radius = 10 } = data;
  
  if (!latitude || !longitude) {
    throw new functions.https.HttpsError('invalid-argument', 'Location is required');
  }

  // Calculate bounding box for geohash query
  const deals = await db.collection('deals')
    .where('isActive', '==', true)
    .where('expiryDate', '>', admin.firestore.Timestamp.now())
    .orderBy('expiryDate')
    .limit(50)
    .get();

  const nearbyDeals: any[] = [];
  
  deals.forEach(doc => {
    const dealData = doc.data();
    const dealLocation = dealData.location;
    
    if (dealLocation) {
      const distance = calculateDistance(
        latitude,
        longitude,
        dealLocation.latitude,
        dealLocation.longitude
      );
      
      if (distance <= radius) {
        nearbyDeals.push({
          id: doc.id,
          ...dealData,
          distance: distance.toFixed(2),
        });
      }
    }
  });

  // Sort by distance
  nearbyDeals.sort((a, b) => parseFloat(a.distance) - parseFloat(b.distance));

  return { deals: nearbyDeals };
});

/**
 * Create a new deal (merchant only)
 */
export const createDeal = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { title, description, category, discountValue, discountType, expiryDate, location } = data;

  // Verify user is a merchant
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const userData = userDoc.data();
  
  if (userData?.role !== 'merchant') {
    throw new functions.https.HttpsError('permission-denied', 'Only merchants can create deals');
  }

  const dealRef = await db.collection('deals').add({
    merchantId: context.auth.uid,
    merchantName: userData?.businessName || 'Unknown Merchant',
    title,
    description,
    category,
    discountType,
    discountValue,
    location,
    expiryDate: admin.firestore.Timestamp.fromMillis(expiryDate),
    isActive: true,
    isFeatured: false,
    isSponsored: false,
    views: 0,
    saves: 0,
    redemptions: 0,
    rating: 0,
    reviewCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update merchant's deal count
  await db.collection('merchants').doc(userData.merchantId).update({
    totalDeals: admin.firestore.FieldValue.increment(1),
    activeDeals: admin.firestore.FieldValue.increment(1),
  });

  return { dealId: dealRef.id };
});

/**
 * AI-powered deal recommendations
 */
export const getAIRecommendations = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { userId, preferences, location } = data;

  // Get user preferences and history
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data();

  if (!userData) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  // Get deals matching preferences
  const preferredCategories = userData.preferences?.categories || [];
  
  let query = db.collection('deals')
    .where('isActive', '==', true)
    .where('expiryDate', '>', admin.firestore.Timestamp.now())
    .orderBy('discountValue', 'desc')
    .limit(20);

  if (preferredCategories.length > 0) {
    query = query.where('category', 'in', preferredCategories.slice(0, 10));
  }

  const snapshot = await query.get();
  const recommendations: any[] = [];

  snapshot.forEach(doc => {
    recommendations.push({
      id: doc.id,
      ...doc.data(),
      matchScore: calculateMatchScore(doc.data(), userData),
    });
  });

  // Sort by match score
  recommendations.sort((a, b) => b.matchScore - a.matchScore);

  return { recommendations: recommendations.slice(0, 10) };
});

/**
 * Process cashback transaction
 */
export const processCashback = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { dealId, amount, receiptImage } = data;

  const dealDoc = await db.collection('deals').doc(dealId).get();
  if (!dealDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Deal not found');
  }

  const dealData = dealDoc.data()!;
  const cashbackPercentage = dealData.cashbackPercentage || 0;
  const cashbackAmount = amount * (cashbackPercentage / 100);

  // Create transaction record
  const transactionRef = await db.collection('transactions').add({
    userId: context.auth.uid,
    dealId,
    merchantId: dealData.merchantId,
    type: 'cashback_pending',
    amount: cashbackAmount,
    originalAmount: amount,
    status: 'pending',
    receiptImage,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update deal redemption count
  await db.collection('deals').doc(dealId).update({
    redemptions: admin.firestore.FieldValue.increment(1),
  });

  return { 
    transactionId: transactionRef.id,
    cashbackAmount,
    status: 'pending'
  };
});

/**
 * Calculate distance between two points using Haversine formula
 */
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(degrees: number): number {
  return degrees * (Math.PI / 180);
}

/**
 * Calculate how well a deal matches user preferences
 */
function calculateMatchScore(deal: any, user: any): number {
  let score = 0;
  
  // Category match
  if (user.preferences?.categories?.includes(deal.category)) {
    score += 50;
  }
  
  // Discount value
  score += deal.discountValue || 0;
  
  // Rating
  score += (deal.rating || 0) * 10;
  
  // Distance (lower is better)
  if (deal.distance) {
    score += Math.max(0, 20 - parseFloat(deal.distance));
  }
  
  return score;
}

// Export Stripe webhook handler
export { handleStripeWebhook } from './payments';
