import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/dio_api/dio_client.dart';
import '../../api/project_api.dart';
import '../../main.dart';
import '../../models/Project/timesheet_model.dart';

part 'TimesheetStore.g.dart';

class TimesheetStore = TimesheetStoreBase with _$TimesheetStore;

abstract class TimesheetStoreBase with Store {
  static const pageSize = 20;

  final ProjectApi _api = ProjectApi(DioApiClient());

  @observable
  PagingController<int, TimesheetModel> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  bool isLoading = false;

  @observable
  num totalHours = 0;

  @observable
  num totalBillableHours = 0;

  @observable
  String? selectedStatus;

  // projectId filter (used when opened from ProjectDetailScreen)
  int? projectId;

  // Form fields
  @observable
  int? selectedProjectId;

  @observable
  String? selectedProjectName;

  @observable
  DateTime selectedDate = DateTime.now();

  @observable
  TextEditingController hoursController = TextEditingController();

  @observable
  TextEditingController descriptionController = TextEditingController();

  @observable
  bool isBillable = true;

  @action
  Future<void> fetchTimesheets(int pageKey) async {
    try {
      final result = await _api.getTimesheets(
        skip: pageKey,
        take: pageSize,
        status: selectedStatus,
        projectId: projectId,
      );
      if (pageKey == 0) {
        totalHours = result.totalHours;
        totalBillableHours = result.totalBillableHours;
      }
      final isLastPage =
          (pageKey + result.values.length) >= result.totalCount;
      if (isLastPage) {
        pagingController.appendLastPage(result.values);
      } else {
        pagingController.appendPage(
            result.values, pageKey + result.values.length);
      }
    } catch (error) {
      log('TimesheetStore fetchTimesheets error: $error');
      pagingController.error = error;
    }
  }

  @action
  Future<bool> createTimesheet() async {
    final hours = double.tryParse(hoursController.text.trim());
    if (hours == null || hours <= 0) {
      toast(language.lblEnterHours);
      return false;
    }
    if (selectedProjectId == null) {
      toast(language.lblProject);
      return false;
    }

    isLoading = true;
    try {
      final payload = <String, dynamic>{
        'projectId': selectedProjectId,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'hours': hours,
        'description': descriptionController.text.trim(),
        'isBillable': isBillable,
      };

      await _api.createTimesheet(payload);
      toast(language.lblTimesheetCreated);
      resetForm();
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TimesheetStore createTimesheet error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> submitTimesheet(int id) async {
    isLoading = true;
    try {
      await _api.submitTimesheet(id);
      toast(language.lblTimesheetSubmitted);
      pagingController.refresh();
      return true;
    } catch (e) {
      log('TimesheetStore submitTimesheet error: $e');
      toast(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void resetForm() {
    selectedProjectId = null;
    selectedProjectName = null;
    selectedDate = DateTime.now();
    hoursController.clear();
    descriptionController.clear();
    isBillable = true;
  }
}
