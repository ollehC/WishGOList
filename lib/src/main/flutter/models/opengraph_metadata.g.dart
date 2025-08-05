// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opengraph_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenGraphMetadata _$OpenGraphMetadataFromJson(Map<String, dynamic> json) =>
    OpenGraphMetadata(
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      siteName: json['siteName'] as String?,
      type: json['type'] as String?,
      author: json['author'] as String?,
      publishedTime: json['publishedTime'] == null
          ? null
          : DateTime.parse(json['publishedTime'] as String),
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$OpenGraphMetadataToJson(OpenGraphMetadata instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'siteName': instance.siteName,
      'type': instance.type,
      'author': instance.author,
      'publishedTime': instance.publishedTime?.toIso8601String(),
      'keywords': instance.keywords,
      'price': instance.price,
      'currency': instance.currency,
    };