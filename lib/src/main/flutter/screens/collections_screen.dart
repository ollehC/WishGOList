import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/collection_provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/routing/app_router.dart';
import '../models/collection.dart';
import '../ui/theme/app_colors.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          Consumer<SubscriptionProvider>(
            builder: (context, subscriptionProvider, child) {
              return IconButton(
                onPressed: () {
                  if (subscriptionProvider.isPremium || 
                      context.read<CollectionProvider>().collections.length < subscriptionProvider.maxCollections) {
                    _showCreateCollectionDialog(context);
                  } else {
                    _showPremiumRequired(context);
                  }
                },
                icon: const Icon(Icons.add),
              );
            },
          ),
        ],
      ),
      body: Consumer2<CollectionProvider, WishItemProvider>(
        builder: (context, collectionProvider, wishItemProvider, child) {
          if (collectionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (collectionProvider.error != null) {
            return _buildErrorState(context, collectionProvider.error!);
          }

          final collections = collectionProvider.collections;

          if (collections.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              final itemCount = wishItemProvider.wishItems
                  .where((item) => item.collectionId == collection.id)
                  .length;

              return _buildCollectionCard(context, collection, itemCount);
            },
          );
        },
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, Collection collection, int itemCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(collection.color).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCollectionIcon(collection.icon),
            color: Color(collection.color),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                collection.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (collection.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (collection.description != null) ...[
              const SizedBox(height: 4),
              Text(
                collection.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onCollectionMenuSelected(context, collection, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Items'),
                ],
              ),
            ),
            if (!collection.isDefault) ...[
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          context.goToList(collectionId: collection.id);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<CollectionProvider>().refreshCollections();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.folder_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Collections Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create collections to organize your wish items by category, theme, or any way you like.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateCollectionDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Collection'),
            ),
          ],
        ),
      ),
    );
  }

  void _onCollectionMenuSelected(BuildContext context, Collection collection, String value) {
    switch (value) {
      case 'view':
        context.goToList(collectionId: collection.id);
        break;
      case 'edit':
        _showEditCollectionDialog(context, collection);
        break;
      case 'duplicate':
        context.read<CollectionProvider>().duplicateCollection(collection.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, collection);
        break;
    }
  }

  void _showCreateCollectionDialog(BuildContext context) {
    _showCollectionDialog(context, null);
  }

  void _showEditCollectionDialog(BuildContext context, Collection collection) {
    _showCollectionDialog(context, collection);
  }

  void _showCollectionDialog(BuildContext context, Collection? collection) {
    final nameController = TextEditingController(text: collection?.name ?? '');
    final descriptionController = TextEditingController(text: collection?.description ?? '');
    int selectedColor = collection?.color ?? 0xFF2196F3;
    String selectedIcon = collection?.icon ?? 'folder';
    CollectionType selectedType = collection?.type ?? CollectionType.wishlist;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(collection == null ? 'Create Collection' : 'Edit Collection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Collection Name',
                    hintText: 'e.g., Electronics, Fashion, Home',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Describe your collection...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Type
                DropdownButtonFormField<CollectionType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: CollectionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getCollectionTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Color selection
                const Text('Color', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _getColorOptions().map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a collection name')),
                  );
                  return;
                }

                final newCollection = Collection(
                  id: collection?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim(),
                  color: selectedColor,
                  icon: selectedIcon,
                  type: selectedType,
                  isDefault: collection?.isDefault ?? false,
                  sortOrder: collection?.sortOrder ?? 0,
                  createdAt: collection?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (collection == null) {
                  context.read<CollectionProvider>().createCollection(newCollection);
                } else {
                  context.read<CollectionProvider>().updateCollection(newCollection);
                }

                Navigator.pop(context);
              },
              child: Text(collection == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "${collection.name}"?\n\nItems in this collection will be moved to the default collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CollectionProvider>().deleteCollection(collection.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPremiumRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: Text('Free users can create up to ${context.read<SubscriptionProvider>().maxCollections} collections. Upgrade to Premium for unlimited collections!'),
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

  IconData _getCollectionIcon(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'computer':
        return Icons.computer;
      case 'home':
        return Icons.home;
      case 'sports':
        return Icons.sports;
      case 'book':
        return Icons.book;
      case 'music':
        return Icons.music_note;
      case 'game':
        return Icons.games;
      default:
        return Icons.folder;
    }
  }

  String _getCollectionTypeName(CollectionType type) {
    switch (type) {
      case CollectionType.wishlist:
        return 'Wishlist';
      case CollectionType.shoppingList:
        return 'Shopping List';
      case CollectionType.favorites:
        return 'Favorites';
      case CollectionType.archive:
        return 'Archive';
    }
  }

  List<int> _getColorOptions() {
    return [
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
  }
}