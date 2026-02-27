import 'dart:io';
import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/Attendance/attendance_regularization.dart';
import '../../../models/Attendance/regularization_type.dart';
import '../../../models/Attendance/regularization_counts.dart';
import '../../../models/Attendance/available_date.dart';

/// Repository for attendance regularization API calls
class AttendanceRegularizationRepository extends BaseRepository {
  /// Get all regularization requests with pagination and filters
  Future<Map<String, dynamic>> getAllRegularizations({
    int skip = 0,
    int take = 10,
    String? status,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    return await safeApiCall(
      () => dioClient.get(
        'attendance-regularization/getAll',
        queryParameters: queryParams,
      ),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => AttendanceRegularization.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get single regularization request by ID
  Future<AttendanceRegularization?> getRegularization(int id) async {
    return await safeApiCall(
      () => dioClient.get('attendance-regularization/$id'),
      parser: (data) => AttendanceRegularization.fromJson(data['data']),
    );
  }

  /// Get all regularization types
  Future<List<RegularizationType>> getTypes() async {
    return await safeApiCall(
      () => dioClient.get('attendance-regularization/getTypes'),
      parser: (data) {
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((item) => RegularizationType.fromJson(item))
              .toList();
        }
        return <RegularizationType>[];
      },
    );
  }

  /// Get counts by status
  Future<RegularizationCounts?> getCounts() async {
    return await safeApiCall(
      () => dioClient.get('attendance-regularization/getCounts'),
      parser: (data) => RegularizationCounts.fromJson(data['data']),
    );
  }

  /// Get available dates for regularization
  Future<AvailableDatesResponse?> getAvailableDates({int days = 30}) async {
    return await safeApiCall(
      () => dioClient.get(
        'attendance-regularization/getAvailableDates',
        queryParameters: {'days': days},
      ),
      parser: (data) => AvailableDatesResponse.fromJson(data['data']),
    );
  }

  /// Create a new regularization request
  Future<String?> createRegularization({
    required String date,
    required String type,
    String? requestedCheckInTime,
    String? requestedCheckOutTime,
    required String reason,
    List<File>? attachments,
  }) async {
    final formData = FormData.fromMap({
      'date': date,
      'type': type,
      'reason': reason,
    });

    if (requestedCheckInTime != null) {
      formData.fields.add(MapEntry('requestedCheckInTime', requestedCheckInTime));
    }
    if (requestedCheckOutTime != null) {
      formData.fields.add(MapEntry('requestedCheckOutTime', requestedCheckOutTime));
    }

    // Add attachments if provided
    if (attachments != null && attachments.isNotEmpty) {
      for (var file in attachments) {
        formData.files.add(MapEntry(
          'attachments[]',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }
    }

    return await safeApiCall(
      () => dioClient.post('attendance-regularization/create', data: formData),
      parser: (data) => data['data'] as String,
    );
  }

  /// Update an existing regularization request
  /// Note: Using POST instead of PUT due to Laravel FormData limitation
  Future<String?> updateRegularization(
    int id, {
    String? date,
    String? type,
    String? requestedCheckInTime,
    String? requestedCheckOutTime,
    String? reason,
    List<File>? attachments,
  }) async {
    final formData = FormData();

    // Add _method field for Laravel to recognize this as a PUT request
    formData.fields.add(const MapEntry('_method', 'PUT'));

    if (date != null) formData.fields.add(MapEntry('date', date));
    if (type != null) formData.fields.add(MapEntry('type', type));
    if (requestedCheckInTime != null) {
      formData.fields.add(MapEntry('requestedCheckInTime', requestedCheckInTime));
    }
    if (requestedCheckOutTime != null) {
      formData.fields.add(MapEntry('requestedCheckOutTime', requestedCheckOutTime));
    }
    if (reason != null) formData.fields.add(MapEntry('reason', reason));

    // Add attachments if provided
    if (attachments != null && attachments.isNotEmpty) {
      for (var file in attachments) {
        formData.files.add(MapEntry(
          'attachments[]',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }
    }

    return await safeApiCall(
      () => dioClient.post('attendance-regularization/$id', data: formData),
      parser: (data) => data['data'] as String,
    );
  }

  /// Delete a regularization request
  Future<String?> deleteRegularization(int id) async {
    return await safeApiCall(
      () => dioClient.delete('attendance-regularization/$id'),
      parser: (data) => data['data'] as String,
    );
  }
}
