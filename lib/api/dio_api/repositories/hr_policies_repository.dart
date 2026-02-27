import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/HRPolicies/policy_model.dart';
import '../../../models/HRPolicies/policy_stats_model.dart';
import '../../../models/HRPolicies/policy_detail_model.dart';
import '../../../models/HRPolicies/policy_category_model.dart';
import '../../../models/HRPolicies/acknowledgment_response_model.dart';

class HRPoliciesRepository extends BaseRepository {
  /// Get all policies assigned to the authenticated user
  /// GET /api/V1/policies/my-policies
  Future<List<PolicyModel>> getMyPolicies() async {
    return await safeApiCall(
      () => dioClient.get('policies/my-policies'),
      parser: (data) {
        return (data['data'] as List? ?? [])
            .map((item) => PolicyModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Get policy statistics (total, pending, acknowledged, overdue)
  /// GET /api/V1/policies/my-policies/stats
  Future<PolicyStatsModel?> getMyPoliciesStats() async {
    return await safeApiCall(
      () => dioClient.get('policies/my-policies/stats'),
      parser: (data) => PolicyStatsModel.fromJson(data['data']),
    );
  }

  /// Get detailed information about a specific policy
  /// GET /api/V1/policies/{policyId}
  Future<PolicyDetailModel?> getPolicyDetails(int policyId) async {
    return await safeApiCall(
      () => dioClient.get('policies/$policyId'),
      parser: (data) => PolicyDetailModel.fromJson(data['data']),
    );
  }

  /// Acknowledge a policy
  /// POST /api/V1/policies/acknowledge
  Future<AcknowledgmentResponseModel?> acknowledgePolicy({
    required int acknowledgmentId,
    String? comments,
  }) async {
    final requestData = <String, dynamic>{
      'acknowledgment_id': acknowledgmentId,
    };

    if (comments != null && comments.isNotEmpty) {
      requestData['comments'] = comments;
    }

    return await safeApiCall(
      () => dioClient.post('policies/acknowledge', data: requestData),
      parser: (data) => AcknowledgmentResponseModel.fromJson(data['data']),
    );
  }

  /// Get all active policy categories
  /// GET /api/V1/policies/categories
  Future<List<PolicyCategoryModel>> getCategories() async {
    return await safeApiCall(
      () => dioClient.get('policies/categories'),
      parser: (data) {
        return (data['data'] as List? ?? [])
            .map((item) => PolicyCategoryModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Get policies by category
  /// GET /api/V1/policies/category/{categoryId}
  Future<List<PolicyModel>> getPoliciesByCategory(int categoryId) async {
    return await safeApiCall(
      () => dioClient.get('policies/category/$categoryId'),
      parser: (data) {
        return (data['data'] as List? ?? [])
            .map((item) => PolicyModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Get all pending policies
  /// GET /api/V1/policies/pending
  Future<List<PolicyModel>> getPendingPolicies() async {
    return await safeApiCall(
      () => dioClient.get('policies/pending'),
      parser: (data) {
        return (data['data'] as List? ?? [])
            .map((item) => PolicyModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Get all overdue policies
  /// GET /api/V1/policies/overdue
  Future<List<PolicyModel>> getOverduePolicies() async {
    return await safeApiCall(
      () => dioClient.get('policies/overdue'),
      parser: (data) {
        return (data['data'] as List? ?? [])
            .map((item) => PolicyModel.fromJson(item))
            .toList();
      },
    );
  }

  /// Download policy document to a specific path
  /// GET /api/V1/policies/{policyId}/download
  ///
  /// [policyId] - The ID of the policy
  /// [savePath] - Full file path where the document should be saved
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0)
  /// [cancelToken] - Optional token to cancel the download
  ///
  /// Example:
  /// ```dart
  /// await hrPoliciesRepository.downloadPolicyDocument(
  ///   5,
  ///   savePath,
  ///   onProgress: (progress) => print('Download: ${(progress * 100).toStringAsFixed(0)}%'),
  /// );
  /// ```
  Future<Response> downloadPolicyDocument(
    int policyId,
    String savePath, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    return await dioClient.downloadFile(
      'policies/$policyId/download',
      savePath,
      onReceiveProgress: onProgress != null
          ? (received, total) {
              if (total != -1) {
                onProgress(received / total);
              }
            }
          : null,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  /// Get policy document download URL
  ///
  /// [policyId] - The ID of the policy
  ///
  /// Returns the URL string for the policy document
  /// This can be used for opening the document in a web view or external app
  String getPolicyDocumentDownloadUrl(int policyId) {
    return 'policies/$policyId/download';
  }
}
