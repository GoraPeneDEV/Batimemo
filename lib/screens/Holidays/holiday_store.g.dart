// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HolidayStore on HolidayStoreBase, Store {
  late final _$yearFilterAtom =
      Atom(name: 'HolidayStoreBase.yearFilter', context: context);

  @override
  int? get yearFilter {
    _$yearFilterAtom.reportRead();
    return super.yearFilter;
  }

  @override
  set yearFilter(int? value) {
    _$yearFilterAtom.reportWrite(value, super.yearFilter, () {
      super.yearFilter = value;
    });
  }

  late final _$typeFilterAtom =
      Atom(name: 'HolidayStoreBase.typeFilter', context: context);

  @override
  String? get typeFilter {
    _$typeFilterAtom.reportRead();
    return super.typeFilter;
  }

  @override
  set typeFilter(String? value) {
    _$typeFilterAtom.reportWrite(value, super.typeFilter, () {
      super.typeFilter = value;
    });
  }

  late final _$isLoadingUpcomingAtom =
      Atom(name: 'HolidayStoreBase.isLoadingUpcoming', context: context);

  @override
  bool get isLoadingUpcoming {
    _$isLoadingUpcomingAtom.reportRead();
    return super.isLoadingUpcoming;
  }

  @override
  set isLoadingUpcoming(bool value) {
    _$isLoadingUpcomingAtom.reportWrite(value, super.isLoadingUpcoming, () {
      super.isLoadingUpcoming = value;
    });
  }

  late final _$upcomingHolidaysAtom =
      Atom(name: 'HolidayStoreBase.upcomingHolidays', context: context);

  @override
  List<HolidayModel> get upcomingHolidays {
    _$upcomingHolidaysAtom.reportRead();
    return super.upcomingHolidays;
  }

  @override
  set upcomingHolidays(List<HolidayModel> value) {
    _$upcomingHolidaysAtom.reportWrite(value, super.upcomingHolidays, () {
      super.upcomingHolidays = value;
    });
  }

  late final _$groupedHolidaysAtom =
      Atom(name: 'HolidayStoreBase.groupedHolidays', context: context);

  @override
  Map<String, List<HolidayModel>>? get groupedHolidays {
    _$groupedHolidaysAtom.reportRead();
    return super.groupedHolidays;
  }

  @override
  set groupedHolidays(Map<String, List<HolidayModel>>? value) {
    _$groupedHolidaysAtom.reportWrite(value, super.groupedHolidays, () {
      super.groupedHolidays = value;
    });
  }

  late final _$isLoadingGroupedAtom =
      Atom(name: 'HolidayStoreBase.isLoadingGrouped', context: context);

  @override
  bool get isLoadingGrouped {
    _$isLoadingGroupedAtom.reportRead();
    return super.isLoadingGrouped;
  }

  @override
  set isLoadingGrouped(bool value) {
    _$isLoadingGroupedAtom.reportWrite(value, super.isLoadingGrouped, () {
      super.isLoadingGrouped = value;
    });
  }

  late final _$fetchHolidaysAsyncAction =
      AsyncAction('HolidayStoreBase.fetchHolidays', context: context);

  @override
  Future<void> fetchHolidays(int pageKey) {
    return _$fetchHolidaysAsyncAction.run(() => super.fetchHolidays(pageKey));
  }

  late final _$fetchUpcomingHolidaysAsyncAction =
      AsyncAction('HolidayStoreBase.fetchUpcomingHolidays', context: context);

  @override
  Future<void> fetchUpcomingHolidays({int limit = 5}) {
    return _$fetchUpcomingHolidaysAsyncAction
        .run(() => super.fetchUpcomingHolidays(limit: limit));
  }

  late final _$fetchGroupedHolidaysAsyncAction =
      AsyncAction('HolidayStoreBase.fetchGroupedHolidays', context: context);

  @override
  Future<void> fetchGroupedHolidays({int? year}) {
    return _$fetchGroupedHolidaysAsyncAction
        .run(() => super.fetchGroupedHolidays(year: year));
  }

  late final _$HolidayStoreBaseActionController =
      ActionController(name: 'HolidayStoreBase', context: context);

  @override
  void clearFilters() {
    final _$actionInfo = _$HolidayStoreBaseActionController.startAction(
        name: 'HolidayStoreBase.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$HolidayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
yearFilter: ${yearFilter},
typeFilter: ${typeFilter},
isLoadingUpcoming: ${isLoadingUpcoming},
upcomingHolidays: ${upcomingHolidays},
groupedHolidays: ${groupedHolidays},
isLoadingGrouped: ${isLoadingGrouped}
    ''';
  }
}
