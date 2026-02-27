// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TimesheetStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TimesheetStore on TimesheetStoreBase, Store {
  late final _$pagingControllerAtom =
      Atom(name: 'TimesheetStoreBase.pagingController', context: context);

  @override
  PagingController<int, InvalidType> get pagingController {
    _$pagingControllerAtom.reportRead();
    return super.pagingController;
  }

  @override
  set pagingController(PagingController<int, InvalidType> value) {
    _$pagingControllerAtom.reportWrite(value, super.pagingController, () {
      super.pagingController = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'TimesheetStoreBase.isLoading', context: context);

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

  late final _$totalHoursAtom =
      Atom(name: 'TimesheetStoreBase.totalHours', context: context);

  @override
  num get totalHours {
    _$totalHoursAtom.reportRead();
    return super.totalHours;
  }

  @override
  set totalHours(num value) {
    _$totalHoursAtom.reportWrite(value, super.totalHours, () {
      super.totalHours = value;
    });
  }

  late final _$totalBillableHoursAtom =
      Atom(name: 'TimesheetStoreBase.totalBillableHours', context: context);

  @override
  num get totalBillableHours {
    _$totalBillableHoursAtom.reportRead();
    return super.totalBillableHours;
  }

  @override
  set totalBillableHours(num value) {
    _$totalBillableHoursAtom.reportWrite(value, super.totalBillableHours, () {
      super.totalBillableHours = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: 'TimesheetStoreBase.selectedStatus', context: context);

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

  late final _$selectedProjectIdAtom =
      Atom(name: 'TimesheetStoreBase.selectedProjectId', context: context);

  @override
  int? get selectedProjectId {
    _$selectedProjectIdAtom.reportRead();
    return super.selectedProjectId;
  }

  @override
  set selectedProjectId(int? value) {
    _$selectedProjectIdAtom.reportWrite(value, super.selectedProjectId, () {
      super.selectedProjectId = value;
    });
  }

  late final _$selectedProjectNameAtom =
      Atom(name: 'TimesheetStoreBase.selectedProjectName', context: context);

  @override
  String? get selectedProjectName {
    _$selectedProjectNameAtom.reportRead();
    return super.selectedProjectName;
  }

  @override
  set selectedProjectName(String? value) {
    _$selectedProjectNameAtom.reportWrite(value, super.selectedProjectName, () {
      super.selectedProjectName = value;
    });
  }

  late final _$selectedDateAtom =
      Atom(name: 'TimesheetStoreBase.selectedDate', context: context);

  @override
  DateTime get selectedDate {
    _$selectedDateAtom.reportRead();
    return super.selectedDate;
  }

  @override
  set selectedDate(DateTime value) {
    _$selectedDateAtom.reportWrite(value, super.selectedDate, () {
      super.selectedDate = value;
    });
  }

  late final _$hoursControllerAtom =
      Atom(name: 'TimesheetStoreBase.hoursController', context: context);

  @override
  TextEditingController get hoursController {
    _$hoursControllerAtom.reportRead();
    return super.hoursController;
  }

  @override
  set hoursController(TextEditingController value) {
    _$hoursControllerAtom.reportWrite(value, super.hoursController, () {
      super.hoursController = value;
    });
  }

  late final _$descriptionControllerAtom =
      Atom(name: 'TimesheetStoreBase.descriptionController', context: context);

  @override
  TextEditingController get descriptionController {
    _$descriptionControllerAtom.reportRead();
    return super.descriptionController;
  }

  @override
  set descriptionController(TextEditingController value) {
    _$descriptionControllerAtom.reportWrite(value, super.descriptionController,
        () {
      super.descriptionController = value;
    });
  }

  late final _$isBillableAtom =
      Atom(name: 'TimesheetStoreBase.isBillable', context: context);

  @override
  bool get isBillable {
    _$isBillableAtom.reportRead();
    return super.isBillable;
  }

  @override
  set isBillable(bool value) {
    _$isBillableAtom.reportWrite(value, super.isBillable, () {
      super.isBillable = value;
    });
  }

  late final _$fetchTimesheetsAsyncAction =
      AsyncAction('TimesheetStoreBase.fetchTimesheets', context: context);

  @override
  Future<void> fetchTimesheets(int pageKey) {
    return _$fetchTimesheetsAsyncAction
        .run(() => super.fetchTimesheets(pageKey));
  }

  late final _$createTimesheetAsyncAction =
      AsyncAction('TimesheetStoreBase.createTimesheet', context: context);

  @override
  Future<bool> createTimesheet() {
    return _$createTimesheetAsyncAction.run(() => super.createTimesheet());
  }

  late final _$submitTimesheetAsyncAction =
      AsyncAction('TimesheetStoreBase.submitTimesheet', context: context);

  @override
  Future<bool> submitTimesheet(int id) {
    return _$submitTimesheetAsyncAction.run(() => super.submitTimesheet(id));
  }

  late final _$TimesheetStoreBaseActionController =
      ActionController(name: 'TimesheetStoreBase', context: context);

  @override
  void resetForm() {
    final _$actionInfo = _$TimesheetStoreBaseActionController.startAction(
        name: 'TimesheetStoreBase.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$TimesheetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pagingController: ${pagingController},
isLoading: ${isLoading},
totalHours: ${totalHours},
totalBillableHours: ${totalBillableHours},
selectedStatus: ${selectedStatus},
selectedProjectId: ${selectedProjectId},
selectedProjectName: ${selectedProjectName},
selectedDate: ${selectedDate},
hoursController: ${hoursController},
descriptionController: ${descriptionController},
isBillable: ${isBillable}
    ''';
  }
}
