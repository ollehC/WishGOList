import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'user_preferences_provider.dart';
import '../../models/order.dart';
import '../../models/wish_item.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final UserPreferencesProvider _userPreferencesProvider;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrderProvider(this._databaseService, this._userPreferencesProvider) {
    _loadOrders();
  }

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get orders by status
  List<Order> get pendingOrders => 
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  
  List<Order> get shippedOrders => 
      _orders.where((o) => o.status == OrderStatus.shipped).toList();
  
  List<Order> get deliveredOrders => 
      _orders.where((o) => o.status == OrderStatus.delivered).toList();
  
  List<Order> get cancelledOrders => 
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  Future<void> _loadOrders() async {
    _setLoading(true);
    try {
      _orders = await _databaseService.getAllOrders();
      _clearError();
    } catch (e) {
      _setError('Failed to load orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      final createdOrder = await _databaseService.createOrder(order);
      _orders.add(createdOrder);
      _sortOrders();
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to create order: $e');
    }
  }

  Future<void> createOrderFromWishItem(WishItem wishItem, {
    String? orderNumber,
    String? trackingNumber,
    String? store,
    double? totalAmount,
    String? notes,
  }) async {
    try {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        wishItemId: wishItem.id,
        orderNumber: orderNumber ?? 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        trackingNumber: trackingNumber,
        carrier: store ?? wishItem.sourceStore ?? 'Unknown Store',
        totalAmount: totalAmount ?? wishItem.price ?? 0.0,
        currency: wishItem.currency ?? 'HKD',
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createOrder(order);
    } catch (e) {
      _setError('Failed to create order from wish item: $e');
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      final updatedOrder = await _databaseService.updateOrder(order);
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to update order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      final updatedOrder = order.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        actualDelivery: status == OrderStatus.delivered ? DateTime.now() : order.actualDelivery,
      );

      await updateOrder(updatedOrder);
    } catch (e) {
      _setError('Failed to update order status: $e');
    }
  }

  Future<void> updateTrackingNumber(String orderId, String trackingNumber) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      final updatedOrder = order.copyWith(
        trackingNumber: trackingNumber,
        updatedAt: DateTime.now(),
      );

      await updateOrder(updatedOrder);
    } catch (e) {
      _setError('Failed to update tracking number: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _databaseService.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      _clearError();
    } catch (e) {
      _setError('Failed to delete order: $e');
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Order> getOrdersByItemId(String itemId) {
    return _orders.where((o) => o.wishItemId == itemId).toList();
  }

  List<Order> getOrdersByCarrier(String carrier) {
    return _orders.where((o) => (o.carrier?.toLowerCase() ?? '').contains(carrier.toLowerCase())).toList();
  }

  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return (order.orderNumber?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (order.trackingNumber?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (order.carrier?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Order> getOrdersInDateRange(DateTime start, DateTime end) {
    return _orders.where((order) {
      return order.orderDate != null &&
             order.orderDate!.isAfter(start.subtract(const Duration(days: 1))) &&
             order.orderDate!.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalSpent({DateTime? startDate, DateTime? endDate}) {
    var ordersToCalculate = _orders.where((o) => 
        o.status != OrderStatus.cancelled && 
        o.status != OrderStatus.pending
    );

    if (startDate != null && endDate != null) {
      ordersToCalculate = ordersToCalculate.where((order) => 
          order.orderDate != null &&
          order.orderDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
          order.orderDate!.isBefore(endDate.add(const Duration(days: 1)))
      );
    }

    return ordersToCalculate.fold(0.0, (sum, order) => sum + (order.totalAmount ?? 0.0));
  }

  Map<String, double> getSpendingByStore({DateTime? startDate, DateTime? endDate}) {
    var ordersToCalculate = _orders.where((o) => 
        o.status != OrderStatus.cancelled && 
        o.status != OrderStatus.pending
    );

    if (startDate != null && endDate != null) {
      ordersToCalculate = ordersToCalculate.where((order) => 
          order.orderDate != null &&
          order.orderDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
          order.orderDate!.isBefore(endDate.add(const Duration(days: 1)))
      );
    }

    final spendingByCarrier = <String, double>{};
    for (final order in ordersToCalculate) {
      final carrier = order.carrier ?? 'Unknown';
      spendingByCarrier[carrier] = (spendingByCarrier[carrier] ?? 0) + (order.totalAmount ?? 0.0);
    }

    return spendingByCarrier;
  }

  Map<OrderStatus, int> getOrderStatusCounts() {
    final counts = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      counts[status] = _orders.where((o) => o.status == status).length;
    }
    return counts;
  }

  Future<void> markAsDelivered(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.delivered);
  }

  Future<void> markAsShipped(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.shipped);
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  void _sortOrders() {
    _orders.sort((a, b) {
      final dateA = a.orderDate ?? a.createdAt;
      final dateB = b.orderDate ?? b.createdAt;
      return dateB.compareTo(dateA);
    });
  }

  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}