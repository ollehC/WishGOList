import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/subscription_provider.dart';
import '../models/wish_item.dart';
import '../ui/theme/app_colors.dart';

class WishItemCard extends StatelessWidget {
  final WishItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDesireLevel;
  final bool showStatus;
  final bool compact;

  const WishItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showDesireLevel = true,
    this.showStatus = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: compact ? 2 : 3,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),

                // Content
                Expanded(
                  flex: compact ? 1 : 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Price and currency
                        if (item.price != null) ...[
                          Text(
                            '${item.currency ?? 'HKD'} ${item.price!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],

                        // Bottom row with status, desire level, and tags
                        Row(
                          children: [
                            // Status indicator
                            if (showStatus) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(item.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(item.status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],

                            // Desire level (Premium feature)
                            if (showDesireLevel &&
                                subscriptionProvider.canUseDesireLevels &&
                                item.desireLevel != null) ...[
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < item.desireLevel!
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 12,
                                    color: index < item.desireLevel!
                                        ? Colors.red
                                        : Colors.grey,
                                  );
                                }),
                              ),
                              const Spacer(),
                            ] else
                              const Spacer(),

                            // Source store
                            if (item.sourceStore != null && !compact)
                              Flexible(
                                child: Text(
                                  item.sourceStore!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),

                        // Tags (show only first tag if compact)
                        if (item.tags.isNotEmpty && !compact) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: item.tags.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Color _getStatusColor(WishItemStatus status) {
    switch (status) {
      case WishItemStatus.toBuy:
        return AppColors.primary;
      case WishItemStatus.purchased:
        return Colors.green;
      case WishItemStatus.dropped:
        return Colors.grey;
    }
  }

  String _getStatusText(WishItemStatus status) {
    switch (status) {
      case WishItemStatus.toBuy:
        return 'TO BUY';
      case WishItemStatus.purchased:
        return 'BOUGHT';
      case WishItemStatus.dropped:
        return 'DROPPED';
    }
  }
}

class CompactWishItemCard extends StatelessWidget {
  final WishItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CompactWishItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WishItemCard(
      item: item,
      onTap: onTap,
      onLongPress: onLongPress,
      compact: true,
      showDesireLevel: false,
      showStatus: true,
    );
  }
}

class ListWishItemCard extends StatelessWidget {
  final WishItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListWishItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shopping_bag_outlined);
                        },
                      ),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.price != null)
                  Text(
                    '${item.currency ?? 'HKD'} ${item.price!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(item.status),
                        ),
                      ),
                    ),
                    if (subscriptionProvider.canUseDesireLevels &&
                        item.desireLevel != null) ...[
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < item.desireLevel!
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 12,
                            color: index < item.desireLevel!
                                ? Colors.red
                                : Colors.grey,
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        );
      },
    );
  }

  Color _getStatusColor(WishItemStatus status) {
    switch (status) {
      case WishItemStatus.toBuy:
        return AppColors.primary;
      case WishItemStatus.purchased:
        return Colors.green;
      case WishItemStatus.dropped:
        return Colors.grey;
    }
  }
}