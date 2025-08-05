import 'package:json_annotation/json_annotation.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final int? color; // Color value as int
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final int itemCount;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.itemCount = 0,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  factory Collection.defaultCollection() {
    final now = DateTime.now();
    return Collection(
      id: 'default',
      name: 'My Wishlist',
      description: 'Default collection for your wish items',
      iconName: 'heart',
      createdAt: now,
      updatedAt: now,
      isDefault: true,
    );
  }

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    int? itemCount,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}