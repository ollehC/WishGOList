// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

import '../utils/json_utils.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as String,
      wishItemId: json['wishItemId'] as String,
      orderNumber: json['orderNumber'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      carrier: json['carrier'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'HKD',
      status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
          OrderStatus.pending,
      orderDate: json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
      estimatedDelivery: json['estimatedDelivery'] == null
          ? null
          : DateTime.parse(json['estimatedDelivery'] as String),
      actualDelivery: json['actualDelivery'] == null
          ? null
          : DateTime.parse(json['actualDelivery'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'wishItemId': instance.wishItemId,
      'orderNumber': instance.orderNumber,
      'trackingNumber': instance.trackingNumber,
      'carrier': instance.carrier,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'orderDate': instance.orderDate?.toIso8601String(),
      'estimatedDelivery': instance.estimatedDelivery?.toIso8601String(),
      'actualDelivery': instance.actualDelivery?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};