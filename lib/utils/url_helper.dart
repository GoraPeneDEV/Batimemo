import '../api/api_routes.dart';

class UrlHelper {
  /// Constructs a full URL from a relative path
  /// If the URL already starts with http/https, returns it as-is
  /// Otherwise, prepends the base URL (without /api/V1/)
  static String getFullUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Get base URL without /api/V1/ suffix
    final baseURL = APIRoutes.baseURL.replaceAll('/api/V1/', '');

    // Ensure proper URL formatting
    if (url.startsWith('/')) {
      return '$baseURL$url';
    } else {
      return '$baseURL/$url';
    }
  }

  /// Gets the base URL for file storage (without /api/V1/)
  static String getStorageBaseUrl() {
    return APIRoutes.baseURL.replaceAll('/api/V1/', '');
  }
}
