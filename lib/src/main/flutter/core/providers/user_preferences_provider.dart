import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../../models/user_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final StorageService _storageService;

  UserPreferences _preferences = const UserPreferences();
  bool _isLoading = false;
  String? _error;

  UserPreferencesProvider(this._databaseService, this._storageService) {
    _loadPreferences();
  }

  // Getters
  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  String get themeMode => _preferences.themeMode;
  String get language => _preferences.language;
  String get currency => _preferences.currency;
  bool get isPremium => _preferences.isPremium;
  bool get notificationsEnabled => _preferences.notificationsEnabled;
  bool get priceTrackingEnabled => _preferences.priceTrackingEnabled;
  bool get analyticsEnabled => _preferences.analyticsEnabled;
  String get defaultView => _preferences.defaultView;
  String get sortBy => _preferences.sortBy;
  bool get showCompletedItems => _preferences.showCompletedItems;

  Future<void> _loadPreferences() async {
    _setLoading(true);
    try {
      final userPrefs = await _databaseService.getUserPreferences();
      if (userPrefs != null) {
        _preferences = userPrefs;
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    try {
      final updatedPrefs = _preferences.copyWith(themeMode: themeMode);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update theme: $e');
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      final updatedPrefs = _preferences.copyWith(language: language);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update language: $e');
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      final updatedPrefs = _preferences.copyWith(currency: currency);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update currency: $e');
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      final updatedPrefs = _preferences.copyWith(notificationsEnabled: enabled);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update notifications: $e');
    }
  }

  Future<void> updatePriceTrackingEnabled(bool enabled) async {
    try {
      final updatedPrefs = _preferences.copyWith(priceTrackingEnabled: enabled);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update price tracking: $e');
    }
  }

  Future<void> updateAnalyticsEnabled(bool enabled) async {
    try {
      final updatedPrefs = _preferences.copyWith(analyticsEnabled: enabled);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update analytics: $e');
    }
  }

  Future<void> updateDefaultView(String view) async {
    try {
      final updatedPrefs = _preferences.copyWith(defaultView: view);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update default view: $e');
    }
  }

  Future<void> updateSortBy(String sortBy) async {
    try {
      final updatedPrefs = _preferences.copyWith(sortBy: sortBy);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update sort preference: $e');
    }
  }

  Future<void> updateShowCompletedItems(bool show) async {
    try {
      final updatedPrefs = _preferences.copyWith(showCompletedItems: show);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update completed items visibility: $e');
    }
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      final updatedPrefs = _preferences.copyWith(isPremium: isPremium);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update premium status: $e');
    }
  }

  Future<void> _savePreferences(UserPreferences updatedPrefs) async {
    await _databaseService.saveUserPreferences(updatedPrefs);
    _preferences = updatedPrefs;
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    try {
      const defaultPrefs = UserPreferences();
      await _savePreferences(defaultPrefs);
    } catch (e) {
      _setError('Failed to reset preferences: $e');
    }
  }

  Future<void> exportData() async {
    try {
      // TODO: Implement data export functionality
      throw UnimplementedError('Data export coming soon!');
    } catch (e) {
      _setError('Export failed: $e');
    }
  }

  Future<void> importData(String data) async {
    try {
      // TODO: Implement data import functionality
      throw UnimplementedError('Data import coming soon!');
    } catch (e) {
      _setError('Import failed: $e');
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