import 'dart:io';
import 'package:mobx/mobx.dart';
import '../api/dio_api/repositories/leave_repository.dart';
import '../api/dio_api/exceptions/api_exceptions.dart';
import '../models/leave/leave_type.dart';
import '../models/leave/leave_balance_summary.dart';
import '../models/leave/leave_request.dart';
import '../models/leave/leave_statistics.dart';
import '../models/leave/team_calendar_item.dart';
import '../models/leave/compensatory_off.dart';

part 'leave_store.g.dart';

class LeaveStore = _LeaveStore with _$LeaveStore;

abstract class _LeaveStore with Store {
  final LeaveRepository _repository = LeaveRepository();

  // Observable states
  @observable
  bool isLoading = false;

  @observable
  ObservableList<LeaveType> leaveTypes = ObservableList<LeaveType>();

  @observable
  LeaveBalanceSummary? leaveBalanceSummary;

  @observable
  ObservableList<LeaveRequest> leaveRequests = ObservableList<LeaveRequest>();

  @observable
  int totalLeaveRequestsCount = 0;

  @observable
  LeaveRequest? selectedLeaveRequest;

  @observable
  LeaveStatistics? leaveStatistics;

  @observable
  TeamCalendar? teamCalendar;

  @observable
  ObservableList<CompensatoryOff> compensatoryOffs =
      ObservableList<CompensatoryOff>();

  @observable
  int totalCompOffsCount = 0;

  @observable
  CompensatoryOff? selectedCompensatoryOff;

  @observable
  CompensatoryOffBalance? compOffBalance;

  @observable
  CompensatoryOffStatistics? compOffStatistics;

  @observable
  String? error;

  // Helper method to extract error message
  void _handleError(dynamic e) {
    if (e is ApiException) {
      error = e.message;
    } else {
      _handleError(e);
    }
  }

  // Actions

  @action
  Future<void> fetchLeaveTypes() async {
    try {
      isLoading = true;
      error = null;
      final types = await _repository.getLeaveTypes();
      leaveTypes = ObservableList.of(types);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchLeaveBalance({int? year}) async {
    try {
      isLoading = true;
      error = null;
      leaveBalanceSummary = await _repository.getLeaveBalance(year: year);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchLeaveRequests({
    int skip = 0,
    int take = 20,
    String? status,
    int? year,
    int? leaveTypeId,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading = true;
      }
      error = null;

      final result = await _repository.getLeaveRequests(
        skip: skip,
        take: take,
        status: status,
        year: year,
        leaveTypeId: leaveTypeId,
      );

      totalLeaveRequestsCount = result['totalCount'];
      final requests = result['values'] as List<LeaveRequest>;

      if (loadMore) {
        leaveRequests.addAll(requests);
      } else {
        leaveRequests = ObservableList.of(requests);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchLeaveRequest(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedLeaveRequest = await _repository.getLeaveRequest(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> createLeaveRequest({
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
    try {
      isLoading = true;
      error = null;

      final result = await _repository.createLeaveRequest(
        leaveTypeId: leaveTypeId,
        fromDate: fromDate,
        toDate: toDate,
        userNotes: userNotes,
        isHalfDay: isHalfDay,
        halfDayType: halfDayType,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        isAbroad: isAbroad,
        abroadLocation: abroadLocation,
        document: document,
        useCompOff: useCompOff,
        compOffIds: compOffIds,
      );

      if (result != null) {
        // Refresh leave requests and balance
        await fetchLeaveRequests();
        await fetchLeaveBalance();
        // Refresh comp off balance if comp off was used
        if (useCompOff) {
          await fetchCompensatoryOffBalance();
        }
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
  Future<bool> updateLeaveRequest(
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
    try {
      isLoading = true;
      error = null;

      final result = await _repository.updateLeaveRequest(
        id,
        fromDate: fromDate,
        toDate: toDate,
        userNotes: userNotes,
        isHalfDay: isHalfDay,
        halfDayType: halfDayType,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        isAbroad: isAbroad,
        abroadLocation: abroadLocation,
        document: document,
      );

      if (result != null) {
        // Update the item in the list
        final index = leaveRequests.indexWhere((req) => req.id == id);
        if (index != -1) {
          leaveRequests[index] = result['leaveRequest'];
        }
        selectedLeaveRequest = result['leaveRequest'];
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
  Future<bool> cancelLeaveRequest(int id, {String? reason}) async {
    try {
      isLoading = true;
      error = null;

      await _repository.cancelLeaveRequest(id, reason: reason);

      // Refresh leave requests and balance
      await fetchLeaveRequests();
      await fetchLeaveBalance();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<String?> uploadLeaveDocument(int id, dynamic file) async {
    try {
      error = null;
      return await _repository.uploadLeaveDocument(id, file);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  @action
  Future<void> fetchLeaveStatistics({int? year}) async {
    try {
      isLoading = true;
      error = null;
      leaveStatistics = await _repository.getLeaveStatistics(year: year);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchTeamCalendar({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      isLoading = true;
      error = null;
      teamCalendar = await _repository.getTeamCalendar(
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  // ===== Compensatory Off Actions =====

  @action
  Future<void> fetchCompensatoryOffs({
    int skip = 0,
    int take = 20,
    String? status,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        isLoading = true;
      }
      error = null;

      final result = await _repository.getCompensatoryOffs(
        skip: skip,
        take: take,
        status: status,
      );

      totalCompOffsCount = result['totalCount'];
      final compOffs = result['values'] as List<CompensatoryOff>;

      if (loadMore) {
        compensatoryOffs.addAll(compOffs);
      } else {
        compensatoryOffs = ObservableList.of(compOffs);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchCompensatoryOff(int id) async {
    try {
      isLoading = true;
      error = null;
      selectedCompensatoryOff = await _repository.getCompensatoryOff(id);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchCompensatoryOffBalance() async {
    try {
      error = null;
      compOffBalance = await _repository.getCompensatoryOffBalance();
    } catch (e) {
      _handleError(e);
    }
  }

  @action
  Future<bool> requestCompensatoryOff({
    required String workedDate,
    required num hoursWorked,
    required String reason,
  }) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.requestCompensatoryOff(
        workedDate: workedDate,
        hoursWorked: hoursWorked,
        reason: reason,
      );

      if (result != null) {
        // Refresh compensatory offs and balance
        await fetchCompensatoryOffs();
        await fetchCompensatoryOffBalance();
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
  Future<bool> updateCompensatoryOff(
    int id, {
    String? workedDate,
    num? hoursWorked,
    String? reason,
  }) async {
    try {
      isLoading = true;
      error = null;

      final result = await _repository.updateCompensatoryOff(
        id,
        workedDate: workedDate,
        hoursWorked: hoursWorked,
        reason: reason,
      );

      if (result != null) {
        // Update the item in the list
        final index = compensatoryOffs.indexWhere((co) => co.id == id);
        if (index != -1) {
          compensatoryOffs[index] = result['compOff'];
        }
        selectedCompensatoryOff = result['compOff'];
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
  Future<bool> deleteCompensatoryOff(int id) async {
    try {
      isLoading = true;
      error = null;

      await _repository.deleteCompensatoryOff(id);

      // Refresh compensatory offs and balance
      await fetchCompensatoryOffs();
      await fetchCompensatoryOffBalance();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchCompensatoryOffStatistics({int? year}) async {
    try {
      isLoading = true;
      error = null;
      compOffStatistics =
          await _repository.getCompensatoryOffStatistics(year: year);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  void clearError() {
    error = null;
  }

  @action
  void clearSelectedLeaveRequest() {
    selectedLeaveRequest = null;
  }

  @action
  void clearSelectedCompensatoryOff() {
    selectedCompensatoryOff = null;
  }
}
