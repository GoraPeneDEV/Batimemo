import 'dart:io';
import 'package:dio/dio.dart';
import '../base_repository.dart';
import '../../../models/leave/leave_type.dart';
import '../../../models/leave/leave_balance_summary.dart';
import '../../../models/leave/leave_request.dart';
import '../../../models/leave/leave_statistics.dart';
import '../../../models/leave/team_calendar_item.dart';
import '../../../models/leave/compensatory_off.dart';

class LeaveRepository extends BaseRepository {
  /// Get all active leave types with user's current balance
  Future<List<LeaveType>> getLeaveTypes() async {
    return await safeApiCall(
      () => dioClient.get('leave/types'),
      parser: (data) {
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((item) => LeaveType.fromJson(item))
              .toList();
        }
        return <LeaveType>[];
      },
    );
  }

  /// Get leave balance summary
  Future<LeaveBalanceSummary?> getLeaveBalance({int? year}) async {
    return await safeApiCall(
      () => dioClient.get(
        'leave/balance',
        queryParameters: year != null ? {'year': year} : null,
      ),
      parser: (data) => LeaveBalanceSummary.fromJson(data['data']),
    );
  }

  /// Get paginated list of leave requests
  Future<Map<String, dynamic>> getLeaveRequests({
    int skip = 0,
    int take = 20,
    String? status,
    int? year,
    int? leaveTypeId,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) queryParams['status'] = status;
    if (year != null) queryParams['year'] = year;
    if (leaveTypeId != null) queryParams['leaveTypeId'] = leaveTypeId;

    return await safeApiCall(
      () => dioClient.get('leave/requests', queryParameters: queryParams),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => LeaveRequest.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get single leave request details
  Future<LeaveRequest?> getLeaveRequest(int id) async {
    return await safeApiCall(
      () => dioClient.get('leave/requests/$id'),
      parser: (data) => LeaveRequest.fromJson(data['data']),
    );
  }

  /// Create a new leave request
  Future<Map<String, dynamic>?> createLeaveRequest({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String userNotes,
    bool isHalfDay = false,
    String? halfDayType,
    String? emergencyContact,
    String? emergencyPhone,
    bool? isAbroad,
    String? abroadLocation,
    File? document,
    bool useCompOff = false,
    List<int>? compOffIds,
  }) async {
    // If document is needed, use FormData, otherwise use JSON
    final hasDocument = document != null;

    if (hasDocument) {
      // Use FormData for file upload
      final formData = FormData.fromMap({
        'leaveTypeId': leaveTypeId,
        'fromDate': fromDate,
        'toDate': toDate,
        'userNotes': userNotes,
        'isHalfDay': isHalfDay ? 1 : 0,
      });

      if (halfDayType != null) formData.fields.add(MapEntry('halfDayType', halfDayType));
      if (emergencyContact != null) formData.fields.add(MapEntry('emergencyContact', emergencyContact));
      if (emergencyPhone != null) formData.fields.add(MapEntry('emergencyPhone', emergencyPhone));
      if (isAbroad != null) formData.fields.add(MapEntry('isAbroad', isAbroad ? '1' : '0'));
      if (abroadLocation != null) formData.fields.add(MapEntry('abroadLocation', abroadLocation));

      // Add compensatory off parameters
      if (useCompOff) {
        formData.fields.add(MapEntry('useCompOff', 'true'));
        if (compOffIds != null && compOffIds.isNotEmpty) {
          // Add each comp off ID as an array element
          for (int i = 0; i < compOffIds.length; i++) {
            formData.fields.add(MapEntry('compOffIds[$i]', compOffIds[i].toString()));
          }
        }
      }

      formData.files.add(MapEntry(
        'document',
        await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      ));

      return await safeApiCall(
        () => dioClient.post('leave/requests', data: formData),
        parser: (data) {
          return {
            'message': data['data']['message'],
            'leaveRequestId': data['data']['leaveRequestId'],
            'leaveRequest': LeaveRequest.fromJson(data['data']['leaveRequest']),
          };
        },
      );
    } else {
      // Use JSON for requests without document
      final requestData = {
        'leaveTypeId': leaveTypeId,
        'fromDate': fromDate,
        'toDate': toDate,
        'userNotes': userNotes,
        'isHalfDay': isHalfDay,
      };

      if (halfDayType != null) requestData['halfDayType'] = halfDayType;
      if (emergencyContact != null) requestData['emergencyContact'] = emergencyContact;
      if (emergencyPhone != null) requestData['emergencyPhone'] = emergencyPhone;
      if (isAbroad != null) requestData['isAbroad'] = isAbroad;
      if (abroadLocation != null) requestData['abroadLocation'] = abroadLocation;

      // Add compensatory off parameters
      if (useCompOff) {
        requestData['useCompOff'] = true;
        if (compOffIds != null && compOffIds.isNotEmpty) {
          requestData['compOffIds'] = compOffIds;
        }
      }

      return await safeApiCall(
        () => dioClient.post('leave/requests', data: requestData),
        parser: (data) {
          return {
            'message': data['data']['message'],
            'leaveRequestId': data['data']['leaveRequestId'],
            'leaveRequest': LeaveRequest.fromJson(data['data']['leaveRequest']),
          };
        },
      );
    }
  }

  /// Update a pending leave request
  Future<Map<String, dynamic>?> updateLeaveRequest(
    int id, {
    String? fromDate,
    String? toDate,
    String? userNotes,
    bool? isHalfDay,
    String? halfDayType,
    String? emergencyContact,
    String? emergencyPhone,
    bool? isAbroad,
    String? abroadLocation,
    File? document,
  }) async {
    final formData = FormData();

    // Add _method field for Laravel method spoofing (required for multipart/form-data with PUT)
    formData.fields.add(MapEntry('_method', 'PUT'));

    if (fromDate != null) formData.fields.add(MapEntry('fromDate', fromDate));
    if (toDate != null) formData.fields.add(MapEntry('toDate', toDate));
    if (userNotes != null) formData.fields.add(MapEntry('userNotes', userNotes));
    if (isHalfDay != null) formData.fields.add(MapEntry('isHalfDay', isHalfDay ? '1' : '0'));
    if (halfDayType != null) formData.fields.add(MapEntry('halfDayType', halfDayType));
    if (emergencyContact != null) formData.fields.add(MapEntry('emergencyContact', emergencyContact));
    if (emergencyPhone != null) formData.fields.add(MapEntry('emergencyPhone', emergencyPhone));
    if (isAbroad != null) formData.fields.add(MapEntry('isAbroad', isAbroad ? '1' : '0'));
    if (abroadLocation != null) formData.fields.add(MapEntry('abroadLocation', abroadLocation));

    if (document != null) {
      formData.files.add(MapEntry(
        'document',
        await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      ));
    }

    return await safeApiCall(
      // Use POST with _method=PUT for Laravel method spoofing
      // This allows multipart/form-data to work properly
      () => dioClient.post(
        'leave/requests/$id',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      ),
      parser: (data) {
        return {
          'message': data['data']['message'],
          'leaveRequest': LeaveRequest.fromJson(data['data']['leaveRequest']),
        };
      },
    );
  }

  /// Cancel a leave request
  Future<String?> cancelLeaveRequest(int id, {String? reason}) async {
    return await safeApiCall(
      () => dioClient.delete(
        'leave/requests/$id',
        data: reason != null ? {'reason': reason} : null,
      ),
      parser: (data) => data['data']['message'] as String,
    );
  }

  /// Upload document for leave request
  Future<String?> uploadLeaveDocument(int id, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return await safeApiCall(
      () => dioClient.post('leave/requests/$id/upload', data: formData),
      parser: (data) => data['data']['documentUrl'] as String,
    );
  }

  /// Get leave statistics
  Future<LeaveStatistics?> getLeaveStatistics({int? year}) async {
    return await safeApiCall(
      () => dioClient.get(
        'leave/statistics',
        queryParameters: year != null ? {'year': year} : null,
      ),
      parser: (data) => LeaveStatistics.fromJson(data['data']),
    );
  }

  /// Get team calendar (approved leaves of team members)
  Future<TeamCalendar?> getTeamCalendar({
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    return await safeApiCall(
      () => dioClient.get('leave/team-calendar', queryParameters: queryParams),
      parser: (data) => TeamCalendar.fromJson(data['data']),
    );
  }

  // ===== Compensatory Off Methods =====

  /// Get paginated list of compensatory offs
  Future<Map<String, dynamic>> getCompensatoryOffs({
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
      () => dioClient.get('comp-off/list', queryParameters: queryParams),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => CompensatoryOff.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get compensatory off details
  Future<CompensatoryOff?> getCompensatoryOff(int id) async {
    return await safeApiCall(
      () => dioClient.get('comp-off/$id'),
      parser: (data) => CompensatoryOff.fromJson(data['data']),
    );
  }

  /// Get compensatory off balance
  Future<CompensatoryOffBalance?> getCompensatoryOffBalance() async {
    return await safeApiCall(
      () => dioClient.get('comp-off/balance'),
      parser: (data) => CompensatoryOffBalance.fromJson(data['data']),
    );
  }

  /// Request compensatory off
  Future<Map<String, dynamic>?> requestCompensatoryOff({
    required String workedDate,
    required num hoursWorked,
    required String reason,
  }) async {
    return await safeApiCall(
      () => dioClient.post('comp-off/request', data: {
        'workedDate': workedDate,
        'hoursWorked': hoursWorked,
        'reason': reason,
      }),
      parser: (data) {
        return {
          'message': data['data']['message'],
          'compOffId': data['data']['compOffId'],
          'compOff': CompensatoryOff.fromJson(data['data']['compOff']),
        };
      },
    );
  }

  /// Update compensatory off
  Future<Map<String, dynamic>?> updateCompensatoryOff(
    int id, {
    String? workedDate,
    num? hoursWorked,
    String? reason,
  }) async {
    final data = <String, dynamic>{};

    if (workedDate != null) data['workedDate'] = workedDate;
    if (hoursWorked != null) data['hoursWorked'] = hoursWorked;
    if (reason != null) data['reason'] = reason;

    return await safeApiCall(
      () => dioClient.put('comp-off/$id', data: data),
      parser: (data) {
        return {
          'message': data['data']['message'],
          'compOff': CompensatoryOff.fromJson(data['data']['compOff']),
        };
      },
    );
  }

  /// Delete compensatory off
  Future<String?> deleteCompensatoryOff(int id) async {
    return await safeApiCall(
      () => dioClient.delete('comp-off/$id'),
      parser: (data) => data['data']['message'] as String,
    );
  }

  /// Get compensatory off statistics
  Future<CompensatoryOffStatistics?> getCompensatoryOffStatistics({
    int? year,
  }) async {
    return await safeApiCall(
      () => dioClient.get(
        'comp-off/statistics',
        queryParameters: year != null ? {'year': year} : null,
      ),
      parser: (data) => CompensatoryOffStatistics.fromJson(data['data']),
    );
  }
}
