import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_theme.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/item_detail_screen.dart';
import '../screens/add_item_screen.dart';
import '../screens/list_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/collections_screen.dart';
import '../screens/order_tracking_screen.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';

class WishGoApp extends StatelessWidget {
  const WishGoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        return MaterialApp(
          title: 'WishGO List',
          debugShowCheckedModeBanner: false,
          
          // Theme Configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getThemeMode(userPrefs.themeMode.name),
          
          // Routing
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.generateRoute,
          
          // Locale Configuration
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'HK'),
            Locale('zh', 'CN'),
            Locale('ja', 'JP'),
          ],
          
          // Builder for global configurations
          builder: (context, child) {
            return MediaQuery(
              // Ensure text doesn't scale beyond reasonable limits
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}