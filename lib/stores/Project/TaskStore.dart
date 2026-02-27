import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

import '../../api/dio_api/dio_client.dart';
import '../../api/project_api.dart';
import '../../main.dart';
import '../../models/Project/task_model.dart';
import '../../models/Project/task_meta_model.dart';

part 'TaskStore.g.dart';

class TaskStore = TaskStoreBase with _$TaskStore;

abstract class TaskStoreBase with Store {
  static const pageSize = 20;

  final ProjectApi _api = ProjectApi(DioApiClient());

  @observable
  PagingController<int, TaskModel> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  bool isLoading = false;

  @observable
  bool taskSystemAvailable = true;

  @observable
  TaskMetaModel? meta;

  @observable
  int? selectedStatusId;

  // Form fields
  @observable
  TextEditingController titleController = TextEditingController();

  @observable
  TextEditingController descriptionController = TextEditingController();

  @observable
  int? selectedFormStatusId;

  @observable
  int? selectedFormPriorityId;

  @observable
  int? selectedAssignedUserId;

  @observable
  DateTime? dueDate;

  @observable
  TextEditingController estimatedHoursController = TextEditingController();

  @observable
  bool isMilestone = false;

  int? _projectId;

  void setProjectId(int id) {
    _projectId = id;
  }

  @action
  Future<void> loadMeta(int projectId) async {
    isLoading = true;
    try {
      meta = await _api.getTaskMeta(projectId);
      taskSystemAvailable = true;
      // Set default status from meta if available
      if (meta != null && meta!.statuses.isNotEmpty) {
        selectedFormStatusId = meta!.statuses.first.id;
      }
    } catch (e) {
      log('TaskStore loadMeta error: $e');
      // 404 means TaskSystem not available
      taskSystemAvailable = false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchTasks(int pageKey) async {
    if (_projectId == null) return;
    try {
      final result = await _api.getTasks(
        _projectId!,
        skip: pageKey,
        take: pageSize,
        statusId: selectedStatusId,
      );
      final isLastPage =
          (pageKey + result.values.length) >= result.totalCount;
      if (isLastPage) {
        pagingController.appendLastPage(result.values);
      } else {
        pagingController.appendPage(
            result.values, pageKey + result.values.length);
      }
    } catch (error) {
      log('TaskStore fetchTasks error: $error');
      pagingController.error = error;
    }
  }

  @action
  Future<bool> createTask(int projectId) async {
    if (titleController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterTaskTitle);
      return false;
    }
    if (selectedFormStatusId == null) {
      toast(language.lblSelectTaskStatus);
      return false;
    }

    isLoading = true;
    try {
      final payload = <String, dynamic>{
        'title': titleController.text.trim(),
        'statusId': selectedFormStatusId,
        'isMilestone': isMilestone,
      };
      if (descriptionController.text.trim().isNotEmpty) {
        payload['description'] = descriptionController.text.trim();
      }
      if (selectedFormPriorityId != null) {
        payload['priorityId'] = selectedFormPriorityId;
      }
      if (selectedAssignedUserId != null) {
        payload['assignedToUserId'] = selectedAssignedUserId;
      }
      if (dueDate != null) {
        payload['dueDate'] = DateFormat('yyyy-MM-dd').format(dueDate!);
      }
      if (estimatedHoursController.text.isNotEmpty) {
        payload['estimatedHours'] =
            double.tryParse(estimatedHoursController.text);
      }

      await _api.createTask(projectId, payload);
      toast(language.lblTaskCreated);
      resetForm();
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TaskStore createTask error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> completeTask(int projectId, int taskId) async {
    isLoading = true;
    try {
      await _api.completeTask(projectId, taskId);
      toast(language.lblTaskCompleted);
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TaskStore completeTask error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> startTask(int projectId, int taskId) async {
    isLoading = true;
    try {
      await _api.startTask(projectId, taskId);
      toast(language.lblTaskStarted);
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TaskStore startTask error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> stopTask(int projectId, int taskId) async {
    isLoading = true;
    try {
      final result = await _api.stopTask(projectId, taskId);
      final elapsed = result['elapsedHours'];
      toast('${language.lblTaskStopped} — ${language.lblElapsedHours}: $elapsed h');
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TaskStore stopTask error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void applyStatusFilter(int? statusId) {
    selectedStatusId = statusId;
    pagingController.refresh();
  }

  @action
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedFormStatusId = meta?.statuses.isNotEmpty == true ? meta!.statuses.first.id : null;
    selectedFormPriorityId = null;
    selectedAssignedUserId = null;
    dueDate = null;
    estimatedHoursController.clear();
    isMilestone = false;
  }
}
