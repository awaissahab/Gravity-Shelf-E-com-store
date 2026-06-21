/// Environment configuration for DealScout
/// 
/// Replace these values with your actual API keys before running the app.
class Env {
  // Firebase Configuration
  static const String firebaseProjectId = 'your-firebase-project-id';
  
  // Google Maps API Key
  // Get from: https://console.cloud.google.com/apis/credentials
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Google Generative AI API Key (for AI Chat Assistant)
  // Get from: https://makersuite.google.com/app/apikey
  static const String googleAiApiKey = 'YOUR_GOOGLE_AI_API_KEY';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String stripeSecretKey = 'YOUR_STRIPE_SECRET_KEY';
  
  // App Configuration
  static const String appName = 'DealScout';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (if using custom backend)
  static const String baseUrl = 'https://us-central1-your-project.cloudfunctions.net';
  
  // Feature Flags
  static const bool enableAIChat = true;
  static const bool enableCashback = true;
  static const bool enableGamification = true;
  static const bool enableMerchantDashboard = true;
  
  // Limits
  static const int maxDealsPerPage = 20;
  static const int maxRadiusKm = 50;
  static const int defaultRadiusKm = 10;
  
  // Cache Duration
  static const int cacheDurationMinutes = 30;
}
