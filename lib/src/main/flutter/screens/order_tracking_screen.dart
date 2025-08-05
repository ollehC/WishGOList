import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/order_provider.dart';
import '../core/providers/wish_item_provider.dart';
import '../models/order.dart';
import '../ui/theme/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? itemId;
  final Order? order;

  const OrderTrackingScreen({
    Key? key,
    this.itemId,
    this.order,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Active'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddOrderDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return _buildErrorState(orderProvider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllOrdersTab(orderProvider.orders),
              _buildActiveOrdersTab([
                ...orderProvider.pendingOrders,
                ...orderProvider.shippedOrders,
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllOrdersTab(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState(
        'No Orders Yet',
        'Your order tracking will appear here when you start making purchases.',
        Icons.local_shipping_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildActiveOrdersTab(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState(
        'No Active Orders',
        'Orders that are pending or shipped will appear here.',
        Icons.timer,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: order.itemImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order.itemImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.shopping_bag_outlined);
                              },
                            ),
                          )
                        : const Icon(Icons.shopping_bag_outlined),
                  ),
                  const SizedBox(width: 12),
                  
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.itemTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderNumber}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.store,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  _buildStatusBadge(order.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Price and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _formatDate(order.orderDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              // Progress indicator
              if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(order.status),
              ],
              
              // Tracking number
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Tracking: ${order.trackingNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'PENDING';
        break;
      case OrderStatus.shipped:
        color = Colors.blue;
        text = 'SHIPPED';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'DELIVERED';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(OrderStatus status) {
    final steps = [
      'Order Placed',
      'Processing',
      'Shipped',
      'Delivered',
    ];
    
    int currentStep = 0;
    switch (status) {
      case OrderStatus.pending:
        currentStep = 1;
        break;
      case OrderStatus.shipped:
        currentStep = 2;
        break;
      case OrderStatus.delivered:
        currentStep = 3;
        break;
      case OrderStatus.cancelled:
        currentStep = 0;
        break;
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep;
        final isLast = index == steps.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
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
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddOrderDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Order'),
            ),
          ],
        ),
      ),
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
              context.read<OrderProvider>().refreshOrders();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Order info
                  _buildDetailRow('Order Number', order.orderNumber),
                  _buildDetailRow('Item', order.itemTitle),
                  _buildDetailRow('Store', order.store),
                  _buildDetailRow('Status', order.status.toString().split('.').last.toUpperCase()),
                  _buildDetailRow('Total Amount', '${order.currency} ${order.totalAmount.toStringAsFixed(2)}'),
                  _buildDetailRow('Order Date', _formatDate(order.orderDate)),
                  
                  if (order.trackingNumber != null)
                    _buildDetailRow('Tracking Number', order.trackingNumber!),
                  
                  if (order.shippedDate != null)
                    _buildDetailRow('Shipped Date', _formatDate(order.shippedDate!)),
                  
                  if (order.deliveredDate != null)
                    _buildDetailRow('Delivered Date', _formatDate(order.deliveredDate!)),
                  
                  if (order.notes != null) ...[
                    const SizedBox(height: 16),
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
                      child: Text(order.notes!),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditOrderDialog(order);
                          },
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateOrderStatus(order);
                          },
                          child: Text(_getNextStatusText(order.status)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  String _getNextStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Mark as Shipped';
      case OrderStatus.shipped:
        return 'Mark as Delivered';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _updateOrderStatus(Order order) {
    OrderStatus nextStatus;
    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.shipped;
        break;
      case OrderStatus.shipped:
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return;
    }
    
    context.read<OrderProvider>().updateOrderStatus(order.id, nextStatus);
  }

  void _showAddOrderDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add order coming soon! For now, orders are created when you mark items as purchased.')),
    );
  }

  void _showEditOrderDialog(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit order coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}