import 'package:json_annotation/json_annotation.dart';

part 'wish_item.g.dart';

@JsonSerializable()
class WishItem {
  final String id;
  final String title;
  final String? description;
  final double? price;
  final String? currency;
  final String? imageUrl;
  final String? productUrl;
  final String? notes;
  final WishItemStatus status;
  final int? desireLevel; // 1-5 hearts (Premium feature)
  final List<String> tags;
  final String collectionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sourceStore;
  
  const WishItem({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.currency = 'HKD',
    this.imageUrl,
    this.productUrl,
    this.notes,
    this.status = WishItemStatus.toBuy,
    this.desireLevel,
    this.tags = const [],
    required this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    this.sourceStore,
  });

  factory WishItem.fromJson(Map<String, dynamic> json) => _$WishItemFromJson(json);
  Map<String, dynamic> toJson() => _$WishItemToJson(this);

  WishItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? imageUrl,
    String? productUrl,
    String? notes,
    WishItemStatus? status,
    int? desireLevel,
    List<String>? tags,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceStore,
  }) {
    return WishItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      productUrl: productUrl ?? this.productUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      desireLevel: desireLevel ?? this.desireLevel,
      tags: tags ?? this.tags,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceStore: sourceStore ?? this.sourceStore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum WishItemStatus {
  @JsonValue('to_buy')
  toBuy,
  @JsonValue('purchased')
  purchased,
  @JsonValue('dropped')
  dropped,
}

extension WishItemStatusExtension on WishItemStatus {
  String get displayName {
    switch (this) {
      case WishItemStatus.toBuy:
        return 'To Buy';
      case WishItemStatus.purchased:
        return 'Purchased';
      case WishItemStatus.dropped:
        return 'Dropped';
    }
  }

  String get value {
    switch (this) {
      case WishItemStatus.toBuy:
        return 'to_buy';
      case WishItemStatus.purchased:
        return 'purchased';
      case WishItemStatus.dropped:
        return 'dropped';
    }
  }
}