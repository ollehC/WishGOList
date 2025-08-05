import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // JSON operations
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Remove operations
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // App-specific convenience methods
  static const String keyThemeMode = 'theme_mode';
  static const String keyViewMode = 'view_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncDate = 'last_sync_date';
  static const String keyFilterPreferences = 'filter_preferences';
  static const String keySearchHistory = 'search_history';
  static const String keyRecentlyViewedItems = 'recently_viewed_items';
  static const String keyQuickTagSuggestions = 'quick_tag_suggestions';

  // Theme mode
  Future<bool> setThemeMode(String themeMode) async {
    return await setString(keyThemeMode, themeMode);
  }

  String getThemeMode() {
    return getString(keyThemeMode) ?? 'system';
  }

  // View mode
  Future<bool> setViewMode(String viewMode) async {
    return await setString(keyViewMode, viewMode);
  }

  String getViewMode() {
    return getString(keyViewMode) ?? 'grid';
  }

  // Onboarding
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await setBool(keyOnboardingCompleted, completed);
  }

  bool isOnboardingCompleted() {
    return getBool(keyOnboardingCompleted) ?? false;
  }

  // Last sync date
  Future<bool> setLastSyncDate(DateTime date) async {
    return await setString(keyLastSyncDate, date.toIso8601String());
  }

  DateTime? getLastSyncDate() {
    final dateString = getString(keyLastSyncDate);
    if (dateString == null) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Filter preferences
  Future<bool> setFilterPreferences(Map<String, dynamic> preferences) async {
    return await setJson(keyFilterPreferences, preferences);
  }

  Map<String, dynamic> getFilterPreferences() {
    return getJson(keyFilterPreferences) ?? {};
  }

  // Search history
  Future<bool> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    history.removeWhere((item) => item == query); // Remove duplicates
    history.insert(0, query); // Add to beginning
    
    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    return await setStringList(keySearchHistory, history);
  }

  List<String> getSearchHistory() {
    return getStringList(keySearchHistory) ?? [];
  }

  Future<bool> clearSearchHistory() async {
    return await remove(keySearchHistory);
  }

  // Recently viewed items
  Future<bool> addToRecentlyViewed(String itemId) async {
    final recentItems = getRecentlyViewedItems();
    recentItems.removeWhere((item) => item == itemId); // Remove duplicates
    recentItems.insert(0, itemId); // Add to beginning
    
    // Keep only last 50 items
    if (recentItems.length > 50) {
      recentItems.removeRange(50, recentItems.length);
    }
    
    return await setStringList(keyRecentlyViewedItems, recentItems);
  }

  List<String> getRecentlyViewedItems() {
    return getStringList(keyRecentlyViewedItems) ?? [];
  }

  Future<bool> clearRecentlyViewed() async {
    return await remove(keyRecentlyViewedItems);
  }

  // Quick tag suggestions
  Future<bool> setQuickTagSuggestions(List<String> tags) async {
    return await setStringList(keyQuickTagSuggestions, tags);
  }

  List<String> getQuickTagSuggestions() {
    return getStringList(keyQuickTagSuggestions) ?? [];
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    final keys = getKeys();
    final data = <String, dynamic>{};
    
    for (final key in keys) {
      // Get the raw value based on type
      if (_prefs.get(key) is String) {
        data[key] = getString(key);
      } else if (_prefs.get(key) is int) {
        data[key] = getInt(key);
      } else if (_prefs.get(key) is bool) {
        data[key] = getBool(key);
      } else if (_prefs.get(key) is double) {
        data[key] = getDouble(key);
      } else if (_prefs.get(key) is List<String>) {
        data[key] = getStringList(key);
      }
    }
    
    return data;
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    bool success = true;
    
    for (final entry in data.entries) {
      try {
        final key = entry.key;
        final value = entry.value;
        
        if (value is String) {
          success = success && await setString(key, value);
        } else if (value is int) {
          success = success && await setInt(key, value);
        } else if (value is bool) {
          success = success && await setBool(key, value);
        } else if (value is double) {
          success = success && await setDouble(key, value);
        } else if (value is List<String>) {
          success = success && await setStringList(key, value);
        }
      } catch (e) {
        success = false;
      }
    }
    
    return success;
  }
}