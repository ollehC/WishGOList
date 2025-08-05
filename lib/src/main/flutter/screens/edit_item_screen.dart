import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../core/providers/collection_provider.dart';
import '../core/providers/subscription_provider.dart';
import '../models/wish_item.dart';
import '../models/collection.dart';
import '../ui/theme/app_colors.dart';

class EditItemScreen extends StatefulWidget {
  final WishItem item;

  const EditItemScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Form controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;

  // Form state
  late String _selectedCurrency;
  Collection? _selectedCollection;
  late WishItemStatus _selectedStatus;
  List<String> _tags = [];
  int? _desireLevel;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description ?? '');
    _priceController = TextEditingController(text: widget.item.price?.toString() ?? '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _tagsController = TextEditingController(text: widget.item.tags.join(', '));

    // Add listeners to detect changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
    _tagsController.addListener(_onFieldChanged);
  }

  void _loadInitialData() {
    _selectedCurrency = widget.item.currency ?? 'HKD';
    _selectedStatus = widget.item.status;
    _tags = List.from(widget.item.tags);
    _desireLevel = widget.item.desireLevel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final collectionProvider = context.read<CollectionProvider>();
      _selectedCollection = collectionProvider.getCollectionById(widget.item.collectionId);
      setState(() {});
    });
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
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
        title: const Text('Edit Item'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Title',
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

              // Status
              DropdownButtonFormField<WishItemStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: WishItemStatus.values
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
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
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Collection selection
              Consumer<CollectionProvider>(
                builder: (context, collectionProvider, child) {
                  return DropdownButtonFormField<Collection>(
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
                        _hasChanges = true;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Desire level (Premium)
              Consumer<SubscriptionProvider>(
                builder: (context, subscriptionProvider, child) {
                  if (subscriptionProvider.canUseDesireLevels) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Desire Level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: AppColors.premiumGradient),
                                borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _desireLevel = _desireLevel == index + 1 ? null : index + 1;
                                    _hasChanges = true;
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
                            if (_desireLevel != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _desireLevel = null;
                                    _hasChanges = true;
                                  });
                                },
                                child: const Text('Clear'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Tags
              Consumer<SubscriptionProvider>(
                builder: (context, subscriptionProvider, child) {
                  return TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Tags (Optional)',
                      prefixIcon: const Icon(Icons.tag),
                      helperText: 'Max ${subscriptionProvider.maxTagsPerItem} tags',
                    ),
                    onChanged: (value) {
                      final tags = value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
                      if (tags.length <= subscriptionProvider.maxTagsPerItem) {
                        setState(() {
                          _tags = tags;
                          _hasChanges = true;
                        });
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Original URL (if exists)
              if (widget.item.productUrl != null) ...[
                TextFormField(
                  initialValue: widget.item.productUrl,
                  decoration: const InputDecoration(
                    labelText: 'Product URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                  readOnly: true,
                  style: const TextStyle(color: Colors.grey),
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
                      'Item Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Created', _formatDate(widget.item.createdAt)),
                    _buildInfoRow('Last Updated', _formatDate(widget.item.updatedAt)),
                    if (widget.item.sourceStore != null)
                      _buildInfoRow('Source Store', widget.item.sourceStore!),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveChanges() async {
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
      final updatedItem = widget.item.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        price: _priceController.text.isEmpty ? null : double.tryParse(_priceController.text),
        currency: _selectedCurrency,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        status: _selectedStatus,
        tags: _tags,
        collectionId: _selectedCollection!.id,
        desireLevel: _desireLevel,
        updatedAt: DateTime.now(),
      );

      await context.read<WishItemProvider>().updateWishItem(updatedItem);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Future<bool> onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }
}