import '../base_repository.dart';
import '../exceptions/api_exceptions.dart';
import '../../../models/project/project.dart';
import '../../../models/project/timesheet.dart';
import '../../../models/project/project_statistics.dart';

class ProjectRepository extends BaseRepository {
  // ===== Projects =====

  /// Get paginated list of accessible projects
  Future<Map<String, dynamic>> getProjects({
    int skip = 0,
    int take = 20,
    String? status,
    String? type,
    String? priority,
    bool archived = false,
    String? search,
  }) async {
    final page = (skip ~/ take) + 1;
    final queryParams = <String, dynamic>{
      'page': page,
      'perPage': take,
      'archived': archived,
    };

    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (priority != null) queryParams['priority'] = priority;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await safeApiCall(
      () => dioClient.get('projects', queryParameters: queryParams),
      parser: (data) {
        final raw = (data is Map) ? data['data'] : null;
        if (raw == null) {
          return {'totalCount': 0, 'values': <Project>[]};
        }
        final responseData = raw as Map<String, dynamic>;
        final rawList = responseData['projects'] ??
            responseData['values'] ??
            responseData['data'];
        return {
          'totalCount': responseData['total'] ?? responseData['totalCount'] ?? 0,
          'values': rawList is List
              ? rawList
                  .map((item) => Project.fromJson(item as Map<String, dynamic>))
                  .toList()
              : <Project>[],
        };
      },
    );
  }

  /// Create a new project
  Future<Project?> createProject({
    required String name,
    String? description,
    required String type,
    required String priority,
    String? startDate,
    String? endDate,
    double? budget,
    bool isBillable = true,
    double? hourlyRate,
    String? colorCode,
  }) async {
    final requestData = <String, dynamic>{
      'name': name,
      'type': type,
      'priority': priority,
      'isBillable': isBillable,
    };

    if (description != null && description.isNotEmpty) requestData['description'] = description;
    if (startDate != null) requestData['startDate'] = startDate;
    if (endDate != null) requestData['endDate'] = endDate;
    if (budget != null) requestData['budget'] = budget;
    if (hourlyRate != null) requestData['hourlyRate'] = hourlyRate;
    if (colorCode != null) requestData['colorCode'] = colorCode;

    return await safeApiCall(
      () => dioClient.post('projects', data: requestData),
      parser: (data) {
        final dataField = (data is Map) ? data['data'] : null;
        if (dataField == null) {
          throw ApiException(message: 'Réponse invalide du serveur');
        }
        final projectData = (dataField is Map && dataField.containsKey('project'))
            ? dataField['project']
            : dataField;
        return Project.fromJson(projectData as Map<String, dynamic>);
      },
    );
  }

  /// Get project statistics for dashboard
  Future<ProjectStatistics?> getProjectStatistics() async {
    return await safeApiCall(
      () => dioClient.get('projects/statistics'),
      parser: (data) => ProjectStatistics.fromJson(data['data']),
    );
  }

  /// Get single project details with members
  Future<Project?> getProject(int id) async {
    return await safeApiCall(
      () => dioClient.get('projects/$id'),
      parser: (data) => Project.fromJson(data['data']),
    );
  }

  /// Archive or unarchive a project
  Future<String?> archiveProject(int id, {required bool archive}) async {
    return await safeApiCall(
      () => dioClient.post('projects/$id/archive', data: {'archive': archive}),
      parser: (data) => data['data']['message'] as String? ?? '',
    );
  }

  // ===== Timesheets =====

  /// Get paginated list of my timesheets
  Future<Map<String, dynamic>> getTimesheets({
    int skip = 0,
    int take = 20,
    String? status,
    int? projectId,
    String? startDate,
    String? endDate,
    bool? billable,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'take': take,
    };

    if (status != null) queryParams['status'] = status;
    if (projectId != null) queryParams['projectId'] = projectId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (billable != null) queryParams['billable'] = billable;

    return await safeApiCall(
      () => dioClient.get('projects/timesheets', queryParameters: queryParams),
      parser: (data) {
        return {
          'totalCount': data['data']['totalCount'] ?? 0,
          'values': (data['data']['values'] as List? ?? [])
              .map((item) => Timesheet.fromJson(item))
              .toList(),
        };
      },
    );
  }

  /// Get single timesheet details
  Future<Timesheet?> getTimesheet(int id) async {
    return await safeApiCall(
      () => dioClient.get('projects/timesheets/$id'),
      parser: (data) => Timesheet.fromJson(data['data']),
    );
  }

  /// Create a new timesheet entry
  Future<Map<String, dynamic>?> createTimesheet({
    required int projectId,
    required String date,
    required double hours,
    required String description,
    bool isBillable = true,
    double? billingRate,
    double? costRate,
    int? taskId,
  }) async {
    final requestData = <String, dynamic>{
      'projectId': projectId,
      'date': date,
      'hours': hours,
      'description': description,
      'isBillable': isBillable,
    };

    if (billingRate != null) requestData['billingRate'] = billingRate;
    if (costRate != null) requestData['costRate'] = costRate;
    if (taskId != null) requestData['taskId'] = taskId;

    return await safeApiCall(
      () => dioClient.post('projects/timesheets', data: requestData),
      parser: (data) {
        return {
          'message': data['data']['message'] ?? '',
          'timesheet': Timesheet.fromJson(data['data']['timesheet']),
        };
      },
    );
  }

  /// Update a draft timesheet
  Future<Map<String, dynamic>?> updateTimesheet(
    int id, {
    String? date,
    double? hours,
    String? description,
    bool? isBillable,
    double? billingRate,
    double? costRate,
  }) async {
    final requestData = <String, dynamic>{};

    if (date != null) requestData['date'] = date;
    if (hours != null) requestData['hours'] = hours;
    if (description != null) requestData['description'] = description;
    if (isBillable != null) requestData['isBillable'] = isBillable;
    if (billingRate != null) requestData['billingRate'] = billingRate;
    if (costRate != null) requestData['costRate'] = costRate;

    return await safeApiCall(
      () => dioClient.put('projects/timesheets/$id', data: requestData),
      parser: (data) {
        return {
          'message': data['data']['message'] ?? '',
          'timesheet': Timesheet.fromJson(data['data']['timesheet']),
        };
      },
    );
  }

  /// Submit a timesheet for approval
  Future<String?> submitTimesheet(int id) async {
    return await safeApiCall(
      () => dioClient.post('projects/timesheets/$id/submit'),
      parser: (data) => data['data']['message'] as String? ?? '',
    );
  }

  /// Delete a draft timesheet
  Future<String?> deleteTimesheet(int id) async {
    return await safeApiCall(
      () => dioClient.delete('projects/timesheets/$id'),
      parser: (data) => data['data']['message'] as String? ?? '',
    );
  }
}
