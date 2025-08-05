import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../core/routing/app_router.dart';
import '../models/wish_item.dart';
import '../ui/theme/app_colors.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  final WishItem? item;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
    this.item,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  WishItem? _item;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    if (_item == null) {
      _loadItem();
    }
  }

  Future<void> _loadItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final item = await context.read<WishItemProvider>().getWishItemById(widget.itemId);
      setState(() {
        _item = item;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load item: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(
          child: Text('Item not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _item!.imageUrl != null
                  ? Image.network(
                      _item!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
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
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
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
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _item!.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusChip(_item!.status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price
                  if (_item!.price != null) ...[
                    Text(
                      '${_item!.currency ?? 'HKD'} ${_item!.price!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Desire level (Premium)
                  Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, child) {
                      if (subscriptionProvider.canUseDesireLevels && _item!.desireLevel != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Desire Level',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < _item!.desireLevel!
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: index < _item!.desireLevel!
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 24,
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Description
                  if (_item!.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _item!.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Notes
                  if (_item!.notes != null) ...[
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _item!.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (_item!.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _item!.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(color: AppColors.primary),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Store info
                  if (_item!.sourceStore != null) ...[
                    const Text(
                      'Store',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.store, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _item!.sourceStore!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMetadataRow('Added', _formatDate(_item!.createdAt)),
                        _buildMetadataRow('Updated', _formatDate(_item!.updatedAt)),
                        if (_item!.productUrl != null)
                          _buildMetadataRow('Product URL', 'Available'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatusChip(WishItemStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case WishItemStatus.toBuy:
        color = AppColors.primary;
        text = 'TO BUY';
        break;
      case WishItemStatus.purchased:
        color = Colors.green;
        text = 'PURCHASED';
        break;
      case WishItemStatus.dropped:
        color = Colors.grey;
        text = 'DROPPED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_item!.productUrl != null) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openProductUrl,
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Product'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _markAsPurchased,
              icon: const Icon(Icons.shopping_cart),
              label: Text(_item!.status == WishItemStatus.purchased ? 'Purchased' : 'Mark as Bought'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _item!.status == WishItemStatus.purchased 
                    ? Colors.green 
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        context.goToEditItem(_item!);
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _openProductUrl() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening product URL coming soon!')),
    );
  }

  void _markAsPurchased() {
    if (_item!.status == WishItemStatus.purchased) {
      // Already purchased, maybe show order tracking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order tracking coming soon!')),
      );
    } else {
      // Mark as purchased
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mark as purchased coming soon!')),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${_item!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}