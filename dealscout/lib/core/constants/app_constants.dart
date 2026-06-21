import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Spacing
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  
  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  
  // Icon Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;
  
  // Avatar Sizes
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 40.0;
  static const double avatarSizeLg = 56.0;
  static const double avatarSizeXl = 80.0;
  
  // Card Heights
  static const double cardHeightSm = 120.0;
  static const double cardHeightMd = 180.0;
  static const double cardHeightLg = 240.0;
  
  // Shadow Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  
  // Opacity
  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.8;
  
  // Shimmer Duration
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  
  // Cache Expiry
  static const int cacheExpirySeconds = 1800; // 30 minutes
  
  // Pagination
  static const int initialPageSize = 10;
  static const int loadMorePageSize = 20;
  
  // Image Aspect Ratios
  static const double imageAspectRatioCard = 16 / 9;
  static const double imageAspectRatioSquare = 1;
  static const double imageAspectRatioPortrait = 3 / 4;
  
  // Map Settings
  static const double defaultZoomLevel = 13.0;
  static const double minZoomLevel = 5.0;
  static const double maxZoomLevel = 18.0;
  
  // Rating
  static const double minRating = 0.0;
  static const double maxRating = 5.0;
  
  // Character Limits
  static const int maxReviewLength = 500;
  static const int maxDealTitleLength = 100;
  static const int maxDealDescriptionLength = 1000;
  
  // Gamification
  static const int coinsPerSave = 5;
  static const int coinsPerRedemption = 20;
  static const int coinsPerReview = 10;
  static const int coinsPerReferral = 100;
  static const int streakBonusCoins = 50;
}
