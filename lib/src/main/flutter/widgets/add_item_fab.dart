import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/routing/app_router.dart';
import '../core/providers/subscription_provider.dart';
import '../ui/theme/app_colors.dart';

class AddItemFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? heroTag;

  const AddItemFab({
    Key? key,
    this.onPressed,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed ?? () => _onAddItemPressed(context, subscriptionProvider),
          tooltip: 'Add New Item',
          backgroundColor: subscriptionProvider.isPremium 
              ? AppColors.primary 
              : AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        );
      },
    );
  }

  void _onAddItemPressed(BuildContext context, SubscriptionProvider subscriptionProvider) {
    // TODO: Check item limit for free users
    // For now, just navigate to add item screen
    context.goToAddItem();
  }
}

class ExtendedAddItemFab extends StatefulWidget {
  final VoidCallback? onAddFromUrl;
  final VoidCallback? onAddManually;
  final VoidCallback? onScanBarcode;

  const ExtendedAddItemFab({
    Key? key,
    this.onAddFromUrl,
    this.onAddManually,
    this.onScanBarcode,
  }) : super(key: key);

  @override
  State<ExtendedAddItemFab> createState() => _ExtendedAddItemFabState();
}

class _ExtendedAddItemFabState extends State<ExtendedAddItemFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Add from URL option
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Add from URL',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FloatingActionButton.small(
                                  heroTag: 'addFromUrl',
                                  onPressed: widget.onAddFromUrl ?? () => _addFromUrl(context),
                                  backgroundColor: AppColors.secondary,
                                  child: const Icon(Icons.link, size: 20),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),

            // Add manually option
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Add manually',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FloatingActionButton.small(
                                  heroTag: 'addManually',
                                  onPressed: widget.onAddManually ?? () => _addManually(context),
                                  backgroundColor: AppColors.accent,
                                  child: const Icon(Icons.edit, size: 20),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),

            // Scan barcode option (Premium feature)
            if (subscriptionProvider.isPremium)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Opacity(
                      opacity: _animation.value,
                      child: _isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Scan barcode',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: AppColors.premiumGradient,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PRO',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FloatingActionButton.small(
                                    heroTag: 'scanBarcode',
                                    onPressed: widget.onScanBarcode ?? () => _scanBarcode(context),
                                    backgroundColor: AppColors.premium,
                                    child: const Icon(Icons.qr_code_scanner, size: 20),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),

            // Main FAB
            FloatingActionButton(
              onPressed: _toggleExpanded,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0, // 45 degrees when expanded
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addFromUrl(BuildContext context) {
    _toggleExpanded();
    context.goToAddItem();
  }

  void _addManually(BuildContext context) {
    _toggleExpanded();
    context.goToAddItem();
  }

  void _scanBarcode(BuildContext context) {
    _toggleExpanded();
    // TODO: Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanning coming soon!'),
        backgroundColor: AppColors.premium,
      ),
    );
  }
}