import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  final String id;
  final String name;
  final int? color; // Color value as int
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;

  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  Tag copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}