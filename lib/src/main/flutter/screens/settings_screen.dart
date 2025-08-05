import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_preferences_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/routing/app_router.dart';
import '../ui/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<UserPreferencesProvider, SubscriptionProvider>(
        builder: (context, userPrefs, subscriptionProvider, child) {
          return ListView(
            children: [
              // Premium status
              if (subscriptionProvider.isPremium) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.premiumGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'WishGO Premium',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (subscriptionProvider.daysUntilExpiry != null)
                        Text(
                          '${subscriptionProvider.daysUntilExpiry} days left',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Appearance section
              _buildSection(
                'Appearance',
                [
                  _buildDropdownTile(
                    'Theme',
                    userPrefs.themeMode,
                    ['System', 'Light', 'Dark'],
                    (value) => userPrefs.updateThemeMode(value.toLowerCase()),
                    Icons.palette,
                  ),
                  _buildDropdownTile(
                    'Default View',
                    _capitalizeFirst(userPrefs.defaultView),
                    ['Grid', 'List', 'Masonry'],
                    (value) => userPrefs.updateDefaultView(value.toLowerCase()),
                    Icons.view_module,
                  ),
                ],
              ),

              // Localization section
              _buildSection(
                'Localization',
                [
                  _buildDropdownTile(
                    'Language',
                    _getLanguageDisplayName(userPrefs.language),
                    ['English', '繁體中文', '简体中文', '日本語'],
                    (value) => userPrefs.updateLanguage(_getLanguageCode(value)),
                    Icons.language,
                  ),
                  _buildDropdownTile(
                    'Currency',
                    userPrefs.currency,
                    ['HKD', 'USD', 'EUR', 'GBP', 'JPY', 'CNY'],
                    (value) => userPrefs.updateCurrency(value),
                    Icons.attach_money,
                  ),
                ],
              ),

              // Notifications section
              _buildSection(
                'Notifications',
                [
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive notifications about your wishlist',
                    userPrefs.notificationsEnabled,
                    (value) => userPrefs.updateNotificationsEnabled(value),
                    Icons.notifications,
                  ),
                  if (subscriptionProvider.canUsePriceTracking)
                    _buildSwitchTile(
                      'Price Alerts',
                      'Get notified when prices drop',
                      userPrefs.priceTrackingEnabled,
                      (value) => userPrefs.updatePriceTrackingEnabled(value),
                      Icons.trending_down,
                      isPremium: true,
                    ),
                ],
              ),

              // Display section
              _buildSection(
                'Display',
                [
                  _buildDropdownTile(
                    'Sort Items By',
                    _getSortDisplayName(userPrefs.sortBy),
                    ['Recently Added', 'Oldest First', 'Price: Low to High', 'Price: High to Low', 'Alphabetical'],
                    (value) => userPrefs.updateSortBy(_getSortCode(value)),
                    Icons.sort,
                  ),
                  _buildSwitchTile(
                    'Show Completed Items',
                    'Display purchased and dropped items',
                    userPrefs.showCompletedItems,
                    (value) => userPrefs.updateShowCompletedItems(value),
                    Icons.check_circle,
                  ),
                ],
              ),

              // Privacy section
              _buildSection(
                'Privacy',
                [
                  _buildSwitchTile(
                    'Analytics',
                    'Help improve the app by sharing usage data',
                    userPrefs.analyticsEnabled,
                    (value) => userPrefs.updateAnalyticsEnabled(value),
                    Icons.analytics,
                  ),
                ],
              ),

              // Premium section
              if (!subscriptionProvider.isPremium)
                _buildSection(
                  'Upgrade',
                  [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.premiumGradient,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star, color: Colors.black),
                      ),
                      title: const Text('Upgrade to Premium'),
                      subtitle: const Text('Unlock all features and remove limits'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.goToSubscription();
                      },
                    ),
                  ],
                ),

              // Data section
              _buildSection(
                'Data',
                [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your wishlist data'),
                    trailing: subscriptionProvider.canExportData
                        ? const Icon(Icons.arrow_forward_ios)
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.premiumGradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                    onTap: () {
                      if (subscriptionProvider.canExportData) {
                        _exportData(context);
                      } else {
                        _showPremiumRequired(context);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload),
                    title: const Text('Import Data'),
                    subtitle: const Text('Import wishlist from file'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _importData(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Reset Settings'),
                    subtitle: const Text('Restore default settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _resetSettings(context),
                  ),
                ],
              ),

              // Account section
              _buildSection(
                'Account',
                [
                  if (subscriptionProvider.isPremium)
                    ListTile(
                      leading: const Icon(Icons.card_membership),
                      title: const Text('Manage Subscription'),
                      subtitle: const Text('View and manage your premium subscription'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.goToSubscription();
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Purchases'),
                    subtitle: const Text('Restore previous premium purchases'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _restorePurchases(context),
                  ),
                ],
              ),

              // About section
              _buildSection(
                'About',
                [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0 (Beta)'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showHelp(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showTermsOfService(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon, {
    bool isPremium = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Text(title),
          if (isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.premiumGradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(currentValue),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Show selection dialog
        // For now, just show a snackbar
      },
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'zh_HK': return '繁體中文';
      case 'zh_CN': return '简体中文';
      case 'ja': return '日本語';
      default: return 'English';
    }
  }

  String _getLanguageCode(String displayName) {
    switch (displayName) {
      case 'English': return 'en';
      case '繁體中文': return 'zh_HK';
      case '简体中文': return 'zh_CN';
      case '日本語': return 'ja';
      default: return 'en';
    }
  }

  String _getSortDisplayName(String code) {
    switch (code) {
      case 'created_desc': return 'Recently Added';
      case 'created_asc': return 'Oldest First';
      case 'price_asc': return 'Price: Low to High';
      case 'price_desc': return 'Price: High to Low';
      case 'title_asc': return 'Alphabetical';
      default: return 'Recently Added';
    }
  }

  String _getSortCode(String displayName) {
    switch (displayName) {
      case 'Recently Added': return 'created_desc';
      case 'Oldest First': return 'created_asc';
      case 'Price: Low to High': return 'price_asc';
      case 'Price: High to Low': return 'price_desc';
      case 'Alphabetical': return 'title_asc';
      default: return 'created_desc';
    }
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon!')),
    );
  }

  void _importData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data import coming soon!')),
    );
  }

  void _resetSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserPreferencesProvider>().resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _restorePurchases(BuildContext context) {
    context.read<SubscriptionProvider>().restorePurchases();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for previous purchases...')),
    );
  }

  void _showPremiumRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: const Text('This feature requires WishGO Premium. Upgrade to unlock data export and more!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.goToSubscription();
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon!')),
    );
  }

  void _showTermsOfService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service coming soon!')),
    );
  }
}