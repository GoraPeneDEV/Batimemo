// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_regularization_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AttendanceRegularizationStore
    on AttendanceRegularizationStoreBase, Store {
  late final _$pagingControllerAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.pagingController',
      context: context);

  @override
  PagingController<int, AttendanceRegularization> get pagingController {
    _$pagingControllerAtom.reportRead();
    return super.pagingController;
  }

  @override
  set pagingController(PagingController<int, AttendanceRegularization> value) {
    _$pagingControllerAtom.reportWrite(value, super.pagingController, () {
      super.pagingController = value;
    });
  }

  late final _$isLoadingAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.isLoading', context: context);

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

  late final _$errorAtom =
      Atom(name: 'AttendanceRegularizationStoreBase.error', context: context);

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

  late final _$regularizationTypesAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.regularizationTypes',
      context: context);

  @override
  ObservableList<RegularizationType> get regularizationTypes {
    _$regularizationTypesAtom.reportRead();
    return super.regularizationTypes;
  }

  @override
  set regularizationTypes(ObservableList<RegularizationType> value) {
    _$regularizationTypesAtom.reportWrite(value, super.regularizationTypes, () {
      super.regularizationTypes = value;
    });
  }

  late final _$countsAtom =
      Atom(name: 'AttendanceRegularizationStoreBase.counts', context: context);

  @override
  RegularizationCounts? get counts {
    _$countsAtom.reportRead();
    return super.counts;
  }

  @override
  set counts(RegularizationCounts? value) {
    _$countsAtom.reportWrite(value, super.counts, () {
      super.counts = value;
    });
  }

  late final _$availableDatesAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.availableDates',
      context: context);

  @override
  AvailableDatesResponse? get availableDates {
    _$availableDatesAtom.reportRead();
    return super.availableDates;
  }

  @override
  set availableDates(AvailableDatesResponse? value) {
    _$availableDatesAtom.reportWrite(value, super.availableDates, () {
      super.availableDates = value;
    });
  }

  late final _$selectedStatusAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.selectedStatus',
      context: context);

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

  late final _$selectedTypeAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.selectedType', context: context);

  @override
  String? get selectedType {
    _$selectedTypeAtom.reportRead();
    return super.selectedType;
  }

  @override
  set selectedType(String? value) {
    _$selectedTypeAtom.reportWrite(value, super.selectedType, () {
      super.selectedType = value;
    });
  }

  late final _$startDateAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.startDate', context: context);

  @override
  String? get startDate {
    _$startDateAtom.reportRead();
    return super.startDate;
  }

  @override
  set startDate(String? value) {
    _$startDateAtom.reportWrite(value, super.startDate, () {
      super.startDate = value;
    });
  }

  late final _$endDateAtom =
      Atom(name: 'AttendanceRegularizationStoreBase.endDate', context: context);

  @override
  String? get endDate {
    _$endDateAtom.reportRead();
    return super.endDate;
  }

  @override
  set endDate(String? value) {
    _$endDateAtom.reportWrite(value, super.endDate, () {
      super.endDate = value;
    });
  }

  late final _$selectedDateAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.selectedDate', context: context);

  @override
  String? get selectedDate {
    _$selectedDateAtom.reportRead();
    return super.selectedDate;
  }

  @override
  set selectedDate(String? value) {
    _$selectedDateAtom.reportWrite(value, super.selectedDate, () {
      super.selectedDate = value;
    });
  }

  late final _$selectedRegularizationTypeAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.selectedRegularizationType',
      context: context);

  @override
  String? get selectedRegularizationType {
    _$selectedRegularizationTypeAtom.reportRead();
    return super.selectedRegularizationType;
  }

  @override
  set selectedRegularizationType(String? value) {
    _$selectedRegularizationTypeAtom
        .reportWrite(value, super.selectedRegularizationType, () {
      super.selectedRegularizationType = value;
    });
  }

  late final _$requestedCheckInTimeAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.requestedCheckInTime',
      context: context);

  @override
  TimeOfDay? get requestedCheckInTime {
    _$requestedCheckInTimeAtom.reportRead();
    return super.requestedCheckInTime;
  }

  @override
  set requestedCheckInTime(TimeOfDay? value) {
    _$requestedCheckInTimeAtom.reportWrite(value, super.requestedCheckInTime,
        () {
      super.requestedCheckInTime = value;
    });
  }

  late final _$requestedCheckOutTimeAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.requestedCheckOutTime',
      context: context);

  @override
  TimeOfDay? get requestedCheckOutTime {
    _$requestedCheckOutTimeAtom.reportRead();
    return super.requestedCheckOutTime;
  }

  @override
  set requestedCheckOutTime(TimeOfDay? value) {
    _$requestedCheckOutTimeAtom.reportWrite(value, super.requestedCheckOutTime,
        () {
      super.requestedCheckOutTime = value;
    });
  }

  late final _$attachmentsAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.attachments', context: context);

  @override
  ObservableList<File> get attachments {
    _$attachmentsAtom.reportRead();
    return super.attachments;
  }

  @override
  set attachments(ObservableList<File> value) {
    _$attachmentsAtom.reportWrite(value, super.attachments, () {
      super.attachments = value;
    });
  }

  late final _$selectedRegularizationAtom = Atom(
      name: 'AttendanceRegularizationStoreBase.selectedRegularization',
      context: context);

  @override
  AttendanceRegularization? get selectedRegularization {
    _$selectedRegularizationAtom.reportRead();
    return super.selectedRegularization;
  }

  @override
  set selectedRegularization(AttendanceRegularization? value) {
    _$selectedRegularizationAtom
        .reportWrite(value, super.selectedRegularization, () {
      super.selectedRegularization = value;
    });
  }

  late final _$fetchRegularizationsAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.fetchRegularizations',
      context: context);

  @override
  Future<void> fetchRegularizations(int pageKey) {
    return _$fetchRegularizationsAsyncAction
        .run(() => super.fetchRegularizations(pageKey));
  }

  late final _$getRegularizationTypesAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.getRegularizationTypes',
      context: context);

  @override
  Future<void> getRegularizationTypes() {
    return _$getRegularizationTypesAsyncAction
        .run(() => super.getRegularizationTypes());
  }

  late final _$getCountsAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.getCounts',
      context: context);

  @override
  Future<void> getCounts() {
    return _$getCountsAsyncAction.run(() => super.getCounts());
  }

  late final _$getAvailableDatesAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.getAvailableDates',
      context: context);

  @override
  Future<void> getAvailableDates({int days = 30}) {
    return _$getAvailableDatesAsyncAction
        .run(() => super.getAvailableDates(days: days));
  }

  late final _$createRegularizationAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.createRegularization',
      context: context);

  @override
  Future<bool> createRegularization() {
    return _$createRegularizationAsyncAction
        .run(() => super.createRegularization());
  }

  late final _$updateRegularizationAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.updateRegularization',
      context: context);

  @override
  Future<bool> updateRegularization(int id) {
    return _$updateRegularizationAsyncAction
        .run(() => super.updateRegularization(id));
  }

  late final _$deleteRegularizationAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.deleteRegularization',
      context: context);

  @override
  Future<bool> deleteRegularization(int id) {
    return _$deleteRegularizationAsyncAction
        .run(() => super.deleteRegularization(id));
  }

  late final _$loadRegularizationDetailsAsyncAction = AsyncAction(
      'AttendanceRegularizationStoreBase.loadRegularizationDetails',
      context: context);

  @override
  Future<void> loadRegularizationDetails(int id) {
    return _$loadRegularizationDetailsAsyncAction
        .run(() => super.loadRegularizationDetails(id));
  }

  late final _$AttendanceRegularizationStoreBaseActionController =
      ActionController(
          name: 'AttendanceRegularizationStoreBase', context: context);

  @override
  void setStatusFilter(String? status) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.setStatusFilter');
    try {
      return super.setStatusFilter(status);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setTypeFilter(String? type) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.setTypeFilter');
    try {
      return super.setTypeFilter(type);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setDateRangeFilter(String? start, String? end) {
    final _$actionInfo =
        _$AttendanceRegularizationStoreBaseActionController.startAction(
            name: 'AttendanceRegularizationStoreBase.setDateRangeFilter');
    try {
      return super.setDateRangeFilter(start, end);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearFilters() {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setDate(String date) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.setDate');
    try {
      return super.setDate(date);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setRegularizationType(String type) {
    final _$actionInfo =
        _$AttendanceRegularizationStoreBaseActionController.startAction(
            name: 'AttendanceRegularizationStoreBase.setRegularizationType');
    try {
      return super.setRegularizationType(type);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setCheckInTime(TimeOfDay time) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.setCheckInTime');
    try {
      return super.setCheckInTime(time);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setCheckOutTime(TimeOfDay time) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.setCheckOutTime');
    try {
      return super.setCheckOutTime(time);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void addAttachment(File file) {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.addAttachment');
    try {
      return super.addAttachment(file);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void removeAttachment(int index) {
    final _$actionInfo =
        _$AttendanceRegularizationStoreBaseActionController.startAction(
            name: 'AttendanceRegularizationStoreBase.removeAttachment');
    try {
      return super.removeAttachment(index);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearForm() {
    final _$actionInfo = _$AttendanceRegularizationStoreBaseActionController
        .startAction(name: 'AttendanceRegularizationStoreBase.clearForm');
    try {
      return super.clearForm();
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void loadFormFromRegularization(AttendanceRegularization regularization) {
    final _$actionInfo =
        _$AttendanceRegularizationStoreBaseActionController.startAction(
            name:
                'AttendanceRegularizationStoreBase.loadFormFromRegularization');
    try {
      return super.loadFormFromRegularization(regularization);
    } finally {
      _$AttendanceRegularizationStoreBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pagingController: ${pagingController},
isLoading: ${isLoading},
error: ${error},
regularizationTypes: ${regularizationTypes},
counts: ${counts},
availableDates: ${availableDates},
selectedStatus: ${selectedStatus},
selectedType: ${selectedType},
startDate: ${startDate},
endDate: ${endDate},
selectedDate: ${selectedDate},
selectedRegularizationType: ${selectedRegularizationType},
requestedCheckInTime: ${requestedCheckInTime},
requestedCheckOutTime: ${requestedCheckOutTime},
attachments: ${attachments},
selectedRegularization: ${selectedRegularization}
    ''';
  }
}
