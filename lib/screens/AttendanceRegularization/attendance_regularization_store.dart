import 'dart:io';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/Attendance/attendance_regularization.dart';
import '../../models/Attendance/regularization_type.dart';
import '../../models/Attendance/regularization_counts.dart';
import '../../models/Attendance/available_date.dart';
import '../../api/dio_api/repositories/attendance_regularization_repository.dart';
import '../../api/dio_api/exceptions/api_exceptions.dart';

part 'attendance_regularization_store.g.dart';

class AttendanceRegularizationStore = AttendanceRegularizationStoreBase
    with _$AttendanceRegularizationStore;

abstract class AttendanceRegularizationStoreBase with Store {
  final AttendanceRegularizationRepository _repository =
      AttendanceRegularizationRepository();
  static const pageSize = 15;

  @observable
  PagingController<int, AttendanceRegularization> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<RegularizationType> regularizationTypes =
      ObservableList<RegularizationType>();

  @observable
  RegularizationCounts? counts;

  @observable
  AvailableDatesResponse? availableDates;

  // Filters
  @observable
  String? selectedStatus;

  @observable
  String? selectedType;

  @observable
  String? startDate;

  @observable
  String? endDate;

  // Form fields
  final formKey = GlobalKey<FormState>();

  @observable
  String? selectedDate;

  @observable
  String? selectedRegularizationType;

  @observable
  TimeOfDay? requestedCheckInTime;

  @observable
  TimeOfDay? requestedCheckOutTime;

  final reasonController = TextEditingController();
  final reasonFocusNode = FocusNode();

  @observable
  ObservableList<File> attachments = ObservableList<File>();

  @observable
  AttendanceRegularization? selectedRegularization;

  void _handleError(dynamic e) {
    if (e is ApiException) {
      error = e.message;
    } else {
      error = e.toString();
    }
  }

  @action
  Future<void> fetchRegularizations(int pageKey) async {
    try {
      final page = (pageKey ~/ pageSize);

      final result = await _repository.getAllRegularizations(
        skip: page * pageSize,
        take: pageSize,
        status: selectedStatus,
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
      );

      final regularizations =
          result['values'] as List<AttendanceRegularization>;
      final totalCount = result['totalCount'] as int;
      final isLastPage = (page + 1) * pageSize >= totalCount;

      if (isLastPage) {
        pagingController.appendLastPage(regularizations);
      } else {
        pagingController.appendPage(
            regularizations, pageKey + regularizations.length);
      }
    } catch (e) {
      _handleError(e);
      pagingController.error = e;
    }
  }

  @action
  Future<void> getRegularizationTypes() async {
    try {
      isLoading = true;
      error = null;

      final types = await _repository.getTypes();
      regularizationTypes = ObservableList.of(types);

      if (regularizationTypes.isNotEmpty) {
        selectedRegularizationType = regularizationTypes.first.value;
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> getCounts() async {
    try {
      error = null;
      counts = await _repository.getCounts();
    } catch (e) {
      _handleError(e);
    }
  }

  @action
  Future<void> getAvailableDates({int days = 30}) async {
    try {
      isLoading = true;
      error = null;

      availableDates = await _repository.getAvailableDates(days: days);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createRegularization() async {
    if (formKey.currentState!.validate()) {
      if (selectedDate == null) {
        toast('Please select a date');
        return false;
      }

      if (selectedRegularizationType == null) {
        toast('Please select a regularization type');
        return false;
      }

      try {
        isLoading = true;
        error = null;

        // Convert TimeOfDay to HH:mm format
        String? checkInTimeStr;
        String? checkOutTimeStr;

        if (requestedCheckInTime != null) {
          checkInTimeStr =
              '${requestedCheckInTime!.hour.toString().padLeft(2, '0')}:${requestedCheckInTime!.minute.toString().padLeft(2, '0')}';
        }

        if (requestedCheckOutTime != null) {
          checkOutTimeStr =
              '${requestedCheckOutTime!.hour.toString().padLeft(2, '0')}:${requestedCheckOutTime!.minute.toString().padLeft(2, '0')}';
        }

        final result = await _repository.createRegularization(
          date: selectedDate!,
          type: selectedRegularizationType!,
          requestedCheckInTime: checkInTimeStr,
          requestedCheckOutTime: checkOutTimeStr,
          reason: reasonController.text,
          attachments: attachments.isNotEmpty ? attachments : null,
        );

        isLoading = false;

        if (result != null) {
          toast(result);
          // Refresh the list and counts
          pagingController.refresh();
          getCounts();
          clearForm();
          return true;
        }
        return false;
      } catch (e) {
        _handleError(e);
        toast(error ?? 'Failed to create regularization request');
        isLoading = false;
        return false;
      }
    }
    return false;
  }

  @action
  Future<bool> updateRegularization(int id) async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading = true;
        error = null;

        // Convert TimeOfDay to HH:mm format
        String? checkInTimeStr;
        String? checkOutTimeStr;

        if (requestedCheckInTime != null) {
          checkInTimeStr =
              '${requestedCheckInTime!.hour.toString().padLeft(2, '0')}:${requestedCheckInTime!.minute.toString().padLeft(2, '0')}';
        }

        if (requestedCheckOutTime != null) {
          checkOutTimeStr =
              '${requestedCheckOutTime!.hour.toString().padLeft(2, '0')}:${requestedCheckOutTime!.minute.toString().padLeft(2, '0')}';
        }

        final result = await _repository.updateRegularization(
          id,
          date: selectedDate,
          type: selectedRegularizationType,
          requestedCheckInTime: checkInTimeStr,
          requestedCheckOutTime: checkOutTimeStr,
          reason: reasonController.text.isNotEmpty ? reasonController.text : null,
          attachments: attachments.isNotEmpty ? attachments : null,
        );

        isLoading = false;

        if (result != null) {
          toast(result);
          // Refresh the list
          pagingController.refresh();
          getCounts();
          clearForm();
          return true;
        }
        return false;
      } catch (e) {
        _handleError(e);
        toast(error ?? 'Failed to update regularization request');
        isLoading = false;
        return false;
      }
    }
    return false;
  }

  @action
  Future<bool> deleteRegularization(int id) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.deleteRegularization(id);

      isLoading = false;

      if (result != null) {
        toast(result);
        // Refresh the list
        pagingController.refresh();
        getCounts();
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      toast(error ?? 'Failed to delete regularization request');
      isLoading = false;
      return false;
    }
  }

  @action
  Future<void> loadRegularizationDetails(int id) async {
    try {
      isLoading = true;
      error = null;

      selectedRegularization = await _repository.getRegularization(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  void setStatusFilter(String? status) {
    selectedStatus = status;
    pagingController.refresh();
  }

  @action
  void setTypeFilter(String? type) {
    selectedType = type;
    pagingController.refresh();
  }

  @action
  void setDateRangeFilter(String? start, String? end) {
    startDate = start;
    endDate = end;
    pagingController.refresh();
  }

  @action
  void clearFilters() {
    selectedStatus = null;
    selectedType = null;
    startDate = null;
    endDate = null;
    pagingController.refresh();
  }

  @action
  void setDate(String date) {
    selectedDate = date;
  }

  @action
  void setRegularizationType(String type) {
    selectedRegularizationType = type;
  }

  @action
  void setCheckInTime(TimeOfDay time) {
    requestedCheckInTime = time;
  }

  @action
  void setCheckOutTime(TimeOfDay time) {
    requestedCheckOutTime = time;
  }

  @action
  void addAttachment(File file) {
    attachments.add(file);
  }

  @action
  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  @action
  void clearForm() {
    selectedDate = null;
    selectedRegularizationType =
        regularizationTypes.isNotEmpty ? regularizationTypes.first.value : null;
    requestedCheckInTime = null;
    requestedCheckOutTime = null;
    reasonController.clear();
    attachments.clear();
    selectedRegularization = null;
  }

  @action
  void loadFormFromRegularization(AttendanceRegularization regularization) {
    selectedDate = regularization.date;
    selectedRegularizationType = regularization.type;
    reasonController.text = regularization.reason;

    // Parse time strings to TimeOfDay
    if (regularization.requestedCheckInTime != null) {
      final timeParts = regularization.requestedCheckInTime!.split(' ');
      if (timeParts.length == 2) {
        final hourMinute = timeParts[0].split(':');
        int hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);
        final isPm = timeParts[1].toLowerCase() == 'pm';

        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;

        requestedCheckInTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    if (regularization.requestedCheckOutTime != null) {
      final timeParts = regularization.requestedCheckOutTime!.split(' ');
      if (timeParts.length == 2) {
        final hourMinute = timeParts[0].split(':');
        int hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);
        final isPm = timeParts[1].toLowerCase() == 'pm';

        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;

        requestedCheckOutTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    selectedRegularization = regularization;
  }

  void dispose() {
    reasonController.dispose();
    reasonFocusNode.dispose();
  }
}
