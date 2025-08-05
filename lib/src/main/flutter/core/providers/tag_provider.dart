import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../../models/tag.dart';

class TagProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _error;

  TagProvider(this._databaseService) {
    _loadTags();
  }

  // Getters
  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get most used tags
  List<Tag> get popularTags {
    final sortedTags = List<Tag>.from(_tags);
    sortedTags.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sortedTags.take(10).toList();
  }

  // Get recently used tags
  List<Tag> get recentTags {
    final sortedTags = List<Tag>.from(_tags);
    sortedTags.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return sortedTags.take(10).toList();
  }

  Future<void> _loadTags() async {
    _setLoading(true);
    try {
      _tags = await _databaseService.getAllTags();
      _clearError();
    } catch (e) {
      _setError('Failed to load tags: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTag(Tag tag) async {
    try {
      final createdTag = await _databaseService.createTag(tag);
      _tags.add(createdTag);
      _sortTags();
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to create tag: $e');
    }
  }

  Future<Tag> createOrGetTag(String name, {int? color}) async {
    try {
      // Check if tag already exists
      final existingTag = getTagByName(name);
      if (existingTag != null) {
        // Update usage count and last used
        final updatedTag = existingTag.copyWith(
          usageCount: existingTag.usageCount + 1,
          lastUsed: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await updateTag(updatedTag);
        return updatedTag;
      }

      // Create new tag
      final newTag = Tag(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        color: color ?? _generateRandomColor(),
        usageCount: 1,
        lastUsed: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createTag(newTag);
      return newTag;
    } catch (e) {
      _setError('Failed to create or get tag: $e');
      rethrow;
    }
  }

  Future<void> updateTag(Tag tag) async {
    try {
      final updatedTag = await _databaseService.updateTag(tag);
      final index = _tags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        _tags[index] = updatedTag;
        notifyListeners();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update tag: $e');
    }
  }

  Future<void> deleteTag(String tagId) async {
    try {
      await _databaseService.deleteTag(tagId);
      _tags.removeWhere((t) => t.id == tagId);
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to delete tag: $e');
    }
  }

  Future<void> incrementTagUsage(String tagName) async {
    try {
      final tag = getTagByName(tagName);
      if (tag != null) {
        final updatedTag = tag.copyWith(
          usageCount: tag.usageCount + 1,
          lastUsed: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await updateTag(updatedTag);
      }
    } catch (e) {
      // Don't show error for usage increment failures
      debugPrint('Failed to increment tag usage: $e');
    }
  }

  Future<void> decrementTagUsage(String tagName) async {
    try {
      final tag = getTagByName(tagName);
      if (tag != null && tag.usageCount > 0) {
        final updatedTag = tag.copyWith(
          usageCount: tag.usageCount - 1,
          updatedAt: DateTime.now(),
        );
        await updateTag(updatedTag);
        
        // Remove unused tags
        if (updatedTag.usageCount == 0) {
          await deleteTag(tag.id);
        }
      }
    } catch (e) {
      // Don't show error for usage decrement failures
      debugPrint('Failed to decrement tag usage: $e');
    }
  }

  Tag? getTagById(String id) {
    try {
      return _tags.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Tag? getTagByName(String name) {
    try {
      return _tags.firstWhere((t) => t.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  List<Tag> searchTags(String query) {
    if (query.isEmpty) return _tags;
    
    final lowercaseQuery = query.toLowerCase();
    return _tags.where((tag) {
      return tag.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Tag> getTagsByNames(List<String> names) {
    return names
        .map((name) => getTagByName(name))
        .where((tag) => tag != null)
        .cast<Tag>()
        .toList();
  }

  List<String> getTagSuggestions(String input) {
    if (input.isEmpty) return [];
    
    final lowercaseInput = input.toLowerCase();
    return _tags
        .where((tag) => tag.name.toLowerCase().startsWith(lowercaseInput))
        .map((tag) => tag.name)
        .take(5)
        .toList();
  }

  Future<void> bulkCreateTags(List<String> tagNames, {int? defaultColor}) async {
    try {
      for (final name in tagNames) {
        await createOrGetTag(name, color: defaultColor);
      }
    } catch (e) {
      _setError('Failed to bulk create tags: $e');
    }
  }

  Future<void> cleanupUnusedTags() async {
    try {
      final unusedTags = _tags.where((tag) => tag.usageCount == 0).toList();
      for (final tag in unusedTags) {
        await deleteTag(tag.id);
      }
    } catch (e) {
      _setError('Failed to cleanup unused tags: $e');
    }
  }

  Map<String, int> getTagUsageStats() {
    final stats = <String, int>{};
    for (final tag in _tags) {
      stats[tag.name] = tag.usageCount;
    }
    return stats;
  }

  List<Tag> getTagsByColor(int color) {
    return _tags.where((tag) => tag.color == color).toList();
  }

  void _sortTags() {
    _tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  int _generateRandomColor() {
    final colors = [
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
      0xFFF44336, // Red
      0xFF00BCD4, // Cyan
      0xFF795548, // Brown
      0xFF607D8B, // Blue Grey
      0xFFE91E63, // Pink
      0xFF3F51B5, // Indigo
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> refreshTags() async {
    await _loadTags();
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