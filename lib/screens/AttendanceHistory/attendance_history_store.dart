import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/attendance_history_model.dart';
import 'package:open_core_hr/api/dio_api/repositories/attendance_history_repository.dart';

part 'attendance_history_store.g.dart';

class AttendanceHistoryStore = AttendanceHistoryStoreBase
    with _$AttendanceHistoryStore;

abstract class AttendanceHistoryStoreBase with Store {
  static const pageSize = 10;

  final _repository = AttendanceHistoryRepository();

  @observable
  bool isLoading = false;

  @observable
  String? startRange;

  @observable
  String? endRange;

  @observable
  bool isMultipleCheckInEnabled = false;

  TextEditingController dateRangeController = TextEditingController();

  @observable
  PagingController<int, AttendanceHistory> pagingController =
      PagingController(firstPageKey: 0);

  @action
  Future getAttendanceHistory(int pageKey) async {
    isLoading = true;
    try {
      var result = await _repository.getHistory(
        skip: pageKey,
        take: pageSize,
        startDate: startRange,
        endDate: endRange,
      );

      if (result != null) {
        // Update the multiple check-in flag from response
        isMultipleCheckInEnabled = result.isMultipleCheckInEnabled;

        final isLastPage = result.values.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(result.values);
        } else {
          pagingController.appendPage(
              result.values, pageKey + result.values.length);
        }
      }
      isLoading = false;
    } catch (error) {
      log('Error: $error');
      pagingController.error = error;
      isLoading = false;
    }
  }
}
