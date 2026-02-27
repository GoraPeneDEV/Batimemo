import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../api/dio_api/repositories/document_request_repository.dart';
import '../api/dio_api/repositories/my_documents_repository.dart';
import '../models/Document/document_request_model.dart';
import '../models/Document/my_document_model.dart';
import '../models/Document/document_type_model.dart';
import '../models/Document/document_category_model.dart';

part 'document_management_store.g.dart';

class DocumentManagementStore = DocumentManagementStoreBase
    with _$DocumentManagementStore;

abstract class DocumentManagementStoreBase with Store {
  final DocumentRequestRepository _documentRequestRepo =
      DocumentRequestRepository();
  final MyDocumentsRepository _myDocumentsRepo = MyDocumentsRepository();

  // Document Requests
  @observable
  ObservableList<DocumentRequestModel> documentRequests =
      ObservableList<DocumentRequestModel>();

  @observable
  DocumentRequestStatistics? requestStatistics;

  @observable
  bool isLoadingRequests = false;

  @observable
  bool isLoadingRequestStats = false;

  @observable
  int requestCurrentPage = 1;

  @observable
  int requestTotalPages = 1;

  @observable
  String? requestStatusFilter;

  // My Documents
  @observable
  ObservableList<MyDocumentModel> myDocuments =
      ObservableList<MyDocumentModel>();

  @observable
  MyDocumentStatistics? documentStatistics;

  @observable
  bool isLoadingDocuments = false;

  @observable
  bool isLoadingDocumentStats = false;

  @observable
  int documentCurrentPage = 1;

  @observable
  int documentTotalPages = 1;

  @observable
  String? documentCategoryFilter;

  @observable
  String? documentStatusFilter;

  // Document Types and Categories
  @observable
  ObservableList<DocumentTypeModel> documentTypes =
      ObservableList<DocumentTypeModel>();

  @observable
  ObservableList<DocumentCategoryModel> documentCategories =
      ObservableList<DocumentCategoryModel>();

  @observable
  bool isLoadingDocumentTypes = false;

  @observable
  bool isLoadingDocumentCategories = false;

  // Expiring and Expired Documents
  @observable
  ObservableList<MyDocumentModel> expiringDocuments =
      ObservableList<MyDocumentModel>();

  @observable
  ObservableList<MyDocumentModel> expiredDocuments =
      ObservableList<MyDocumentModel>();

  @observable
  bool isLoadingExpiringDocuments = false;

  @observable
  bool isLoadingExpiredDocuments = false;

  // Document Requests Actions
  @action
  Future<void> fetchDocumentRequests({
    String? status,
    int? documentTypeId,
    int page = 1,
  }) async {
    try {
      isLoadingRequests = true;
      requestStatusFilter = status;
      requestCurrentPage = page;

      final result = await _documentRequestRepo.getMyDocumentRequests(
        status: status,
        documentTypeId: documentTypeId,
        page: page,
      );

      if (result != null) {
        if (page == 1) {
          documentRequests.clear();
        }
        documentRequests.addAll(result['data']);
        final meta = result['meta'];
        requestTotalPages = meta['last_page'] ?? 1;
      }
    } catch (e) {
      toast('Failed to load document requests: ${e.toString()}');
    } finally {
      isLoadingRequests = false;
    }
  }

  @action
  Future<void> fetchRequestStatistics() async {
    try {
      isLoadingRequestStats = true;
      final stats = await _documentRequestRepo.getMyStatistics();
      if (stats != null) {
        requestStatistics = stats;
      }
    } catch (e) {
      toast('Failed to load statistics: ${e.toString()}');
    } finally {
      isLoadingRequestStats = false;
    }
  }

  @action
  Future<void> fetchDocumentTypes() async {
    try {
      isLoadingDocumentTypes = true;
      final types = await _documentRequestRepo.getAvailableDocumentTypes();
      documentTypes.clear();
      documentTypes.addAll(types);
    } catch (e) {
      toast('Failed to load document types: ${e.toString()}');
    } finally {
      isLoadingDocumentTypes = false;
    }
  }

  @action
  Future<bool> requestDocument({
    required int documentTypeId,
    String? remarks,
  }) async {
    try {
      final result = await _documentRequestRepo.requestDocument(
        documentTypeId: documentTypeId,
        remarks: remarks,
      );

      if (result != null) {
        documentRequests.insert(0, result);
        toast('Document request submitted successfully');
        // Refresh statistics
        fetchRequestStatistics();
        return true;
      }
      return false;
    } catch (e) {
      toast('Failed to submit request: ${e.toString()}');
      return false;
    }
  }

  @action
  Future<bool> cancelDocumentRequest(int id) async {
    try {
      final success = await _documentRequestRepo.cancelDocumentRequest(id);
      if (success) {
        // Update local list
        final index = documentRequests.indexWhere((req) => req.id == id);
        if (index != -1) {
          documentRequests[index].status = 'cancelled';
          documentRequests[index].canCancel = false;
        }
        toast('Request cancelled successfully');
        // Refresh statistics
        fetchRequestStatistics();
        return true;
      }
      return false;
    } catch (e) {
      toast('Failed to cancel request: ${e.toString()}');
      return false;
    }
  }

  @action
  Future<Map<String, String>?> getRequestDownloadUrl(int id) async {
    try {
      return await _documentRequestRepo.getDownloadUrl(id);
    } catch (e) {
      toast('Failed to get download URL: ${e.toString()}');
      return null;
    }
  }

  // My Documents Actions
  @action
  Future<void> fetchMyDocuments({
    int? categoryId,
    String? status,
    String? expiryStatus,
    String? search,
    int page = 1,
  }) async {
    try {
      isLoadingDocuments = true;
      documentCategoryFilter = categoryId?.toString();
      documentStatusFilter = status;
      documentCurrentPage = page;

      final result = await _myDocumentsRepo.getMyDocuments(
        categoryId: categoryId,
        status: status,
        expiryStatus: expiryStatus,
        search: search,
        page: page,
      );

      if (result != null) {
        if (page == 1) {
          myDocuments.clear();
        }
        myDocuments.addAll(result['data']);
        final meta = result['meta'];
        documentTotalPages = meta['last_page'] ?? 1;
      }
    } catch (e) {
      toast('Failed to load documents: ${e.toString()}');
    } finally {
      isLoadingDocuments = false;
    }
  }

  @action
  Future<void> fetchDocumentStatistics() async {
    try {
      isLoadingDocumentStats = true;
      final stats = await _myDocumentsRepo.getMyStatistics();
      if (stats != null) {
        documentStatistics = stats;
      }
    } catch (e) {
      toast('Failed to load statistics: ${e.toString()}');
    } finally {
      isLoadingDocumentStats = false;
    }
  }

  @action
  Future<void> fetchDocumentCategories() async {
    try {
      isLoadingDocumentCategories = true;
      final categories = await _myDocumentsRepo.getCategories();
      documentCategories.clear();
      documentCategories.addAll(categories);
    } catch (e) {
      toast('Failed to load categories: ${e.toString()}');
    } finally {
      isLoadingDocumentCategories = false;
    }
  }

  @action
  Future<void> fetchExpiringDocuments({int days = 30}) async {
    try {
      isLoadingExpiringDocuments = true;
      final documents = await _myDocumentsRepo.getExpiringDocuments(days: days);
      expiringDocuments.clear();
      expiringDocuments.addAll(documents);
    } catch (e) {
      toast('Failed to load expiring documents: ${e.toString()}');
    } finally {
      isLoadingExpiringDocuments = false;
    }
  }

  @action
  Future<void> fetchExpiredDocuments() async {
    try {
      isLoadingExpiredDocuments = true;
      final documents = await _myDocumentsRepo.getExpiredDocuments();
      expiredDocuments.clear();
      expiredDocuments.addAll(documents);
    } catch (e) {
      toast('Failed to load expired documents: ${e.toString()}');
    } finally {
      isLoadingExpiredDocuments = false;
    }
  }

  @action
  Future<Map<String, String>?> getDocumentDownloadUrl(int id) async {
    try {
      return await _myDocumentsRepo.getDownloadUrl(id);
    } catch (e) {
      toast('Failed to get download URL: ${e.toString()}');
      return null;
    }
  }

  // Computed values
  @computed
  int get totalDocumentRequests => documentRequests.length;

  @computed
  int get totalMyDocuments => myDocuments.length;

  @computed
  int get pendingRequestsCount => requestStatistics?.pending ?? 0;

  @computed
  int get generatedRequestsCount => requestStatistics?.generated ?? 0;

  @computed
  int get expiringDocumentsCount => documentStatistics?.expiringSoon ?? 0;

  @computed
  int get expiredDocumentsCount => documentStatistics?.expired ?? 0;

  @computed
  bool get hasExpiringDocuments => expiringDocumentsCount > 0;

  @computed
  bool get hasExpiredDocuments => expiredDocumentsCount > 0;

  // Filter methods
  @computed
  List<DocumentRequestModel> get pendingRequests =>
      documentRequests.where((req) => req.status == 'pending').toList();

  @computed
  List<DocumentRequestModel> get generatedRequests =>
      documentRequests.where((req) => req.status == 'generated').toList();

  @computed
  List<MyDocumentModel> get verifiedDocuments =>
      myDocuments.where((doc) => doc.verificationStatus == 'verified').toList();

  @computed
  List<MyDocumentModel> get pendingVerificationDocuments => myDocuments
      .where((doc) => doc.verificationStatus == 'pending')
      .toList();

  // Utility methods
  @action
  void clearFilters() {
    requestStatusFilter = null;
    documentCategoryFilter = null;
    documentStatusFilter = null;
  }

  @action
  void refreshAll() {
    fetchDocumentRequests();
    fetchRequestStatistics();
    fetchMyDocuments();
    fetchDocumentStatistics();
    fetchExpiringDocuments();
    fetchExpiredDocuments();
  }
}
