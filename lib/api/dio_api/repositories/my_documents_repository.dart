import '../base_repository.dart';
import '../../../models/Document/my_document_model.dart';
import '../../../models/Document/document_category_model.dart';

/// Repository for My Documents API
/// Handles personal employee documents (passport, ID, certificates, etc.)
class MyDocumentsRepository extends BaseRepository {
  /// Get all my documents
  Future<Map<String, dynamic>?> getMyDocuments({
    int? categoryId,
    String? status,
    String? expiryStatus,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (status != null) queryParams['status'] = status;
    if (expiryStatus != null) queryParams['expiry_status'] = expiryStatus;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await safeApiCall(
      () => dioClient.get('my-documents', queryParameters: queryParams),
      parser: (data) {
        final responseData = data['data'];
        final documents = responseData['employee_documents'];

        return {
          'data': (documents['data'] as List)
              .map((item) => MyDocumentModel.fromJson(item))
              .toList(),
          'meta': documents['meta'],
        };
      },
    );
  }

  /// Get statistics for my documents
  Future<MyDocumentStatistics?> getMyStatistics() async {
    return await safeApiCall(
      () => dioClient.get('my-documents/statistics'),
      parser: (data) {
        return MyDocumentStatistics.fromJson(data['data']['statistics']);
      },
    );
  }

  /// Get available document categories
  Future<List<DocumentCategoryModel>> getCategories() async {
    return await safeApiCallList(
      () => dioClient.get('my-documents/categories'),
      itemParser: (item) => DocumentCategoryModel.fromJson(item),
    );
  }

  /// Get documents expiring soon
  Future<List<MyDocumentModel>> getExpiringDocuments({int days = 30}) async {
    return await safeApiCallList(
      () => dioClient.get(
        'my-documents/expiring',
        queryParameters: {'days': days},
      ),
      itemParser: (item) => MyDocumentModel.fromJson(item),
    );
  }

  /// Get expired documents
  Future<List<MyDocumentModel>> getExpiredDocuments() async {
    return await safeApiCallList(
      () => dioClient.get('my-documents/expired'),
      itemParser: (item) => MyDocumentModel.fromJson(item),
    );
  }

  /// Get single document details
  Future<MyDocumentModel?> getDocument(int id) async {
    return await safeApiCall(
      () => dioClient.get('my-documents/$id'),
      parser: (data) {
        final documentData = data['data']['document'];
        return MyDocumentModel.fromJson(documentData);
      },
    );
  }

  /// Get download URL for document
  Future<Map<String, String>?> getDownloadUrl(int id) async {
    return await safeApiCall(
      () => dioClient.get('my-documents/$id/download'),
      parser: (data) {
        final downloadData = data['data'];
        return {
          'file_url': downloadData['file_url'] ?? '',
          'file_name': downloadData['file_name'] ?? '',
          'mime_type': downloadData['mime_type'] ?? '',
        };
      },
    );
  }

  /// Download document file
  Future<void> downloadDocument({
    required int id,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    final downloadInfo = await getDownloadUrl(id);
    if (downloadInfo == null || downloadInfo['file_url'] == null) {
      throw Exception('Download URL not available');
    }

    await dioClient.downloadFile(
      downloadInfo['file_url']!,
      savePath,
      onReceiveProgress: onProgress,
    );
  }
}
