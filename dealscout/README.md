# DealScout - Premium Deal Discovery App

[![Flutter](https://img.shields.io/badge/Flutter-3.16-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Overview

DealScout is a production-ready, premium mobile application that helps users discover the best nearby discounts, sales, cashback offers, restaurant deals, grocery discounts, fashion sales, electronics offers, and local business promotions in real-time.

Built with **Flutter** and **Firebase**, featuring **AI-powered recommendations**, **real-time map views**, **price tracking**, and a **merchant dashboard**.

## ✨ Features

### For Users
- 🎯 **Nearby Deals**: Discover deals sorted by distance, rating, and discount percentage
- 🗺️ **Interactive Map**: Live map with deal pins and filtering
- 🔍 **Smart Search**: Search by store, product, brand, discount, location, or category
- 🤖 **AI Assistant**: Chat-based deal recommendations powered by Google Generative AI
- 💰 **Cashback Tracking**: Track pending and completed cashback
- 🎫 **Coupons**: Auto-copy, QR codes, and barcode coupons
- 📊 **Price History**: View price trends and get alerts on drops
- ⭐ **Reviews & Ratings**: Rate stores and upload photos
- 🏆 **Gamification**: Daily streaks, coins, achievements, and leaderboards
- 🔔 **Smart Notifications**: Nearby deals, flash sales, expiring offers
- ❤️ **Favorites**: Save deals, stores, and products

### For Merchants
- 📈 **Analytics Dashboard**: Real-time insights on deal performance
- 🚀 **Boost Deals**: Promoted listings and featured placements
- 💳 **Payment Integration**: Stripe and Apple Pay support
- 📝 **Review Management**: Respond to customer reviews
- 🎨 **Deal Creation**: Easy-to-use interface for creating offers

### Admin Panel
- 👥 **User Management**: Manage users and roles
- 🏪 **Store Verification**: Approve and verify merchants
- 📊 **Analytics**: Revenue dashboard and reports
- 🚫 **Moderation**: Block spam and fake deals
- 📱 **Push Notifications**: Send targeted campaigns

## 🏗️ Architecture

DealScout follows **Clean Architecture** principles with **MVVM** pattern:

```
lib/
├── core/                    # Core utilities, constants, theme
│   ├── constants/          # App-wide constants
│   ├── theme/              # Theme configuration
│   ├── utils/              # Utility functions
│   └── error/              # Error handling
├── data/                    # Data layer
│   ├── datasources/        # Remote & local data sources
│   ├── models/             # Data models (DTOs)
│   └── repositories/       # Repository implementations
├── domain/                  # Business logic layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
└── presentation/            # UI layer
    ├── providers/          # State management (Riverpod)
    ├── screens/            # App screens
    └── widgets/            # Reusable widgets
```

## 📦 Tech Stack

### Frontend
- **Flutter 3.16+** - Cross-platform framework
- **Riverpod 2.4** - State management
- **GoRouter 13** - Navigation
- **Freezed** - Code generation for immutable models
- **Json Serializable** - JSON parsing

### Backend
- **Firebase Authentication** - User auth
- **Cloud Firestore** - NoSQL database
- **Cloud Functions** - Server-side logic
- **Firebase Storage** - File storage
- **Firebase Messaging** - Push notifications
- **Firebase Analytics** - Usage analytics

### Third-party Services
- **Google Maps** - Location and mapping
- **Google Generative AI** - AI chat assistant
- **Stripe** - Payment processing
- **Geolocator** - GPS location

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Firebase project
- Google Maps API key
- Stripe account (for payments)
- Google Generative AI API key

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/dealscout.git
cd dealscout
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add iOS and Android apps
   - Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android)
   - Place them in their respective directories

4. **Configure environment variables**
   
Create `lib/core/constants/env.dart`:
```dart
class Env {
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googleAiApiKey = 'YOUR_GOOGLE_AI_API_KEY';
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
}
```

5. **Run the app**
```bash
flutter run
```

## 📱 Screenshots

| Onboarding | Home | Map View | AI Chat |
|------------|------|----------|---------|
| ![Onboarding](assets/screenshots/onboarding.png) | ![Home](assets/screenshots/home.png) | ![Map](assets/screenshots/map.png) | ![AI Chat](assets/screenshots/ai_chat.png) |

## 🗄️ Database Schema

### Collections

#### users
```typescript
{
  id: string;
  email: string;
  displayName: string;
  photoURL?: string;
  phoneNumber?: string;
  location: GeoPoint;
  city: string;
  preferences: {
    categories: string[];
    brands: string[];
    maxDistance: number;
  };
  gamification: {
    coins: number;
    streak: number;
    level: number;
    achievements: string[];
  };
  createdAt: Timestamp;
  lastActiveAt: Timestamp;
}
```

#### deals
```typescript
{
  id: string;
  merchantId: string;
  title: string;
  description: string;
  category: string;
  subcategory?: string;
  discountType: 'percentage' | 'fixed' | 'bogo';
  discountValue: number;
  originalPrice?: number;
  finalPrice?: number;
  location: GeoPoint;
  address: string;
  expiryDate: Timestamp;
  images: string[];
  terms: string[];
  isActive: boolean;
  isFeatured: boolean;
  isSponsored: boolean;
  views: number;
  saves: number;
  redemptions: number;
  rating: number;
  reviewCount: number;
  cashbackPercentage?: number;
  couponCode?: string;
  qrCode?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### merchants
```typescript
{
  id: string;
  userId: string;
  businessName: string;
  description: string;
  category: string;
  subcategories: string[];
  location: GeoPoint;
  address: string;
  phone: string;
  email: string;
  website?: string;
  socialLinks: {
    facebook?: string;
    instagram?: string;
    twitter?: string;
  };
  openingHours: {
    monday: { open: string; close: string };
    // ... other days
  };
  images: string[];
  logo?: string;
  verified: boolean;
  subscriptionTier: 'free' | 'basic' | 'premium';
  subscriptionExpiry?: Timestamp;
  totalDeals: number;
  activeDeals: number;
  totalViews: number;
  totalRedemptions: number;
  rating: number;
  reviewCount: number;
  createdAt: Timestamp;
}
```

#### reviews
```typescript
{
  id: string;
  dealId?: string;
  merchantId?: string;
  userId: string;
  userName: string;
  userPhoto?: string;
  rating: number;
  comment: string;
  images: string[];
  helpful: number;
  reported: boolean;
  merchantResponse?: {
    comment: string;
    timestamp: Timestamp;
  };
  createdAt: Timestamp;
}
```

#### transactions
```typescript
{
  id: string;
  userId: string;
  dealId: string;
  merchantId: string;
  type: 'cashback_pending' | 'cashback_completed' | 'purchase';
  amount: number;
  status: 'pending' | 'completed' | 'cancelled';
  paymentIntentId?: string;
  createdAt: Timestamp;
  completedAt?: Timestamp;
}
```

## 🔌 API Structure

### Cloud Functions Endpoints

#### Deals
- `POST /api/deals/create` - Create new deal
- `GET /api/deals/nearby` - Get nearby deals
- `GET /api/deals/:id` - Get deal details
- `PUT /api/deals/:id` - Update deal
- `DELETE /api/deals/:id` - Delete deal
- `POST /api/deals/:id/boost` - Boost deal visibility

#### Merchants
- `POST /api/merchants/create` - Create merchant profile
- `GET /api/merchants/:id` - Get merchant details
- `PUT /api/merchants/:id` - Update merchant profile
- `GET /api/merchants/:id/analytics` - Get merchant analytics

#### Users
- `GET /api/users/:id/favorites` - Get user favorites
- `POST /api/users/:id/favorites` - Add to favorites
- `DELETE /api/users/:id/favorites/:dealId` - Remove from favorites
- `GET /api/users/:id/rewards` - Get user rewards

#### AI
- `POST /api/ai/recommend` - Get AI recommendations
- `POST /api/ai/chat` - Chat with AI assistant

#### Payments
- `POST /api/payments/create-intent` - Create payment intent
- `POST /api/payments/webhook` - Stripe webhook handler

## 🎨 Design System

### Colors
```dart
primary: Color(0xFF6C63FF)    // Purple
secondary: Color(0xFFFF6584)   // Pink
accent: Color(0xFF4FC3F7)      // Light Blue
success: Color(0xFF4CAF50)     // Green
warning: Color(0xFFFF9800)     // Orange
error: Color(0xFFF44336)       // Red
```

### Typography
- **Font Family**: Poppins
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Components
- Glassmorphism cards with blur effects
- Premium gradients
- Smooth micro-interactions
- Material 3 design language
- Dark/Light mode support

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widget

# Integration tests
flutter test integration_test

# Coverage
flutter test --coverage
```

### Test Strategy
- **Unit Tests**: Business logic, use cases, utilities
- **Widget Tests**: Individual widgets and components
- **Integration Tests**: Full user flows
- **E2E Tests**: Complete app scenarios

## 📊 Performance Optimization

- ✅ Lazy loading for lists
- ✅ Pagination for large datasets
- ✅ Image caching with CachedNetworkImage
- ✅ Offline support with Firestore persistence
- ✅ Efficient state management with Riverpod
- ✅ Code splitting and tree shaking
- ✅ Minimized build size

## 🔒 Security

- JWT authentication
- Encrypted secure storage
- Role-based access control
- Rate limiting on API endpoints
- Input validation and sanitization
- Anti-spam measures
- HTTPS enforcement

## 📤 Deployment

### Firebase Setup

1. **Enable services in Firebase Console:**
   - Authentication (Email, Google, Apple, Phone)
   - Firestore Database
   - Cloud Storage
   - Cloud Functions
   - Cloud Messaging
   - Analytics

2. **Deploy Cloud Functions:**
```bash
cd functions
npm install
firebase deploy --only functions
```

3. **Configure security rules:**
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Build for Production

#### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### CI/CD Pipeline

Example GitHub Actions workflow:
```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
```

## 📈 Monetization

1. **Featured Deals** - Merchants pay for prominent placement
2. **Sponsored Listings** - Paid search results
3. **Merchant Subscriptions** - Monthly plans for advanced features
4. **Affiliate Links** - Commission on referred purchases
5. **Premium Membership** - Ad-free experience with exclusive deals
6. **Data Insights** - Analytics reports for businesses

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@dealscout.app or join our Discord community.

---

Made with ❤️ by the DealScout Team
