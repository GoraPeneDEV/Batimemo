import 'package:intl/intl.dart';

/// Utility class for parsing dates from API
class DateParser {
  /// Parse date in DD-MM-YYYY format (used for most API responses)
  static DateTime parseDate(String dateStr) {
    return DateFormat('dd-MM-yyyy').parse(dateStr);
  }

  /// Parse date in YYYY-MM-DD format (ISO format used by some endpoints)
  static DateTime parseApiDate(String dateStr) {
    return DateFormat('yyyy-MM-dd').parse(dateStr);
  }

  /// Parse datetime in DD-MM-YYYY hh:mm A format
  static DateTime parseDateTime(String dateTimeStr) {
    return DateFormat('dd-MM-yyyy hh:mm a').parse(dateTimeStr);
  }

  /// Format date to DD-MM-YYYY for display
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Format date to YYYY-MM-DD for API
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format datetime to DD-MM-YYYY hh:mm A for display
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }
}
