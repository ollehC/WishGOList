import 'package:flutter/foundation.dart';
import '../models/wish_item.dart';
import '../services/database_service.dart';
import '../services/opengraph_service.dart';
import 'user_preferences_provider.dart';

class WishItemProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final OpenGraphService _openGraphService;
  final UserPreferencesProvider _userPreferencesProvider;

  WishItemProvider(
    this._databaseService,
    this._openGraphService,
    this._userPreferencesProvider,
  );

  List<WishItem> _wishItems = [];
  bool _isLoading = false;
  String? _error;
  WishItemFilter _filter = WishItemFilter();
  String _searchQuery = '';

  // Getters
  List<WishItem> get wishItems => _filteredWishItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WishItemFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<WishItem> get _filteredWishItems {
    var items = List<WishItem>.from(_wishItems);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    // Apply status filter
    if (_filter.status != null) {
      items = items.where((item) => item.status == _filter.status).toList();
    }

    // Apply collection filter
    if (_filter.collectionId != null) {
      items = items.where((item) => item.collectionId == _filter.collectionId).toList();
    }

    // Apply tag filter
    if (_filter.tags.isNotEmpty) {
      items = items.where((item) =>
          _filter.tags.every((tag) => item.tags.contains(tag))).toList();
    }

    // Apply price range filter
    if (_filter.minPrice != null) {
      items = items.where((item) => item.price != null && item.price! >= _filter.minPrice!).toList();
    }
    if (_filter.maxPrice != null) {
      items = items.where((item) => item.price != null && item.price! <= _filter.maxPrice!).toList();
    }

    // Apply sorting
    switch (_filter.sortBy) {
      case WishItemSortBy.dateCreated:
        items.sort((a, b) => _filter.sortAscending 
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case WishItemSortBy.dateUpdated:
        items.sort((a, b) => _filter.sortAscending 
            ? a.updatedAt.compareTo(b.updatedAt)
            : b.updatedAt.compareTo(a.updatedAt));
        break;
      case WishItemSortBy.title:
        items.sort((a, b) => _filter.sortAscending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case WishItemSortBy.price:
        items.sort((a, b) {
          final priceA = a.price ?? 0;
          final priceB = b.price ?? 0;
          return _filter.sortAscending 
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        });
        break;
      case WishItemSortBy.desireLevel:
        items.sort((a, b) {
          final levelA = a.desireLevel ?? 0;
          final levelB = b.desireLevel ?? 0;
          return _filter.sortAscending 
              ? levelA.compareTo(levelB)
              : levelB.compareTo(levelA);
        });
        break;
    }

    return items;
  }

  Future<void> loadWishItems({String? collectionId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _wishItems = await _databaseService.getAllWishItems(collectionId: collectionId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading wish items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WishItem?> createWishItemFromUrl(String url, {String? collectionId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Extract metadata from URL
      final metadata = await _openGraphService.extractMetadata(url);
      
      // Create wish item with extracted data
      final wishItem = WishItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: metadata.title ?? 'Untitled Item',
        description: metadata.description,
        imageUrl: metadata.imageUrl,
        productUrl: url,
        collectionId: collectionId ?? 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sourceStore: metadata.siteName,
      );

      final createdItem = await _databaseService.insertWishItem(wishItem);
      _wishItems.add(createdItem);
      
      return createdItem;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating wish item from URL: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WishItem?> createWishItem(WishItem wishItem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final createdItem = await _databaseService.insertWishItem(wishItem);
      _wishItems.add(createdItem);
      
      return createdItem;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating wish item: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWishItem(WishItem wishItem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedItem = await _databaseService.updateWishItem(wishItem);
      final index = _wishItems.indexWhere((item) => item.id == wishItem.id);
      
      if (index != -1) {
        _wishItems[index] = updatedItem;
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating wish item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWishItem(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.deleteWishItem(id);
      _wishItems.removeWhere((item) => item.id == id);
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting wish item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(WishItemFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Premium feature checks
  bool canAddMoreTags(int currentTagCount) {
    if (_userPreferencesProvider.isPremium) return true;
    return currentTagCount < 5;
  }

  bool canSetDesireLevel() {
    return _userPreferencesProvider.isPremium;
  }

  bool canCreateMoreCollections(int currentCollectionCount) {
    if (_userPreferencesProvider.isPremium) return true;
    return currentCollectionCount == 0; // Free tier gets 1 collection
  }
}

class WishItemFilter {
  final WishItemStatus? status;
  final String? collectionId;
  final List<String> tags;
  final double? minPrice;
  final double? maxPrice;
  final WishItemSortBy sortBy;
  final bool sortAscending;

  WishItemFilter({
    this.status,
    this.collectionId,
    this.tags = const [],
    this.minPrice,
    this.maxPrice,
    this.sortBy = WishItemSortBy.dateCreated,
    this.sortAscending = false,
  });

  WishItemFilter copyWith({
    WishItemStatus? status,
    String? collectionId,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    WishItemSortBy? sortBy,
    bool? sortAscending,
  }) {
    return WishItemFilter(
      status: status ?? this.status,
      collectionId: collectionId ?? this.collectionId,
      tags: tags ?? this.tags,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

enum WishItemSortBy {
  dateCreated,
  dateUpdated,
  title,
  price,
  desireLevel,
}