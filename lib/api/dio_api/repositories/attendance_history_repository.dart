import '../base_repository.dart';
import '../../../models/attendance_history_model.dart';

/// Repository for attendance history related API calls
class AttendanceHistoryRepository extends BaseRepository {
  /// Get paginated attendance history with optional filters
  ///
  /// [skip] - Number of records to skip for pagination (default: 0)
  /// [take] - Number of records to fetch per page (default: 10)
  /// [startDate] - Filter from date (format: dd-MM-yyyy)
  /// [endDate] - Filter to date (format: dd-MM-yyyy)
  /// [status] - Filter by status: checked_in, checked_out, absent, leave, holiday
  Future<AttendanceHistoryResponse?> getHistory({
    int skip = 0,
    int take = 10,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (status != null) queryParams['status'] = status;

    return await safeApiCall(
      () => dioClient.get('attendance/getHistory', queryParameters: queryParams),
      parser: (data) {
        if (data['status'] == 'success' && data['data'] != null) {
          return AttendanceHistoryResponse.fromJson(data['data']);
        }
        return null;
      },
    );
  }

  /// Get attendance history for a specific date range
  Future<AttendanceHistoryResponse?> getHistoryByDateRange({
    required String startDate,
    required String endDate,
    int take = 31,
  }) async {
    return await getHistory(
      startDate: startDate,
      endDate: endDate,
      take: take,
    );
  }

  /// Get current month attendance history
  Future<AttendanceHistoryResponse?> getCurrentMonthHistory() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final startDate = _formatDate(firstDay);
    final endDate = _formatDate(lastDay);

    return await getHistoryByDateRange(
      startDate: startDate,
      endDate: endDate,
      take: 31,
    );
  }

  /// Get recent attendance history (last N days)
  Future<AttendanceHistoryResponse?> getRecentHistory({int days = 10}) async {
    return await getHistory(take: days);
  }

  /// Get attendance history filtered by status
  Future<AttendanceHistoryResponse?> getHistoryByStatus({
    required String status,
    int skip = 0,
    int take = 20,
  }) async {
    return await getHistory(
      status: status,
      skip: skip,
      take: take,
    );
  }

  /// Helper method to format date to dd-MM-yyyy
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
