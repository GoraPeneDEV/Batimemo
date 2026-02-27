import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/disciplinary/warning_model.dart';
import '../../../models/disciplinary/warning_type_model.dart';
import '../../../models/disciplinary/warning_appeal_model.dart';

class DisciplinaryRepository extends BaseRepository {
  // ===== Warnings =====

  /// Get paginated list of warnings
  Future<Map<String, dynamic>> getWarnings({
    int skip = 0,
    int take = 20,
    String? status,
    int? warningTypeId,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) queryParams['status'] = status;
    if (warningTypeId != null) queryParams['warning_type_id'] = warningTypeId;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    return await safeApiCall(
      () => dioClient.get('disciplinary/warnings', queryParameters: queryParams),
      parser: (data) {
        try {
          final dataSection = data['data'];
          if (dataSection == null) {
            print('⚠️ Warning: data section is null');
            return {'totalCount': 0, 'values': <Warning>[]};
          }

          final totalCount = dataSection['totalCount'] ?? 0;
          final valuesList = dataSection['values'] as List? ?? [];

          final warnings = <Warning>[];
          for (var i = 0; i < valuesList.length; i++) {
            try {
              final item = valuesList[i];
              print('📋 Parsing warning $i: ${item['warningNumber']}');
              warnings.add(Warning.fromJson(item));
            } catch (e, stackTrace) {
              print('❌ Error parsing warning at index $i: $e');
              print('📄 Item data: ${valuesList[i]}');
              print('Stack trace: $stackTrace');
              // Continue with other items
            }
          }

          return {
            'totalCount': totalCount,
            'values': warnings,
          };
        } catch (e, stackTrace) {
          print('❌ Error in getWarnings parser: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
  }

  /// Get single warning details
  Future<Map<String, dynamic>?> getWarningDetails(int id) async {
    return await safeApiCall(
      () => dioClient.get('disciplinary/warnings/$id'),
      parser: (data) {
        try {
          // Detail endpoint returns data.warning and data.appeals structure
          final warningData = data['data']['warning'];
          if (warningData == null) {
            print('⚠️ Warning: warning data is null');
            return null;
          }

          final appealsList = data['data']['appeals'] as List? ?? [];
          final appeals = appealsList
              .map((item) => WarningAppeal.fromJson(item))
              .toList();

          return {
            'warning': Warning.fromJson(warningData),
            'appeals': appeals,
          };
        } catch (e, stackTrace) {
          print('❌ Error in getWarningDetails parser: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
  }

  /// Acknowledge a warning
  Future<Map<String, dynamic>?> acknowledgeWarning(
    int id, {
    String? comments,
  }) async {
    final requestData = <String, dynamic>{};
    if (comments != null && comments.isNotEmpty) {
      requestData['comments'] = comments;
    }

    return await safeApiCall(
      () => dioClient.post(
        'disciplinary/warnings/$id/acknowledge',
        data: requestData,
      ),
      parser: (data) {
        try {
          // API returns simple string message in data field
          final message = data['data'] is String
              ? data['data']
              : data['data']['message'] ?? 'Warning acknowledged successfully';

          return {
            'message': message,
          };
        } catch (e, stackTrace) {
          print('❌ Error in acknowledgeWarning parser: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
  }

  /// Create an appeal for a warning
  Future<Map<String, dynamic>?> createAppeal(
    int warningId, {
    required String appealReason,
    required String employeeStatement,
    List<String>? supportingDocumentPaths,
  }) async {
    final formData = FormData.fromMap({
      'appeal_reason': appealReason,
      'employee_statement': employeeStatement,
    });

    // Add file uploads if any
    if (supportingDocumentPaths != null && supportingDocumentPaths.isNotEmpty) {
      for (var filePath in supportingDocumentPaths) {
        final fileName = filePath.split('/').last;
        formData.files.add(MapEntry(
          'supporting_documents[]',
          await MultipartFile.fromFile(filePath, filename: fileName),
        ));
      }
    }

    return await safeApiCall(
      () => dioClient.post(
        'disciplinary/warnings/$warningId/appeal',
        data: formData,
      ),
      parser: (data) {
        try {
          // API returns message, appealId, and appealNumber (not full appeal object)
          return {
            'message': data['data']['message'] ?? 'Appeal submitted successfully',
            'appealId': data['data']['appealId'],
            'appealNumber': data['data']['appealNumber'],
          };
        } catch (e, stackTrace) {
          print('❌ Error in createAppeal parser: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
  }

  // ===== Appeals =====

  /// Get paginated list of appeals
  Future<Map<String, dynamic>> getAppeals({
    int skip = 0,
    int take = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) queryParams['status'] = status;

    return await safeApiCall(
      () => dioClient.get('disciplinary/appeals', queryParameters: queryParams),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => WarningAppeal.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get single appeal details
  Future<WarningAppeal?> getAppealDetails(int id) async {
    return await safeApiCall(
      () => dioClient.get('disciplinary/appeals/$id'),
      parser: (data) {
        try {
          // Detail endpoint might return data.appeal structure
          final appealData = data['data']['appeal'] ?? data['data'];
          if (appealData == null) {
            print('⚠️ Warning: appeal data is null');
            return null;
          }
          return WarningAppeal.fromJson(appealData);
        } catch (e, stackTrace) {
          print('❌ Error in getAppealDetails parser: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
  }

  /// Withdraw an appeal
  Future<String?> withdrawAppeal(int id) async {
    return await safeApiCall(
      () => dioClient.post('disciplinary/appeals/$id/withdraw'),
      parser: (data) {
        // API might return simple string or object with message
        if (data['data'] is String) {
          return data['data'] as String;
        }
        return data['data']['message'] as String? ?? 'Appeal withdrawn successfully';
      },
    );
  }

  // ===== Reference Data & Statistics =====

  /// Get all warning types
  Future<List<WarningType>> getWarningTypes() async {
    return await safeApiCall(
      () => dioClient.get('disciplinary/warning-types'),
      parser: (data) {
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((item) => WarningType.fromJson(item))
              .toList();
        }
        return <WarningType>[];
      },
    );
  }

  /// Get employee statistics
  Future<Map<String, dynamic>?> getStatistics() async {
    return await safeApiCall(
      () => dioClient.get('disciplinary/statistics'),
      parser: (data) => data['data'] as Map<String, dynamic>,
    );
  }

  /// Get warning history
  Future<Map<String, dynamic>?> getHistory({int? year}) async {
    return await safeApiCall(
      () => dioClient.get(
        'disciplinary/history',
        queryParameters: year != null ? {'year': year} : null,
      ),
      parser: (data) => data['data'] as Map<String, dynamic>,
    );
  }
}
