import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/subscription_provider.dart';
import '../ui/theme/app_colors.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WishGO Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          if (subscriptionProvider.isPremium) {
            return _buildPremiumUserView(context, subscriptionProvider);
          } else {
            return _buildUpgradeView(context, subscriptionProvider);
          }
        },
      ),
    );
  }

  Widget _buildUpgradeView(BuildContext context, SubscriptionProvider subscriptionProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.premiumGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 80,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unlock Premium',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get unlimited access to all features',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Features section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Features',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                ...subscriptionProvider.getPremiumFeatures().map((feature) => 
                  _buildFeatureItem(feature)
                ),

                const SizedBox(height: 32),

                // Current usage
                const Text(
                  'Current Usage (Free)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildUsageCard(
                  'Wish Items',
                  subscriptionProvider.getFeatureUsageStatus('wishItems'),
                  Icons.shopping_bag_outlined,
                ),
                _buildUsageCard(
                  'Collections',
                  subscriptionProvider.getFeatureUsageStatus('collections'),
                  Icons.folder_outlined,
                ),
                _buildUsageCard(
                  'Price Tracking',
                  subscriptionProvider.getFeatureUsageStatus('priceTracking'),
                  Icons.trending_down,
                ),
                _buildUsageCard(
                  'Analytics',
                  subscriptionProvider.getFeatureUsageStatus('analytics'),
                  Icons.analytics_outlined,
                ),

                const SizedBox(height: 32),

                // Pricing
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...subscriptionProvider.getSubscriptionPlans().entries.map((entry) =>
                  _buildPricingCard(entry.key, entry.value, entry.key == 'Yearly')
                ),

                const SizedBox(height: 24),

                // Purchase button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: subscriptionProvider.isLoading
                        ? null
                        : () => _purchasePremium(context, subscriptionProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: subscriptionProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Start Free Trial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Restore purchases
                Center(
                  child: TextButton(
                    onPressed: () => _restorePurchases(context, subscriptionProvider),
                    child: const Text('Restore Purchases'),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms
                const Text(
                  'By purchasing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumUserView(BuildContext context, SubscriptionProvider subscriptionProvider) {
    final subscriptionInfo = subscriptionProvider.subscriptionInfo;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.premiumGradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 60,
                  color: Colors.black,
                ),
                const SizedBox(height: 12),
                const Text(
                  'WishGO Premium',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subscriptionInfo.status == SubscriptionStatus.active
                      ? 'Active Subscription'
                      : 'Subscription ${subscriptionInfo.status.toString().split('.').last}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (subscriptionProvider.daysUntilExpiry != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${subscriptionProvider.daysUntilExpiry} days remaining',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Subscription details
          const Text(
            'Subscription Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailCard('Plan', 'Premium Annual'),
          _buildDetailCard('Status', subscriptionInfo.status.toString().split('.').last.toUpperCase()),
          if (subscriptionInfo.startDate != null)
            _buildDetailCard('Started', _formatDate(subscriptionInfo.startDate!)),
          if (subscriptionInfo.endDate != null)
            _buildDetailCard('Renews', _formatDate(subscriptionInfo.endDate!)),
          _buildDetailCard('Auto-Renew', subscriptionInfo.autoRenew ? 'Enabled' : 'Disabled'),

          const SizedBox(height: 32),

          // Premium features
          const Text(
            'Your Premium Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...subscriptionProvider.getPremiumFeatures().map((feature) =>
            _buildActiveFeatureItem(feature)
          ),

          const SizedBox(height: 32),

          // Actions
          if (subscriptionInfo.status == SubscriptionStatus.active) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _manageBilling(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Manage Billing',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _cancelSubscription(context, subscriptionProvider),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel Subscription',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Support
          Center(
            child: TextButton.icon(
              onPressed: () => _contactSupport(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('Contact Support'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFeatureItem(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(String title, String usage, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            usage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(String plan, String price, bool isRecommended) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? AppColors.premium : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              plan,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRecommended) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.premiumGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BEST VALUE',
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
        subtitle: Text(price),
        trailing: isRecommended
            ? const Icon(Icons.star, color: AppColors.premium)
            : null,
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _purchasePremium(BuildContext context, SubscriptionProvider subscriptionProvider) async {
    try {
      await subscriptionProvider.purchasePremium();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to WishGO Premium!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  void _restorePurchases(BuildContext context, SubscriptionProvider subscriptionProvider) async {
    try {
      await subscriptionProvider.restorePurchases();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  void _cancelSubscription(BuildContext context, SubscriptionProvider subscriptionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your premium subscription? '
          'You will lose access to premium features at the end of your current billing period.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Premium'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await subscriptionProvider.cancelSubscription();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscription cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancellation failed: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _manageBilling(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage billing coming soon!')),
    );
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}