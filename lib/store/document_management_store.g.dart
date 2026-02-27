// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_management_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DocumentManagementStore on DocumentManagementStoreBase, Store {
  Computed<int>? _$totalDocumentRequestsComputed;

  @override
  int get totalDocumentRequests => (_$totalDocumentRequestsComputed ??=
          Computed<int>(() => super.totalDocumentRequests,
              name: 'DocumentManagementStoreBase.totalDocumentRequests'))
      .value;
  Computed<int>? _$totalMyDocumentsComputed;

  @override
  int get totalMyDocuments => (_$totalMyDocumentsComputed ??= Computed<int>(
          () => super.totalMyDocuments,
          name: 'DocumentManagementStoreBase.totalMyDocuments'))
      .value;
  Computed<int>? _$pendingRequestsCountComputed;

  @override
  int get pendingRequestsCount => (_$pendingRequestsCountComputed ??=
          Computed<int>(() => super.pendingRequestsCount,
              name: 'DocumentManagementStoreBase.pendingRequestsCount'))
      .value;
  Computed<int>? _$generatedRequestsCountComputed;

  @override
  int get generatedRequestsCount => (_$generatedRequestsCountComputed ??=
          Computed<int>(() => super.generatedRequestsCount,
              name: 'DocumentManagementStoreBase.generatedRequestsCount'))
      .value;
  Computed<int>? _$expiringDocumentsCountComputed;

  @override
  int get expiringDocumentsCount => (_$expiringDocumentsCountComputed ??=
          Computed<int>(() => super.expiringDocumentsCount,
              name: 'DocumentManagementStoreBase.expiringDocumentsCount'))
      .value;
  Computed<int>? _$expiredDocumentsCountComputed;

  @override
  int get expiredDocumentsCount => (_$expiredDocumentsCountComputed ??=
          Computed<int>(() => super.expiredDocumentsCount,
              name: 'DocumentManagementStoreBase.expiredDocumentsCount'))
      .value;
  Computed<bool>? _$hasExpiringDocumentsComputed;

  @override
  bool get hasExpiringDocuments => (_$hasExpiringDocumentsComputed ??=
          Computed<bool>(() => super.hasExpiringDocuments,
              name: 'DocumentManagementStoreBase.hasExpiringDocuments'))
      .value;
  Computed<bool>? _$hasExpiredDocumentsComputed;

  @override
  bool get hasExpiredDocuments => (_$hasExpiredDocumentsComputed ??=
          Computed<bool>(() => super.hasExpiredDocuments,
              name: 'DocumentManagementStoreBase.hasExpiredDocuments'))
      .value;
  Computed<List<DocumentRequestModel>>? _$pendingRequestsComputed;

  @override
  List<DocumentRequestModel> get pendingRequests =>
      (_$pendingRequestsComputed ??= Computed<List<DocumentRequestModel>>(
              () => super.pendingRequests,
              name: 'DocumentManagementStoreBase.pendingRequests'))
          .value;
  Computed<List<DocumentRequestModel>>? _$generatedRequestsComputed;

  @override
  List<DocumentRequestModel> get generatedRequests =>
      (_$generatedRequestsComputed ??= Computed<List<DocumentRequestModel>>(
              () => super.generatedRequests,
              name: 'DocumentManagementStoreBase.generatedRequests'))
          .value;
  Computed<List<MyDocumentModel>>? _$verifiedDocumentsComputed;

  @override
  List<MyDocumentModel> get verifiedDocuments =>
      (_$verifiedDocumentsComputed ??= Computed<List<MyDocumentModel>>(
              () => super.verifiedDocuments,
              name: 'DocumentManagementStoreBase.verifiedDocuments'))
          .value;
  Computed<List<MyDocumentModel>>? _$pendingVerificationDocumentsComputed;

  @override
  List<MyDocumentModel> get pendingVerificationDocuments =>
      (_$pendingVerificationDocumentsComputed ??= Computed<
                  List<MyDocumentModel>>(
              () => super.pendingVerificationDocuments,
              name: 'DocumentManagementStoreBase.pendingVerificationDocuments'))
          .value;

  late final _$documentRequestsAtom = Atom(
      name: 'DocumentManagementStoreBase.documentRequests', context: context);

  @override
  ObservableList<DocumentRequestModel> get documentRequests {
    _$documentRequestsAtom.reportRead();
    return super.documentRequests;
  }

  @override
  set documentRequests(ObservableList<DocumentRequestModel> value) {
    _$documentRequestsAtom.reportWrite(value, super.documentRequests, () {
      super.documentRequests = value;
    });
  }

  late final _$requestStatisticsAtom = Atom(
      name: 'DocumentManagementStoreBase.requestStatistics', context: context);

  @override
  DocumentRequestStatistics? get requestStatistics {
    _$requestStatisticsAtom.reportRead();
    return super.requestStatistics;
  }

  @override
  set requestStatistics(DocumentRequestStatistics? value) {
    _$requestStatisticsAtom.reportWrite(value, super.requestStatistics, () {
      super.requestStatistics = value;
    });
  }

  late final _$isLoadingRequestsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingRequests', context: context);

  @override
  bool get isLoadingRequests {
    _$isLoadingRequestsAtom.reportRead();
    return super.isLoadingRequests;
  }

  @override
  set isLoadingRequests(bool value) {
    _$isLoadingRequestsAtom.reportWrite(value, super.isLoadingRequests, () {
      super.isLoadingRequests = value;
    });
  }

  late final _$isLoadingRequestStatsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingRequestStats',
      context: context);

  @override
  bool get isLoadingRequestStats {
    _$isLoadingRequestStatsAtom.reportRead();
    return super.isLoadingRequestStats;
  }

  @override
  set isLoadingRequestStats(bool value) {
    _$isLoadingRequestStatsAtom.reportWrite(value, super.isLoadingRequestStats,
        () {
      super.isLoadingRequestStats = value;
    });
  }

  late final _$requestCurrentPageAtom = Atom(
      name: 'DocumentManagementStoreBase.requestCurrentPage', context: context);

  @override
  int get requestCurrentPage {
    _$requestCurrentPageAtom.reportRead();
    return super.requestCurrentPage;
  }

  @override
  set requestCurrentPage(int value) {
    _$requestCurrentPageAtom.reportWrite(value, super.requestCurrentPage, () {
      super.requestCurrentPage = value;
    });
  }

  late final _$requestTotalPagesAtom = Atom(
      name: 'DocumentManagementStoreBase.requestTotalPages', context: context);

  @override
  int get requestTotalPages {
    _$requestTotalPagesAtom.reportRead();
    return super.requestTotalPages;
  }

  @override
  set requestTotalPages(int value) {
    _$requestTotalPagesAtom.reportWrite(value, super.requestTotalPages, () {
      super.requestTotalPages = value;
    });
  }

  late final _$requestStatusFilterAtom = Atom(
      name: 'DocumentManagementStoreBase.requestStatusFilter',
      context: context);

  @override
  String? get requestStatusFilter {
    _$requestStatusFilterAtom.reportRead();
    return super.requestStatusFilter;
  }

  @override
  set requestStatusFilter(String? value) {
    _$requestStatusFilterAtom.reportWrite(value, super.requestStatusFilter, () {
      super.requestStatusFilter = value;
    });
  }

  late final _$myDocumentsAtom =
      Atom(name: 'DocumentManagementStoreBase.myDocuments', context: context);

  @override
  ObservableList<MyDocumentModel> get myDocuments {
    _$myDocumentsAtom.reportRead();
    return super.myDocuments;
  }

  @override
  set myDocuments(ObservableList<MyDocumentModel> value) {
    _$myDocumentsAtom.reportWrite(value, super.myDocuments, () {
      super.myDocuments = value;
    });
  }

  late final _$documentStatisticsAtom = Atom(
      name: 'DocumentManagementStoreBase.documentStatistics', context: context);

  @override
  MyDocumentStatistics? get documentStatistics {
    _$documentStatisticsAtom.reportRead();
    return super.documentStatistics;
  }

  @override
  set documentStatistics(MyDocumentStatistics? value) {
    _$documentStatisticsAtom.reportWrite(value, super.documentStatistics, () {
      super.documentStatistics = value;
    });
  }

  late final _$isLoadingDocumentsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingDocuments', context: context);

  @override
  bool get isLoadingDocuments {
    _$isLoadingDocumentsAtom.reportRead();
    return super.isLoadingDocuments;
  }

  @override
  set isLoadingDocuments(bool value) {
    _$isLoadingDocumentsAtom.reportWrite(value, super.isLoadingDocuments, () {
      super.isLoadingDocuments = value;
    });
  }

  late final _$isLoadingDocumentStatsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingDocumentStats',
      context: context);

  @override
  bool get isLoadingDocumentStats {
    _$isLoadingDocumentStatsAtom.reportRead();
    return super.isLoadingDocumentStats;
  }

  @override
  set isLoadingDocumentStats(bool value) {
    _$isLoadingDocumentStatsAtom
        .reportWrite(value, super.isLoadingDocumentStats, () {
      super.isLoadingDocumentStats = value;
    });
  }

  late final _$documentCurrentPageAtom = Atom(
      name: 'DocumentManagementStoreBase.documentCurrentPage',
      context: context);

  @override
  int get documentCurrentPage {
    _$documentCurrentPageAtom.reportRead();
    return super.documentCurrentPage;
  }

  @override
  set documentCurrentPage(int value) {
    _$documentCurrentPageAtom.reportWrite(value, super.documentCurrentPage, () {
      super.documentCurrentPage = value;
    });
  }

  late final _$documentTotalPagesAtom = Atom(
      name: 'DocumentManagementStoreBase.documentTotalPages', context: context);

  @override
  int get documentTotalPages {
    _$documentTotalPagesAtom.reportRead();
    return super.documentTotalPages;
  }

  @override
  set documentTotalPages(int value) {
    _$documentTotalPagesAtom.reportWrite(value, super.documentTotalPages, () {
      super.documentTotalPages = value;
    });
  }

  late final _$documentCategoryFilterAtom = Atom(
      name: 'DocumentManagementStoreBase.documentCategoryFilter',
      context: context);

  @override
  String? get documentCategoryFilter {
    _$documentCategoryFilterAtom.reportRead();
    return super.documentCategoryFilter;
  }

  @override
  set documentCategoryFilter(String? value) {
    _$documentCategoryFilterAtom
        .reportWrite(value, super.documentCategoryFilter, () {
      super.documentCategoryFilter = value;
    });
  }

  late final _$documentStatusFilterAtom = Atom(
      name: 'DocumentManagementStoreBase.documentStatusFilter',
      context: context);

  @override
  String? get documentStatusFilter {
    _$documentStatusFilterAtom.reportRead();
    return super.documentStatusFilter;
  }

  @override
  set documentStatusFilter(String? value) {
    _$documentStatusFilterAtom.reportWrite(value, super.documentStatusFilter,
        () {
      super.documentStatusFilter = value;
    });
  }

  late final _$documentTypesAtom =
      Atom(name: 'DocumentManagementStoreBase.documentTypes', context: context);

  @override
  ObservableList<DocumentTypeModel> get documentTypes {
    _$documentTypesAtom.reportRead();
    return super.documentTypes;
  }

  @override
  set documentTypes(ObservableList<DocumentTypeModel> value) {
    _$documentTypesAtom.reportWrite(value, super.documentTypes, () {
      super.documentTypes = value;
    });
  }

  late final _$documentCategoriesAtom = Atom(
      name: 'DocumentManagementStoreBase.documentCategories', context: context);

  @override
  ObservableList<DocumentCategoryModel> get documentCategories {
    _$documentCategoriesAtom.reportRead();
    return super.documentCategories;
  }

  @override
  set documentCategories(ObservableList<DocumentCategoryModel> value) {
    _$documentCategoriesAtom.reportWrite(value, super.documentCategories, () {
      super.documentCategories = value;
    });
  }

  late final _$isLoadingDocumentTypesAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingDocumentTypes',
      context: context);

  @override
  bool get isLoadingDocumentTypes {
    _$isLoadingDocumentTypesAtom.reportRead();
    return super.isLoadingDocumentTypes;
  }

  @override
  set isLoadingDocumentTypes(bool value) {
    _$isLoadingDocumentTypesAtom
        .reportWrite(value, super.isLoadingDocumentTypes, () {
      super.isLoadingDocumentTypes = value;
    });
  }

  late final _$isLoadingDocumentCategoriesAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingDocumentCategories',
      context: context);

  @override
  bool get isLoadingDocumentCategories {
    _$isLoadingDocumentCategoriesAtom.reportRead();
    return super.isLoadingDocumentCategories;
  }

  @override
  set isLoadingDocumentCategories(bool value) {
    _$isLoadingDocumentCategoriesAtom
        .reportWrite(value, super.isLoadingDocumentCategories, () {
      super.isLoadingDocumentCategories = value;
    });
  }

  late final _$expiringDocumentsAtom = Atom(
      name: 'DocumentManagementStoreBase.expiringDocuments', context: context);

  @override
  ObservableList<MyDocumentModel> get expiringDocuments {
    _$expiringDocumentsAtom.reportRead();
    return super.expiringDocuments;
  }

  @override
  set expiringDocuments(ObservableList<MyDocumentModel> value) {
    _$expiringDocumentsAtom.reportWrite(value, super.expiringDocuments, () {
      super.expiringDocuments = value;
    });
  }

  late final _$expiredDocumentsAtom = Atom(
      name: 'DocumentManagementStoreBase.expiredDocuments', context: context);

  @override
  ObservableList<MyDocumentModel> get expiredDocuments {
    _$expiredDocumentsAtom.reportRead();
    return super.expiredDocuments;
  }

  @override
  set expiredDocuments(ObservableList<MyDocumentModel> value) {
    _$expiredDocumentsAtom.reportWrite(value, super.expiredDocuments, () {
      super.expiredDocuments = value;
    });
  }

  late final _$isLoadingExpiringDocumentsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingExpiringDocuments',
      context: context);

  @override
  bool get isLoadingExpiringDocuments {
    _$isLoadingExpiringDocumentsAtom.reportRead();
    return super.isLoadingExpiringDocuments;
  }

  @override
  set isLoadingExpiringDocuments(bool value) {
    _$isLoadingExpiringDocumentsAtom
        .reportWrite(value, super.isLoadingExpiringDocuments, () {
      super.isLoadingExpiringDocuments = value;
    });
  }

  late final _$isLoadingExpiredDocumentsAtom = Atom(
      name: 'DocumentManagementStoreBase.isLoadingExpiredDocuments',
      context: context);

  @override
  bool get isLoadingExpiredDocuments {
    _$isLoadingExpiredDocumentsAtom.reportRead();
    return super.isLoadingExpiredDocuments;
  }

  @override
  set isLoadingExpiredDocuments(bool value) {
    _$isLoadingExpiredDocumentsAtom
        .reportWrite(value, super.isLoadingExpiredDocuments, () {
      super.isLoadingExpiredDocuments = value;
    });
  }

  late final _$fetchDocumentRequestsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchDocumentRequests',
      context: context);

  @override
  Future<void> fetchDocumentRequests(
      {String? status, int? documentTypeId, int page = 1}) {
    return _$fetchDocumentRequestsAsyncAction.run(() => super
        .fetchDocumentRequests(
            status: status, documentTypeId: documentTypeId, page: page));
  }

  late final _$fetchRequestStatisticsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchRequestStatistics',
      context: context);

  @override
  Future<void> fetchRequestStatistics() {
    return _$fetchRequestStatisticsAsyncAction
        .run(() => super.fetchRequestStatistics());
  }

  late final _$fetchDocumentTypesAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchDocumentTypes',
      context: context);

  @override
  Future<void> fetchDocumentTypes() {
    return _$fetchDocumentTypesAsyncAction
        .run(() => super.fetchDocumentTypes());
  }

  late final _$requestDocumentAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.requestDocument',
      context: context);

  @override
  Future<bool> requestDocument({required int documentTypeId, String? remarks}) {
    return _$requestDocumentAsyncAction.run(() => super
        .requestDocument(documentTypeId: documentTypeId, remarks: remarks));
  }

  late final _$cancelDocumentRequestAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.cancelDocumentRequest',
      context: context);

  @override
  Future<bool> cancelDocumentRequest(int id) {
    return _$cancelDocumentRequestAsyncAction
        .run(() => super.cancelDocumentRequest(id));
  }

  late final _$getRequestDownloadUrlAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.getRequestDownloadUrl',
      context: context);

  @override
  Future<Map<String, String>?> getRequestDownloadUrl(int id) {
    return _$getRequestDownloadUrlAsyncAction
        .run(() => super.getRequestDownloadUrl(id));
  }

  late final _$fetchMyDocumentsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchMyDocuments',
      context: context);

  @override
  Future<void> fetchMyDocuments(
      {int? categoryId,
      String? status,
      String? expiryStatus,
      String? search,
      int page = 1}) {
    return _$fetchMyDocumentsAsyncAction.run(() => super.fetchMyDocuments(
        categoryId: categoryId,
        status: status,
        expiryStatus: expiryStatus,
        search: search,
        page: page));
  }

  late final _$fetchDocumentStatisticsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchDocumentStatistics',
      context: context);

  @override
  Future<void> fetchDocumentStatistics() {
    return _$fetchDocumentStatisticsAsyncAction
        .run(() => super.fetchDocumentStatistics());
  }

  late final _$fetchDocumentCategoriesAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchDocumentCategories',
      context: context);

  @override
  Future<void> fetchDocumentCategories() {
    return _$fetchDocumentCategoriesAsyncAction
        .run(() => super.fetchDocumentCategories());
  }

  late final _$fetchExpiringDocumentsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchExpiringDocuments',
      context: context);

  @override
  Future<void> fetchExpiringDocuments({int days = 30}) {
    return _$fetchExpiringDocumentsAsyncAction
        .run(() => super.fetchExpiringDocuments(days: days));
  }

  late final _$fetchExpiredDocumentsAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.fetchExpiredDocuments',
      context: context);

  @override
  Future<void> fetchExpiredDocuments() {
    return _$fetchExpiredDocumentsAsyncAction
        .run(() => super.fetchExpiredDocuments());
  }

  late final _$getDocumentDownloadUrlAsyncAction = AsyncAction(
      'DocumentManagementStoreBase.getDocumentDownloadUrl',
      context: context);

  @override
  Future<Map<String, String>?> getDocumentDownloadUrl(int id) {
    return _$getDocumentDownloadUrlAsyncAction
        .run(() => super.getDocumentDownloadUrl(id));
  }

  late final _$DocumentManagementStoreBaseActionController =
      ActionController(name: 'DocumentManagementStoreBase', context: context);

  @override
  void clearFilters() {
    final _$actionInfo = _$DocumentManagementStoreBaseActionController
        .startAction(name: 'DocumentManagementStoreBase.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$DocumentManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void refreshAll() {
    final _$actionInfo = _$DocumentManagementStoreBaseActionController
        .startAction(name: 'DocumentManagementStoreBase.refreshAll');
    try {
      return super.refreshAll();
    } finally {
      _$DocumentManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
documentRequests: ${documentRequests},
requestStatistics: ${requestStatistics},
isLoadingRequests: ${isLoadingRequests},
isLoadingRequestStats: ${isLoadingRequestStats},
requestCurrentPage: ${requestCurrentPage},
requestTotalPages: ${requestTotalPages},
requestStatusFilter: ${requestStatusFilter},
myDocuments: ${myDocuments},
documentStatistics: ${documentStatistics},
isLoadingDocuments: ${isLoadingDocuments},
isLoadingDocumentStats: ${isLoadingDocumentStats},
documentCurrentPage: ${documentCurrentPage},
documentTotalPages: ${documentTotalPages},
documentCategoryFilter: ${documentCategoryFilter},
documentStatusFilter: ${documentStatusFilter},
documentTypes: ${documentTypes},
documentCategories: ${documentCategories},
isLoadingDocumentTypes: ${isLoadingDocumentTypes},
isLoadingDocumentCategories: ${isLoadingDocumentCategories},
expiringDocuments: ${expiringDocuments},
expiredDocuments: ${expiredDocuments},
isLoadingExpiringDocuments: ${isLoadingExpiringDocuments},
isLoadingExpiredDocuments: ${isLoadingExpiredDocuments},
totalDocumentRequests: ${totalDocumentRequests},
totalMyDocuments: ${totalMyDocuments},
pendingRequestsCount: ${pendingRequestsCount},
generatedRequestsCount: ${generatedRequestsCount},
expiringDocumentsCount: ${expiringDocumentsCount},
expiredDocumentsCount: ${expiredDocumentsCount},
hasExpiringDocuments: ${hasExpiringDocuments},
hasExpiredDocuments: ${hasExpiredDocuments},
pendingRequests: ${pendingRequests},
generatedRequests: ${generatedRequests},
verifiedDocuments: ${verifiedDocuments},
pendingVerificationDocuments: ${pendingVerificationDocuments}
    ''';
  }
}
