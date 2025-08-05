import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

@JsonSerializable()
class UserPreferences {
  final String id;
  final bool isPremium;
  final SubscriptionType? subscriptionType;
  final DateTime? subscriptionExpiry;
  final ThemeMode themeMode;
  final String currency;
  final bool priceAlerts;
  final bool pushNotifications;
  final ViewMode defaultViewMode;
  final String? firebaseUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferences({
    required this.id,
    this.isPremium = false,
    this.subscriptionType,
    this.subscriptionExpiry,
    this.themeMode = ThemeMode.system,
    this.currency = 'HKD',
    this.priceAlerts = false,
    this.pushNotifications = true,
    this.defaultViewMode = ViewMode.grid,
    this.firebaseUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  factory UserPreferences.defaultPreferences() {
    final now = DateTime.now();
    return UserPreferences(
      id: 'default',
      createdAt: now,
      updatedAt: now,
    );
  }

  UserPreferences copyWith({
    String? id,
    bool? isPremium,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiry,
    ThemeMode? themeMode,
    String? currency,
    bool? priceAlerts,
    bool? pushNotifications,
    ViewMode? defaultViewMode,
    String? firebaseUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      isPremium: isPremium ?? this.isPremium,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      firebaseUserId: firebaseUserId ?? this.firebaseUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasActiveSubscription {
    if (!isPremium || subscriptionExpiry == null) return false;
    return DateTime.now().isBefore(subscriptionExpiry!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum SubscriptionType {
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('lifetime')
  lifetime,
}

enum ThemeMode {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system,
}

enum ViewMode {
  @JsonValue('grid')
  grid,
  @JsonValue('list')
  list,
}