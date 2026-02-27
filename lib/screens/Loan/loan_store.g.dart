// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoanStore on LoanStoreBase, Store {
  late final _$pagingControllerAtom =
      Atom(name: 'LoanStoreBase.pagingController', context: context);

  @override
  PagingController<int, LoanRequestModel> get pagingController {
    _$pagingControllerAtom.reportRead();
    return super.pagingController;
  }

  @override
  set pagingController(PagingController<int, LoanRequestModel> value) {
    _$pagingControllerAtom.reportWrite(value, super.pagingController, () {
      super.pagingController = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: 'LoanStoreBase.selectedStatus', context: context);

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

  late final _$statusesAtom =
      Atom(name: 'LoanStoreBase.statuses', context: context);

  @override
  ObservableList<String> get statuses {
    _$statusesAtom.reportRead();
    return super.statuses;
  }

  @override
  set statuses(ObservableList<String> value) {
    _$statusesAtom.reportWrite(value, super.statuses, () {
      super.statuses = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'LoanStoreBase.isLoading', context: context);

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

  late final _$statisticsAtom =
      Atom(name: 'LoanStoreBase.statistics', context: context);

  @override
  LoanStatistics? get statistics {
    _$statisticsAtom.reportRead();
    return super.statistics;
  }

  @override
  set statistics(LoanStatistics? value) {
    _$statisticsAtom.reportWrite(value, super.statistics, () {
      super.statistics = value;
    });
  }

  late final _$loanTypesAtom =
      Atom(name: 'LoanStoreBase.loanTypes', context: context);

  @override
  ObservableList<LoanType> get loanTypes {
    _$loanTypesAtom.reportRead();
    return super.loanTypes;
  }

  @override
  set loanTypes(ObservableList<LoanType> value) {
    _$loanTypesAtom.reportWrite(value, super.loanTypes, () {
      super.loanTypes = value;
    });
  }

  late final _$selectedLoanTypeAtom =
      Atom(name: 'LoanStoreBase.selectedLoanType', context: context);

  @override
  LoanType? get selectedLoanType {
    _$selectedLoanTypeAtom.reportRead();
    return super.selectedLoanType;
  }

  @override
  set selectedLoanType(LoanType? value) {
    _$selectedLoanTypeAtom.reportWrite(value, super.selectedLoanType, () {
      super.selectedLoanType = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('LoanStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$fetchLoanStatisticsAsyncAction =
      AsyncAction('LoanStoreBase.fetchLoanStatistics', context: context);

  @override
  Future<void> fetchLoanStatistics() {
    return _$fetchLoanStatisticsAsyncAction
        .run(() => super.fetchLoanStatistics());
  }

  late final _$fetchLoanTypesAsyncAction =
      AsyncAction('LoanStoreBase.fetchLoanTypes', context: context);

  @override
  Future<void> fetchLoanTypes() {
    return _$fetchLoanTypesAsyncAction.run(() => super.fetchLoanTypes());
  }

  late final _$fetchLoanRequestsAsyncAction =
      AsyncAction('LoanStoreBase.fetchLoanRequests', context: context);

  @override
  Future<void> fetchLoanRequests(int pageKey) {
    return _$fetchLoanRequestsAsyncAction
        .run(() => super.fetchLoanRequests(pageKey));
  }

  late final _$createLoanRequestAsyncAction =
      AsyncAction('LoanStoreBase.createLoanRequest', context: context);

  @override
  Future<Map<String, dynamic>?> createLoanRequest({bool saveAsDraft = false}) {
    return _$createLoanRequestAsyncAction
        .run(() => super.createLoanRequest(saveAsDraft: saveAsDraft));
  }

  late final _$updateLoanRequestAsyncAction =
      AsyncAction('LoanStoreBase.updateLoanRequest', context: context);

  @override
  Future<Map<String, dynamic>?> updateLoanRequest(int id,
      {bool submit = false}) {
    return _$updateLoanRequestAsyncAction
        .run(() => super.updateLoanRequest(id, submit: submit));
  }

  late final _$cancelLoanRequestAsyncAction =
      AsyncAction('LoanStoreBase.cancelLoanRequest', context: context);

  @override
  Future<void> cancelLoanRequest(int id) {
    return _$cancelLoanRequestAsyncAction
        .run(() => super.cancelLoanRequest(id));
  }

  late final _$deleteLoanRequestAsyncAction =
      AsyncAction('LoanStoreBase.deleteLoanRequest', context: context);

  @override
  Future<void> deleteLoanRequest(int id) {
    return _$deleteLoanRequestAsyncAction
        .run(() => super.deleteLoanRequest(id));
  }

  late final _$calculateEmiAsyncAction =
      AsyncAction('LoanStoreBase.calculateEmi', context: context);

  @override
  Future<Map<String, dynamic>?> calculateEmi() {
    return _$calculateEmiAsyncAction.run(() => super.calculateEmi());
  }

  late final _$LoanStoreBaseActionController =
      ActionController(name: 'LoanStoreBase', context: context);

  @override
  void setSelectedLoanType(LoanType? type) {
    final _$actionInfo = _$LoanStoreBaseActionController.startAction(
        name: 'LoanStoreBase.setSelectedLoanType');
    try {
      return super.setSelectedLoanType(type);
    } finally {
      _$LoanStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedStatus(String? status) {
    final _$actionInfo = _$LoanStoreBaseActionController.startAction(
        name: 'LoanStoreBase.setSelectedStatus');
    try {
      return super.setSelectedStatus(status);
    } finally {
      _$LoanStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearForm() {
    final _$actionInfo = _$LoanStoreBaseActionController.startAction(
        name: 'LoanStoreBase.clearForm');
    try {
      return super.clearForm();
    } finally {
      _$LoanStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pagingController: ${pagingController},
selectedStatus: ${selectedStatus},
statuses: ${statuses},
isLoading: ${isLoading},
statistics: ${statistics},
loanTypes: ${loanTypes},
selectedLoanType: ${selectedLoanType}
    ''';
  }
}
