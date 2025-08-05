import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/opengraph_service.dart';
import 'wish_item_provider.dart';
import 'collection_provider.dart';
import 'order_provider.dart';
import 'tag_provider.dart';
import 'user_preferences_provider.dart';
import 'subscription_provider.dart';

class AppProviders {
  static late DatabaseService _databaseService;
  static late StorageService _storageService;
  static late ApiService _apiService;
  static late OpenGraphService _openGraphService;

  static Future<void> initialize() async {
    // Initialize core services
    _databaseService = DatabaseService();
    await _databaseService.initialize();
    
    _storageService = StorageService();
    await _storageService.initialize();
    
    _apiService = ApiService();
    _openGraphService = OpenGraphService(_apiService);
  }

  static List<SingleChildWidget> get providers => [
    // Core Services
    Provider<DatabaseService>.value(value: _databaseService),
    Provider<StorageService>.value(value: _storageService),
    Provider<ApiService>.value(value: _apiService),
    Provider<OpenGraphService>.value(value: _openGraphService),

    // State Providers
    ChangeNotifierProvider<UserPreferencesProvider>(
      create: (context) => UserPreferencesProvider(
        context.read<DatabaseService>(),
        context.read<StorageService>(),
      ),
    ),
    
    ChangeNotifierProvider<SubscriptionProvider>(
      create: (context) => SubscriptionProvider(
        context.read<UserPreferencesProvider>(),
      ),
    ),
    
    ChangeNotifierProvider<CollectionProvider>(
      create: (context) => CollectionProvider(
        context.read<DatabaseService>(),
      ),
    ),
    
    ChangeNotifierProvider<TagProvider>(
      create: (context) => TagProvider(
        context.read<DatabaseService>(),
      ),
    ),
    
    ChangeNotifierProvider<WishItemProvider>(
      create: (context) => WishItemProvider(
        context.read<DatabaseService>(),
        context.read<OpenGraphService>(),
        context.read<UserPreferencesProvider>(),
      ),
    ),
    
    ChangeNotifierProvider<OrderProvider>(
      create: (context) => OrderProvider(
        context.read<DatabaseService>(),
        context.read<UserPreferencesProvider>(),
      ),
    ),
  ];
}