import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/wish_item.dart';
import '../../models/collection.dart';
import '../../models/order.dart';
import '../../models/tag.dart';
import '../../models/user_preferences.dart';

class DatabaseHelper {
  static const _databaseName = 'wishgo_list.db';
  static const _databaseVersion = 1;

  // Table names
  static const String tableWishItems = 'wish_items';
  static const String tableCollections = 'collections';
  static const String tableOrders = 'orders';
  static const String tableTags = 'tags';
  static const String tableUserPreferences = 'user_preferences';
  static const String tableWishItemTags = 'wish_item_tags';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create collections table
    await db.execute('''
      CREATE TABLE $tableCollections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_name TEXT,
        color INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        item_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create wish_items table
    await db.execute('''
      CREATE TABLE $tableWishItems (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL,
        currency TEXT DEFAULT 'HKD',
        image_url TEXT,
        product_url TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'to_buy',
        desire_level INTEGER,
        collection_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        source_store TEXT,
        FOREIGN KEY (collection_id) REFERENCES $tableCollections (id) ON DELETE CASCADE
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE $tableOrders (
        id TEXT PRIMARY KEY,
        wish_item_id TEXT NOT NULL,
        order_number TEXT,
        tracking_number TEXT,
        carrier TEXT,
        total_amount REAL,
        currency TEXT DEFAULT 'HKD',
        status TEXT NOT NULL DEFAULT 'pending',
        order_date TEXT,
        estimated_delivery TEXT,
        actual_delivery TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (wish_item_id) REFERENCES $tableWishItems (id) ON DELETE CASCADE
      )
    ''');

    // Create tags table
    await db.execute('''
      CREATE TABLE $tableTags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        usage_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create wish_item_tags junction table
    await db.execute('''
      CREATE TABLE $tableWishItemTags (
        wish_item_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (wish_item_id, tag_id),
        FOREIGN KEY (wish_item_id) REFERENCES $tableWishItems (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES $tableTags (id) ON DELETE CASCADE
      )
    ''');

    // Create user_preferences table
    await db.execute('''
      CREATE TABLE $tableUserPreferences (
        id TEXT PRIMARY KEY,
        is_premium INTEGER NOT NULL DEFAULT 0,
        subscription_type TEXT,
        subscription_expiry TEXT,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        currency TEXT NOT NULL DEFAULT 'HKD',
        price_alerts INTEGER NOT NULL DEFAULT 0,
        push_notifications INTEGER NOT NULL DEFAULT 1,
        default_view_mode TEXT NOT NULL DEFAULT 'grid',
        firebase_user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_wish_items_collection_id ON $tableWishItems (collection_id)');
    await db.execute('CREATE INDEX idx_wish_items_status ON $tableWishItems (status)');
    await db.execute('CREATE INDEX idx_orders_wish_item_id ON $tableOrders (wish_item_id)');
    await db.execute('CREATE INDEX idx_wish_item_tags_wish_item_id ON $tableWishItemTags (wish_item_id)');
    await db.execute('CREATE INDEX idx_wish_item_tags_tag_id ON $tableWishItemTags (tag_id)');

    // Insert default collection
    final defaultCollection = Collection.defaultCollection();
    await db.insert(tableCollections, _collectionToMap(defaultCollection));

    // Insert default user preferences
    final defaultPreferences = UserPreferences.defaultPreferences();
    await db.insert(tableUserPreferences, _userPreferencesToMap(defaultPreferences));
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic for future versions
    }
  }

  // Helper methods to convert models to/from maps
  Map<String, dynamic> _wishItemToMap(WishItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'currency': item.currency,
      'image_url': item.imageUrl,
      'product_url': item.productUrl,
      'notes': item.notes,
      'status': item.status.value,
      'desire_level': item.desireLevel,
      'collection_id': item.collectionId,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
      'source_store': item.sourceStore,
    };
  }

  WishItem _wishItemFromMap(Map<String, dynamic> map) {
    return WishItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price']?.toDouble(),
      currency: map['currency'] ?? 'HKD',
      imageUrl: map['image_url'],
      productUrl: map['product_url'],
      notes: map['notes'],
      status: _parseWishItemStatus(map['status']),
      desireLevel: map['desire_level'],
      tags: [], // Tags will be loaded separately
      collectionId: map['collection_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      sourceStore: map['source_store'],
    );
  }

  Map<String, dynamic> _collectionToMap(Collection collection) {
    return {
      'id': collection.id,
      'name': collection.name,
      'description': collection.description,
      'icon_name': collection.iconName,
      'color': collection.color,
      'created_at': collection.createdAt.toIso8601String(),
      'updated_at': collection.updatedAt.toIso8601String(),
      'is_default': collection.isDefault ? 1 : 0,
      'item_count': collection.itemCount,
    };
  }

  Collection _collectionFromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconName: map['icon_name'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isDefault: map['is_default'] == 1,
      itemCount: map['item_count'] ?? 0,
    );
  }

  Map<String, dynamic> _orderToMap(Order order) {
    return {
      'id': order.id,
      'wish_item_id': order.wishItemId,
      'order_number': order.orderNumber,
      'tracking_number': order.trackingNumber,
      'carrier': order.carrier,
      'total_amount': order.totalAmount,
      'currency': order.currency,
      'status': order.status.value,
      'order_date': order.orderDate?.toIso8601String(),
      'estimated_delivery': order.estimatedDelivery?.toIso8601String(),
      'actual_delivery': order.actualDelivery?.toIso8601String(),
      'notes': order.notes,
      'created_at': order.createdAt.toIso8601String(),
      'updated_at': order.updatedAt.toIso8601String(),
    };
  }

  Order _orderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      wishItemId: map['wish_item_id'],
      orderNumber: map['order_number'],
      trackingNumber: map['tracking_number'],
      carrier: map['carrier'],
      totalAmount: map['total_amount']?.toDouble(),
      currency: map['currency'] ?? 'HKD',
      status: _parseOrderStatus(map['status']),
      orderDate: map['order_date'] != null ? DateTime.parse(map['order_date']) : null,
      estimatedDelivery: map['estimated_delivery'] != null ? DateTime.parse(map['estimated_delivery']) : null,
      actualDelivery: map['actual_delivery'] != null ? DateTime.parse(map['actual_delivery']) : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> _tagToMap(Tag tag) {
    return {
      'id': tag.id,
      'name': tag.name,
      'color': tag.color,
      'created_at': tag.createdAt.toIso8601String(),
      'updated_at': tag.updatedAt.toIso8601String(),
      'usage_count': tag.usageCount,
    };
  }

  Tag _tagFromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      usageCount: map['usage_count'] ?? 0,
    );
  }

  Map<String, dynamic> _userPreferencesToMap(UserPreferences preferences) {
    return {
      'id': preferences.id,
      'is_premium': preferences.isPremium ? 1 : 0,
      'subscription_type': preferences.subscriptionType?.name,
      'subscription_expiry': preferences.subscriptionExpiry?.toIso8601String(),
      'theme_mode': preferences.themeMode.name,
      'currency': preferences.currency,
      'price_alerts': preferences.priceAlerts ? 1 : 0,
      'push_notifications': preferences.pushNotifications ? 1 : 0,
      'default_view_mode': preferences.defaultViewMode.name,
      'firebase_user_id': preferences.firebaseUserId,
      'created_at': preferences.createdAt.toIso8601String(),
      'updated_at': preferences.updatedAt.toIso8601String(),
    };
  }

  UserPreferences _userPreferencesFromMap(Map<String, dynamic> map) {
    return UserPreferences(
      id: map['id'],
      isPremium: map['is_premium'] == 1,
      subscriptionType: map['subscription_type'] != null 
          ? SubscriptionType.values.firstWhere((e) => e.name == map['subscription_type'])
          : null,
      subscriptionExpiry: map['subscription_expiry'] != null 
          ? DateTime.parse(map['subscription_expiry']) 
          : null,
      themeMode: ThemeMode.values.firstWhere((e) => e.name == map['theme_mode']),
      currency: map['currency'] ?? 'HKD',
      priceAlerts: map['price_alerts'] == 1,
      pushNotifications: map['push_notifications'] == 1,
      defaultViewMode: ViewMode.values.firstWhere((e) => e.name == map['default_view_mode']),
      firebaseUserId: map['firebase_user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  WishItemStatus _parseWishItemStatus(String status) {
    return WishItemStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => WishItemStatus.toBuy,
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatus.pending,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}