// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_policies_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HRPoliciesStore on HRPoliciesStoreBase, Store {
  Computed<List<PolicyModel>>? _$acknowledgedPoliciesComputed;

  @override
  List<PolicyModel> get acknowledgedPolicies =>
      (_$acknowledgedPoliciesComputed ??= Computed<List<PolicyModel>>(
              () => super.acknowledgedPolicies,
              name: 'HRPoliciesStoreBase.acknowledgedPolicies'))
          .value;

  late final _$allPoliciesAtom =
      Atom(name: 'HRPoliciesStoreBase.allPolicies', context: context);

  @override
  ObservableList<PolicyModel> get allPolicies {
    _$allPoliciesAtom.reportRead();
    return super.allPolicies;
  }

  @override
  set allPolicies(ObservableList<PolicyModel> value) {
    _$allPoliciesAtom.reportWrite(value, super.allPolicies, () {
      super.allPolicies = value;
    });
  }

  late final _$pendingPoliciesAtom =
      Atom(name: 'HRPoliciesStoreBase.pendingPolicies', context: context);

  @override
  ObservableList<PolicyModel> get pendingPolicies {
    _$pendingPoliciesAtom.reportRead();
    return super.pendingPolicies;
  }

  @override
  set pendingPolicies(ObservableList<PolicyModel> value) {
    _$pendingPoliciesAtom.reportWrite(value, super.pendingPolicies, () {
      super.pendingPolicies = value;
    });
  }

  late final _$overduePoliciesAtom =
      Atom(name: 'HRPoliciesStoreBase.overduePolicies', context: context);

  @override
  ObservableList<PolicyModel> get overduePolicies {
    _$overduePoliciesAtom.reportRead();
    return super.overduePolicies;
  }

  @override
  set overduePolicies(ObservableList<PolicyModel> value) {
    _$overduePoliciesAtom.reportWrite(value, super.overduePolicies, () {
      super.overduePolicies = value;
    });
  }

  late final _$statsAtom =
      Atom(name: 'HRPoliciesStoreBase.stats', context: context);

  @override
  PolicyStatsModel? get stats {
    _$statsAtom.reportRead();
    return super.stats;
  }

  @override
  set stats(PolicyStatsModel? value) {
    _$statsAtom.reportWrite(value, super.stats, () {
      super.stats = value;
    });
  }

  late final _$categoriesAtom =
      Atom(name: 'HRPoliciesStoreBase.categories', context: context);

  @override
  ObservableList<PolicyCategoryModel> get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableList<PolicyCategoryModel> value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  late final _$selectedCategoryIdAtom =
      Atom(name: 'HRPoliciesStoreBase.selectedCategoryId', context: context);

  @override
  int? get selectedCategoryId {
    _$selectedCategoryIdAtom.reportRead();
    return super.selectedCategoryId;
  }

  @override
  set selectedCategoryId(int? value) {
    _$selectedCategoryIdAtom.reportWrite(value, super.selectedCategoryId, () {
      super.selectedCategoryId = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'HRPoliciesStoreBase.isLoading', context: context);

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
      Atom(name: 'HRPoliciesStoreBase.errorMessage', context: context);

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

  late final _$currentPolicyDetailAtom =
      Atom(name: 'HRPoliciesStoreBase.currentPolicyDetail', context: context);

  @override
  PolicyDetailModel? get currentPolicyDetail {
    _$currentPolicyDetailAtom.reportRead();
    return super.currentPolicyDetail;
  }

  @override
  set currentPolicyDetail(PolicyDetailModel? value) {
    _$currentPolicyDetailAtom.reportWrite(value, super.currentPolicyDetail, () {
      super.currentPolicyDetail = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('HRPoliciesStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$fetchAllPoliciesAsyncAction =
      AsyncAction('HRPoliciesStoreBase.fetchAllPolicies', context: context);

  @override
  Future<void> fetchAllPolicies() {
    return _$fetchAllPoliciesAsyncAction.run(() => super.fetchAllPolicies());
  }

  late final _$fetchPolicyStatsAsyncAction =
      AsyncAction('HRPoliciesStoreBase.fetchPolicyStats', context: context);

  @override
  Future<void> fetchPolicyStats() {
    return _$fetchPolicyStatsAsyncAction.run(() => super.fetchPolicyStats());
  }

  late final _$fetchCategoriesAsyncAction =
      AsyncAction('HRPoliciesStoreBase.fetchCategories', context: context);

  @override
  Future<void> fetchCategories() {
    return _$fetchCategoriesAsyncAction.run(() => super.fetchCategories());
  }

  late final _$filterByCategoryAsyncAction =
      AsyncAction('HRPoliciesStoreBase.filterByCategory', context: context);

  @override
  Future<void> filterByCategory(int? categoryId) {
    return _$filterByCategoryAsyncAction
        .run(() => super.filterByCategory(categoryId));
  }

  late final _$refreshDataAsyncAction =
      AsyncAction('HRPoliciesStoreBase.refreshData', context: context);

  @override
  Future<void> refreshData() {
    return _$refreshDataAsyncAction.run(() => super.refreshData());
  }

  late final _$acknowledgePolicyAsyncAction =
      AsyncAction('HRPoliciesStoreBase.acknowledgePolicy', context: context);

  @override
  Future<AcknowledgmentResponseModel?> acknowledgePolicy(
      int acknowledgmentId, String? comments) {
    return _$acknowledgePolicyAsyncAction
        .run(() => super.acknowledgePolicy(acknowledgmentId, comments));
  }

  late final _$fetchPolicyDetailsAsyncAction =
      AsyncAction('HRPoliciesStoreBase.fetchPolicyDetails', context: context);

  @override
  Future<void> fetchPolicyDetails(int policyId) {
    return _$fetchPolicyDetailsAsyncAction
        .run(() => super.fetchPolicyDetails(policyId));
  }

  late final _$HRPoliciesStoreBaseActionController =
      ActionController(name: 'HRPoliciesStoreBase', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$HRPoliciesStoreBaseActionController.startAction(
        name: 'HRPoliciesStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$HRPoliciesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
allPolicies: ${allPolicies},
pendingPolicies: ${pendingPolicies},
overduePolicies: ${overduePolicies},
stats: ${stats},
categories: ${categories},
selectedCategoryId: ${selectedCategoryId},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
currentPolicyDetail: ${currentPolicyDetail},
acknowledgedPolicies: ${acknowledgedPolicies}
    ''';
  }
}
