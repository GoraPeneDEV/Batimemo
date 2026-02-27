import 'package:mobx/mobx.dart';
import '../api/dio_api/repositories/payroll_repository.dart';
import '../api/dio_api/exceptions/api_exceptions.dart';
import '../models/payslip_model.dart';
import '../models/payroll_record_model.dart';
import '../models/salary_structure_model.dart';
import '../models/payroll/modifier_record.dart';

part 'payroll_store.g.dart';

/// PayrollStore - Comprehensive MobX store for Payroll state management
///
/// This store manages all payroll-related state including:
/// - Payroll records with pagination
/// - Payslip details and downloads
/// - Salary structure information
/// - Payroll statistics and analytics
/// - Loading states and error handling
///
/// Usage:
/// ```dart
/// final payrollStore = PayrollStore();
/// await payrollStore.fetchPayslips(year: 2024);
/// ```
class PayrollStore = _PayrollStore with _$PayrollStore;

abstract class _PayrollStore with Store {
  final PayrollRepository _repository = PayrollRepository();

  // ===== Observable States =====

  /// Global loading state for payroll operations
  @observable
  bool isLoading = false;

  /// Loading state specifically for downloading payslip PDFs
  @observable
  bool isDownloadingPayslip = false;

  /// Loading state for refreshing data
  @observable
  bool isRefreshing = false;

  /// List of payslip records
  @observable
  ObservableList<PayslipModel> payslips = ObservableList<PayslipModel>();

  /// Total count of payslip records (for pagination)
  @observable
  int totalPayslipsCount = 0;

  /// Currently selected/viewed payslip
  @observable
  PayslipModel? selectedPayslip;

  /// Salary structure details (breakdown of salary components)
  @observable
  SalaryStructureModel? salaryStructure;

  /// Payroll statistics (summary data, trends, etc.)
  @observable
  Map<String, dynamic>? payrollStatistics;

  /// Current year filter for payroll data
  @observable
  int? selectedYear;

  /// Current status filter (e.g., 'paid', 'pending', 'draft')
  @observable
  String? selectedStatus;

  /// Error message from API operations
  @observable
  String? error;

  /// Has more data to load (for infinite scroll pagination)
  @observable
  bool hasMore = true;

  /// Current page for pagination
  @observable
  int currentPage = 0;

  /// List of modifier records (payroll modifiers grouped by period)
  @observable
  ObservableList<ModifierRecord> modifiers = ObservableList<ModifierRecord>();

  /// Loading state for modifiers
  @observable
  bool isLoadingModifiers = false;

  // ===== Computed Values =====

  /// Returns true if there are no modifiers loaded
  @computed
  bool get hasNoModifiers => modifiers.isEmpty && !isLoadingModifiers;

  /// Returns true if modifiers are available
  @computed
  bool get hasModifiers => modifiers.isNotEmpty;

  /// Returns true if there are no payslips loaded
  @computed
  bool get hasNoPayslips => payslips.isEmpty && !isLoading;

  /// Returns true if payslips are available
  @computed
  bool get hasPayslips => payslips.isNotEmpty;

  /// Returns the latest payslip (most recent)
  @computed
  PayslipModel? get latestPayslip {
    if (payslips.isEmpty) return null;
    return payslips.first;
  }

  /// Returns count of loaded payslips
  @computed
  int get loadedPayslipsCount => payslips.length;

  /// Returns true if all payslips have been loaded
  @computed
  bool get allPayslipsLoaded => loadedPayslipsCount >= totalPayslipsCount;

  // ===== Actions =====

  /// Handles errors from API operations
  void _handleError(dynamic e) {
    if (e is ApiException) {
      error = e.message;
    } else {
      error = 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Fetches payslip records with optional filters and pagination
  ///
  /// Parameters:
  /// - [skip]: Number of records to skip (for pagination)
  /// - [take]: Number of records to fetch (default: 20)
  /// - [year]: Filter by specific year
  /// - [status]: Filter by status ('paid', 'pending', 'draft', etc.)
  /// - [loadMore]: If true, appends to existing list; otherwise replaces it
  ///
  /// Example:
  /// ```dart
  /// // Fetch first page
  /// await payrollStore.fetchPayslips();
  ///
  /// // Load more (pagination)
  /// await payrollStore.fetchPayslips(skip: 20, loadMore: true);
  ///
  /// // Filter by year
  /// await payrollStore.fetchPayslips(year: 2024);
  /// ```
  @action
  Future<void> fetchPayslips({
    int skip = 0,
    int take = 20,
    int? year,
    String? status,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading = true;
        currentPage = 0;
      }
      error = null;

      // Update filters
      if (year != null) selectedYear = year;
      if (status != null) selectedStatus = status;

      final result = await _repository.getPayslips(
        skip: skip,
        take: take,
        year: year ?? selectedYear,
        status: status ?? selectedStatus,
      );

      totalPayslipsCount = result['totalCount'];
      final payslipsList = (result['values'] as List).cast<PayslipModel>();

      if (loadMore) {
        payslips.addAll(payslipsList);
        currentPage++;
      } else {
        payslips = ObservableList.of(payslipsList);
        currentPage = 1;
      }

      // Update hasMore flag
      hasMore = payslips.length < totalPayslipsCount;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Fetches a single payslip by ID and sets it as selected
  ///
  /// Parameters:
  /// - [id]: The payslip ID to fetch
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.fetchPayslipById(123);
  /// final payslip = payrollStore.selectedPayslip;
  /// ```
  @action
  Future<void> fetchPayslipById(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedPayslip = await _repository.getPayslipById(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Fetches salary structure details for the current user
  ///
  /// Returns salary breakdown including:
  /// - Earnings (salary components that add to total)
  /// - Deductions (salary components that reduce total)
  /// - Component details (name, code, value, calculation type)
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.fetchSalaryStructure();
  /// final structure = payrollStore.salaryStructure;
  /// ```
  @action
  Future<void> fetchSalaryStructure() async {
    try {
      isLoading = true;
      error = null;
      final data = await _repository.getSalaryStructure();
      if (data != null) {
        salaryStructure = SalaryStructureModel.fromJson(data);
      } else {
        salaryStructure = null;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Fetches payroll statistics for analysis and reporting
  ///
  /// Parameters:
  /// - [year]: Optional year filter for statistics
  ///
  /// Returns statistics including:
  /// - Total paid amount
  /// - Average salary
  /// - Trends over time
  /// - Deduction summaries
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.fetchPayrollStatistics(year: 2024);
  /// final stats = payrollStore.payrollStatistics;
  /// ```
  @action
  Future<void> fetchPayrollStatistics({int? year}) async {
    try {
      isLoading = true;
      error = null;
      payrollStatistics = await _repository.getPayrollStatistics(
        year: year ?? selectedYear,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Fetches payroll modifiers for the employee
  ///
  /// Returns modifier records grouped by payroll period
  /// Each record contains earnings (benefits) and deductions
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.fetchModifiers();
  /// final modifiers = payrollStore.modifiers;
  /// ```
  @action
  Future<void> fetchModifiers() async {
    try {
      isLoadingModifiers = true;
      error = null;

      final records = await _repository.getMyAdjustments();

      // Parse the records into ModifierRecord objects
      modifiers = ObservableList.of(
        records.map((json) => ModifierRecord.fromJson(json as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingModifiers = false;
    }
  }

  /// Downloads payslip as PDF file
  ///
  /// Parameters:
  /// - [id]: The payslip ID to download
  ///
  /// Returns:
  /// - File path of downloaded PDF on success
  /// - null on failure
  ///
  /// Example:
  /// ```dart
  /// final filePath = await payrollStore.downloadPayslipPdf(123);
  /// if (filePath != null) {
  ///   // Open PDF file
  /// }
  /// ```
  @action
  Future<String?> downloadPayslipPdf(int id) async {
    try {
      isDownloadingPayslip = true;
      error = null;
      return await _repository.downloadPayslipPdf(id);
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      isDownloadingPayslip = false;
    }
  }

  /// Refreshes all payroll data (payslips, statistics, salary structure)
  ///
  /// This method is useful for pull-to-refresh functionality
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.refreshPayrollData();
  /// ```
  @action
  Future<void> refreshPayrollData() async {
    try {
      isRefreshing = true;
      error = null;

      // Refresh payslips
      await fetchPayslips();

      // Refresh statistics if previously loaded
      if (payrollStatistics != null) {
        await fetchPayrollStatistics();
      }

      // Refresh salary structure if previously loaded
      if (salaryStructure != null) {
        await fetchSalaryStructure();
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isRefreshing = false;
    }
  }

  /// Loads next page of payslips (for infinite scroll)
  ///
  /// Example:
  /// ```dart
  /// if (payrollStore.hasMore && !payrollStore.isLoading) {
  ///   await payrollStore.loadMorePayslips();
  /// }
  /// ```
  @action
  Future<void> loadMorePayslips() async {
    if (!hasMore || isLoading) return;

    await fetchPayslips(
      skip: payslips.length,
      loadMore: true,
    );
  }

  /// Sets the selected payslip
  ///
  /// Parameters:
  /// - [payslip]: The payslip to select
  ///
  /// Example:
  /// ```dart
  /// payrollStore.setSelectedPayslip(payslipModel);
  /// ```
  @action
  void setSelectedPayslip(PayslipModel? payslip) {
    selectedPayslip = payslip;
  }

  /// Sets the year filter
  ///
  /// Parameters:
  /// - [year]: The year to filter by
  ///
  /// Example:
  /// ```dart
  /// payrollStore.setYearFilter(2024);
  /// await payrollStore.fetchPayslips(); // Fetch with new filter
  /// ```
  @action
  void setYearFilter(int? year) {
    selectedYear = year;
  }

  /// Sets the status filter
  ///
  /// Parameters:
  /// - [status]: The status to filter by ('paid', 'pending', 'draft', etc.)
  ///
  /// Example:
  /// ```dart
  /// payrollStore.setStatusFilter('paid');
  /// await payrollStore.fetchPayslips(); // Fetch with new filter
  /// ```
  @action
  void setStatusFilter(String? status) {
    selectedStatus = status;
  }

  /// Clears all filters and resets to default state
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearFilters();
  /// await payrollStore.fetchPayslips(); // Fetch without filters
  /// ```
  @action
  void clearFilters() {
    selectedYear = null;
    selectedStatus = null;
  }

  /// Clears the error message
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearError();
  /// ```
  @action
  void clearError() {
    error = null;
  }

  /// Clears the selected payslip
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearSelectedPayslip();
  /// ```
  @action
  void clearSelectedPayslip() {
    selectedPayslip = null;
  }

  /// Clears all payroll data and resets to initial state
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearAllData();
  /// ```
  @action
  void clearAllData() {
    payslips.clear();
    modifiers.clear();
    selectedPayslip = null;
    salaryStructure = null;
    payrollStatistics = null;
    selectedYear = null;
    selectedStatus = null;
    totalPayslipsCount = 0;
    currentPage = 0;
    hasMore = true;
    error = null;
  }

  /// Resets pagination state
  ///
  /// Example:
  /// ```dart
  /// payrollStore.resetPagination();
  /// await payrollStore.fetchPayslips(); // Fetch from beginning
  /// ```
  @action
  void resetPagination() {
    currentPage = 0;
    hasMore = true;
  }

  // ===== Payroll Records Management =====

  /// List of payroll records
  @observable
  ObservableList<PayrollRecordModel> payrollRecords = ObservableList<PayrollRecordModel>();

  /// Total count of payroll records (for pagination)
  @observable
  int totalPayrollRecordsCount = 0;

  /// Currently selected/viewed payroll record detail
  @observable
  PayrollRecordDetailModel? selectedPayrollRecord;

  /// Has more payroll records to load (for infinite scroll pagination)
  @observable
  bool hasMorePayrollRecords = true;

  /// Current page for payroll records pagination
  @observable
  int currentPayrollRecordsPage = 1;

  /// Fetches payroll record records with optional filters and pagination
  ///
  /// Parameters:
  /// - [page]: Page number (1-based indexing)
  /// - [perPage]: Number of records to fetch (default: 15)
  /// - [status]: Filter by status ('pending', 'processed', 'paid', etc.)
  /// - [period]: Filter by period string
  /// - [loadMore]: If true, appends to existing list; otherwise replaces it
  ///
  /// Example:
  /// ```dart
  /// // Fetch first page
  /// await payrollStore.fetchPayrollRecords();
  ///
  /// // Load more (pagination)
  /// await payrollStore.fetchPayrollRecords(page: 2, loadMore: true);
  ///
  /// // Filter by status
  /// await payrollStore.fetchPayrollRecords(status: 'paid');
  /// ```
  @action
  Future<void> fetchPayrollRecords({
    int page = 1,
    int perPage = 15,
    String? status,
    String? period,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading = true;
        currentPayrollRecordsPage = 1;
      }
      error = null;

      final result = await _repository.getMyPayrollRecords(
        page: page,
        perPage: perPage,
        status: status,
        period: period,
      );

      totalPayrollRecordsCount = result['totalCount'];
      final recordsList = (result['values'] as List).cast<PayrollRecordModel>();
      final lastPage = result['lastPage'] as int;

      if (loadMore) {
        payrollRecords.addAll(recordsList);
        currentPayrollRecordsPage++;
      } else {
        payrollRecords = ObservableList.of(recordsList);
        currentPayrollRecordsPage = page;
      }

      // Update hasMore flag
      hasMorePayrollRecords = currentPayrollRecordsPage < lastPage;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Fetches a single payroll record by ID and sets it as selected
  ///
  /// Parameters:
  /// - [id]: The payroll record ID to fetch
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.fetchPayrollRecordById(123);
  /// final record = payrollStore.selectedPayrollRecord;
  /// ```
  @action
  Future<void> fetchPayrollRecordById(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedPayrollRecord = await _repository.getPayrollRecordDetails(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  /// Loads next page of payroll records (for infinite scroll)
  ///
  /// Example:
  /// ```dart
  /// if (payrollStore.hasMorePayrollRecords && !payrollStore.isLoading) {
  ///   await payrollStore.loadMorePayrollRecords();
  /// }
  /// ```
  @action
  Future<void> loadMorePayrollRecords() async {
    if (!hasMorePayrollRecords || isLoading) return;

    await fetchPayrollRecords(
      page: currentPayrollRecordsPage + 1,
      loadMore: true,
    );
  }

  /// Refreshes payroll records data
  ///
  /// This method is useful for pull-to-refresh functionality
  ///
  /// Example:
  /// ```dart
  /// await payrollStore.refreshPayrollRecords();
  /// ```
  @action
  Future<void> refreshPayrollRecords() async {
    try {
      isRefreshing = true;
      error = null;
      await fetchPayrollRecords();
    } catch (e) {
      _handleError(e);
    } finally {
      isRefreshing = false;
    }
  }

  /// Sets the selected payroll record
  ///
  /// Parameters:
  /// - [record]: The payroll record detail to select
  ///
  /// Example:
  /// ```dart
  /// payrollStore.setSelectedPayrollRecord(recordModel);
  /// ```
  @action
  void setSelectedPayrollRecord(PayrollRecordDetailModel? record) {
    selectedPayrollRecord = record;
  }

  /// Clears the selected payroll record
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearSelectedPayrollRecord();
  /// ```
  @action
  void clearSelectedPayrollRecord() {
    selectedPayrollRecord = null;
  }

  /// Clears all payroll records and resets to initial state
  ///
  /// Example:
  /// ```dart
  /// payrollStore.clearPayrollRecords();
  /// ```
  @action
  void clearPayrollRecords() {
    payrollRecords.clear();
    selectedPayrollRecord = null;
    totalPayrollRecordsCount = 0;
    currentPayrollRecordsPage = 1;
    hasMorePayrollRecords = true;
  }

  /// Resets payroll records pagination state
  ///
  /// Example:
  /// ```dart
  /// payrollStore.resetPayrollRecordsPagination();
  /// await payrollStore.fetchPayrollRecords(); // Fetch from beginning
  /// ```
  @action
  void resetPayrollRecordsPagination() {
    currentPayrollRecordsPage = 1;
    hasMorePayrollRecords = true;
  }
}
