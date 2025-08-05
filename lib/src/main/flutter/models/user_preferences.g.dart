// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

import '../utils/json_utils.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      id: json['id'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionType: $enumDecodeNullable(
          _$SubscriptionTypeEnumMap, json['subscriptionType']),
      subscriptionExpiry: json['subscriptionExpiry'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiry'] as String),
      themeMode: $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
          AppThemeMode.system,
      currency: json['currency'] as String? ?? 'HKD',
      priceAlerts: json['priceAlerts'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      defaultViewMode:
          $enumDecodeNullable(_$ViewModeEnumMap, json['defaultViewMode']) ??
              ViewMode.grid,
      firebaseUserId: json['firebaseUserId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isPremium': instance.isPremium,
      'subscriptionType': _$SubscriptionTypeEnumMap[instance.subscriptionType],
      'subscriptionExpiry': instance.subscriptionExpiry?.toIso8601String(),
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'currency': instance.currency,
      'priceAlerts': instance.priceAlerts,
      'pushNotifications': instance.pushNotifications,
      'defaultViewMode': _$ViewModeEnumMap[instance.defaultViewMode]!,
      'firebaseUserId': instance.firebaseUserId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubscriptionTypeEnumMap = {
  SubscriptionType.monthly: 'monthly',
  SubscriptionType.yearly: 'yearly',
  SubscriptionType.lifetime: 'lifetime',
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};

const _$ViewModeEnumMap = {
  ViewMode.grid: 'grid',
  ViewMode.list: 'list',
};