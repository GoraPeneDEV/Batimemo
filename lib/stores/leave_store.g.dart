// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LeaveStore on _LeaveStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_LeaveStore.isLoading', context: context);

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

  late final _$leaveTypesAtom =
      Atom(name: '_LeaveStore.leaveTypes', context: context);

  @override
  ObservableList<LeaveType> get leaveTypes {
    _$leaveTypesAtom.reportRead();
    return super.leaveTypes;
  }

  @override
  set leaveTypes(ObservableList<LeaveType> value) {
    _$leaveTypesAtom.reportWrite(value, super.leaveTypes, () {
      super.leaveTypes = value;
    });
  }

  late final _$leaveBalanceSummaryAtom =
      Atom(name: '_LeaveStore.leaveBalanceSummary', context: context);

  @override
  LeaveBalanceSummary? get leaveBalanceSummary {
    _$leaveBalanceSummaryAtom.reportRead();
    return super.leaveBalanceSummary;
  }

  @override
  set leaveBalanceSummary(LeaveBalanceSummary? value) {
    _$leaveBalanceSummaryAtom.reportWrite(value, super.leaveBalanceSummary, () {
      super.leaveBalanceSummary = value;
    });
  }

  late final _$leaveRequestsAtom =
      Atom(name: '_LeaveStore.leaveRequests', context: context);

  @override
  ObservableList<LeaveRequest> get leaveRequests {
    _$leaveRequestsAtom.reportRead();
    return super.leaveRequests;
  }

  @override
  set leaveRequests(ObservableList<LeaveRequest> value) {
    _$leaveRequestsAtom.reportWrite(value, super.leaveRequests, () {
      super.leaveRequests = value;
    });
  }

  late final _$totalLeaveRequestsCountAtom =
      Atom(name: '_LeaveStore.totalLeaveRequestsCount', context: context);

  @override
  int get totalLeaveRequestsCount {
    _$totalLeaveRequestsCountAtom.reportRead();
    return super.totalLeaveRequestsCount;
  }

  @override
  set totalLeaveRequestsCount(int value) {
    _$totalLeaveRequestsCountAtom
        .reportWrite(value, super.totalLeaveRequestsCount, () {
      super.totalLeaveRequestsCount = value;
    });
  }

  late final _$selectedLeaveRequestAtom =
      Atom(name: '_LeaveStore.selectedLeaveRequest', context: context);

  @override
  LeaveRequest? get selectedLeaveRequest {
    _$selectedLeaveRequestAtom.reportRead();
    return super.selectedLeaveRequest;
  }

  @override
  set selectedLeaveRequest(LeaveRequest? value) {
    _$selectedLeaveRequestAtom.reportWrite(value, super.selectedLeaveRequest,
        () {
      super.selectedLeaveRequest = value;
    });
  }

  late final _$leaveStatisticsAtom =
      Atom(name: '_LeaveStore.leaveStatistics', context: context);

  @override
  LeaveStatistics? get leaveStatistics {
    _$leaveStatisticsAtom.reportRead();
    return super.leaveStatistics;
  }

  @override
  set leaveStatistics(LeaveStatistics? value) {
    _$leaveStatisticsAtom.reportWrite(value, super.leaveStatistics, () {
      super.leaveStatistics = value;
    });
  }

  late final _$teamCalendarAtom =
      Atom(name: '_LeaveStore.teamCalendar', context: context);

  @override
  TeamCalendar? get teamCalendar {
    _$teamCalendarAtom.reportRead();
    return super.teamCalendar;
  }

  @override
  set teamCalendar(TeamCalendar? value) {
    _$teamCalendarAtom.reportWrite(value, super.teamCalendar, () {
      super.teamCalendar = value;
    });
  }

  late final _$compensatoryOffsAtom =
      Atom(name: '_LeaveStore.compensatoryOffs', context: context);

  @override
  ObservableList<CompensatoryOff> get compensatoryOffs {
    _$compensatoryOffsAtom.reportRead();
    return super.compensatoryOffs;
  }

  @override
  set compensatoryOffs(ObservableList<CompensatoryOff> value) {
    _$compensatoryOffsAtom.reportWrite(value, super.compensatoryOffs, () {
      super.compensatoryOffs = value;
    });
  }

  late final _$totalCompOffsCountAtom =
      Atom(name: '_LeaveStore.totalCompOffsCount', context: context);

  @override
  int get totalCompOffsCount {
    _$totalCompOffsCountAtom.reportRead();
    return super.totalCompOffsCount;
  }

  @override
  set totalCompOffsCount(int value) {
    _$totalCompOffsCountAtom.reportWrite(value, super.totalCompOffsCount, () {
      super.totalCompOffsCount = value;
    });
  }

  late final _$selectedCompensatoryOffAtom =
      Atom(name: '_LeaveStore.selectedCompensatoryOff', context: context);

  @override
  CompensatoryOff? get selectedCompensatoryOff {
    _$selectedCompensatoryOffAtom.reportRead();
    return super.selectedCompensatoryOff;
  }

  @override
  set selectedCompensatoryOff(CompensatoryOff? value) {
    _$selectedCompensatoryOffAtom
        .reportWrite(value, super.selectedCompensatoryOff, () {
      super.selectedCompensatoryOff = value;
    });
  }

  late final _$compOffBalanceAtom =
      Atom(name: '_LeaveStore.compOffBalance', context: context);

  @override
  CompensatoryOffBalance? get compOffBalance {
    _$compOffBalanceAtom.reportRead();
    return super.compOffBalance;
  }

  @override
  set compOffBalance(CompensatoryOffBalance? value) {
    _$compOffBalanceAtom.reportWrite(value, super.compOffBalance, () {
      super.compOffBalance = value;
    });
  }

  late final _$compOffStatisticsAtom =
      Atom(name: '_LeaveStore.compOffStatistics', context: context);

  @override
  CompensatoryOffStatistics? get compOffStatistics {
    _$compOffStatisticsAtom.reportRead();
    return super.compOffStatistics;
  }

  @override
  set compOffStatistics(CompensatoryOffStatistics? value) {
    _$compOffStatisticsAtom.reportWrite(value, super.compOffStatistics, () {
      super.compOffStatistics = value;
    });
  }

  late final _$errorAtom = Atom(name: '_LeaveStore.error', context: context);

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

  late final _$fetchLeaveTypesAsyncAction =
      AsyncAction('_LeaveStore.fetchLeaveTypes', context: context);

  @override
  Future<void> fetchLeaveTypes() {
    return _$fetchLeaveTypesAsyncAction.run(() => super.fetchLeaveTypes());
  }

  late final _$fetchLeaveBalanceAsyncAction =
      AsyncAction('_LeaveStore.fetchLeaveBalance', context: context);

  @override
  Future<void> fetchLeaveBalance({int? year}) {
    return _$fetchLeaveBalanceAsyncAction
        .run(() => super.fetchLeaveBalance(year: year));
  }

  late final _$fetchLeaveRequestsAsyncAction =
      AsyncAction('_LeaveStore.fetchLeaveRequests', context: context);

  @override
  Future<void> fetchLeaveRequests(
      {int skip = 0,
      int take = 20,
      String? status,
      int? year,
      int? leaveTypeId,
      bool loadMore = false}) {
    return _$fetchLeaveRequestsAsyncAction.run(() => super.fetchLeaveRequests(
        skip: skip,
        take: take,
        status: status,
        year: year,
        leaveTypeId: leaveTypeId,
        loadMore: loadMore));
  }

  late final _$fetchLeaveRequestAsyncAction =
      AsyncAction('_LeaveStore.fetchLeaveRequest', context: context);

  @override
  Future<void> fetchLeaveRequest(int id) {
    return _$fetchLeaveRequestAsyncAction
        .run(() => super.fetchLeaveRequest(id));
  }

  late final _$createLeaveRequestAsyncAction =
      AsyncAction('_LeaveStore.createLeaveRequest', context: context);

  @override
  Future<bool> createLeaveRequest(
      {required int leaveTypeId,
      required String fromDate,
      required String toDate,
      required String userNotes,
      bool isHalfDay = false,
      String? halfDayType,
      String? emergencyContact,
      String? emergencyPhone,
      bool? isAbroad,
      String? abroadLocation,
      File? document,
      bool useCompOff = false,
      List<int>? compOffIds}) {
    return _$createLeaveRequestAsyncAction.run(() => super.createLeaveRequest(
        leaveTypeId: leaveTypeId,
        fromDate: fromDate,
        toDate: toDate,
        userNotes: userNotes,
        isHalfDay: isHalfDay,
        halfDayType: halfDayType,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        isAbroad: isAbroad,
        abroadLocation: abroadLocation,
        document: document,
        useCompOff: useCompOff,
        compOffIds: compOffIds));
  }

  late final _$updateLeaveRequestAsyncAction =
      AsyncAction('_LeaveStore.updateLeaveRequest', context: context);

  @override
  Future<bool> updateLeaveRequest(int id,
      {String? fromDate,
      String? toDate,
      String? userNotes,
      bool? isHalfDay,
      String? halfDayType,
      String? emergencyContact,
      String? emergencyPhone,
      bool? isAbroad,
      String? abroadLocation,
      File? document}) {
    return _$updateLeaveRequestAsyncAction.run(() => super.updateLeaveRequest(
        id,
        fromDate: fromDate,
        toDate: toDate,
        userNotes: userNotes,
        isHalfDay: isHalfDay,
        halfDayType: halfDayType,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        isAbroad: isAbroad,
        abroadLocation: abroadLocation,
        document: document));
  }

  late final _$cancelLeaveRequestAsyncAction =
      AsyncAction('_LeaveStore.cancelLeaveRequest', context: context);

  @override
  Future<bool> cancelLeaveRequest(int id, {String? reason}) {
    return _$cancelLeaveRequestAsyncAction
        .run(() => super.cancelLeaveRequest(id, reason: reason));
  }

  late final _$uploadLeaveDocumentAsyncAction =
      AsyncAction('_LeaveStore.uploadLeaveDocument', context: context);

  @override
  Future<String?> uploadLeaveDocument(int id, dynamic file) {
    return _$uploadLeaveDocumentAsyncAction
        .run(() => super.uploadLeaveDocument(id, file));
  }

  late final _$fetchLeaveStatisticsAsyncAction =
      AsyncAction('_LeaveStore.fetchLeaveStatistics', context: context);

  @override
  Future<void> fetchLeaveStatistics({int? year}) {
    return _$fetchLeaveStatisticsAsyncAction
        .run(() => super.fetchLeaveStatistics(year: year));
  }

  late final _$fetchTeamCalendarAsyncAction =
      AsyncAction('_LeaveStore.fetchTeamCalendar', context: context);

  @override
  Future<void> fetchTeamCalendar({String? fromDate, String? toDate}) {
    return _$fetchTeamCalendarAsyncAction
        .run(() => super.fetchTeamCalendar(fromDate: fromDate, toDate: toDate));
  }

  late final _$fetchCompensatoryOffsAsyncAction =
      AsyncAction('_LeaveStore.fetchCompensatoryOffs', context: context);

  @override
  Future<void> fetchCompensatoryOffs(
      {int skip = 0, int take = 20, String? status, bool loadMore = false}) {
    return _$fetchCompensatoryOffsAsyncAction.run(() => super
        .fetchCompensatoryOffs(
            skip: skip, take: take, status: status, loadMore: loadMore));
  }

  late final _$fetchCompensatoryOffAsyncAction =
      AsyncAction('_LeaveStore.fetchCompensatoryOff', context: context);

  @override
  Future<void> fetchCompensatoryOff(int id) {
    return _$fetchCompensatoryOffAsyncAction
        .run(() => super.fetchCompensatoryOff(id));
  }

  late final _$fetchCompensatoryOffBalanceAsyncAction =
      AsyncAction('_LeaveStore.fetchCompensatoryOffBalance', context: context);

  @override
  Future<void> fetchCompensatoryOffBalance() {
    return _$fetchCompensatoryOffBalanceAsyncAction
        .run(() => super.fetchCompensatoryOffBalance());
  }

  late final _$requestCompensatoryOffAsyncAction =
      AsyncAction('_LeaveStore.requestCompensatoryOff', context: context);

  @override
  Future<bool> requestCompensatoryOff(
      {required String workedDate,
      required num hoursWorked,
      required String reason}) {
    return _$requestCompensatoryOffAsyncAction.run(() => super
        .requestCompensatoryOff(
            workedDate: workedDate, hoursWorked: hoursWorked, reason: reason));
  }

  late final _$updateCompensatoryOffAsyncAction =
      AsyncAction('_LeaveStore.updateCompensatoryOff', context: context);

  @override
  Future<bool> updateCompensatoryOff(int id,
      {String? workedDate, num? hoursWorked, String? reason}) {
    return _$updateCompensatoryOffAsyncAction.run(() => super
        .updateCompensatoryOff(id,
            workedDate: workedDate, hoursWorked: hoursWorked, reason: reason));
  }

  late final _$deleteCompensatoryOffAsyncAction =
      AsyncAction('_LeaveStore.deleteCompensatoryOff', context: context);

  @override
  Future<bool> deleteCompensatoryOff(int id) {
    return _$deleteCompensatoryOffAsyncAction
        .run(() => super.deleteCompensatoryOff(id));
  }

  late final _$fetchCompensatoryOffStatisticsAsyncAction = AsyncAction(
      '_LeaveStore.fetchCompensatoryOffStatistics',
      context: context);

  @override
  Future<void> fetchCompensatoryOffStatistics({int? year}) {
    return _$fetchCompensatoryOffStatisticsAsyncAction
        .run(() => super.fetchCompensatoryOffStatistics(year: year));
  }

  late final _$_LeaveStoreActionController =
      ActionController(name: '_LeaveStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_LeaveStoreActionController.startAction(
        name: '_LeaveStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_LeaveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedLeaveRequest() {
    final _$actionInfo = _$_LeaveStoreActionController.startAction(
        name: '_LeaveStore.clearSelectedLeaveRequest');
    try {
      return super.clearSelectedLeaveRequest();
    } finally {
      _$_LeaveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedCompensatoryOff() {
    final _$actionInfo = _$_LeaveStoreActionController.startAction(
        name: '_LeaveStore.clearSelectedCompensatoryOff');
    try {
      return super.clearSelectedCompensatoryOff();
    } finally {
      _$_LeaveStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
leaveTypes: ${leaveTypes},
leaveBalanceSummary: ${leaveBalanceSummary},
leaveRequests: ${leaveRequests},
totalLeaveRequestsCount: ${totalLeaveRequestsCount},
selectedLeaveRequest: ${selectedLeaveRequest},
leaveStatistics: ${leaveStatistics},
teamCalendar: ${teamCalendar},
compensatoryOffs: ${compensatoryOffs},
totalCompOffsCount: ${totalCompOffsCount},
selectedCompensatoryOff: ${selectedCompensatoryOff},
compOffBalance: ${compOffBalance},
compOffStatistics: ${compOffStatistics},
error: ${error}
    ''';
  }
}
