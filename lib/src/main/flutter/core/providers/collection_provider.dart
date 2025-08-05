import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../../models/collection.dart';

class CollectionProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  List<Collection> _collections = [];
  Collection? _selectedCollection;
  bool _isLoading = false;
  String? _error;

  CollectionProvider(this._databaseService) {
    _loadCollections();
  }

  // Getters
  List<Collection> get collections => _collections;
  Collection? get selectedCollection => _selectedCollection;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get default collection
  Collection get defaultCollection {
    final defaultCol = _collections.where((c) => c.isDefault).firstOrNull;
    return defaultCol ?? _createDefaultCollection();
  }

  Future<void> _loadCollections() async {
    _setLoading(true);
    try {
      _collections = await _databaseService.getAllCollections();
      
      // Ensure we have a default collection
      if (_collections.isEmpty || !_collections.any((c) => c.isDefault)) {
        await _createAndAddDefaultCollection();
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load collections: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createCollection(Collection collection) async {
    try {
      final createdCollection = await _databaseService.createCollection(collection);
      _collections.add(createdCollection);
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to create collection: $e');
    }
  }

  Future<void> updateCollection(Collection collection) async {
    try {
      final updatedCollection = await _databaseService.updateCollection(collection);
      final index = _collections.indexWhere((c) => c.id == collection.id);
      if (index != -1) {
        _collections[index] = updatedCollection;
        if (_selectedCollection?.id == collection.id) {
          _selectedCollection = updatedCollection;
        }
        notifyListeners();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update collection: $e');
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      // Don't allow deletion of default collection
      final collection = _collections.firstWhere((c) => c.id == collectionId);
      if (collection.isDefault) {
        throw Exception('Cannot delete the default collection');
      }

      await _databaseService.deleteCollection(collectionId);
      _collections.removeWhere((c) => c.id == collectionId);
      
      if (_selectedCollection?.id == collectionId) {
        _selectedCollection = null;
      }
      
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to delete collection: $e');
    }
  }

  void selectCollection(Collection? collection) {
    _selectedCollection = collection;
    notifyListeners();
  }

  Collection? getCollectionById(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Collection> searchCollections(String query) {
    if (query.isEmpty) return _collections;
    
    final lowercaseQuery = query.toLowerCase();
    return _collections.where((collection) {
      return collection.name.toLowerCase().contains(lowercaseQuery) ||
             (collection.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Collection> getCollectionsByType(CollectionType type) {
    return _collections.where((c) => c.type == type).toList();
  }

  Future<void> duplicateCollection(String collectionId) async {
    try {
      final original = getCollectionById(collectionId);
      if (original == null) {
        throw Exception('Collection not found');
      }

      final duplicate = original.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${original.name} (Copy)',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createCollection(duplicate);
    } catch (e) {
      _setError('Failed to duplicate collection: $e');
    }
  }

  Future<void> reorderCollections(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final collection = _collections.removeAt(oldIndex);
      _collections.insert(newIndex, collection);
      
      // Update the sort order in the database
      for (int i = 0; i < _collections.length; i++) {
        final updatedCollection = _collections[i].copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateCollection(updatedCollection);
        _collections[i] = updatedCollection;
      }
      
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to reorder collections: $e');
    }
  }

  Future<void> refreshCollections() async {
    await _loadCollections();
  }

  Collection _createDefaultCollection() {
    return Collection(
      id: 'default',
      name: 'My Wishlist',
      description: 'Default collection for all items',
      color: 0xFF2196F3,
      icon: 'favorite',
      type: CollectionType.wishlist,
      isDefault: true,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _createAndAddDefaultCollection() async {
    final defaultCollection = _createDefaultCollection();
    try {
      final created = await _databaseService.createCollection(defaultCollection);
      _collections.insert(0, created);
    } catch (e) {
      // If creation fails, add the default collection locally
      _collections.insert(0, defaultCollection);
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
}

extension _ListExtension<T> on List<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}