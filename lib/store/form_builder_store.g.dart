// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_builder_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FormBuilderStore on FormBuilderStoreBase, Store {
  Computed<List<AssignedFormModel>>? _$pendingFormsComputed;

  @override
  List<AssignedFormModel> get pendingForms => (_$pendingFormsComputed ??=
          Computed<List<AssignedFormModel>>(() => super.pendingForms,
              name: 'FormBuilderStoreBase.pendingForms'))
      .value;
  Computed<List<AssignedFormModel>>? _$submittedFormsComputed;

  @override
  List<AssignedFormModel> get submittedForms => (_$submittedFormsComputed ??=
          Computed<List<AssignedFormModel>>(() => super.submittedForms,
              name: 'FormBuilderStoreBase.submittedForms'))
      .value;
  Computed<List<AssignedFormModel>>? _$overdueFormsComputed;

  @override
  List<AssignedFormModel> get overdueForms => (_$overdueFormsComputed ??=
          Computed<List<AssignedFormModel>>(() => super.overdueForms,
              name: 'FormBuilderStoreBase.overdueForms'))
      .value;
  Computed<bool>? _$isSubmittingComputed;

  @override
  bool get isSubmitting =>
      (_$isSubmittingComputed ??= Computed<bool>(() => super.isSubmitting,
              name: 'FormBuilderStoreBase.isSubmitting'))
          .value;

  late final _$assignedFormsAtom =
      Atom(name: 'FormBuilderStoreBase.assignedForms', context: context);

  @override
  ObservableList<AssignedFormModel> get assignedForms {
    _$assignedFormsAtom.reportRead();
    return super.assignedForms;
  }

  @override
  set assignedForms(ObservableList<AssignedFormModel> value) {
    _$assignedFormsAtom.reportWrite(value, super.assignedForms, () {
      super.assignedForms = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'FormBuilderStoreBase.isLoading', context: context);

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

  late final _$errorMessageAtom =
      Atom(name: 'FormBuilderStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$totalCountAtom =
      Atom(name: 'FormBuilderStoreBase.totalCount', context: context);

  @override
  int get totalCount {
    _$totalCountAtom.reportRead();
    return super.totalCount;
  }

  @override
  set totalCount(int value) {
    _$totalCountAtom.reportWrite(value, super.totalCount, () {
      super.totalCount = value;
    });
  }

  late final _$currentFilterAtom =
      Atom(name: 'FormBuilderStoreBase.currentFilter', context: context);

  @override
  String? get currentFilter {
    _$currentFilterAtom.reportRead();
    return super.currentFilter;
  }

  @override
  set currentFilter(String? value) {
    _$currentFilterAtom.reportWrite(value, super.currentFilter, () {
      super.currentFilter = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: 'FormBuilderStoreBase.currentPage', context: context);

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

  late final _$hasMoreDataAtom =
      Atom(name: 'FormBuilderStoreBase.hasMoreData', context: context);

  @override
  bool get hasMoreData {
    _$hasMoreDataAtom.reportRead();
    return super.hasMoreData;
  }

  @override
  set hasMoreData(bool value) {
    _$hasMoreDataAtom.reportWrite(value, super.hasMoreData, () {
      super.hasMoreData = value;
    });
  }

  late final _$submittingFormIdAtom =
      Atom(name: 'FormBuilderStoreBase.submittingFormId', context: context);

  @override
  int? get submittingFormId {
    _$submittingFormIdAtom.reportRead();
    return super.submittingFormId;
  }

  @override
  set submittingFormId(int? value) {
    _$submittingFormIdAtom.reportWrite(value, super.submittingFormId, () {
      super.submittingFormId = value;
    });
  }

  late final _$fetchAssignedFormsAsyncAction =
      AsyncAction('FormBuilderStoreBase.fetchAssignedForms', context: context);

  @override
  Future<void> fetchAssignedForms(
      {int? skip, int? take, String? status, bool append = false}) {
    return _$fetchAssignedFormsAsyncAction.run(() => super.fetchAssignedForms(
        skip: skip, take: take, status: status, append: append));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('FormBuilderStoreBase.loadMore', context: context);

  @override
  Future<void> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  late final _$filterByStatusAsyncAction =
      AsyncAction('FormBuilderStoreBase.filterByStatus', context: context);

  @override
  Future<void> filterByStatus(String? status) {
    return _$filterByStatusAsyncAction.run(() => super.filterByStatus(status));
  }

  late final _$submitFormAsyncAction =
      AsyncAction('FormBuilderStoreBase.submitForm', context: context);

  @override
  Future<bool> submitForm(
      {required int assignmentId, required Map<String, dynamic> formData}) {
    return _$submitFormAsyncAction.run(
        () => super.submitForm(assignmentId: assignmentId, formData: formData));
  }

  late final _$refreshFormsAsyncAction =
      AsyncAction('FormBuilderStoreBase.refreshForms', context: context);

  @override
  Future<void> refreshForms() {
    return _$refreshFormsAsyncAction.run(() => super.refreshForms());
  }

  late final _$FormBuilderStoreBaseActionController =
      ActionController(name: 'FormBuilderStoreBase', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$FormBuilderStoreBaseActionController.startAction(
        name: 'FormBuilderStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$FormBuilderStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$FormBuilderStoreBaseActionController.startAction(
        name: 'FormBuilderStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$FormBuilderStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
assignedForms: ${assignedForms},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalCount: ${totalCount},
currentFilter: ${currentFilter},
currentPage: ${currentPage},
hasMoreData: ${hasMoreData},
submittingFormId: ${submittingFormId},
pendingForms: ${pendingForms},
submittedForms: ${submittedForms},
overdueForms: ${overdueForms},
isSubmitting: ${isSubmitting}
    ''';
  }
}
