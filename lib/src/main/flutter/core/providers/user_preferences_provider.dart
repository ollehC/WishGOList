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
  ThemeMode get themeMode => _preferences.themeMode;
  String get currency => _preferences.currency;
  bool get isPremium => _preferences.isPremium;
  bool get notificationsEnabled => _preferences.pushNotifications;
  bool get priceTrackingEnabled => _preferences.priceAlerts;
  ViewMode get defaultView => _preferences.defaultViewMode;

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

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      final updatedPrefs = _preferences.copyWith(themeMode: themeMode);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update theme: $e');
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
      final updatedPrefs = _preferences.copyWith(pushNotifications: enabled);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update notifications: $e');
    }
  }

  Future<void> updatePriceTrackingEnabled(bool enabled) async {
    try {
      final updatedPrefs = _preferences.copyWith(priceAlerts: enabled);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update price tracking: $e');
    }
  }

  Future<void> updateDefaultView(ViewMode view) async {
    try {
      final updatedPrefs = _preferences.copyWith(defaultViewMode: view);
      await _savePreferences(updatedPrefs);
    } catch (e) {
      _setError('Failed to update default view: $e');
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