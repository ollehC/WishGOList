import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlUtils {
  // Common shopping domains for better URL recognition
  static const Set<String> _shoppingDomains = {
    'amazon.com', 'amazon.co.uk', 'amazon.de', 'amazon.fr', 'amazon.ca', 'amazon.au', 'amazon.jp',
    'ebay.com', 'etsy.com', 'shopify.com', 'alibaba.com', 'aliexpress.com',
    'target.com', 'walmart.com', 'bestbuy.com', 'homedepot.com',
    'zalando.com', 'asos.com', 'hm.com', 'zara.com', 'uniqlo.com',
    'taobao.com', 'tmall.com', 'jd.com', 'pinduoduo.com',
    'rakuten.com', 'mercari.com', 'yahoo.co.jp',
    'shopee.com', 'lazada.com', 'qoo10.com',
    'hktvmall.com', 'fortress.com.hk', 'pccw.com', 'price.com.hk',
  };

  // File extensions that shouldn't be processed as product URLs
  static const Set<String> _excludedExtensions = {
    '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg',
    '.mp3', '.mp4', '.wav', '.avi', '.mov', '.mkv', '.flv',
    '.zip', '.rar', '.7z', '.tar', '.gz',
    '.exe', '.msi', '.dmg', '.pkg', '.deb', '.rpm',
    '.txt', '.log', '.xml', '.json', '.csv',
  };

  /// Validate if a string is a valid URL
  static bool isValidUrl(String input) {
    if (input.isEmpty) return false;
    
    try {
      final uri = Uri.parse(input);
      return uri.hasScheme && 
             uri.hasAuthority && 
             ['http', 'https'].contains(uri.scheme.toLowerCase()) &&
             uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Normalize and clean a URL
  static String? normalizeUrl(String input) {
    if (input.isEmpty) return null;
    
    String url = input.trim();
    
    // Add protocol if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Try to detect if it looks like a domain
      if (url.contains('.') && !url.contains(' ')) {
        url = 'https://$url';
      } else {
        return null;
      }
    }
    
    try {
      final uri = Uri.parse(url);
      
      // Validate the URI
      if (!uri.hasScheme || !uri.hasAuthority || uri.host.isEmpty) {
        return null;
      }
      
      // Convert HTTP to HTTPS for better security (with some exceptions)
      String scheme = uri.scheme.toLowerCase();
      if (scheme == 'http' && _shouldUseHttps(uri.host)) {
        scheme = 'https';
      }
      
      // Rebuild the URI with cleaned components
      final normalizedUri = Uri(
        scheme: scheme,
        host: uri.host.toLowerCase(),
        port: uri.hasPort ? uri.port : null,
        path: uri.path.isEmpty ? null : uri.path,
        query: uri.query.isEmpty ? null : uri.query,
        fragment: null, // Remove fragments for cleaner URLs
      );
      
      return normalizedUri.toString();
    } catch (e) {
      debugPrint('Error normalizing URL: $input, Error: $e');
      return null;
    }
  }

  /// Check if a URL is likely a product/shopping URL
  static bool isShoppingUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      
      // Check against known shopping domains
      if (_shoppingDomains.any((domain) => host.contains(domain))) {
        return true;
      }
      
      // Check URL path for shopping-related keywords
      final path = uri.path.toLowerCase();
      final shoppingKeywords = [
        '/product/', '/item/', '/shop/', '/store/', '/buy/', '/purchase/',
        '/goods/', '/merchandise/', '/catalog/', '/collection/',
        '/p/', '/dp/', '/products/', '/items/',
      ];
      
      if (shoppingKeywords.any((keyword) => path.contains(keyword))) {
        return true;
      }
      
      // Check query parameters for product indicators
      final query = uri.query.toLowerCase();
      final productParams = ['productid', 'itemid', 'pid', 'id', 'sku'];
      
      if (productParams.any((param) => query.contains(param))) {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if URL should be processed for metadata extraction
  static bool shouldProcessForMetadata(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Check if it's a valid HTTP/HTTPS URL
      if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
        return false;
      }
      
      // Check if it's not a direct file download
      final path = uri.path.toLowerCase();
      if (_excludedExtensions.any((ext) => path.endsWith(ext))) {
        return false;
      }
      
      // Check if it's not an image or media URL
      if (_isDirectMediaUrl(path)) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract domain name from URL
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Extract clean domain name for display
  static String extractDisplayDomain(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host.toLowerCase();
      
      // Remove 'www.' prefix
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }
      
      // Remove 'm.' mobile prefix
      if (host.startsWith('m.')) {
        host = host.substring(2);
      }
      
      return host;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Clean tracking parameters from URL
  static String cleanTrackingParams(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Common tracking parameters to remove
      const trackingParams = {
        // Google Analytics
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
        'gclid', 'gclsrc', 'dclid', 'fbclid',
        
        // Amazon
        'tag', 'linkCode', 'linkId', 'ref_', 'ref', 'pf_rd_p', 'pf_rd_r',
        'pd_rd_i', 'pd_rd_r', 'pd_rd_w', 'pd_rd_wg',
        
        // Other common tracking
        'mc_cid', 'mc_eid', '_openstat', 'yclid', 'hash', 'from',
        'utm_id', 'utm_source_platform', 'utm_creative_format',
        'utm_marketing_tactic', 'igshid', 'fs', 'clickid',
      };
      
      // Parse existing query parameters
      final queryParams = Map<String, String>.from(uri.queryParameters);
      
      // Remove tracking parameters
      for (final param in trackingParams) {
        queryParams.remove(param);
      }
      
      // Also remove parameters that start with utm_ or start with _
      queryParams.removeWhere((key, value) => 
          key.startsWith('utm_') || 
          key.startsWith('_') ||
          key.startsWith('fbclid') ||
          key.startsWith('gclid'));
      
      // Rebuild URI
      final cleanUri = uri.replace(queryParameters: queryParams.isEmpty ? {} : queryParams);
      
      return cleanUri.toString();
    } catch (e) {
      return url;
    }
  }

  /// Shorten URL for display purposes
  static String shortenUrl(String url, {int maxLength = 50}) {
    if (url.length <= maxLength) return url;
    
    try {
      final uri = Uri.parse(url);
      String shortened = '${uri.host}${uri.path}';
      
      if (shortened.length > maxLength) {
        shortened = '${shortened.substring(0, maxLength - 3)}...';
      }
      
      return shortened;
    } catch (e) {
      return url.length > maxLength 
          ? '${url.substring(0, maxLength - 3)}...'
          : url;
    }
  }

  /// Check if URL points to a mobile version and convert to desktop
  static String convertToDesktopUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;
      
      // Convert mobile domains to desktop versions
      final mobileToDeskTop = {
        'm.amazon.com': 'amazon.com',
        'm.ebay.com': 'ebay.com',
        'm.etsy.com': 'etsy.com',
        'm.alibaba.com': 'alibaba.com',
        'm.aliexpress.com': 'aliexpress.com',
        'mobile.twitter.com': 'twitter.com',
        'm.facebook.com': 'facebook.com',
        'm.youtube.com': 'youtube.com',
        'm.taobao.com': 'taobao.com',
        'm.tmall.com': 'tmall.com',
        'm.jd.com': 'jd.com',
      };
      
      if (mobileToDeskTop.containsKey(host.toLowerCase())) {
        host = mobileToDeskTop[host.toLowerCase()]!;
        return uri.replace(host: host).toString();
      }
      
      return url;
    } catch (e) {
      return url;
    }
  }

  /// Validate URL accessibility (basic check)
  static Future<bool> isUrlAccessible(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse(url);
      final request = await client.headUrl(uri);
      request.headers.set('User-Agent', 'WishGO-List/1.0.0');
      
      final response = await request.close();
      final isAccessible = response.statusCode >= 200 && response.statusCode < 400;
      
      client.close();
      return isAccessible;
    } catch (e) {
      debugPrint('URL accessibility check failed for $url: $e');
      return false;
    }
  }

  /// Get URL suggestions based on input
  static List<String> getUrlSuggestions(String input) {
    if (input.isEmpty) return [];
    
    final suggestions = <String>[];
    
    // If input looks like a domain, suggest with protocols
    if (input.contains('.') && !input.contains(' ')) {
      if (!input.startsWith('http://') && !input.startsWith('https://')) {
        suggestions.add('https://$input');
        suggestions.add('http://$input');
      }
      
      // Add www variant
      if (!input.startsWith('www.')) {
        suggestions.add('https://www.$input');
      }
    }
    
    return suggestions;
  }

  // Private helper methods
  
  static bool _shouldUseHttps(String host) {
    // Most modern sites support HTTPS, but some local/development sites might not
    const httpOnlyDomains = {
      'localhost',
      '127.0.0.1',
      '0.0.0.0',
    };
    
    return !httpOnlyDomains.contains(host.toLowerCase()) && 
           !host.endsWith('.local') &&
           !_isPrivateIp(host);
  }

  static bool _isPrivateIp(String host) {
    try {
      final ip = InternetAddress.tryParse(host);
      if (ip == null) return false;
      
      // Check for private IP ranges
      final bytes = ip.rawAddress;
      if (bytes.length == 4) {
        // IPv4 private ranges
        return (bytes[0] == 10) ||
               (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
               (bytes[0] == 192 && bytes[1] == 168);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool _isDirectMediaUrl(String path) {
    const mediaExtensions = {
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.ico',
      '.mp3', '.mp4', '.wav', '.avi', '.mov', '.mkv', '.flv', '.webm',
      '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
    };
    
    return mediaExtensions.any((ext) => path.endsWith(ext));
  }
}