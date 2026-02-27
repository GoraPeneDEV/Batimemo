import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/payslip_model.dart';
import '../../../models/payroll_record_model.dart';

/// Repository for payroll and payslip related API calls
///
/// This repository handles all payroll-related operations including:
/// - Payroll records management
/// - Salary structure information
/// - Payroll statistics
/// - Payslip viewing and downloading
/// - Salary adjustments
class PayrollRepository extends BaseRepository {
  // ===== Payroll Records =====

  /// Get paginated list of payroll records
  ///
  /// [page] - Page number (1-based indexing, default: 1)
  /// [perPage] - Number of records per page (default: 15)
  /// [status] - Filter by status: pending, processed, paid (optional)
  /// [period] - Filter by period string (optional)
  /// [fromDate] - Filter from date (optional)
  /// [toDate] - Filter to date (optional)
  ///
  /// Returns a Map containing:
  /// - totalCount: Total number of records
  /// - values: List of PayrollRecordModel objects
  /// - currentPage: Current page number
  /// - lastPage: Last page number
  Future<Map<String, dynamic>> getMyPayrollRecords({
    int page = 1,
    int perPage = 15,
    String? status,
    String? period,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) queryParams['status'] = status;
    if (period != null) queryParams['period'] = period;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    return await safeApiCall(
      () => dioClient.get('payroll/my-records', queryParameters: queryParams),
      parser: (data) {
        final records = (data['data']['records'] as List<dynamic>?)
                ?.map((item) => PayrollRecordModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];

        final pagination = data['data']['pagination'] as Map<String, dynamic>?;

        return {
          'totalCount': pagination?['total'] ?? 0,
          'values': records,
          'currentPage': pagination?['current_page'] ?? 1,
          'lastPage': pagination?['last_page'] ?? 1,
        };
      },
    );
  }

  /// Get single payroll record details
  ///
  /// [id] - Payroll record ID
  ///
  /// Returns PayrollRecordDetailModel with complete breakdown
  Future<PayrollRecordDetailModel?> getPayrollRecordDetails(int id) async {
    return await safeApiCall(
      () => dioClient.get('payroll/my-records/$id'),
      parser: (data) => PayrollRecordDetailModel.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  // ===== Salary Structure =====

  /// Get employee's salary structure
  ///
  /// Returns salary structure data including:
  /// - Basic salary
  /// - Allowances
  /// - Deductions
  /// - Tax information
  Future<Map<String, dynamic>?> getMySalaryStructure() async {
    return await safeApiCall(
      () => dioClient.get('payroll/my-salary-structure'),
      parser: (data) => data['data'] as Map<String, dynamic>,
    );
  }

  // ===== Payroll Statistics =====

  /// Get payroll statistics for the employee
  ///
  /// [year] - Filter by year (optional)
  ///
  /// Returns statistics including:
  /// - Total earnings
  /// - Total deductions
  /// - Net pay
  /// - Monthly breakdown
  Future<Map<String, dynamic>?> getMyPayrollStatistics({int? year}) async {
    return await safeApiCall(
      () => dioClient.get(
        'payroll/my-statistics',
        queryParameters: year != null ? {'year': year} : null,
      ),
      parser: (data) => data['data'] as Map<String, dynamic>,
    );
  }

  // ===== Payslips =====

  /// Get paginated list of payslips
  ///
  /// [skip] - Number of records to skip for pagination (default: 0)
  /// [take] - Number of records to fetch per page (default: 20)
  /// [year] - Filter by year (optional)
  /// [month] - Filter by month (optional)
  /// [status] - Filter by status (optional)
  ///
  /// Returns a Map containing:
  /// - totalCount: Total number of payslips
  /// - values: List of payslips (as dynamic maps)
  Future<Map<String, dynamic>> getMyPayslips({
    int skip = 0,
    int take = 20,
    int? year,
    int? month,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;
    if (status != null) queryParams['status'] = status;

    return await safeApiCall(
      () => dioClient.get('payroll/my-payslips', queryParameters: queryParams),
      parser: (data) {
        final values = (data['data']['payslips'] as List<dynamic>?)
                ?.map((item) => PayslipModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];

        final pagination = data['data']['pagination'] as Map<String, dynamic>?;

        return {
          'totalCount': pagination?['total'] ?? 0,
          'values': values,
        };
      },
    );
  }

  /// Get single payslip details
  ///
  /// [id] - Payslip ID
  ///
  /// Returns the payslip data including:
  /// - Earnings breakdown
  /// - Deductions breakdown
  /// - Net pay
  /// - Payment date
  Future<PayslipModel?> getPayslipDetails(int id) async {
    return await safeApiCall(
      () => dioClient.get('payroll/my-payslips/$id'),
      parser: (data) => PayslipModel.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  /// Download payslip as PDF
  ///
  /// [id] - Payslip ID
  /// [savePath] - Local file path where the PDF will be saved
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  /// [cancelToken] - Optional token to cancel the download
  ///
  /// Returns the response from the download operation
  ///
  /// Example:
  /// ```dart
  /// final savePath = '/storage/emulated/0/Download/payslip_${id}.pdf';
  /// await payrollRepository.downloadPayslip(
  ///   123,
  ///   savePath,
  ///   onProgress: (progress) => print('Download: ${(progress * 100).toStringAsFixed(0)}%'),
  /// );
  /// ```
  Future<Response> downloadPayslip(
    int id,
    String savePath, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    return await dioClient.downloadFile(
      'payroll/download-payslip/$id',
      savePath,
      onReceiveProgress: onProgress != null
          ? (received, total) {
              if (total != -1) {
                onProgress(received / total);
              }
            }
          : null,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  /// Get payslip PDF download URL
  ///
  /// [id] - Payslip ID
  ///
  /// Returns the URL string for the payslip PDF
  /// This can be used for opening the PDF in a web view or external app
  String getPayslipDownloadUrl(int id) {
    final baseUrl = dioClient.dio.options.baseUrl;
    return '${baseUrl}payroll/download-payslip/$id';
  }

  // ===== Salary Modifiers =====

  /// Get list of salary modifiers
  ///
  /// Returns a list of modifier records grouped by payroll period
  /// Each record contains earnings and deductions applied in that period
  ///
  /// Note: This endpoint returns ALL modifier records (not paginated)
  /// The backend returns modifiers grouped by payroll period
  ///
  /// Returns a List of ModifierRecord objects
  Future<List<dynamic>> getMyAdjustments() async {
    return await safeApiCall(
      () => dioClient.get('payroll/my-modifiers'),
      parser: (data) {
        // Backend returns an array of modifier records directly in data
        final records = data['data'] as List<dynamic>? ?? [];
        return records;
      },
    );
  }

  // ===== Utility Methods =====

  /// Get payslips for a specific month and year
  ///
  /// Convenience method to fetch payslips for a specific month
  Future<Map<String, dynamic>> getPayslipsForMonth({
    required int year,
    required int month,
  }) async {
    return await getMyPayslips(
      year: year,
      month: month,
      take: 10,
    );
  }

  /// Get current year's payslips
  ///
  /// Convenience method to fetch all payslips for current year
  Future<Map<String, dynamic>> getCurrentYearPayslips() async {
    final currentYear = DateTime.now().year;
    return await getMyPayslips(
      year: currentYear,
      take: 12,
    );
  }

  /// Get current month's payslip
  ///
  /// Convenience method to fetch payslip for current month
  Future<Map<String, dynamic>> getCurrentMonthPayslip() async {
    final now = DateTime.now();
    return await getPayslipsForMonth(
      year: now.year,
      month: now.month,
    );
  }

  // ===== Wrapper Methods for Store Compatibility =====

  /// Wrapper method for getMyPayslips (for store compatibility)
  Future<Map<String, dynamic>> getPayslips({
    int skip = 0,
    int take = 20,
    int? year,
    String? status,
  }) async {
    return await getMyPayslips(
      skip: skip,
      take: take,
      year: year,
      status: status,
    );
  }

  /// Wrapper method for getPayslipDetails (for store compatibility)
  Future<PayslipModel?> getPayslipById(int id) async {
    return await getPayslipDetails(id);
  }

  /// Wrapper method for getMySalaryStructure (for store compatibility)
  Future<Map<String, dynamic>?> getSalaryStructure() async {
    return await getMySalaryStructure();
  }

  /// Wrapper method for getMyPayrollStatistics (for store compatibility)
  Future<Map<String, dynamic>?> getPayrollStatistics({int? year}) async {
    return await getMyPayrollStatistics(year: year);
  }

  /// Wrapper method for downloadPayslip with simplified signature (for store compatibility)
  Future<String?> downloadPayslipPdf(int id) async {
    // This is a simplified version - actual implementation should handle file paths
    // For now, return null to indicate not implemented
    // TODO: Implement proper file download with path handling
    throw UnimplementedError('downloadPayslipPdf needs proper file path implementation');
  }

  /// Get payroll records for a specific month and year
  ///
  /// Convenience method to fetch payroll records for a specific month
  Future<Map<String, dynamic>> getPayrollRecordsForMonth({
    required int year,
    required int month,
  }) async {
    // Format period string as "MonthName Year" (e.g., "January 2024")
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final period = '${monthNames[month - 1]} $year';

    return await getMyPayrollRecords(
      period: period,
      perPage: 10,
    );
  }

}
