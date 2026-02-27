// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssetStore on AssetStoreBase, Store {
  Computed<ObservableList<AssetModel>>? _$filteredAssetsComputed;

  @override
  ObservableList<AssetModel> get filteredAssets => (_$filteredAssetsComputed ??=
          Computed<ObservableList<AssetModel>>(() => super.filteredAssets,
              name: 'AssetStoreBase.filteredAssets'))
      .value;
  Computed<int>? _$activeAssignmentsCountComputed;

  @override
  int get activeAssignmentsCount => (_$activeAssignmentsCountComputed ??=
          Computed<int>(() => super.activeAssignmentsCount,
              name: 'AssetStoreBase.activeAssignmentsCount'))
      .value;
  Computed<bool>? _$hasAssetsComputed;

  @override
  bool get hasAssets =>
      (_$hasAssetsComputed ??= Computed<bool>(() => super.hasAssets,
              name: 'AssetStoreBase.hasAssets'))
          .value;
  Computed<bool>? _$hasFiltersAppliedComputed;

  @override
  bool get hasFiltersApplied => (_$hasFiltersAppliedComputed ??= Computed<bool>(
          () => super.hasFiltersApplied,
          name: 'AssetStoreBase.hasFiltersApplied'))
      .value;

  late final _$assetListAtom =
      Atom(name: 'AssetStoreBase.assetList', context: context);

  @override
  ObservableList<AssetModel> get assetList {
    _$assetListAtom.reportRead();
    return super.assetList;
  }

  @override
  set assetList(ObservableList<AssetModel> value) {
    _$assetListAtom.reportWrite(value, super.assetList, () {
      super.assetList = value;
    });
  }

  late final _$currentAssetAtom =
      Atom(name: 'AssetStoreBase.currentAsset', context: context);

  @override
  AssetModel? get currentAsset {
    _$currentAssetAtom.reportRead();
    return super.currentAsset;
  }

  @override
  set currentAsset(AssetModel? value) {
    _$currentAssetAtom.reportWrite(value, super.currentAsset, () {
      super.currentAsset = value;
    });
  }

  late final _$assignmentHistoryAtom =
      Atom(name: 'AssetStoreBase.assignmentHistory', context: context);

  @override
  ObservableList<AssetAssignmentModel> get assignmentHistory {
    _$assignmentHistoryAtom.reportRead();
    return super.assignmentHistory;
  }

  @override
  set assignmentHistory(ObservableList<AssetAssignmentModel> value) {
    _$assignmentHistoryAtom.reportWrite(value, super.assignmentHistory, () {
      super.assignmentHistory = value;
    });
  }

  late final _$assetDocumentsAtom =
      Atom(name: 'AssetStoreBase.assetDocuments', context: context);

  @override
  ObservableList<AssetDocumentModel> get assetDocuments {
    _$assetDocumentsAtom.reportRead();
    return super.assetDocuments;
  }

  @override
  set assetDocuments(ObservableList<AssetDocumentModel> value) {
    _$assetDocumentsAtom.reportWrite(value, super.assetDocuments, () {
      super.assetDocuments = value;
    });
  }

  late final _$maintenanceHistoryAtom =
      Atom(name: 'AssetStoreBase.maintenanceHistory', context: context);

  @override
  ObservableList<AssetMaintenanceModel> get maintenanceHistory {
    _$maintenanceHistoryAtom.reportRead();
    return super.maintenanceHistory;
  }

  @override
  set maintenanceHistory(ObservableList<AssetMaintenanceModel> value) {
    _$maintenanceHistoryAtom.reportWrite(value, super.maintenanceHistory, () {
      super.maintenanceHistory = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'AssetStoreBase.isLoading', context: context);

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

  late final _$isLoadingMoreAtom =
      Atom(name: 'AssetStoreBase.isLoadingMore', context: context);

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$isLoadingDetailsAtom =
      Atom(name: 'AssetStoreBase.isLoadingDetails', context: context);

  @override
  bool get isLoadingDetails {
    _$isLoadingDetailsAtom.reportRead();
    return super.isLoadingDetails;
  }

  @override
  set isLoadingDetails(bool value) {
    _$isLoadingDetailsAtom.reportWrite(value, super.isLoadingDetails, () {
      super.isLoadingDetails = value;
    });
  }

  late final _$isReportingIssueAtom =
      Atom(name: 'AssetStoreBase.isReportingIssue', context: context);

  @override
  bool get isReportingIssue {
    _$isReportingIssueAtom.reportRead();
    return super.isReportingIssue;
  }

  @override
  set isReportingIssue(bool value) {
    _$isReportingIssueAtom.reportWrite(value, super.isReportingIssue, () {
      super.isReportingIssue = value;
    });
  }

  late final _$isScanningQRAtom =
      Atom(name: 'AssetStoreBase.isScanningQR', context: context);

  @override
  bool get isScanningQR {
    _$isScanningQRAtom.reportRead();
    return super.isScanningQR;
  }

  @override
  set isScanningQR(bool value) {
    _$isScanningQRAtom.reportWrite(value, super.isScanningQR, () {
      super.isScanningQR = value;
    });
  }

  late final _$isLoadingMaintenanceAtom =
      Atom(name: 'AssetStoreBase.isLoadingMaintenance', context: context);

  @override
  bool get isLoadingMaintenance {
    _$isLoadingMaintenanceAtom.reportRead();
    return super.isLoadingMaintenance;
  }

  @override
  set isLoadingMaintenance(bool value) {
    _$isLoadingMaintenanceAtom.reportWrite(value, super.isLoadingMaintenance,
        () {
      super.isLoadingMaintenance = value;
    });
  }

  late final _$hasMoreDataAtom =
      Atom(name: 'AssetStoreBase.hasMoreData', context: context);

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

  late final _$totalAssetsCountAtom =
      Atom(name: 'AssetStoreBase.totalAssetsCount', context: context);

  @override
  int get totalAssetsCount {
    _$totalAssetsCountAtom.reportRead();
    return super.totalAssetsCount;
  }

  @override
  set totalAssetsCount(int value) {
    _$totalAssetsCountAtom.reportWrite(value, super.totalAssetsCount, () {
      super.totalAssetsCount = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: 'AssetStoreBase.currentPage', context: context);

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

  late final _$itemsPerPageAtom =
      Atom(name: 'AssetStoreBase.itemsPerPage', context: context);

  @override
  int get itemsPerPage {
    _$itemsPerPageAtom.reportRead();
    return super.itemsPerPage;
  }

  @override
  set itemsPerPage(int value) {
    _$itemsPerPageAtom.reportWrite(value, super.itemsPerPage, () {
      super.itemsPerPage = value;
    });
  }

  late final _$totalHistoryCountAtom =
      Atom(name: 'AssetStoreBase.totalHistoryCount', context: context);

  @override
  int get totalHistoryCount {
    _$totalHistoryCountAtom.reportRead();
    return super.totalHistoryCount;
  }

  @override
  set totalHistoryCount(int value) {
    _$totalHistoryCountAtom.reportWrite(value, super.totalHistoryCount, () {
      super.totalHistoryCount = value;
    });
  }

  late final _$hasMoreHistoryAtom =
      Atom(name: 'AssetStoreBase.hasMoreHistory', context: context);

  @override
  bool get hasMoreHistory {
    _$hasMoreHistoryAtom.reportRead();
    return super.hasMoreHistory;
  }

  @override
  set hasMoreHistory(bool value) {
    _$hasMoreHistoryAtom.reportWrite(value, super.hasMoreHistory, () {
      super.hasMoreHistory = value;
    });
  }

  late final _$currentHistoryPageAtom =
      Atom(name: 'AssetStoreBase.currentHistoryPage', context: context);

  @override
  int get currentHistoryPage {
    _$currentHistoryPageAtom.reportRead();
    return super.currentHistoryPage;
  }

  @override
  set currentHistoryPage(int value) {
    _$currentHistoryPageAtom.reportWrite(value, super.currentHistoryPage, () {
      super.currentHistoryPage = value;
    });
  }

  late final _$totalMaintenanceCountAtom =
      Atom(name: 'AssetStoreBase.totalMaintenanceCount', context: context);

  @override
  int get totalMaintenanceCount {
    _$totalMaintenanceCountAtom.reportRead();
    return super.totalMaintenanceCount;
  }

  @override
  set totalMaintenanceCount(int value) {
    _$totalMaintenanceCountAtom.reportWrite(value, super.totalMaintenanceCount,
        () {
      super.totalMaintenanceCount = value;
    });
  }

  late final _$hasMoreMaintenanceAtom =
      Atom(name: 'AssetStoreBase.hasMoreMaintenance', context: context);

  @override
  bool get hasMoreMaintenance {
    _$hasMoreMaintenanceAtom.reportRead();
    return super.hasMoreMaintenance;
  }

  @override
  set hasMoreMaintenance(bool value) {
    _$hasMoreMaintenanceAtom.reportWrite(value, super.hasMoreMaintenance, () {
      super.hasMoreMaintenance = value;
    });
  }

  late final _$currentMaintenancePageAtom =
      Atom(name: 'AssetStoreBase.currentMaintenancePage', context: context);

  @override
  int get currentMaintenancePage {
    _$currentMaintenancePageAtom.reportRead();
    return super.currentMaintenancePage;
  }

  @override
  set currentMaintenancePage(int value) {
    _$currentMaintenancePageAtom
        .reportWrite(value, super.currentMaintenancePage, () {
      super.currentMaintenancePage = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'AssetStoreBase.errorMessage', context: context);

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

  late final _$searchQueryAtom =
      Atom(name: 'AssetStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: 'AssetStoreBase.selectedStatus', context: context);

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

  late final _$selectedCategoryIdAtom =
      Atom(name: 'AssetStoreBase.selectedCategoryId', context: context);

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

  late final _$fetchAssignedAssetsAsyncAction =
      AsyncAction('AssetStoreBase.fetchAssignedAssets', context: context);

  @override
  Future<void> fetchAssignedAssets({bool loadMore = false}) {
    return _$fetchAssignedAssetsAsyncAction
        .run(() => super.fetchAssignedAssets(loadMore: loadMore));
  }

  late final _$fetchAssetDetailsAsyncAction =
      AsyncAction('AssetStoreBase.fetchAssetDetails', context: context);

  @override
  Future<bool> fetchAssetDetails(int assetId) {
    return _$fetchAssetDetailsAsyncAction
        .run(() => super.fetchAssetDetails(assetId));
  }

  late final _$scanQRCodeAsyncAction =
      AsyncAction('AssetStoreBase.scanQRCode', context: context);

  @override
  Future<AssetModel?> scanQRCode(String qrCode) {
    return _$scanQRCodeAsyncAction.run(() => super.scanQRCode(qrCode));
  }

  late final _$fetchAssignmentHistoryAsyncAction =
      AsyncAction('AssetStoreBase.fetchAssignmentHistory', context: context);

  @override
  Future<void> fetchAssignmentHistory({bool loadMore = false}) {
    return _$fetchAssignmentHistoryAsyncAction
        .run(() => super.fetchAssignmentHistory(loadMore: loadMore));
  }

  late final _$reportIssueAsyncAction =
      AsyncAction('AssetStoreBase.reportIssue', context: context);

  @override
  Future<bool> reportIssue(int assetId, String description) {
    return _$reportIssueAsyncAction
        .run(() => super.reportIssue(assetId, description));
  }

  late final _$fetchMaintenanceHistoryAsyncAction =
      AsyncAction('AssetStoreBase.fetchMaintenanceHistory', context: context);

  @override
  Future<void> fetchMaintenanceHistory(int assetId, {bool loadMore = false}) {
    return _$fetchMaintenanceHistoryAsyncAction
        .run(() => super.fetchMaintenanceHistory(assetId, loadMore: loadMore));
  }

  late final _$saveToCacheAsyncAction =
      AsyncAction('AssetStoreBase.saveToCache', context: context);

  @override
  Future<void> saveToCache() {
    return _$saveToCacheAsyncAction.run(() => super.saveToCache());
  }

  late final _$loadFromCacheAsyncAction =
      AsyncAction('AssetStoreBase.loadFromCache', context: context);

  @override
  Future<void> loadFromCache() {
    return _$loadFromCacheAsyncAction.run(() => super.loadFromCache());
  }

  late final _$saveHistoryToCacheAsyncAction =
      AsyncAction('AssetStoreBase.saveHistoryToCache', context: context);

  @override
  Future<void> saveHistoryToCache() {
    return _$saveHistoryToCacheAsyncAction
        .run(() => super.saveHistoryToCache());
  }

  late final _$loadHistoryFromCacheAsyncAction =
      AsyncAction('AssetStoreBase.loadHistoryFromCache', context: context);

  @override
  Future<void> loadHistoryFromCache() {
    return _$loadHistoryFromCacheAsyncAction
        .run(() => super.loadHistoryFromCache());
  }

  late final _$refreshAllAsyncAction =
      AsyncAction('AssetStoreBase.refreshAll', context: context);

  @override
  Future<void> refreshAll() {
    return _$refreshAllAsyncAction.run(() => super.refreshAll());
  }

  late final _$AssetStoreBaseActionController =
      ActionController(name: 'AssetStoreBase', context: context);

  @override
  void searchAssets(String query) {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.searchAssets');
    try {
      return super.searchAssets(query);
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void filterByStatus(String? status) {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.filterByStatus');
    try {
      return super.filterByStatus(status);
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void filterByCategory(int? categoryId) {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.filterByCategory');
    try {
      return super.filterByCategory(categoryId);
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearFilters() {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentAsset(AssetModel? asset) {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.setCurrentAsset');
    try {
      return super.setCurrentAsset(asset);
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCurrentAsset() {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.clearCurrentAsset');
    try {
      return super.clearCurrentAsset();
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$AssetStoreBaseActionController.startAction(
        name: 'AssetStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$AssetStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
assetList: ${assetList},
currentAsset: ${currentAsset},
assignmentHistory: ${assignmentHistory},
assetDocuments: ${assetDocuments},
maintenanceHistory: ${maintenanceHistory},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
isLoadingDetails: ${isLoadingDetails},
isReportingIssue: ${isReportingIssue},
isScanningQR: ${isScanningQR},
isLoadingMaintenance: ${isLoadingMaintenance},
hasMoreData: ${hasMoreData},
totalAssetsCount: ${totalAssetsCount},
currentPage: ${currentPage},
itemsPerPage: ${itemsPerPage},
totalHistoryCount: ${totalHistoryCount},
hasMoreHistory: ${hasMoreHistory},
currentHistoryPage: ${currentHistoryPage},
totalMaintenanceCount: ${totalMaintenanceCount},
hasMoreMaintenance: ${hasMoreMaintenance},
currentMaintenancePage: ${currentMaintenancePage},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
selectedStatus: ${selectedStatus},
selectedCategoryId: ${selectedCategoryId},
filteredAssets: ${filteredAssets},
activeAssignmentsCount: ${activeAssignmentsCount},
hasAssets: ${hasAssets},
hasFiltersApplied: ${hasFiltersApplied}
    ''';
  }
}
