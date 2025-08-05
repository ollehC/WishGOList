import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../models/wish_item.dart';
import '../../models/collection.dart';
import '../../models/order.dart';
import '../../models/tag.dart';
import '../../models/user_preferences.dart';

class DatabaseService {
  late final DatabaseHelper _dbHelper;

  Future<void> initialize() async {
    _dbHelper = DatabaseHelper.instance;
  }

  // WishItem CRUD operations
  Future<WishItem> insertWishItem(WishItem wishItem) async {
    final db = await _dbHelper.database;
    final id = await db.insert(DatabaseHelper.tableWishItems, _wishItemToMap(wishItem));
    
    // Insert tags
    await _insertWishItemTags(wishItem.id, wishItem.tags);
    
    // Update collection item count
    await _updateCollectionItemCount(wishItem.collectionId);
    
    return wishItem;
  }

  Future<WishItem> updateWishItem(WishItem wishItem) async {
    final db = await _dbHelper.database;
    final updatedItem = wishItem.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      DatabaseHelper.tableWishItems,
      _wishItemToMap(updatedItem),
      where: 'id = ?',
      whereArgs: [wishItem.id],
    );

    // Update tags
    await _deleteWishItemTags(wishItem.id);
    await _insertWishItemTags(wishItem.id, wishItem.tags);

    return updatedItem;
  }

  Future<void> deleteWishItem(String id) async {
    final db = await _dbHelper.database;
    
    // Get the item to find its collection
    final items = await db.query(
      DatabaseHelper.tableWishItems,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (items.isNotEmpty) {
      final collectionId = items.first['collection_id'] as String;
      
      // Delete the item (tags will be deleted via cascade)
      await db.delete(
        DatabaseHelper.tableWishItems,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Update collection item count
      await _updateCollectionItemCount(collectionId);
    }
  }

  Future<WishItem?> getWishItem(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableWishItems,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final wishItem = _wishItemFromMap(maps.first);
    final tags = await _getWishItemTags(id);
    
    return wishItem.copyWith(tags: tags);
  }

  Future<List<WishItem>> getAllWishItems({String? collectionId}) async {
    final db = await _dbHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (collectionId != null) {
      whereClause = 'collection_id = ?';
      whereArgs = [collectionId];
    }
    
    final maps = await db.query(
      DatabaseHelper.tableWishItems,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
    );

    final wishItems = <WishItem>[];
    for (final map in maps) {
      final wishItem = _wishItemFromMap(map);
      final tags = await _getWishItemTags(wishItem.id);
      wishItems.add(wishItem.copyWith(tags: tags));
    }

    return wishItems;
  }

  // Collection CRUD operations
  Future<Collection> createCollection(Collection collection) async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.tableCollections, _collectionToMap(collection));
    return collection;
  }

  Future<Collection> insertCollection(Collection collection) async {
    return await createCollection(collection);
  }

  Future<Collection> updateCollection(Collection collection) async {
    final db = await _dbHelper.database;
    final updatedCollection = collection.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      DatabaseHelper.tableCollections,
      _collectionToMap(updatedCollection),
      where: 'id = ?',
      whereArgs: [collection.id],
    );

    return updatedCollection;
  }

  Future<void> deleteCollection(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableCollections,
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  Future<List<Collection>> getAllCollections() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableCollections,
      orderBy: 'is_default DESC, created_at ASC',
    );

    return maps.map((map) => _collectionFromMap(map)).toList();
  }

  // Order CRUD operations
  Future<Order> createOrder(Order order) async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.tableOrders, _orderToMap(order));
    return order;
  }

  Future<Order> insertOrder(Order order) async {
    return await createOrder(order);
  }

  Future<Order> updateOrder(Order order) async {
    final db = await _dbHelper.database;
    final updatedOrder = order.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      DatabaseHelper.tableOrders,
      _orderToMap(updatedOrder),
      where: 'id = ?',
      whereArgs: [order.id],
    );

    return updatedOrder;
  }

  Future<void> deleteOrder(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Order>> getOrdersForWishItem(String wishItemId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableOrders,
      where: 'wish_item_id = ?',
      whereArgs: [wishItemId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _orderFromMap(map)).toList();
  }

  Future<List<Order>> getAllOrders() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableOrders,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _orderFromMap(map)).toList();
  }

  // Tag CRUD operations
  Future<Tag> createTag(Tag tag) async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.tableTags, _tagToMap(tag));
    return tag;
  }

  Future<Tag> insertTag(Tag tag) async {
    return await createTag(tag);
  }

  Future<Tag> updateTag(Tag tag) async {
    final db = await _dbHelper.database;
    final updatedTag = tag.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      DatabaseHelper.tableTags,
      _tagToMap(updatedTag),
      where: 'id = ?',
      whereArgs: [tag.id],
    );

    return updatedTag;
  }

  Future<void> deleteTag(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableTags,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Tag>> getAllTags() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTags,
      orderBy: 'usage_count DESC, name ASC',
    );

    return maps.map((map) => _tagFromMap(map)).toList();
  }

  Future<List<String>> getPopularTagNames({int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTags,
      columns: ['name'],
      orderBy: 'usage_count DESC',
      limit: limit,
    );

    return maps.map((map) => map['name'] as String).toList();
  }

  // UserPreferences CRUD operations
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences) async {
    final db = await _dbHelper.database;
    final updatedPreferences = preferences.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      DatabaseHelper.tableUserPreferences,
      _userPreferencesToMap(updatedPreferences),
      where: 'id = ?',
      whereArgs: [preferences.id],
    );

    return updatedPreferences;
  }

  Future<UserPreferences> saveUserPreferences(UserPreferences preferences) async {
    return await updateUserPreferences(preferences);
  }

  Future<UserPreferences?> getUserPreferences() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DatabaseHelper.tableUserPreferences);

    if (maps.isEmpty) return null;
    return _userPreferencesFromMap(maps.first);
  }

  // Helper methods
  Future<void> _insertWishItemTags(String wishItemId, List<String> tagNames) async {
    final db = await _dbHelper.database;
    
    for (final tagName in tagNames) {
      // Get or create tag
      var tag = await _getOrCreateTag(tagName);
      
      // Insert relationship
      await db.insert(
        DatabaseHelper.tableWishItemTags,
        {
          'wish_item_id': wishItemId,
          'tag_id': tag.id,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      
      // Update tag usage count
      tag = tag.copyWith(usageCount: tag.usageCount + 1);
      await updateTag(tag);
    }
  }

  Future<void> _deleteWishItemTags(String wishItemId) async {
    final db = await _dbHelper.database;
    
    // Get current tags to decrease usage count
    final currentTags = await _getWishItemTags(wishItemId);
    
    // Delete relationships
    await db.delete(
      DatabaseHelper.tableWishItemTags,
      where: 'wish_item_id = ?',
      whereArgs: [wishItemId],
    );
    
    // Decrease usage count for tags
    for (final tagName in currentTags) {
      final tags = await db.query(
        DatabaseHelper.tableTags,
        where: 'name = ?',
        whereArgs: [tagName],
      );
      
      if (tags.isNotEmpty) {
        final tag = _tagFromMap(tags.first);
        final updatedTag = tag.copyWith(usageCount: (tag.usageCount - 1).clamp(0, double.infinity).toInt());
        await updateTag(updatedTag);
      }
    }
  }

  Future<List<String>> _getWishItemTags(String wishItemId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.name
      FROM ${DatabaseHelper.tableTags} t
      INNER JOIN ${DatabaseHelper.tableWishItemTags} wit ON t.id = wit.tag_id
      WHERE wit.wish_item_id = ?
    ''', [wishItemId]);

    return maps.map((map) => map['name'] as String).toList();
  }

  Future<Tag> _getOrCreateTag(String tagName) async {
    final db = await _dbHelper.database;
    
    // Try to find existing tag
    final maps = await db.query(
      DatabaseHelper.tableTags,
      where: 'name = ?',
      whereArgs: [tagName],
    );

    if (maps.isNotEmpty) {
      return _tagFromMap(maps.first);
    }

    // Create new tag
    final tag = Tag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: tagName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await insertTag(tag);
  }

  Future<void> _updateCollectionItemCount(String collectionId) async {
    final db = await _dbHelper.database;
    
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DatabaseHelper.tableWishItems}
      WHERE collection_id = ?
    ''', [collectionId]);

    final count = countResult.first['count'] as int;
    
    await db.update(
      DatabaseHelper.tableCollections,
      {'item_count': count, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [collectionId],
    );
  }

  // Conversion methods (referencing DatabaseHelper's private methods)
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
}