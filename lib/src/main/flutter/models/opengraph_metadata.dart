import 'package:json_annotation/json_annotation.dart';

part 'opengraph_metadata.g.dart';

@JsonSerializable()
class OpenGraphMetadata {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
  final String? type;
  final String? author;
  final DateTime? publishedTime;
  final List<String>? keywords;
  final double? price;
  final String? currency;

  const OpenGraphMetadata({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
    this.type,
    this.author,
    this.publishedTime,
    this.keywords,
    this.price,
    this.currency,
  });

  factory OpenGraphMetadata.fromJson(Map<String, dynamic> json) => _$OpenGraphMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$OpenGraphMetadataToJson(this);

  OpenGraphMetadata copyWith({
    String? url,
    String? title,
    String? description,
    String? imageUrl,
    String? siteName,
    String? type,
    String? author,
    DateTime? publishedTime,
    List<String>? keywords,
    double? price,
    String? currency,
  }) {
    return OpenGraphMetadata(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      siteName: siteName ?? this.siteName,
      type: type ?? this.type,
      author: author ?? this.author,
      publishedTime: publishedTime ?? this.publishedTime,
      keywords: keywords ?? this.keywords,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  /// Check if the metadata has essential information
  bool get hasEssentialData {
    return title != null || description != null || imageUrl != null;
  }

  /// Get the best available title
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (siteName != null && siteName!.isNotEmpty) return 'Item from $siteName';
    return 'Untitled Item';
  }

  /// Get the best available description
  String get displayDescription {
    if (description != null && description!.isNotEmpty) return description!;
    if (siteName != null && siteName!.isNotEmpty) return 'From $siteName';
    return 'No description available';
  }

  /// Check if metadata includes price information
  bool get hasPriceInfo => price != null && price! > 0;

  /// Get formatted price string
  String? get formattedPrice {
    if (!hasPriceInfo) return null;
    final currencySymbol = _getCurrencySymbol(currency ?? 'USD');
    return '$currencySymbol${price!.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'HKD':
        return 'HK\$';
      case 'TWD':
        return 'NT\$';
      default:
        return '$currencyCode ';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenGraphMetadata &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() {
    return 'OpenGraphMetadata(url: $url, title: $title, siteName: $siteName, hasImage: ${imageUrl != null}, hasPrice: $hasPriceInfo)';
  }
}