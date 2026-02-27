// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PayrollStore on _PayrollStore, Store {
  Computed<bool>? _$hasNoModifiersComputed;

  @override
  bool get hasNoModifiers =>
      (_$hasNoModifiersComputed ??= Computed<bool>(() => super.hasNoModifiers,
              name: '_PayrollStore.hasNoModifiers'))
          .value;
  Computed<bool>? _$hasModifiersComputed;

  @override
  bool get hasModifiers =>
      (_$hasModifiersComputed ??= Computed<bool>(() => super.hasModifiers,
              name: '_PayrollStore.hasModifiers'))
          .value;
  Computed<bool>? _$hasNoPayslipsComputed;

  @override
  bool get hasNoPayslips =>
      (_$hasNoPayslipsComputed ??= Computed<bool>(() => super.hasNoPayslips,
              name: '_PayrollStore.hasNoPayslips'))
          .value;
  Computed<bool>? _$hasPayslipsComputed;

  @override
  bool get hasPayslips =>
      (_$hasPayslipsComputed ??= Computed<bool>(() => super.hasPayslips,
              name: '_PayrollStore.hasPayslips'))
          .value;
  Computed<PayslipModel?>? _$latestPayslipComputed;

  @override
  PayslipModel? get latestPayslip => (_$latestPayslipComputed ??=
          Computed<PayslipModel?>(() => super.latestPayslip,
              name: '_PayrollStore.latestPayslip'))
      .value;
  Computed<int>? _$loadedPayslipsCountComputed;

  @override
  int get loadedPayslipsCount => (_$loadedPayslipsCountComputed ??=
          Computed<int>(() => super.loadedPayslipsCount,
              name: '_PayrollStore.loadedPayslipsCount'))
      .value;
  Computed<bool>? _$allPayslipsLoadedComputed;

  @override
  bool get allPayslipsLoaded => (_$allPayslipsLoadedComputed ??= Computed<bool>(
          () => super.allPayslipsLoaded,
          name: '_PayrollStore.allPayslipsLoaded'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: '_PayrollStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isDownloadingPayslipAtom =
      Atom(name: '_PayrollStore.isDownloadingPayslip', context: context);

  @override
  bool get isDownloadingPayslip {
    _$isDownloadingPayslipAtom.reportRead();
    return super.isDownloadingPayslip;
  }

  @override
  set isDownloadingPayslip(bool value) {
    _$isDownloadingPayslipAtom.reportWrite(value, super.isDownloadingPayslip,
        () {
      super.isDownloadingPayslip = value;
    });
  }

  late final _$isRefreshingAtom =
      Atom(name: '_PayrollStore.isRefreshing', context: context);

  @override
  bool get isRefreshing {
    _$isRefreshingAtom.reportRead();
    return super.isRefreshing;
  }

  @override
  set isRefreshing(bool value) {
    _$isRefreshingAtom.reportWrite(value, super.isRefreshing, () {
      super.isRefreshing = value;
    });
  }

  late final _$payslipsAtom =
      Atom(name: '_PayrollStore.payslips', context: context);

  @override
  ObservableList<PayslipModel> get payslips {
    _$payslipsAtom.reportRead();
    return super.payslips;
  }

  @override
  set payslips(ObservableList<PayslipModel> value) {
    _$payslipsAtom.reportWrite(value, super.payslips, () {
      super.payslips = value;
    });
  }

  late final _$totalPayslipsCountAtom =
      Atom(name: '_PayrollStore.totalPayslipsCount', context: context);

  @override
  int get totalPayslipsCount {
    _$totalPayslipsCountAtom.reportRead();
    return super.totalPayslipsCount;
  }

  @override
  set totalPayslipsCount(int value) {
    _$totalPayslipsCountAtom.reportWrite(value, super.totalPayslipsCount, () {
      super.totalPayslipsCount = value;
    });
  }

  late final _$selectedPayslipAtom =
      Atom(name: '_PayrollStore.selectedPayslip', context: context);

  @override
  PayslipModel? get selectedPayslip {
    _$selectedPayslipAtom.reportRead();
    return super.selectedPayslip;
  }

  @override
  set selectedPayslip(PayslipModel? value) {
    _$selectedPayslipAtom.reportWrite(value, super.selectedPayslip, () {
      super.selectedPayslip = value;
    });
  }

  late final _$salaryStructureAtom =
      Atom(name: '_PayrollStore.salaryStructure', context: context);

  @override
  SalaryStructureModel? get salaryStructure {
    _$salaryStructureAtom.reportRead();
    return super.salaryStructure;
  }

  @override
  set salaryStructure(SalaryStructureModel? value) {
    _$salaryStructureAtom.reportWrite(value, super.salaryStructure, () {
      super.salaryStructure = value;
    });
  }

  late final _$payrollStatisticsAtom =
      Atom(name: '_PayrollStore.payrollStatistics', context: context);

  @override
  Map<String, dynamic>? get payrollStatistics {
    _$payrollStatisticsAtom.reportRead();
    return super.payrollStatistics;
  }

  @override
  set payrollStatistics(Map<String, dynamic>? value) {
    _$payrollStatisticsAtom.reportWrite(value, super.payrollStatistics, () {
      super.payrollStatistics = value;
    });
  }

  late final _$selectedYearAtom =
      Atom(name: '_PayrollStore.selectedYear', context: context);

  @override
  int? get selectedYear {
    _$selectedYearAtom.reportRead();
    return super.selectedYear;
  }

  @override
  set selectedYear(int? value) {
    _$selectedYearAtom.reportWrite(value, super.selectedYear, () {
      super.selectedYear = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: '_PayrollStore.selectedStatus', context: context);

  @override
  String? get selectedStatus {
    _$selectedStatusAtom.reportRead();
    return super.selectedStatus;
  }

  @override
  set selectedStatus(String? value) {
    _$selectedStatusAtom.reportWrite(value, super.selectedStatus, () {
      super.selectedStatus = value;
    });
  }

  late final _$errorAtom = Atom(name: '_PayrollStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$hasMoreAtom =
      Atom(name: '_PayrollStore.hasMore', context: context);

  @override
  bool get hasMore {
    _$hasMoreAtom.reportRead();
    return super.hasMore;
  }

  @override
  set hasMore(bool value) {
    _$hasMoreAtom.reportWrite(value, super.hasMore, () {
      super.hasMore = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_PayrollStore.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$modifiersAtom =
      Atom(name: '_PayrollStore.modifiers', context: context);

  @override
  ObservableList<ModifierRecord> get modifiers {
    _$modifiersAtom.reportRead();
    return super.modifiers;
  }

  @override
  set modifiers(ObservableList<ModifierRecord> value) {
    _$modifiersAtom.reportWrite(value, super.modifiers, () {
      super.modifiers = value;
    });
  }

  late final _$isLoadingModifiersAtom =
      Atom(name: '_PayrollStore.isLoadingModifiers', context: context);

  @override
  bool get isLoadingModifiers {
    _$isLoadingModifiersAtom.reportRead();
    return super.isLoadingModifiers;
  }

  @override
  set isLoadingModifiers(bool value) {
    _$isLoadingModifiersAtom.reportWrite(value, super.isLoadingModifiers, () {
      super.isLoadingModifiers = value;
    });
  }

  late final _$payrollRecordsAtom =
      Atom(name: '_PayrollStore.payrollRecords', context: context);

  @override
  ObservableList<PayrollRecordModel> get payrollRecords {
    _$payrollRecordsAtom.reportRead();
    return super.payrollRecords;
  }

  @override
  set payrollRecords(ObservableList<PayrollRecordModel> value) {
    _$payrollRecordsAtom.reportWrite(value, super.payrollRecords, () {
      super.payrollRecords = value;
    });
  }

  late final _$totalPayrollRecordsCountAtom =
      Atom(name: '_PayrollStore.totalPayrollRecordsCount', context: context);

  @override
  int get totalPayrollRecordsCount {
    _$totalPayrollRecordsCountAtom.reportRead();
    return super.totalPayrollRecordsCount;
  }

  @override
  set totalPayrollRecordsCount(int value) {
    _$totalPayrollRecordsCountAtom
        .reportWrite(value, super.totalPayrollRecordsCount, () {
      super.totalPayrollRecordsCount = value;
    });
  }

  late final _$selectedPayrollRecordAtom =
      Atom(name: '_PayrollStore.selectedPayrollRecord', context: context);

  @override
  PayrollRecordDetailModel? get selectedPayrollRecord {
    _$selectedPayrollRecordAtom.reportRead();
    return super.selectedPayrollRecord;
  }

  @override
  set selectedPayrollRecord(PayrollRecordDetailModel? value) {
    _$selectedPayrollRecordAtom.reportWrite(value, super.selectedPayrollRecord,
        () {
      super.selectedPayrollRecord = value;
    });
  }

  late final _$hasMorePayrollRecordsAtom =
      Atom(name: '_PayrollStore.hasMorePayrollRecords', context: context);

  @override
  bool get hasMorePayrollRecords {
    _$hasMorePayrollRecordsAtom.reportRead();
    return super.hasMorePayrollRecords;
  }

  @override
  set hasMorePayrollRecords(bool value) {
    _$hasMorePayrollRecordsAtom.reportWrite(value, super.hasMorePayrollRecords,
        () {
      super.hasMorePayrollRecords = value;
    });
  }

  late final _$currentPayrollRecordsPageAtom =
      Atom(name: '_PayrollStore.currentPayrollRecordsPage', context: context);

  @override
  int get currentPayrollRecordsPage {
    _$currentPayrollRecordsPageAtom.reportRead();
    return super.currentPayrollRecordsPage;
  }

  @override
  set currentPayrollRecordsPage(int value) {
    _$currentPayrollRecordsPageAtom
        .reportWrite(value, super.currentPayrollRecordsPage, () {
      super.currentPayrollRecordsPage = value;
    });
  }

  late final _$fetchPayslipsAsyncAction =
      AsyncAction('_PayrollStore.fetchPayslips', context: context);

  @override
  Future<void> fetchPayslips(
      {int skip = 0,
      int take = 20,
      int? year,
      String? status,
      bool loadMore = false}) {
    return _$fetchPayslipsAsyncAction.run(() => super.fetchPayslips(
        skip: skip,
        take: take,
        year: year,
        status: status,
        loadMore: loadMore));
  }

  late final _$fetchPayslipByIdAsyncAction =
      AsyncAction('_PayrollStore.fetchPayslipById', context: context);

  @override
  Future<void> fetchPayslipById(int id) {
    return _$fetchPayslipByIdAsyncAction.run(() => super.fetchPayslipById(id));
  }

  late final _$fetchSalaryStructureAsyncAction =
      AsyncAction('_PayrollStore.fetchSalaryStructure', context: context);

  @override
  Future<void> fetchSalaryStructure() {
    return _$fetchSalaryStructureAsyncAction
        .run(() => super.fetchSalaryStructure());
  }

  late final _$fetchPayrollStatisticsAsyncAction =
      AsyncAction('_PayrollStore.fetchPayrollStatistics', context: context);

  @override
  Future<void> fetchPayrollStatistics({int? year}) {
    return _$fetchPayrollStatisticsAsyncAction
        .run(() => super.fetchPayrollStatistics(year: year));
  }

  late final _$fetchModifiersAsyncAction =
      AsyncAction('_PayrollStore.fetchModifiers', context: context);

  @override
  Future<void> fetchModifiers() {
    return _$fetchModifiersAsyncAction.run(() => super.fetchModifiers());
  }

  late final _$downloadPayslipPdfAsyncAction =
      AsyncAction('_PayrollStore.downloadPayslipPdf', context: context);

  @override
  Future<String?> downloadPayslipPdf(int id) {
    return _$downloadPayslipPdfAsyncAction
        .run(() => super.downloadPayslipPdf(id));
  }

  late final _$refreshPayrollDataAsyncAction =
      AsyncAction('_PayrollStore.refreshPayrollData', context: context);

  @override
  Future<void> refreshPayrollData() {
    return _$refreshPayrollDataAsyncAction
        .run(() => super.refreshPayrollData());
  }

  late final _$loadMorePayslipsAsyncAction =
      AsyncAction('_PayrollStore.loadMorePayslips', context: context);

  @override
  Future<void> loadMorePayslips() {
    return _$loadMorePayslipsAsyncAction.run(() => super.loadMorePayslips());
  }

  late final _$fetchPayrollRecordsAsyncAction =
      AsyncAction('_PayrollStore.fetchPayrollRecords', context: context);

  @override
  Future<void> fetchPayrollRecords(
      {int page = 1,
      int perPage = 15,
      String? status,
      String? period,
      bool loadMore = false}) {
    return _$fetchPayrollRecordsAsyncAction.run(() => super.fetchPayrollRecords(
        page: page,
        perPage: perPage,
        status: status,
        period: period,
        loadMore: loadMore));
  }

  late final _$fetchPayrollRecordByIdAsyncAction =
      AsyncAction('_PayrollStore.fetchPayrollRecordById', context: context);

  @override
  Future<void> fetchPayrollRecordById(int id) {
    return _$fetchPayrollRecordByIdAsyncAction
        .run(() => super.fetchPayrollRecordById(id));
  }

  late final _$loadMorePayrollRecordsAsyncAction =
      AsyncAction('_PayrollStore.loadMorePayrollRecords', context: context);

  @override
  Future<void> loadMorePayrollRecords() {
    return _$loadMorePayrollRecordsAsyncAction
        .run(() => super.loadMorePayrollRecords());
  }

  late final _$refreshPayrollRecordsAsyncAction =
      AsyncAction('_PayrollStore.refreshPayrollRecords', context: context);

  @override
  Future<void> refreshPayrollRecords() {
    return _$refreshPayrollRecordsAsyncAction
        .run(() => super.refreshPayrollRecords());
  }

  late final _$_PayrollStoreActionController =
      ActionController(name: '_PayrollStore', context: context);

  @override
  void setSelectedPayslip(PayslipModel? payslip) {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.setSelectedPayslip');
    try {
      return super.setSelectedPayslip(payslip);
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setYearFilter(int? year) {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.setYearFilter');
    try {
      return super.setYearFilter(year);
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStatusFilter(String? status) {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.setStatusFilter');
    try {
      return super.setStatusFilter(status);
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearFilters() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedPayslip() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearSelectedPayslip');
    try {
      return super.clearSelectedPayslip();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAllData() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearAllData');
    try {
      return super.clearAllData();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetPagination() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.resetPagination');
    try {
      return super.resetPagination();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPayrollRecord(PayrollRecordDetailModel? record) {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.setSelectedPayrollRecord');
    try {
      return super.setSelectedPayrollRecord(record);
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedPayrollRecord() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearSelectedPayrollRecord');
    try {
      return super.clearSelectedPayrollRecord();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPayrollRecords() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.clearPayrollRecords');
    try {
      return super.clearPayrollRecords();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetPayrollRecordsPagination() {
    final _$actionInfo = _$_PayrollStoreActionController.startAction(
        name: '_PayrollStore.resetPayrollRecordsPagination');
    try {
      return super.resetPayrollRecordsPagination();
    } finally {
      _$_PayrollStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isDownloadingPayslip: ${isDownloadingPayslip},
isRefreshing: ${isRefreshing},
payslips: ${payslips},
totalPayslipsCount: ${totalPayslipsCount},
selectedPayslip: ${selectedPayslip},
salaryStructure: ${salaryStructure},
payrollStatistics: ${payrollStatistics},
selectedYear: ${selectedYear},
selectedStatus: ${selectedStatus},
error: ${error},
hasMore: ${hasMore},
currentPage: ${currentPage},
modifiers: ${modifiers},
isLoadingModifiers: ${isLoadingModifiers},
payrollRecords: ${payrollRecords},
totalPayrollRecordsCount: ${totalPayrollRecordsCount},
selectedPayrollRecord: ${selectedPayrollRecord},
hasMorePayrollRecords: ${hasMorePayrollRecords},
currentPayrollRecordsPage: ${currentPayrollRecordsPage},
hasNoModifiers: ${hasNoModifiers},
hasModifiers: ${hasModifiers},
hasNoPayslips: ${hasNoPayslips},
hasPayslips: ${hasPayslips},
latestPayslip: ${latestPayslip},
loadedPayslipsCount: ${loadedPayslipsCount},
allPayslipsLoaded: ${allPayslipsLoaded}
    ''';
  }
}
