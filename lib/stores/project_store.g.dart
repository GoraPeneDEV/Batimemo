// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectStore on _ProjectStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_ProjectStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorAtom = Atom(name: '_ProjectStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$projectsAtom =
      Atom(name: '_ProjectStore.projects', context: context);

  @override
  ObservableList<Project> get projects {
    _$projectsAtom.reportRead();
    return super.projects;
  }

  @override
  set projects(ObservableList<Project> value) {
    _$projectsAtom.reportWrite(value, super.projects, () {
      super.projects = value;
    });
  }

  late final _$totalProjectsCountAtom =
      Atom(name: '_ProjectStore.totalProjectsCount', context: context);

  @override
  int get totalProjectsCount {
    _$totalProjectsCountAtom.reportRead();
    return super.totalProjectsCount;
  }

  @override
  set totalProjectsCount(int value) {
    _$totalProjectsCountAtom.reportWrite(value, super.totalProjectsCount, () {
      super.totalProjectsCount = value;
    });
  }

  late final _$selectedProjectAtom =
      Atom(name: '_ProjectStore.selectedProject', context: context);

  @override
  Project? get selectedProject {
    _$selectedProjectAtom.reportRead();
    return super.selectedProject;
  }

  @override
  set selectedProject(Project? value) {
    _$selectedProjectAtom.reportWrite(value, super.selectedProject, () {
      super.selectedProject = value;
    });
  }

  late final _$projectStatisticsAtom =
      Atom(name: '_ProjectStore.projectStatistics', context: context);

  @override
  ProjectStatistics? get projectStatistics {
    _$projectStatisticsAtom.reportRead();
    return super.projectStatistics;
  }

  @override
  set projectStatistics(ProjectStatistics? value) {
    _$projectStatisticsAtom.reportWrite(value, super.projectStatistics, () {
      super.projectStatistics = value;
    });
  }

  late final _$timesheetsAtom =
      Atom(name: '_ProjectStore.timesheets', context: context);

  @override
  ObservableList<Timesheet> get timesheets {
    _$timesheetsAtom.reportRead();
    return super.timesheets;
  }

  @override
  set timesheets(ObservableList<Timesheet> value) {
    _$timesheetsAtom.reportWrite(value, super.timesheets, () {
      super.timesheets = value;
    });
  }

  late final _$totalTimesheetsCountAtom =
      Atom(name: '_ProjectStore.totalTimesheetsCount', context: context);

  @override
  int get totalTimesheetsCount {
    _$totalTimesheetsCountAtom.reportRead();
    return super.totalTimesheetsCount;
  }

  @override
  set totalTimesheetsCount(int value) {
    _$totalTimesheetsCountAtom.reportWrite(value, super.totalTimesheetsCount,
        () {
      super.totalTimesheetsCount = value;
    });
  }

  late final _$selectedTimesheetAtom =
      Atom(name: '_ProjectStore.selectedTimesheet', context: context);

  @override
  Timesheet? get selectedTimesheet {
    _$selectedTimesheetAtom.reportRead();
    return super.selectedTimesheet;
  }

  @override
  set selectedTimesheet(Timesheet? value) {
    _$selectedTimesheetAtom.reportWrite(value, super.selectedTimesheet, () {
      super.selectedTimesheet = value;
    });
  }

  late final _$fetchProjectsAsyncAction =
      AsyncAction('_ProjectStore.fetchProjects', context: context);

  @override
  Future<void> fetchProjects(
      {int skip = 0,
      int take = 20,
      String? status,
      String? type,
      String? priority,
      bool archived = false,
      String? search,
      bool loadMore = false}) {
    return _$fetchProjectsAsyncAction.run(() => super.fetchProjects(
        skip: skip,
        take: take,
        status: status,
        type: type,
        priority: priority,
        archived: archived,
        search: search,
        loadMore: loadMore));
  }

  late final _$fetchProjectStatisticsAsyncAction =
      AsyncAction('_ProjectStore.fetchProjectStatistics', context: context);

  @override
  Future<void> fetchProjectStatistics() {
    return _$fetchProjectStatisticsAsyncAction
        .run(() => super.fetchProjectStatistics());
  }

  late final _$fetchProjectAsyncAction =
      AsyncAction('_ProjectStore.fetchProject', context: context);

  @override
  Future<void> fetchProject(int id) {
    return _$fetchProjectAsyncAction.run(() => super.fetchProject(id));
  }

  late final _$createProjectAsyncAction =
      AsyncAction('_ProjectStore.createProject', context: context);

  @override
  Future<Project?> createProject(
      {required String name,
      String? description,
      required String type,
      required String priority,
      String? startDate,
      String? endDate,
      double? budget,
      bool isBillable = true,
      double? hourlyRate,
      String? colorCode}) {
    return _$createProjectAsyncAction.run(() => super.createProject(
        name: name,
        description: description,
        type: type,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        isBillable: isBillable,
        hourlyRate: hourlyRate,
        colorCode: colorCode));
  }

  late final _$archiveProjectAsyncAction =
      AsyncAction('_ProjectStore.archiveProject', context: context);

  @override
  Future<bool> archiveProject(int id, {required bool archive}) {
    return _$archiveProjectAsyncAction
        .run(() => super.archiveProject(id, archive: archive));
  }

  late final _$fetchTimesheetsAsyncAction =
      AsyncAction('_ProjectStore.fetchTimesheets', context: context);

  @override
  Future<void> fetchTimesheets(
      {int skip = 0,
      int take = 20,
      String? status,
      int? projectId,
      String? startDate,
      String? endDate,
      bool? billable,
      bool loadMore = false}) {
    return _$fetchTimesheetsAsyncAction.run(() => super.fetchTimesheets(
        skip: skip,
        take: take,
        status: status,
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
        billable: billable,
        loadMore: loadMore));
  }

  late final _$fetchTimesheetAsyncAction =
      AsyncAction('_ProjectStore.fetchTimesheet', context: context);

  @override
  Future<void> fetchTimesheet(int id) {
    return _$fetchTimesheetAsyncAction.run(() => super.fetchTimesheet(id));
  }

  late final _$createTimesheetAsyncAction =
      AsyncAction('_ProjectStore.createTimesheet', context: context);

  @override
  Future<bool> createTimesheet(
      {required int projectId,
      required String date,
      required double hours,
      required String description,
      bool isBillable = true,
      double? billingRate,
      double? costRate}) {
    return _$createTimesheetAsyncAction.run(() => super.createTimesheet(
        projectId: projectId,
        date: date,
        hours: hours,
        description: description,
        isBillable: isBillable,
        billingRate: billingRate,
        costRate: costRate));
  }

  late final _$updateTimesheetAsyncAction =
      AsyncAction('_ProjectStore.updateTimesheet', context: context);

  @override
  Future<bool> updateTimesheet(int id,
      {String? date,
      double? hours,
      String? description,
      bool? isBillable,
      double? billingRate,
      double? costRate}) {
    return _$updateTimesheetAsyncAction.run(() => super.updateTimesheet(id,
        date: date,
        hours: hours,
        description: description,
        isBillable: isBillable,
        billingRate: billingRate,
        costRate: costRate));
  }

  late final _$submitTimesheetAsyncAction =
      AsyncAction('_ProjectStore.submitTimesheet', context: context);

  @override
  Future<bool> submitTimesheet(int id) {
    return _$submitTimesheetAsyncAction.run(() => super.submitTimesheet(id));
  }

  late final _$deleteTimesheetAsyncAction =
      AsyncAction('_ProjectStore.deleteTimesheet', context: context);

  @override
  Future<bool> deleteTimesheet(int id) {
    return _$deleteTimesheetAsyncAction.run(() => super.deleteTimesheet(id));
  }

  late final _$_ProjectStoreActionController =
      ActionController(name: '_ProjectStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_ProjectStoreActionController.startAction(
        name: '_ProjectStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_ProjectStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedProject() {
    final _$actionInfo = _$_ProjectStoreActionController.startAction(
        name: '_ProjectStore.clearSelectedProject');
    try {
      return super.clearSelectedProject();
    } finally {
      _$_ProjectStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedTimesheet() {
    final _$actionInfo = _$_ProjectStoreActionController.startAction(
        name: '_ProjectStore.clearSelectedTimesheet');
    try {
      return super.clearSelectedTimesheet();
    } finally {
      _$_ProjectStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
projects: ${projects},
totalProjectsCount: ${totalProjectsCount},
selectedProject: ${selectedProject},
projectStatistics: ${projectStatistics},
timesheets: ${timesheets},
totalTimesheetsCount: ${totalTimesheetsCount},
selectedTimesheet: ${selectedTimesheet}
    ''';
  }
}
