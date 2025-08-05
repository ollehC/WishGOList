import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/collection_provider.dart';
import '../core/providers/tag_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../models/wish_item.dart';
import '../models/collection.dart';
import '../ui/theme/app_colors.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialUrl;
  final String? collectionId;

  const AddItemScreen({
    Key? key,
    this.initialUrl,
    this.collectionId,
  }) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  // Form state
  String _selectedCurrency = 'HKD';
  Collection? _selectedCollection;
  List<String> _tags = [];
  int? _desireLevel;
  bool _fetchingFromUrl = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final collectionProvider = context.read<CollectionProvider>();
      if (widget.collectionId != null) {
        _selectedCollection = collectionProvider.getCollectionById(widget.collectionId!);
      } else {
        _selectedCollection = collectionProvider.defaultCollection;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'From URL'),
            Tab(text: 'Manual'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUrlTab(),
            _buildManualTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL input
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Product URL',
              hintText: 'Paste the product URL here...',
              prefixIcon: const Icon(Icons.link),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _fetchFromUrl,
                      icon: _fetchingFromUrl 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a product URL';
              }
              if (!Uri.tryParse(value)?.hasAbsolutePath == true) {
                return 'Please enter a valid URL';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'How to add items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Copy the product URL from any shopping website\n'
                  '2. Paste it in the field above\n'
                  '3. Tap the download icon to fetch product details\n'
                  '4. Review and save your item',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Fetched content (if any)
          if (_titleController.text.isNotEmpty) ...[
            const Text(
              'Fetched Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildItemPreview(),
            const SizedBox(height: 16),
            _buildSharedFormFields(),
          ],
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Item Title',
              hintText: 'Enter the item name...',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an item title';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Describe the item...',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Price and currency
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (Optional)',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                  ),
                  items: ['HKD', 'USD', 'EUR', 'GBP', 'JPY', 'CNY']
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value ?? 'HKD';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSharedFormFields(),
        ],
      ),
    );
  }

  Widget _buildSharedFormFields() {
    return Consumer3<CollectionProvider, SubscriptionProvider, TagProvider>(
      builder: (context, collectionProvider, subscriptionProvider, tagProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collection selection
            DropdownButtonFormField<Collection>(
              value: _selectedCollection,
              decoration: const InputDecoration(
                labelText: 'Collection',
                prefixIcon: Icon(Icons.folder),
              ),
              items: collectionProvider.collections
                  .map((collection) => DropdownMenuItem(
                        value: collection,
                        child: Text(collection.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCollection = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Desire level (Premium)
            if (subscriptionProvider.canUseDesireLevels) ...[
              const Text(
                'Desire Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _desireLevel = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          _desireLevel != null && index < _desireLevel!
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _desireLevel != null && index < _desireLevel!
                              ? Colors.red
                              : Colors.grey,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                  Container(
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
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (Optional)',
                hintText: 'Enter tags separated by commas...',
                prefixIcon: const Icon(Icons.tag),
                helperText: 'Max ${subscriptionProvider.maxTagsPerItem} tags',
              ),
              onChanged: (value) {
                final tags = value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
                if (tags.length <= subscriptionProvider.maxTagsPerItem) {
                  setState(() {
                    _tags = tags;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any personal notes...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildItemPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titleController.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _descriptionController.text,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (_priceController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '$_selectedCurrency ${_priceController.text}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _fetchFromUrl() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _fetchingFromUrl = true;
    });

    try {
      // TODO: Implement actual URL fetching using OpenGraph service
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call
      
      // Mock data for demonstration
      _titleController.text = 'Sample Product Title';
      _descriptionController.text = 'This is a sample product description fetched from the URL.';
      _priceController.text = '299.99';
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product details fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch product details: $e')),
      );
    } finally {
      setState(() {
        _fetchingFromUrl = false;
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCollection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a collection')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final item = WishItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        price: _priceController.text.isEmpty ? null : double.tryParse(_priceController.text),
        currency: _selectedCurrency,
        productUrl: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        tags: _tags,
        collectionId: _selectedCollection!.id,
        desireLevel: _desireLevel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<WishItemProvider>().createWishItem(item);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}