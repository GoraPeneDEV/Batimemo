import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';

import '../../api/dio_api/repositories/holiday_repository.dart';
import '../../models/holiday_model.dart';

part 'holiday_store.g.dart';

class HolidayStore = HolidayStoreBase with _$HolidayStore;

abstract class HolidayStoreBase with Store {
  static const pageSize = 10;

  final HolidayRepository _repository = HolidayRepository();
  final TextEditingController yearFilterController = TextEditingController();
  final TextEditingController typeFilterController = TextEditingController();

  final PagingController<int, HolidayModel> pagingController =
      PagingController(firstPageKey: 0);

  @observable
  int? yearFilter;

  @observable
  String? typeFilter;

  @observable
  bool isLoadingUpcoming = false;

  @observable
  List<HolidayModel> upcomingHolidays = [];

  @observable
  Map<String, List<HolidayModel>>? groupedHolidays;

  @observable
  bool isLoadingGrouped = false;

  @action
  Future<void> fetchHolidays(int pageKey) async {
    try {
      final result = await _repository.getAllHolidays(
        skip: pageKey,
        take: pageSize,
        year: yearFilter ?? DateTime.now().year,
        type: typeFilter,
        visibleToEmployees: true,
      );

      if (result != null) {
        final isLastPage = result.values.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(result.values);
        } else {
          final nextPageKey = pageKey + result.values.length;
          pagingController.appendPage(result.values, nextPageKey);
        }
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @action
  Future<void> fetchUpcomingHolidays({int limit = 5}) async {
    try {
      isLoadingUpcoming = true;
      upcomingHolidays = await _repository.getUpcomingHolidays(limit: limit);
    } catch (error) {
      print('Error fetching upcoming holidays: $error');
    } finally {
      isLoadingUpcoming = false;
    }
  }

  @action
  Future<void> fetchGroupedHolidays({int? year}) async {
    try {
      isLoadingGrouped = true;
      groupedHolidays = await _repository.getHolidaysByYearGrouped(
        year: year ?? DateTime.now().year,
      );
    } catch (error) {
      print('Error fetching grouped holidays: $error');
    } finally {
      isLoadingGrouped = false;
    }
  }

  @action
  void clearFilters() {
    yearFilterController.clear();
    typeFilterController.clear();
    yearFilter = null;
    typeFilter = null;
  }
}
