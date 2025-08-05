import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors (WishGO brand colors)
  static const Color primary = Color(0xFF6B73FF); // Modern purple-blue
  static const Color primaryDark = Color(0xFF5A62E8); // Darker variant for dark theme
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D); // Pink accent
  static const Color secondaryDark = Color(0xFFE8577A); // Darker pink for dark theme
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);

  // Surface Colors (Light Theme)
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color onLightBackground = Color(0xFF212121);
  static const Color onLightSurface = Color(0xFF212121);

  // Surface Colors (Dark Theme)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color onDarkBackground = Color(0xFFE0E0E0);
  static const Color onDarkSurface = Color(0xFFE0E0E0);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Border Colors
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF45A049);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE68900);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFE53E3E);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Shopping-specific Colors
  static const Color price = Color(0xFF4CAF50); // Green for prices
  static const Color discount = Color(0xFFFF5722); // Orange-red for discounts
  static const Color outOfStock = Color(0xFF9E9E9E); // Gray for out of stock

  // Wish Item Status Colors
  static const Color toBuyStatus = Color(0xFF2196F3); // Blue
  static const Color purchasedStatus = Color(0xFF4CAF50); // Green
  static const Color droppedStatus = Color(0xFF9E9E9E); // Gray

  // Premium Feature Colors
  static const Color premium = Color(0xFFFFD700); // Gold
  static const Color premiumDark = Color(0xFFE6C200);
  static const Color onPremium = Color(0xFF000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6B73FF),
    Color(0xFF9B59B6),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFF8A80),
  ];

  static const List<Color> premiumGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFE135),
  ];

  // Card Shadow Colors
  static const Color lightShadow = Color(0x1A000000);
  static const Color darkShadow = Color(0x3A000000);

  // Overlay Colors
  static const Color lightOverlay = Color(0x80000000);
  static const Color darkOverlay = Color(0x80FFFFFF);

  // Social Media Brand Colors (for URL source identification)
  static const Color amazon = Color(0xFFFF9900);
  static const Color ebay = Color(0xFF0064D2);
  static const Color etsy = Color(0xFFE47911);
  static const Color alibaba = Color(0xFFFF6600);
  static const Color shopee = Color(0xFF16537E);
  static const Color taobao = Color(0xFFFF5000);

  // Chart Colors (for analytics)
  static const List<Color> chartColors = [
    Color(0xFF6B73FF),
    Color(0xFFFF6B9D),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF795548),
  ];

  // Utility Functions
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'to_buy':
        return toBuyStatus;
      case 'purchased':
        return purchasedStatus;
      case 'dropped':
        return droppedStatus;
      default:
        return toBuyStatus;
    }
  }

  static Color getSourceColor(String? source) {
    if (source == null) return primary;
    
    final sourceLower = source.toLowerCase();
    if (sourceLower.contains('amazon')) return amazon;
    if (sourceLower.contains('ebay')) return ebay;
    if (sourceLower.contains('etsy')) return etsy;
    if (sourceLower.contains('alibaba') || sourceLower.contains('aliexpress')) return alibaba;
    if (sourceLower.contains('shopee')) return shopee;
    if (sourceLower.contains('taobao') || sourceLower.contains('tmall')) return taobao;
    
    return primary;
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
}