import 'package:flutter/material.dart';
import 'user_preferences_provider.dart';

enum SubscriptionTier {
  free,
  premium,
}

enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
}

class SubscriptionInfo {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? transactionId;
  final bool autoRenew;

  const SubscriptionInfo({
    required this.tier,
    required this.status,
    this.startDate,
    this.endDate,
    this.transactionId,
    this.autoRenew = false,
  });

  SubscriptionInfo copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionId,
    bool? autoRenew,
  }) {
    return SubscriptionInfo(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      transactionId: transactionId ?? this.transactionId,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}

class SubscriptionProvider extends ChangeNotifier {
  final UserPreferencesProvider _userPreferencesProvider;

  SubscriptionInfo _subscriptionInfo = const SubscriptionInfo(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.inactive,
  );
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider(this._userPreferencesProvider) {
    _loadSubscriptionInfo();
  }

  // Getters
  SubscriptionInfo get subscriptionInfo => _subscriptionInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  bool get isPremium => _subscriptionInfo.tier == SubscriptionTier.premium && 
                      _subscriptionInfo.status == SubscriptionStatus.active;
  bool get isFree => _subscriptionInfo.tier == SubscriptionTier.free;
  bool get isSubscriptionActive => _subscriptionInfo.status == SubscriptionStatus.active;
  bool get isSubscriptionExpired => _subscriptionInfo.status == SubscriptionStatus.expired;
  
  DateTime? get subscriptionEndDate => _subscriptionInfo.endDate;
  int? get daysUntilExpiry {
    if (_subscriptionInfo.endDate == null) return null;
    final now = DateTime.now();
    final difference = _subscriptionInfo.endDate!.difference(now);
    return difference.inDays;
  }

  // Premium feature limits
  int get maxWishItems => isPremium ? 1000 : 50;
  int get maxCollections => isPremium ? 50 : 3;
  int get maxTagsPerItem => isPremium ? 20 : 5;
  bool get canUseDesireLevels => isPremium;
  bool get canUsePriceTracking => isPremium;
  bool get canUseAdvancedAnalytics => isPremium;
  bool get canExportData => isPremium;
  bool get canUseCustomThemes => isPremium;
  bool get hasCloudSync => isPremium;
  bool get hasAdFree => isPremium;

  Future<void> _loadSubscriptionInfo() async {
    _setLoading(true);
    try {
      // In a real app, this would load from a backend service
      // For now, we'll check the user preferences
      final isPremiumFromPrefs = _userPreferencesProvider.isPremium;
      
      if (isPremiumFromPrefs) {
        _subscriptionInfo = SubscriptionInfo(
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.active,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 335)),
          autoRenew: true,
        );
      } else {
        _subscriptionInfo = const SubscriptionInfo(
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.inactive,
        );
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load subscription info: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> purchasePremium() async {
    _setLoading(true);
    try {
      // TODO: Implement actual purchase logic with app store
      // For now, simulate a purchase
      await Future.delayed(const Duration(seconds: 2));
      
      _subscriptionInfo = SubscriptionInfo(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        autoRenew: true,
      );

      // Update user preferences
      await _userPreferencesProvider.setPremiumStatus(true);
      
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to purchase premium: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelSubscription() async {
    _setLoading(true);
    try {
      // TODO: Implement actual cancellation logic with app store
      await Future.delayed(const Duration(seconds: 1));
      
      _subscriptionInfo = _subscriptionInfo.copyWith(
        status: SubscriptionStatus.cancelled,
        autoRenew: false,
      );
      
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to cancel subscription: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restorePurchases() async {
    _setLoading(true);
    try {
      // TODO: Implement actual restore logic with app store
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate finding an existing purchase
      final hasExistingPurchase = DateTime.now().millisecond % 2 == 0;
      
      if (hasExistingPurchase) {
        _subscriptionInfo = SubscriptionInfo(
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.active,
          startDate: DateTime.now().subtract(const Duration(days: 100)),
          endDate: DateTime.now().add(const Duration(days: 265)),
          autoRenew: true,
        );
        
        await _userPreferencesProvider.setPremiumStatus(true);
        
        notifyListeners();
      } else {
        throw Exception('No previous purchases found');
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to restore purchases: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkSubscriptionStatus() async {
    _setLoading(true);
    try {
      // TODO: Implement actual status check with backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if subscription has expired
      if (_subscriptionInfo.endDate != null &&
          _subscriptionInfo.endDate!.isBefore(DateTime.now()) &&
          _subscriptionInfo.status == SubscriptionStatus.active) {
        
        _subscriptionInfo = _subscriptionInfo.copyWith(
          status: SubscriptionStatus.expired,
        );
        
        await _userPreferencesProvider.setPremiumStatus(false);
        notifyListeners();
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to check subscription status: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool canUsePremiumFeature(String featureName) {
    if (isPremium) return true;
    
    // Show upgrade prompt for premium features
    _setError('This feature requires WishGO Premium. Upgrade to unlock!');
    return false;
  }

  List<String> getPremiumFeatures() {
    return [
      'Unlimited wish items (vs 50 for free)',
      'Unlimited collections (vs 3 for free)',
      'Price tracking and alerts',
      'Advanced analytics and insights',
      'Desire levels (1-5 hearts)',
      'Data export and backup',
      'Custom themes and appearance',
      'Cloud sync across devices',
      'Ad-free experience',
      'Priority customer support',
    ];
  }

  Map<String, String> getSubscriptionPlans() {
    return {
      'Monthly': '\$4.99/month',
      'Yearly': '\$39.99/year (Save 33%)',
      'Lifetime': '\$79.99 (One-time payment)',
    };
  }

  String getFeatureUsageStatus(String feature) {
    switch (feature) {
      case 'wishItems':
        // TODO: Get actual count from wish item provider
        return isPremium ? 'Unlimited' : '0 / $maxWishItems';
      case 'collections':
        // TODO: Get actual count from collection provider
        return isPremium ? 'Unlimited' : '0 / $maxCollections';
      case 'priceTracking':
        return isPremium ? 'Available' : 'Premium only';
      case 'analytics':
        return isPremium ? 'Available' : 'Basic only';
      default:
        return isPremium ? 'Available' : 'Premium only';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  Future<void> refreshSubscriptionInfo() async {
    await _loadSubscriptionInfo();
  }
}