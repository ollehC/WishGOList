import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/order_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../models/wish_item.dart';
import '../ui/theme/app_colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '30days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishItemProvider>().loadWishItems();
      context.read<OrderProvider>().refreshOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '7days', child: Text('Last 7 days')),
                  const PopupMenuItem(value: '30days', child: Text('Last 30 days')),
                  const PopupMenuItem(value: '90days', child: Text('Last 90 days')),
                  const PopupMenuItem(value: '1year', child: Text('Last year')),
                  const PopupMenuItem(value: 'all', child: Text('All time')),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getPeriodText()),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Spending'),
              ],
            ),
          ),
          body: subscriptionProvider.canUseAdvancedAnalytics
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildSpendingTab(),
                  ],
                )
              : _buildPremiumPrompt(),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<WishItemProvider, OrderProvider>(
      builder: (context, wishItemProvider, orderProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats cards
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    'Total Items',
                    wishItemProvider.wishItems.length.toString(),
                    Icons.shopping_bag_outlined,
                    AppColors.primary,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    'To Buy',
                    wishItemProvider.wishItems.where((i) => i.status == WishItemStatus.toBuy).length.toString(),
                    Icons.shopping_cart_outlined,
                    Colors.orange,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    'Purchased',
                    wishItemProvider.wishItems.where((i) => i.status == WishItemStatus.purchased).length.toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    'Total Orders',
                    orderProvider.orders.length.toString(),
                    Icons.local_shipping_outlined,
                    AppColors.secondary,
                  )),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Coming soon placeholder
              _buildComingSoonSection('Detailed Analytics', [
                'Purchase patterns and trends',
                'Price tracking history',
                'Collection insights',
                'Monthly/yearly comparisons',
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final totalSpent = orderProvider.getTotalSpent();
        final spendingByStore = orderProvider.getSpendingByStore();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total spending card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Spent',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'HKD ${totalSpent.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Store spending breakdown
              if (spendingByStore.isNotEmpty) ..[
                const Text(
                  'Spending by Store',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...spendingByStore.entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        entry.key.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      'HKD ${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )),
              ] else ..[
                _buildComingSoonSection('Spending Analytics', [
                  'Store-wise spending breakdown',
                  'Monthly spending trends',
                  'Category-wise analysis',
                  'Budget tracking and alerts',
                ]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonSection(String title, List<String> features) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Coming Soon!',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.premiumGradient,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.analytics,
                size: 60,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Advanced Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock detailed insights about your shopping habits and spending patterns with WishGO Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.premiumGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Premium Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getPremiumFeatures().map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to subscription screen
                Navigator.pushNamed(context, '/subscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getPremiumFeatures() {
    return [
      'Detailed spending analytics',
      'Price tracking and alerts',
      'Purchase pattern insights',
      'Monthly/yearly comparisons',
      'Store-wise breakdowns',
      'Export analytics data',
    ];
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case '7days': return 'Last 7 days';
      case '30days': return 'Last 30 days';
      case '90days': return 'Last 90 days';
      case '1year': return 'Last year';
      case 'all': return 'All time';
      default: return 'Last 30 days';
    }
  }
}