import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'api_service.dart';
import '../../models/opengraph_metadata.dart';

class OpenGraphService {
  final ApiService _apiService;
  
  static const Duration _timeout = Duration(seconds: 15);
  
  // Cache to avoid repeated requests for the same URL
  final Map<String, OpenGraphMetadata> _cache = {};
  
  OpenGraphService(this._apiService);

  /// Extract metadata from a URL using multiple fallback methods
  Future<OpenGraphMetadata> extractMetadata(String url) async {
    try {
      // Check cache first
      if (_cache.containsKey(url)) {
        debugPrint('📋 Using cached metadata for: $url');
        return _cache[url]!;
      }

      debugPrint('🔍 Extracting metadata from: $url');
      
      // Method 1: Try metadata_fetch package (primary)
      try {
        final metadata = await MetadataFetch.extract(url).timeout(_timeout);
        if (metadata != null) {
          final result = _convertToOpenGraphMetadata(metadata, url);
          _cache[url] = result;
          debugPrint('✅ Metadata extracted successfully from: $url');
          return result;
        }
      } catch (e) {
        debugPrint('⚠️ metadata_fetch failed for $url: $e');
      }

      // Method 2: Try custom HTML parsing (fallback)
      try {
        final result = await _extractMetadataCustom(url);
        _cache[url] = result;
        debugPrint('✅ Custom metadata extraction successful for: $url');
        return result;
      } catch (e) {
        debugPrint('⚠️ Custom extraction failed for $url: $e');
      }

      // Method 3: Basic URL analysis (last resort)
      final result = _extractBasicMetadata(url);
      _cache[url] = result;
      debugPrint('ℹ️ Using basic metadata for: $url');
      return result;

    } catch (e) {
      debugPrint('❌ All metadata extraction methods failed for $url: $e');
      final result = _extractBasicMetadata(url);
      _cache[url] = result;
      return result;
    }
  }

  /// Convert metadata_fetch result to our OpenGraphMetadata model
  OpenGraphMetadata _convertToOpenGraphMetadata(Metadata metadata, String url) {
    return OpenGraphMetadata(
      url: url,
      title: _cleanText(metadata.title),
      description: _cleanText(metadata.description),
      imageUrl: _processImageUrl(metadata.image, url),
      siteName: _cleanText(metadata.siteName),
      type: metadata.type,
      author: metadata.author,
      publishedTime: metadata.publishedTime,
      keywords: metadata.keywords,
      price: _extractPrice(metadata.description),
      currency: _extractCurrency(metadata.description),
    );
  }

  /// Custom HTML parsing method as fallback
  Future<OpenGraphMetadata> _extractMetadataCustom(String url) async {
    final response = await _apiService.get<String>(
      url,
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; WishGO-List/1.0.0; +https://wishgo.app)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception('Failed to fetch HTML content');
    }

    final html = response.data!;
    return _parseHtmlMetadata(html, url);
  }

  /// Parse HTML content for OpenGraph and meta tags
  OpenGraphMetadata _parseHtmlMetadata(String html, String url) {
    final metadata = OpenGraphMetadata(url: url);
    
    // OpenGraph tags
    final ogTitle = _extractMetaContent(html, 'property', 'og:title');
    final ogDescription = _extractMetaContent(html, 'property', 'og:description');
    final ogImage = _extractMetaContent(html, 'property', 'og:image');
    final ogSiteName = _extractMetaContent(html, 'property', 'og:site_name');
    final ogType = _extractMetaContent(html, 'property', 'og:type');
    
    // Twitter Card tags (fallback)
    final twitterTitle = _extractMetaContent(html, 'name', 'twitter:title');
    final twitterDescription = _extractMetaContent(html, 'name', 'twitter:description');
    final twitterImage = _extractMetaContent(html, 'name', 'twitter:image');
    
    // Standard meta tags (fallback)
    final metaDescription = _extractMetaContent(html, 'name', 'description');
    final metaKeywords = _extractMetaContent(html, 'name', 'keywords');
    final metaAuthor = _extractMetaContent(html, 'name', 'author');
    
    // HTML title tag
    final titleMatch = RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false).firstMatch(html);
    final htmlTitle = titleMatch?.group(1)?.trim();

    return metadata.copyWith(
      title: _cleanText(ogTitle ?? twitterTitle ?? htmlTitle),
      description: _cleanText(ogDescription ?? twitterDescription ?? metaDescription),
      imageUrl: _processImageUrl(ogImage ?? twitterImage, url),
      siteName: _cleanText(ogSiteName ?? _extractDomainName(url)),
      type: ogType,
      author: _cleanText(metaAuthor),
      keywords: metaKeywords?.split(',').map((k) => k.trim()).toList(),
      price: _extractPriceFromHtml(html),
      currency: _extractCurrencyFromHtml(html),
    );
  }

  /// Extract meta tag content by attribute
  String? _extractMetaContent(String html, String attribute, String value) {
    final pattern = RegExp(
      '<meta\\s+$attribute=["\']$value["\']\\s+content=["\']([^"\']+)["\'][^>]*>',
      caseSensitive: false,
    );
    
    final match = pattern.firstMatch(html);
    return match?.group(1)?.trim();
  }

  /// Create basic metadata from URL when other methods fail
  OpenGraphMetadata _extractBasicMetadata(String url) {
    final uri = Uri.tryParse(url);
    final domain = uri?.host ?? 'Unknown Site';
    final title = _generateTitleFromUrl(url);
    
    return OpenGraphMetadata(
      url: url,
      title: title,
      siteName: domain,
      description: 'Item from $domain',
    );
  }

  /// Generate a reasonable title from URL
  String _generateTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      
      if (path.isNotEmpty) {
        // Remove file extensions and clean up
        String title = path.replaceAll(RegExp(r'\.[^.]+$'), '');
        title = title.replaceAll(RegExp(r'[-_]'), ' ');
        title = title.split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
        ).join(' ');
        
        return title.isNotEmpty ? title : uri.host;
      }
      
      return uri.host;
    } catch (e) {
      return 'Unknown Item';
    }
  }

  /// Process image URL to ensure it's absolute
  String? _processImageUrl(String? imageUrl, String baseUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // If already absolute URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Convert relative URL to absolute
    try {
      final baseUri = Uri.parse(baseUrl);
      final imageUri = baseUri.resolve(imageUrl);
      return imageUri.toString();
    } catch (e) {
      debugPrint('⚠️ Failed to process image URL: $imageUrl');
      return null;
    }
  }

  /// Extract domain name from URL
  String _extractDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'Unknown Site';
    }
  }

  /// Clean and normalize text content
  String? _cleanText(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Remove extra whitespace and decode HTML entities
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Basic HTML entity decoding
    cleaned = cleaned
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
    
    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// Extract price information from text
  double? _extractPrice(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Common price patterns
    final patterns = [
      RegExp(r'[\$¥€£]\s*(\d+(?:[,\.]\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'(\d+(?:[,\.]\d+)*(?:\.\d{2})?)\s*[\$¥€£]', caseSensitive: false),
      RegExp(r'price[:\s]*[\$¥€£]?\s*(\d+(?:[,\.]\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'HKD?\s*(\d+(?:[,\.]\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final priceStr = match.group(1)?.replaceAll(',', '');
        return double.tryParse(priceStr ?? '');
      }
    }
    
    return null;
  }

  /// Extract currency information from text
  String? _extractCurrency(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Currency symbols and codes
    final currencyPatterns = {
      RegExp(r'\$', caseSensitive: false): 'USD',
      RegExp(r'¥', caseSensitive: false): 'JPY',
      RegExp(r'€', caseSensitive: false): 'EUR',
      RegExp(r'£', caseSensitive: false): 'GBP',
      RegExp(r'HKD?', caseSensitive: false): 'HKD',
      RegExp(r'CNY', caseSensitive: false): 'CNY',
      RegExp(r'TWD', caseSensitive: false): 'TWD',
    };
    
    for (final entry in currencyPatterns.entries) {
      if (entry.key.hasMatch(text)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Extract price from HTML content using structured data
  double? _extractPriceFromHtml(String html) {
    // Try JSON-LD structured data first
    final jsonLdMatch = RegExp(r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>([^<]+)</script>', 
        caseSensitive: false).firstMatch(html);
    
    if (jsonLdMatch != null) {
      try {
        // This would need a JSON parser - simplified for now
        final jsonText = jsonLdMatch.group(1) ?? '';
        final priceMatch = RegExp(r'"price"[:\s]*"?(\d+(?:\.\d+)?)"?').firstMatch(jsonText);
        if (priceMatch != null) {
          return double.tryParse(priceMatch.group(1) ?? '');
        }
      } catch (e) {
        // Ignore JSON parsing errors
      }
    }
    
    // Fallback to meta tags and text content
    final pricePatterns = [
      RegExp(r'<meta[^>]*(?:property|name)=["\'](?:product:)?price["\'][^>]*content=["\']([^"\']+)["\'][^>]*>', caseSensitive: false),
      RegExp(r'class=["\'][^"\']*price[^"\']*["\'][^>]*>[\s\$€£¥]*(\d+(?:[,\.]\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in pricePatterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        final priceStr = match.group(1)?.replaceAll(',', '');
        final price = double.tryParse(priceStr ?? '');
        if (price != null) return price;
      }
    }
    
    return null;
  }

  /// Extract currency from HTML content
  String? _extractCurrencyFromHtml(String html) {
    final currencyMatch = RegExp(r'<meta[^>]*(?:property|name)=["\'](?:product:)?currency["\'][^>]*content=["\']([^"\']+)["\'][^>]*>', 
        caseSensitive: false).firstMatch(html);
    
    return currencyMatch?.group(1)?.toUpperCase();
  }

  /// Clear the metadata cache
  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ OpenGraph metadata cache cleared');
  }

  /// Get cache size for debugging
  int get cacheSize => _cache.length;

  /// Validate if a URL is likely to have useful metadata
  bool isValidMetadataUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Check if it's a valid HTTP/HTTPS URL
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
        return false;
      }
      
      // Check if it has a valid host
      if (!uri.hasAuthority || uri.host.isEmpty) {
        return false;
      }
      
      // Exclude direct file downloads that won't have metadata
      final path = uri.path.toLowerCase();
      final excludedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.zip', '.rar', '.exe', '.dmg'];
      
      for (final ext in excludedExtensions) {
        if (path.endsWith(ext)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}