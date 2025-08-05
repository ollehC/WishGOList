import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/collection_provider.dart';
import '../core/providers/user_preferences_provider.dart';
import '../core/routing/app_router.dart';
import '../models/wish_item.dart';
import '../models/collection.dart';
import '../ui/theme/app_colors.dart';
import '../widgets/wish_item_grid.dart';
import '../widgets/add_item_fab.dart';

class ListScreen extends StatefulWidget {
  final String? collectionId;
  final WishItemStatus? status;

  const ListScreen({
    Key? key,
    this.collectionId,
    this.status,
  }) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  WishItemStatus? _selectedStatus;
  String? _selectedCollectionId;
  String _sortBy = 'created_desc';
  bool _showFilters = false;

  final List<Tab> _tabs = [
    const Tab(text: 'All'),
    const Tab(text: 'To Buy'),
    const Tab(text: 'Purchased'),
    const Tab(text: 'Dropped'),
  ];

  final Map<int, WishItemStatus?> _tabStatus = {
    0: null,
    1: WishItemStatus.toBuy,
    2: WishItemStatus.purchased,
    3: WishItemStatus.dropped,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _selectedStatus = widget.status;
    _selectedCollectionId = widget.collectionId;
    
    // Set initial tab based on status
    if (_selectedStatus != null) {
      final tabIndex = _tabStatus.entries
          .firstWhere((entry) => entry.value == _selectedStatus,
              orElse: () => const MapEntry(0, null))
          .key;
      _tabController.index = tabIndex;
    }

    _tabController.addListener(_onTabChanged);
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishItemProvider>().loadWishItems();
      context.read<CollectionProvider>().refreshCollections();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedStatus = _tabStatus[_tabController.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _toggleFilters,
            icon: Icon(
              Icons.filter_list,
              color: _showFilters ? AppColors.primary : null,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_toggle',
                child: Row(
                  children: [
                    Icon(Icons.view_module),
                    SizedBox(width: 8),
                    Text('Toggle View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sort Options'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty || _showFilters) _buildSearchAndFilters(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabContent()).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: const AddItemFab(),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          // Filters
          if (_showFilters) ...[
            const SizedBox(height: 16),
            _buildFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<CollectionProvider>(
      builder: (context, collectionProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collection filter
            const Text(
              'Collection',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Collections'),
                    selected: _selectedCollectionId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCollectionId = selected ? null : _selectedCollectionId;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...collectionProvider.collections.map((collection) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(collection.name),
                        selected: _selectedCollectionId == collection.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCollectionId = selected ? collection.id : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sort options
            const Text(
              'Sort by',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Recently Added', 'created_desc'),
                  _buildSortChip('Oldest First', 'created_asc'),
                  _buildSortChip('Price: Low to High', 'price_asc'),
                  _buildSortChip('Price: High to Low', 'price_desc'),
                  _buildSortChip('Alphabetical', 'title_asc'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _sortBy == value,
        onSelected: (selected) {
          setState(() {
            _sortBy = selected ? value : 'created_desc';
          });
        },
      ),
    );
  }

  Widget _buildTabContent() {
    return Consumer<WishItemProvider>(
      builder: (context, wishItemProvider, child) {
        if (wishItemProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishItemProvider.error != null) {
          return _buildErrorState(wishItemProvider.error!);
        }

        final filteredItems = _filterAndSortItems(wishItemProvider.wishItems);

        if (filteredItems.isEmpty) {
          return _buildEmptyState();
        }

        return AdaptiveWishItemGrid(
          items: filteredItems,
          onItemTap: (item) {
            context.goToItemDetail(item.id, item: item);
          },
          onItemLongPress: (item) {
            _showItemOptions(context, item);
          },
          padding: const EdgeInsets.all(16),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
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
              context.read<WishItemProvider>().loadWishItems();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = 'No items found';
    String subtitle = 'Try adjusting your filters or search terms.';
    IconData icon = Icons.search_off;

    if (_searchQuery.isEmpty && _selectedStatus == null) {
      title = 'Start Your Wishlist!';
      subtitle = 'Add items you want to buy by sharing URLs from your favorite shopping sites.';
      icon = Icons.shopping_bag_outlined;
    } else if (_selectedStatus == WishItemStatus.toBuy) {
      title = 'Nothing to buy yet';
      subtitle = 'Add some items to your wishlist to get started.';
    } else if (_selectedStatus == WishItemStatus.purchased) {
      title = 'No purchases yet';
      subtitle = 'Mark items as purchased when you buy them.';
    } else if (_selectedStatus == WishItemStatus.dropped) {
      title = 'No dropped items';
      subtitle = 'Items you\'re no longer interested in will appear here.';
    }

    return EmptyWishItemGrid(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onActionPressed: () {
        context.goToAddItem();
      },
      actionText: 'Add Your First Item',
    );
  }

  List<WishItem> _filterAndSortItems(List<WishItem> items) {
    var filteredItems = items;

    // Filter by status
    if (_selectedStatus != null) {
      filteredItems = filteredItems.where((item) => item.status == _selectedStatus).toList();
    }

    // Filter by collection
    if (_selectedCollectionId != null) {
      filteredItems = filteredItems.where((item) => item.collectionId == _selectedCollectionId).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
               (item.description?.toLowerCase().contains(query) ?? false) ||
               item.tags.any((tag) => tag.toLowerCase().contains(query)) ||
               (item.sourceStore?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort items
    switch (_sortBy) {
      case 'created_asc':
        filteredItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'created_desc':
        filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_asc':
        filteredItems.sort((a, b) {
          final aPrice = a.price ?? double.infinity;
          final bPrice = b.price ?? double.infinity;
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'price_desc':
        filteredItems.sort((a, b) {
          final aPrice = a.price ?? 0;
          final bPrice = b.price ?? 0;
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'title_asc':
        filteredItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return filteredItems;
  }

  String _getScreenTitle() {
    if (widget.collectionId != null) {
      final collection = context.read<CollectionProvider>().getCollectionById(widget.collectionId!);
      return collection?.name ?? 'Collection';
    }
    return 'My Items';
  }

  void _toggleSearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _searchQuery = ' '; // Trigger search bar to show
      } else {
        _searchQuery = '';
      }
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'view_toggle':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('View toggle coming soon!')),
        );
        break;
      case 'sort':
        _showSortBottomSheet();
        break;
    }
  }

  void _showSortBottomSheet() {
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSortOption('Recently Added', 'created_desc'),
              _buildSortOption('Oldest First', 'created_asc'),
              _buildSortOption('Price: Low to High', 'price_asc'),
              _buildSortOption('Price: High to Low', 'price_desc'),
              _buildSortOption('Alphabetical', 'title_asc'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: _sortBy == value ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showItemOptions(BuildContext context, WishItem item) {
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
                leading: const Icon(Icons.visibility),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  context.goToItemDetail(item.id, item: item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  context.goToEditItem(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
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

  void _showDeleteConfirmation(BuildContext context, WishItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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