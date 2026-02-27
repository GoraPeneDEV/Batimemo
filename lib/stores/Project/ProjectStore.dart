import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/dio_api/dio_client.dart';
import '../../api/project_api.dart';
import '../../main.dart';
import '../../models/Project/project_model.dart';

part 'ProjectStore.g.dart';

class ProjectStore = ProjectStoreBase with _$ProjectStore;

abstract class ProjectStoreBase with Store {
  static const pageSize = 20;

  final ProjectApi _api = ProjectApi(DioApiClient());

  @observable
  PagingController<int, ProjectModel> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  bool isLoading = false;

  @observable
  ProjectModel? selectedProject;

  @observable
  Map<String, dynamic>? statistics;

  @observable
  String? selectedStatus;

  @observable
  String? selectedType;

  @observable
  String searchQuery = '';

  // Form fields
  @observable
  TextEditingController nameController = TextEditingController();

  @observable
  TextEditingController descriptionController = TextEditingController();

  @observable
  String selectedProjectType = 'client';

  @observable
  String selectedPriority = 'medium';

  @observable
  DateTime? startDate;

  @observable
  DateTime? endDate;

  @observable
  TextEditingController budgetController = TextEditingController();

  @observable
  bool isBillable = true;

  @observable
  TextEditingController hourlyRateController = TextEditingController();

  @observable
  String selectedColor = '#007bff';

  @action
  Future<void> fetchProjects(int pageKey) async {
    try {
      final result = await _api.getProjects(
        skip: pageKey,
        take: pageSize,
        status: selectedStatus,
        type: selectedType,
        search: searchQuery.isNotEmpty ? searchQuery : null,
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
      log('ProjectStore fetchProjects error: $error');
      pagingController.error = error;
    }
  }

  @action
  Future<void> loadProjectDetail(int id) async {
    isLoading = true;
    try {
      selectedProject = await _api.getProject(id);
    } catch (e) {
      log('ProjectStore loadProjectDetail error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadStatistics() async {
    isLoading = true;
    try {
      statistics = await _api.getStatistics();
    } catch (e) {
      log('ProjectStore loadStatistics error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createProject() async {
    if (nameController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterProjectName);
      return false;
    }
    if (startDate != null &&
        endDate != null &&
        endDate!.isBefore(startDate!)) {
      toast(language.lblEndDateError);
      return false;
    }

    isLoading = true;
    try {
      final payload = <String, dynamic>{
        'name': nameController.text.trim(),
        'type': selectedProjectType,
        'priority': selectedPriority,
        'isBillable': isBillable,
        'colorCode': selectedColor,
      };
      if (descriptionController.text.trim().isNotEmpty) {
        payload['description'] = descriptionController.text.trim();
      }
      if (startDate != null) {
        payload['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
      }
      if (endDate != null) {
        payload['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
      }
      if (budgetController.text.isNotEmpty) {
        payload['budget'] = double.tryParse(budgetController.text);
      }
      if (hourlyRateController.text.isNotEmpty) {
        payload['hourlyRate'] = double.tryParse(hourlyRateController.text);
      }

      await _api.createProject(payload);
      toast(language.lblProjectCreatedSuccessfully);
      resetForm();
      pagingController.refresh();
      return true;
    } catch (e) {
      log('ProjectStore createProject error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void applyFilters() {
    pagingController.refresh();
  }

  @action
  void resetFilters() {
    selectedStatus = null;
    selectedType = null;
    searchQuery = '';
    pagingController.refresh();
  }

  @action
  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    selectedProjectType = 'client';
    selectedPriority = 'medium';
    startDate = null;
    endDate = null;
    budgetController.clear();
    isBillable = true;
    hourlyRateController.clear();
    selectedColor = '#007bff';
  }
}
