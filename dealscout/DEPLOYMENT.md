# DealScout Deployment Guide

## Prerequisites

1. **Flutter SDK** (>= 3.0.0)
   ```bash
   flutter doctor
   ```

2. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

3. **Node.js** (>= 18.x) for Cloud Functions

4. **Google Cloud Project** with billing enabled

5. **API Keys**:
   - Google Maps API Key
   - Google Generative AI API Key
   - Stripe API Keys

## Firebase Setup

### 1. Create Firebase Project

```bash
firebase login
firebase projects:create dealscout-yourname
firebase use --add
```

### 2. Enable Firebase Services

In Firebase Console:
- **Authentication**: Enable Email/Password, Google, Apple sign-in
- **Firestore Database**: Create database in production mode
- **Cloud Storage**: Create bucket
- **Cloud Functions**: Upgrade to Blaze plan
- **Cloud Messaging**: Enable FCM

### 3. Add Apps to Firebase

#### Android
1. Register app with package name: `com.dealscout.app`
2. Download `google-services.json`
3. Place in `android/app/google-services.json`

#### iOS
1. Register app with bundle ID: `com.dealscout.app`
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`

### 4. Configure Environment

Create `lib/core/constants/env.dart`:

```dart
class Env {
  static const String googleMapsApiKey = 'YOUR_KEY';
  static const String googleAiApiKey = 'YOUR_KEY';
  static const String stripePublishableKey = 'YOUR_KEY';
}
```

### 5. Deploy Firestore Rules & Indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 6. Deploy Storage Rules

```bash
firebase deploy --only storage:rules
```

### 7. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

Set up Stripe webhook secret:
```bash
firebase functions:config:set stripe.secret_key="sk_xxx" stripe.webhook_secret="whsec_xxx"
```

## Build Mobile App

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`
AAB location: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive.

## CI/CD Pipeline (GitHub Actions)

Create `.github/workflows/build.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  deploy-functions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install -g firebase-tools
      - run: cd functions && npm install
      - run: firebase deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Monitoring & Analytics

### 1. Set up Firebase Crashlytics

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

Initialize in `main.dart`:
```dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

### 2. Set up Performance Monitoring

```dart
await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
```

### 3. Configure Alerts

In Firebase Console:
- Set up crash-free users alert (< 95%)
- Set up ANR rate alert
- Set up function error rate alert

## Scaling Considerations

### Database Optimization

1. Use composite indexes for complex queries
2. Implement pagination for large collections
3. Cache frequently accessed data locally
4. Use Firestore offline persistence

### Function Optimization

1. Keep functions under 5 seconds execution time
2. Use background functions for non-critical operations
3. Implement retry logic with exponential backoff
4. Monitor function cold starts

### CDN & Caching

1. Use Firebase Hosting CDN for static assets
2. Implement image caching with CachedNetworkImage
3. Cache API responses locally

## Security Checklist

- [ ] Firestore rules properly configured
- [ ] Storage rules restrict unauthorized access
- [ ] API keys not hardcoded in source
- [ ] Stripe webhook signature verification
- [ ] Rate limiting on Cloud Functions
- [ ] Input validation on all user inputs
- [ ] HTTPS enforced everywhere
- [ ] Authentication required for sensitive operations

## Rollback Procedure

### Mobile App
1. Revert code in Git
2. Build previous version
3. Submit update to stores

### Cloud Functions
```bash
firebase functions:rollback
```

### Firestore Rules
```bash
# Keep previous version saved
firebase deploy --only firestore:rules --rules firestore.rules.backup
```

## Cost Estimation

### Firebase (Monthly for ~10k users)
- Firestore: ~$25
- Storage: ~$5
- Functions: ~$10
- Auth: Free (up to 10k/month)
- Hosting: Free tier
- **Total: ~$40-50/month**

### Third-party Services
- Google Maps: ~$200 (first $200 free monthly)
- Stripe: 2.9% + $0.30 per transaction
- Google AI: ~$50 (depending on usage)

## Support

For deployment issues:
1. Check Firebase Console logs
2. Review Cloud Function logs
3. Check Crashlytics for app crashes
4. Contact support at support@dealscout.app
