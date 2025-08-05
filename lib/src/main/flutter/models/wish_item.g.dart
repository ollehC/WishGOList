// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_item.dart';

import '../utils/json_utils.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishItem _$WishItemFromJson(Map<String, dynamic> json) => WishItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'HKD',
      imageUrl: json['imageUrl'] as String?,
      productUrl: json['productUrl'] as String?,
      notes: json['notes'] as String?,
      status: $enumDecodeNullable(_$WishItemStatusEnumMap, json['status']) ??
          WishItemStatus.toBuy,
      desireLevel: json['desireLevel'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      collectionId: json['collectionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sourceStore: json['sourceStore'] as String?,
    );

Map<String, dynamic> _$WishItemToJson(WishItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'imageUrl': instance.imageUrl,
      'productUrl': instance.productUrl,
      'notes': instance.notes,
      'status': _$WishItemStatusEnumMap[instance.status]!,
      'desireLevel': instance.desireLevel,
      'tags': instance.tags,
      'collectionId': instance.collectionId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sourceStore': instance.sourceStore,
    };

const _$WishItemStatusEnumMap = {
  WishItemStatus.toBuy: 'to_buy',
  WishItemStatus.purchased: 'purchased',
  WishItemStatus.dropped: 'dropped',
};