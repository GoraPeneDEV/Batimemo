import '../base_repository.dart';
import '../../../models/Document/document_request_model.dart';
import '../../../models/Document/document_type_model.dart';

/// Repository for Document Requests API
/// Handles all employee document request operations
class DocumentRequestRepository extends BaseRepository {
  /// Get all document requests for the authenticated employee
  Future<Map<String, dynamic>?> getMyDocumentRequests({
    String? status,
    int? documentTypeId,
    String? date,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) queryParams['status'] = status;
    if (documentTypeId != null) {
      queryParams['document_type_id'] = documentTypeId;
    }
    if (date != null) queryParams['date'] = date;

    return await safeApiCall(
      () => dioClient.get('document-requests', queryParameters: queryParams),
      parser: (data) {
        final responseData = data['data'];
        final documentRequests = responseData['document_requests'];
        final meta = documentRequests['meta'];

        return {
          'data': (documentRequests['data'] as List? ?? [])
              .map((item) => DocumentRequestModel.fromJson(item))
              .toList(),
          'current_page': meta['current_page'] ?? 1,
          'last_page': meta['last_page'] ?? 1,
          'total': meta['total'] ?? 0,
          'per_page': meta['per_page'] ?? 15,
        };
      },
    );
  }

  /// Get statistics for my document requests
  Future<DocumentRequestStatistics?> getMyStatistics() async {
    return await safeApiCall(
      () => dioClient.get('document-requests/statistics'),
      parser: (data) {
        return DocumentRequestStatistics.fromJson(
          data['data']['statistics'],
        );
      },
    );
  }

  /// Get available document types for requesting
  Future<List<DocumentTypeModel>> getAvailableDocumentTypes() async {
    return await safeApiCall(
      () => dioClient.get('document-requests/document-types'),
      parser: (data) {
        return (data['data']['document_types'] as List? ?? [])
            .map((item) => DocumentTypeModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Request a new document
  Future<DocumentRequestModel?> requestDocument({
    required int documentTypeId,
    String? remarks,
  }) async {
    return await safeApiCall(
      () => dioClient.post('document-requests', data: {
        'document_type_id': documentTypeId,
        if (remarks != null) 'remarks': remarks,
      }),
      parser: (data) {
        return DocumentRequestModel.fromJson(
          data['data']['document_request'],
        );
      },
    );
  }

  /// Get single document request details
  Future<DocumentRequestModel?> getDocumentRequest(int id) async {
    return await safeApiCall(
      () => dioClient.get('document-requests/$id'),
      parser: (data) {
        return DocumentRequestModel.fromJson(data['data']);
      },
    );
  }

  /// Cancel a pending document request
  Future<bool> cancelDocumentRequest(int id) async {
    final response = await safeApiCallWithResponse(
      () => dioClient.post('document-requests/$id/cancel'),
    );
    return response?.status == 'success';
  }

  /// Get download URL for generated document
  Future<Map<String, String>?> getDownloadUrl(int id) async {
    return await safeApiCall(
      () => dioClient.get('document-requests/$id/download'),
      parser: (data) {
        final downloadData = data['data'];
        return {
          'file_url': downloadData['file_url'] ?? '',
          'file_name': downloadData['file_name'] ?? '',
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
