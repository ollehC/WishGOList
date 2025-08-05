import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/item_detail_screen.dart';
import '../../screens/add_item_screen.dart';
import '../../screens/list_screen.dart';
import '../../screens/stats_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/collections_screen.dart';
import '../../screens/order_tracking_screen.dart';
import '../../screens/edit_item_screen.dart';
import '../../screens/subscription_screen.dart';
import '../../models/wish_item.dart';
import '../../models/collection.dart';
import '../../models/order.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String main = '/main';
  static const String itemDetail = '/item-detail';
  static const String addItem = '/add-item';
  static const String editItem = '/edit-item';
  static const String list = '/list';
  static const String collections = '/collections';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String orderTracking = '/order-tracking';
  static const String subscription = '/subscription';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case main:
        return _buildRoute(const MainNavigationScreen(), settings);

      case home:
        return _buildRoute(const HomeScreen(), settings);

      case itemDetail:
        final args = settings.arguments as ItemDetailArguments?;
        if (args == null) {
          return _buildErrorRoute(settings, 'Item ID is required');
        }
        return _buildRoute(
          ItemDetailScreen(
            itemId: args.itemId,
            item: args.item,
          ),
          settings,
        );

      case addItem:
        final args = settings.arguments as AddItemArguments?;
        return _buildRoute(
          AddItemScreen(
            initialUrl: args?.initialUrl,
            collectionId: args?.collectionId,
          ),
          settings,
        );

      case editItem:
        final args = settings.arguments as EditItemArguments?;
        if (args?.item == null) {
          return _buildErrorRoute(settings, 'Item is required');
        }
        return _buildRoute(
          EditItemScreen(item: args!.item),
          settings,
        );

      case list:
        final args = settings.arguments as ListArguments?;
        return _buildRoute(
          ListScreen(
            collectionId: args?.collectionId,
            status: args?.status,
          ),
          settings,
        );

      case collections:
        return _buildRoute(const CollectionsScreen(), settings);

      case stats:
        return _buildRoute(const StatsScreen(), settings);

      case settings:
        return _buildRoute(const SettingsScreen(), settings);

      case orderTracking:
        final args = settings.arguments as OrderTrackingArguments?;
        return _buildRoute(
          OrderTrackingScreen(
            itemId: args?.itemId,
            order: args?.order,
          ),
          settings,
        );

      case subscription:
        return _buildRoute(const SubscriptionScreen(), settings);

      default:
        return _buildErrorRoute(settings, 'Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Custom slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _buildErrorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Route Arguments Classes
class ItemDetailArguments {
  final String itemId;
  final WishItem? item;

  const ItemDetailArguments({
    required this.itemId,
    this.item,
  });
}

class AddItemArguments {
  final String? initialUrl;
  final String? collectionId;

  const AddItemArguments({
    this.initialUrl,
    this.collectionId,
  });
}

class EditItemArguments {
  final WishItem item;

  const EditItemArguments({required this.item});
}

class ListArguments {
  final String? collectionId;
  final WishItemStatus? status;

  const ListArguments({
    this.collectionId,
    this.status,
  });
}

class OrderTrackingArguments {
  final String? itemId;
  final Order? order;

  const OrderTrackingArguments({
    this.itemId,
    this.order,
  });
}

// Navigation Helper Methods
extension AppRouterNavigation on BuildContext {
  // Navigation shortcuts
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  bool canPop() {
    return Navigator.of(this).canPop();
  }

  // Specific navigation methods
  Future<void> goToHome() {
    return pushNamedAndRemoveUntil(AppRouter.main, (route) => false);
  }

  Future<void> goToItemDetail(String itemId, {WishItem? item}) {
    return pushNamed(
      AppRouter.itemDetail,
      arguments: ItemDetailArguments(itemId: itemId, item: item),
    );
  }

  Future<void> goToAddItem({String? initialUrl, String? collectionId}) {
    return pushNamed(
      AppRouter.addItem,
      arguments: AddItemArguments(
        initialUrl: initialUrl,
        collectionId: collectionId,
      ),
    );
  }

  Future<void> goToEditItem(WishItem item) {
    return pushNamed(
      AppRouter.editItem,
      arguments: EditItemArguments(item: item),
    );
  }

  Future<void> goToList({String? collectionId, WishItemStatus? status}) {
    return pushNamed(
      AppRouter.list,
      arguments: ListArguments(collectionId: collectionId, status: status),
    );
  }

  Future<void> goToOrderTracking({String? itemId, Order? order}) {
    return pushNamed(
      AppRouter.orderTracking,
      arguments: OrderTrackingArguments(itemId: itemId, order: order),
    );
  }

  Future<void> goToSubscription() {
    return pushNamed(AppRouter.subscription);
  }
}