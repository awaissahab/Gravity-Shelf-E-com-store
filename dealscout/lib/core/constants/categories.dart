/// Deal categories available in the app
class DealCategory {
  static const String restaurants = 'restaurants';
  static const String fastFood = 'fast_food';
  static const String groceries = 'groceries';
  static const String fashion = 'fashion';
  static const String electronics = 'electronics';
  static const String medicine = 'medicine';
  static const String beauty = 'beauty';
  static const String hotels = 'hotels';
  static const String gyms = 'gyms';
  static const String entertainment = 'entertainment';
  static const String coffee = 'coffee';
  static const String fuel = 'fuel';
  static const String onlineShopping = 'online_shopping';
  static const String travel = 'travel';
  static const String education = 'education';
  
  /// Get display name for category
  static String getDisplayName(String category) {
    switch (category) {
      case restaurants: return '🍽️ Restaurants';
      case fastFood: return '🍔 Fast Food';
      case groceries: return '🛒 Groceries';
      case fashion: return '👗 Fashion';
      case electronics: return '📱 Electronics';
      case medicine: return '💊 Medicine';
      case beauty: return '💄 Beauty';
      case hotels: return '🏨 Hotels';
      case gyms: return '💪 Gyms';
      case entertainment: return '🎬 Entertainment';
      case coffee: return '☕ Coffee';
      case fuel: return '⛽ Fuel';
      case onlineShopping: return '🛍️ Online Shopping';
      case travel: return '✈️ Travel';
      case education: return '📚 Education';
      default: return category;
    }
  }
  
  /// Get icon data for category
  static IconData getIcon(String category) {
    switch (category) {
      case restaurants: return Icons.restaurant;
      case fastFood: return Icons.fastfood;
      case groceries: return Icons.shopping_cart;
      case fashion: return Icons.checkroom;
      case electronics: return Icons.devices;
      case medicine: return Icons.medication;
      case beauty: return Icons.face;
      case hotels: return Icons.hotel;
      case gyms: return Icons.fitness_center;
      case entertainment: return Icons.movie;
      case coffee: return Icons.local_cafe;
      case fuel: return Icons.local_gas_station;
      case onlineShopping: return Icons.shopping_bag;
      case travel: return Icons.flight;
      case education: return Icons.school;
      default: return Icons.store;
    }
  }
  
  /// Get all categories
  static List<String> getAllCategories() {
    return [
      restaurants,
      fastFood,
      groceries,
      fashion,
      electronics,
      medicine,
      beauty,
      hotels,
      gyms,
      entertainment,
      coffee,
      fuel,
      onlineShopping,
      travel,
      education,
    ];
  }
}

/// Discount types
enum DiscountType {
  percentage,
  fixed,
  bogo, // Buy One Get One
}

/// Deal status
enum DealStatus {
  active,
  expired,
  upcoming,
  paused,
}

/// User role
enum UserRole {
  user,
  merchant,
  admin,
}

/// Subscription tier for merchants
enum SubscriptionTier {
  free,
  basic,
  premium,
}
