import 'package:mobx/mobx.dart';
import '../api/dio_api/repositories/project_repository.dart';
import '../api/dio_api/exceptions/api_exceptions.dart';
import '../models/project/project.dart';
import '../models/project/timesheet.dart';
import '../models/project/project_statistics.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  final ProjectRepository _repository = ProjectRepository();

  // ─── Observable states ──────────────────────────────────────────────────────

  @observable
  bool isLoading = false;

  @observable
  String? error;

  // Projects
  @observable
  ObservableList<Project> projects = ObservableList<Project>();

  @observable
  int totalProjectsCount = 0;

  @observable
  Project? selectedProject;

  @observable
  ProjectStatistics? projectStatistics;

  // Timesheets
  @observable
  ObservableList<Timesheet> timesheets = ObservableList<Timesheet>();

  @observable
  int totalTimesheetsCount = 0;

  @observable
  Timesheet? selectedTimesheet;

  // ─── Error handling ──────────────────────────────────────────────────────────

  void _handleError(dynamic e) {
    if (e is ApiException) {
      error = e.message;
    } else {
      error = e.toString();
    }
  }

  // ─── Project Actions ─────────────────────────────────────────────────────────

  @action
  Future<void> fetchProjects({
    int skip = 0,
    int take = 20,
    String? status,
    String? type,
    String? priority,
    bool archived = false,
    String? search,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) isLoading = true;
      error = null;

      final result = await _repository.getProjects(
        skip: skip,
        take: take,
        status: status,
        type: type,
        priority: priority,
        archived: archived,
        search: search,
      );

      totalProjectsCount = result['totalCount'];
      final items = result['values'] as List<Project>;

      if (loadMore) {
        projects.addAll(items);
      } else {
        projects = ObservableList.of(items);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchProjectStatistics() async {
    try {
      isLoading = true;
      error = null;
      projectStatistics = await _repository.getProjectStatistics();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchProject(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedProject = await _repository.getProject(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
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
    try {
      isLoading = true;
      error = null;
      final project = await _repository.createProject(
        name: name,
        description: description,
        type: type,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        isBillable: isBillable,
        hourlyRate: hourlyRate,
        colorCode: colorCode,
      );
      if (project != null) {
        projects.insert(0, project);
        totalProjectsCount++;
      }
      return project;
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> archiveProject(int id, {required bool archive}) async {
    try {
      isLoading = true;
      error = null;
      await _repository.archiveProject(id, archive: archive);
      await fetchProjects();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  // ─── Timesheet Actions ────────────────────────────────────────────────────────

  @action
  Future<void> fetchTimesheets({
    int skip = 0,
    int take = 20,
    String? status,
    int? projectId,
    String? startDate,
    String? endDate,
    bool? billable,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) isLoading = true;
      error = null;

      final result = await _repository.getTimesheets(
        skip: skip,
        take: take,
        status: status,
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
        billable: billable,
      );

      totalTimesheetsCount = result['totalCount'];
      final items = result['values'] as List<Timesheet>;

      if (loadMore) {
        timesheets.addAll(items);
      } else {
        timesheets = ObservableList.of(items);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchTimesheet(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedTimesheet = await _repository.getTimesheet(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createTimesheet({
    required int projectId,
    required String date,
    required double hours,
    required String description,
    bool isBillable = true,
    double? billingRate,
    double? costRate,
  }) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.createTimesheet(
        projectId: projectId,
        date: date,
        hours: hours,
        description: description,
        isBillable: isBillable,
        billingRate: billingRate,
        costRate: costRate,
      );

      if (result != null) {
        await fetchTimesheets();
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updateTimesheet(
    int id, {
    String? date,
    double? hours,
    String? description,
    bool? isBillable,
    double? billingRate,
    double? costRate,
  }) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.updateTimesheet(
        id,
        date: date,
        hours: hours,
        description: description,
        isBillable: isBillable,
        billingRate: billingRate,
        costRate: costRate,
      );

      if (result != null) {
        final index = timesheets.indexWhere((t) => t.id == id);
        if (index != -1) {
          timesheets[index] = result['timesheet'];
        }
        selectedTimesheet = result['timesheet'];
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> submitTimesheet(int id) async {
    try {
      isLoading = true;
      error = null;
      await _repository.submitTimesheet(id);
      await fetchTimesheets();
      await fetchProjectStatistics();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deleteTimesheet(int id) async {
    try {
      isLoading = true;
      error = null;
      await _repository.deleteTimesheet(id);
      await fetchTimesheets();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  // ─── Utility ─────────────────────────────────────────────────────────────────

  @action
  void clearError() {
    error = null;
  }

  @action
  void clearSelectedProject() {
    selectedProject = null;
  }

  @action
  void clearSelectedTimesheet() {
    selectedTimesheet = null;
  }
}
