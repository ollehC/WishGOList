import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wish_item.dart';
import '../core/providers/user_preferences_provider.dart';
import 'wish_item_card.dart';

enum GridViewType {
  masonry,
  fixed,
  list,
}

class WishItemGrid extends StatelessWidget {
  final List<WishItem> items;
  final Function(WishItem) onItemTap;
  final Function(WishItem)? onItemLongPress;
  final GridViewType viewType;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const WishItemGrid({
    Key? key,
    required this.items,
    required this.onItemTap,
    this.onItemLongPress,
    this.viewType = GridViewType.masonry,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final effectiveViewType = _getEffectiveViewType(userPrefs.defaultView.name);
        
        switch (effectiveViewType) {
          case GridViewType.masonry:
            return _buildMasonryGrid(context);
          case GridViewType.fixed:
            return _buildFixedGrid(context);
          case GridViewType.list:
            return _buildListView(context);
        }
      },
    );
  }

  GridViewType _getEffectiveViewType(String defaultView) {
    switch (defaultView.toLowerCase()) {
      case 'masonry':
        return GridViewType.masonry;
      case 'fixed':
      case 'grid':
        return GridViewType.fixed;
      case 'list':
        return GridViewType.list;
      default:
        return viewType;
    }
  }

  Widget _buildMasonryGrid(BuildContext context) {
    return MasonryGridView(
      items: items,
      onItemTap: onItemTap,
      onItemLongPress: onItemLongPress,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );
  }

  Widget _buildFixedGrid(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WishItemCard(
          item: item,
          onTap: () => onItemTap(item),
          onLongPress: onItemLongPress != null 
              ? () => onItemLongPress!(item)
              : null,
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListWishItemCard(
          item: item,
          onTap: () => onItemTap(item),
          onLongPress: onItemLongPress != null 
              ? () => onItemLongPress!(item)
              : null,
        );
      },
    );
  }
}

class MasonryGridView extends StatelessWidget {
  final List<WishItem> items;
  final Function(WishItem) onItemTap;
  final Function(WishItem)? onItemLongPress;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MasonryGridView({
    Key? key,
    required this.items,
    required this.onItemTap,
    this.onItemLongPress,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      slivers: [
        SliverPadding(
          padding: padding ?? const EdgeInsets.all(16),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return WishItemCard(
                item: item,
                onTap: () => onItemTap(item),
                onLongPress: onItemLongPress != null 
                    ? () => onItemLongPress!(item)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablet/Desktop
    } else if (screenWidth > 400) {
      return 2; // Large phone
    } else {
      return 2; // Small phone
    }
  }
}

// Custom Sliver Masonry Grid implementation
class SliverMasonryGrid extends StatelessWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int childCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const SliverMasonryGrid.count({
    Key? key,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childCount,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now, use a regular grid as a fallback
    // In a production app, you'd want to implement a proper masonry layout
    // or use a package like flutter_staggered_grid_view
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: childCount,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: _getRandomAspectRatio(),
      ),
    );
  }

  double _getRandomAspectRatio() {
    // Simulate different heights for masonry effect
    final ratios = [0.6, 0.75, 0.9, 1.0, 1.2];
    return ratios[DateTime.now().millisecond % ratios.length];
  }
}

class AdaptiveWishItemGrid extends StatelessWidget {
  final List<WishItem> items;
  final Function(WishItem) onItemTap;
  final Function(WishItem)? onItemLongPress;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdaptiveWishItemGrid({
    Key? key,
    required this.items,
    required this.onItemTap,
    this.onItemLongPress,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine optimal view type based on screen size
        final width = constraints.maxWidth;
        GridViewType viewType;
        
        if (width > 800) {
          // Desktop/Large tablet - use masonry for Pinterest-like experience
          viewType = GridViewType.masonry;
        } else if (width > 600) {
          // Tablet - use fixed grid
          viewType = GridViewType.fixed;
        } else {
          // Phone - check orientation
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          viewType = isLandscape ? GridViewType.fixed : GridViewType.masonry;
        }

        return WishItemGrid(
          items: items,
          onItemTap: onItemTap,
          onItemLongPress: onItemLongPress,
          viewType: viewType,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
        );
      },
    );
  }
}

class EmptyWishItemGrid extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyWishItemGrid({
    Key? key,
    this.title = 'No items found',
    this.subtitle = 'Try adjusting your filters or add some items to get started.',
    this.icon = Icons.shopping_bag_outlined,
    this.onActionPressed,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}