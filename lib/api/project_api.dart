import 'dio_api/dio_client.dart';
import '../models/Project/project_model.dart';
import '../models/Project/timesheet_model.dart';
import '../models/Project/task_model.dart';
import '../models/Project/task_meta_model.dart';

class ProjectApi {
  final DioApiClient _client;

  ProjectApi(this._client);

  // GET /projects (liste paginée)
  Future<ProjectListResponse> getProjects({
    int skip = 0,
    int take = 20,
    String? status,
    String? type,
    String? priority,
    String? search,
    bool archived = false,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'take': take,
      'archived': archived ? 'true' : 'false',
    };
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    if (priority != null) params['priority'] = priority;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get('projects', queryParameters: params);
    return ProjectListResponse.fromJson(response.data['data']);
  }

  // GET /projects/{id}
  Future<ProjectModel> getProject(int id) async {
    final response = await _client.get('projects/$id');
    return ProjectModel.fromJson(response.data['data']);
  }

  // POST /projects
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> payload) async {
    final response = await _client.post('projects', data: payload);
    return response.data['data'] as Map<String, dynamic>;
  }

  // PUT /projects/{id}
  Future<ProjectModel> updateProject(int id, Map<String, dynamic> payload) async {
    final response = await _client.put('projects/$id', data: payload);
    return ProjectModel.fromJson(response.data['data']['project']);
  }

  // DELETE /projects/{id}
  Future<void> deleteProject(int id) async {
    await _client.delete('projects/$id');
  }

  // POST /projects/{id}/archive
  Future<void> archiveProject(int id, {required bool archive}) async {
    await _client.post('projects/$id/archive', data: {'archive': archive});
  }

  // GET /projects/statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _client.get('projects/statistics');
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /projects/{id}/members
  Future<List<dynamic>> getMembers(int projectId) async {
    final response = await _client.get('projects/$projectId/members');
    final data = response.data['data'];
    return (data['members'] as List<dynamic>? ?? []);
  }

  // POST /projects/{id}/members
  Future<void> addMember(int projectId, Map<String, dynamic> payload) async {
    await _client.post('projects/$projectId/members', data: payload);
  }

  // PUT /projects/{id}/members/{memberId}
  Future<void> updateMember(int projectId, int memberId, Map<String, dynamic> payload) async {
    await _client.put('projects/$projectId/members/$memberId', data: payload);
  }

  // DELETE /projects/{id}/members/{memberId}
  Future<void> removeMember(int projectId, int memberId) async {
    await _client.delete('projects/$projectId/members/$memberId');
  }

  // GET /projects/timesheets
  Future<TimesheetListResponse> getTimesheets({
    int skip = 0,
    int take = 20,
    String? status,
    int? projectId,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{'skip': skip, 'take': take};
    if (status != null) params['status'] = status;
    if (projectId != null) params['projectId'] = projectId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _client.get('projects/timesheets', queryParameters: params);
    return TimesheetListResponse.fromJson(response.data['data']);
  }

  // POST /projects/timesheets
  Future<TimesheetModel> createTimesheet(Map<String, dynamic> payload) async {
    final response = await _client.post('projects/timesheets', data: payload);
    return TimesheetModel.fromJson(response.data['data']['timesheet']);
  }

  // GET /projects/timesheets/{id}
  Future<TimesheetModel> getTimesheet(int id) async {
    final response = await _client.get('projects/timesheets/$id');
    return TimesheetModel.fromJson(response.data['data']);
  }

  // PUT /projects/timesheets/{id}
  Future<TimesheetModel> updateTimesheet(int id, Map<String, dynamic> payload) async {
    final response = await _client.put('projects/timesheets/$id', data: payload);
    return TimesheetModel.fromJson(response.data['data']['timesheet']);
  }

  // POST /projects/timesheets/{id}/submit
  Future<void> submitTimesheet(int id) async {
    await _client.post('projects/timesheets/$id/submit');
  }

  // DELETE /projects/timesheets/{id}
  Future<void> deleteTimesheet(int id) async {
    await _client.delete('projects/timesheets/$id');
  }

  // GET /projects/{projectId}/tasks/meta
  Future<TaskMetaModel> getTaskMeta(int projectId) async {
    final response = await _client.get('projects/$projectId/tasks/meta');
    return TaskMetaModel.fromJson(response.data['data']);
  }

  // GET /projects/{projectId}/tasks
  Future<TaskListResponse> getTasks(
    int projectId, {
    int skip = 0,
    int take = 20,
    int? statusId,
    bool? completed,
    String? search,
  }) async {
    final params = <String, dynamic>{'skip': skip, 'take': take};
    if (statusId != null) params['statusId'] = statusId;
    if (completed != null) params['completed'] = completed;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get('projects/$projectId/tasks', queryParameters: params);
    return TaskListResponse.fromJson(response.data['data']);
  }

  // POST /projects/{projectId}/tasks
  Future<TaskModel> createTask(int projectId, Map<String, dynamic> payload) async {
    final response = await _client.post('projects/$projectId/tasks', data: payload);
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // GET /projects/{projectId}/tasks/{taskId}
  Future<TaskModel> getTask(int projectId, int taskId) async {
    final response = await _client.get('projects/$projectId/tasks/$taskId');
    return TaskModel.fromJson(response.data['data']);
  }

  // PUT /projects/{projectId}/tasks/{taskId}
  Future<TaskModel> updateTask(int projectId, int taskId, Map<String, dynamic> payload) async {
    final response = await _client.put('projects/$projectId/tasks/$taskId', data: payload);
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // DELETE /projects/{projectId}/tasks/{taskId}
  Future<void> deleteTask(int projectId, int taskId) async {
    await _client.delete('projects/$projectId/tasks/$taskId');
  }

  // POST /projects/{projectId}/tasks/{taskId}/complete
  Future<TaskModel> completeTask(int projectId, int taskId) async {
    final response = await _client.post('projects/$projectId/tasks/$taskId/complete');
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // POST /projects/{projectId}/tasks/{taskId}/start
  Future<TaskModel> startTask(int projectId, int taskId) async {
    final response = await _client.post('projects/$projectId/tasks/$taskId/start');
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // POST /projects/{projectId}/tasks/{taskId}/stop
  Future<Map<String, dynamic>> stopTask(int projectId, int taskId) async {
    final response = await _client.post('projects/$projectId/tasks/$taskId/stop');
    return response.data['data'] as Map<String, dynamic>;
  }
}
