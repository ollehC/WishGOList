import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/user_preferences_provider.dart';
import '../core/routing/app_router.dart';
import '../ui/theme/app_colors.dart';
import '../widgets/add_item_fab.dart';
import '../widgets/wish_item_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load wish items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishItemProvider>().loadWishItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WishGO List'),
        actions: [
          Consumer<UserPreferencesProvider>(
            builder: (context, userPrefs, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium badge
                  if (userPrefs.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.premiumGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // Search button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement search
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
                  
                  // View mode toggle
                  IconButton(
                    onPressed: () {
                      // TODO: Toggle view mode
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View toggle coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.view_module),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WishItemProvider>(
        builder: (context, wishItemProvider, child) {
          if (wishItemProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (wishItemProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wishItemProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      wishItemProvider.clearError();
                      wishItemProvider.loadWishItems();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (wishItemProvider.wishItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return WishItemGrid(
            items: wishItemProvider.wishItems,
            onItemTap: (item) {
              context.goToItemDetail(item.id, item: item);
            },
            onItemLongPress: (item) {
              _showItemOptions(context, item);
            },
          );
        },
      ),
      floatingActionButton: const AddItemFab(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Start Your Wishlist!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Add items you want to buy by sharing URLs from your favorite shopping sites.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {
                context.goToAddItem();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Item'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}