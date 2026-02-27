// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProjectStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectStore on ProjectStoreBase, Store {
  late final _$pagingControllerAtom =
      Atom(name: 'ProjectStoreBase.pagingController', context: context);

  @override
  PagingController<int, InvalidType> get pagingController {
    _$pagingControllerAtom.reportRead();
    return super.pagingController;
  }

  @override
  set pagingController(PagingController<int, InvalidType> value) {
    _$pagingControllerAtom.reportWrite(value, super.pagingController, () {
      super.pagingController = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'ProjectStoreBase.isLoading', context: context);

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

  late final _$selectedProjectAtom =
      Atom(name: 'ProjectStoreBase.selectedProject', context: context);

  @override
  InvalidType get selectedProject {
    _$selectedProjectAtom.reportRead();
    return super.selectedProject;
  }

  @override
  set selectedProject(InvalidType value) {
    _$selectedProjectAtom.reportWrite(value, super.selectedProject, () {
      super.selectedProject = value;
    });
  }

  late final _$statisticsAtom =
      Atom(name: 'ProjectStoreBase.statistics', context: context);

  @override
  Map<String, dynamic>? get statistics {
    _$statisticsAtom.reportRead();
    return super.statistics;
  }

  @override
  set statistics(Map<String, dynamic>? value) {
    _$statisticsAtom.reportWrite(value, super.statistics, () {
      super.statistics = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: 'ProjectStoreBase.selectedStatus', context: context);

  @override
  String? get selectedStatus {
    _$selectedStatusAtom.reportRead();
    return super.selectedStatus;
  }

  @override
  set selectedStatus(String? value) {
    _$selectedStatusAtom.reportWrite(value, super.selectedStatus, () {
      super.selectedStatus = value;
    });
  }

  late final _$selectedTypeAtom =
      Atom(name: 'ProjectStoreBase.selectedType', context: context);

  @override
  String? get selectedType {
    _$selectedTypeAtom.reportRead();
    return super.selectedType;
  }

  @override
  set selectedType(String? value) {
    _$selectedTypeAtom.reportWrite(value, super.selectedType, () {
      super.selectedType = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: 'ProjectStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$nameControllerAtom =
      Atom(name: 'ProjectStoreBase.nameController', context: context);

  @override
  TextEditingController get nameController {
    _$nameControllerAtom.reportRead();
    return super.nameController;
  }

  @override
  set nameController(TextEditingController value) {
    _$nameControllerAtom.reportWrite(value, super.nameController, () {
      super.nameController = value;
    });
  }

  late final _$descriptionControllerAtom =
      Atom(name: 'ProjectStoreBase.descriptionController', context: context);

  @override
  TextEditingController get descriptionController {
    _$descriptionControllerAtom.reportRead();
    return super.descriptionController;
  }

  @override
  set descriptionController(TextEditingController value) {
    _$descriptionControllerAtom.reportWrite(value, super.descriptionController,
        () {
      super.descriptionController = value;
    });
  }

  late final _$selectedProjectTypeAtom =
      Atom(name: 'ProjectStoreBase.selectedProjectType', context: context);

  @override
  String get selectedProjectType {
    _$selectedProjectTypeAtom.reportRead();
    return super.selectedProjectType;
  }

  @override
  set selectedProjectType(String value) {
    _$selectedProjectTypeAtom.reportWrite(value, super.selectedProjectType, () {
      super.selectedProjectType = value;
    });
  }

  late final _$selectedPriorityAtom =
      Atom(name: 'ProjectStoreBase.selectedPriority', context: context);

  @override
  String get selectedPriority {
    _$selectedPriorityAtom.reportRead();
    return super.selectedPriority;
  }

  @override
  set selectedPriority(String value) {
    _$selectedPriorityAtom.reportWrite(value, super.selectedPriority, () {
      super.selectedPriority = value;
    });
  }

  late final _$startDateAtom =
      Atom(name: 'ProjectStoreBase.startDate', context: context);

  @override
  DateTime? get startDate {
    _$startDateAtom.reportRead();
    return super.startDate;
  }

  @override
  set startDate(DateTime? value) {
    _$startDateAtom.reportWrite(value, super.startDate, () {
      super.startDate = value;
    });
  }

  late final _$endDateAtom =
      Atom(name: 'ProjectStoreBase.endDate', context: context);

  @override
  DateTime? get endDate {
    _$endDateAtom.reportRead();
    return super.endDate;
  }

  @override
  set endDate(DateTime? value) {
    _$endDateAtom.reportWrite(value, super.endDate, () {
      super.endDate = value;
    });
  }

  late final _$budgetControllerAtom =
      Atom(name: 'ProjectStoreBase.budgetController', context: context);

  @override
  TextEditingController get budgetController {
    _$budgetControllerAtom.reportRead();
    return super.budgetController;
  }

  @override
  set budgetController(TextEditingController value) {
    _$budgetControllerAtom.reportWrite(value, super.budgetController, () {
      super.budgetController = value;
    });
  }

  late final _$isBillableAtom =
      Atom(name: 'ProjectStoreBase.isBillable', context: context);

  @override
  bool get isBillable {
    _$isBillableAtom.reportRead();
    return super.isBillable;
  }

  @override
  set isBillable(bool value) {
    _$isBillableAtom.reportWrite(value, super.isBillable, () {
      super.isBillable = value;
    });
  }

  late final _$hourlyRateControllerAtom =
      Atom(name: 'ProjectStoreBase.hourlyRateController', context: context);

  @override
  TextEditingController get hourlyRateController {
    _$hourlyRateControllerAtom.reportRead();
    return super.hourlyRateController;
  }

  @override
  set hourlyRateController(TextEditingController value) {
    _$hourlyRateControllerAtom.reportWrite(value, super.hourlyRateController,
        () {
      super.hourlyRateController = value;
    });
  }

  late final _$selectedColorAtom =
      Atom(name: 'ProjectStoreBase.selectedColor', context: context);

  @override
  String get selectedColor {
    _$selectedColorAtom.reportRead();
    return super.selectedColor;
  }

  @override
  set selectedColor(String value) {
    _$selectedColorAtom.reportWrite(value, super.selectedColor, () {
      super.selectedColor = value;
    });
  }

  late final _$fetchProjectsAsyncAction =
      AsyncAction('ProjectStoreBase.fetchProjects', context: context);

  @override
  Future<void> fetchProjects(int pageKey) {
    return _$fetchProjectsAsyncAction.run(() => super.fetchProjects(pageKey));
  }

  late final _$loadProjectDetailAsyncAction =
      AsyncAction('ProjectStoreBase.loadProjectDetail', context: context);

  @override
  Future<void> loadProjectDetail(int id) {
    return _$loadProjectDetailAsyncAction
        .run(() => super.loadProjectDetail(id));
  }

  late final _$loadStatisticsAsyncAction =
      AsyncAction('ProjectStoreBase.loadStatistics', context: context);

  @override
  Future<void> loadStatistics() {
    return _$loadStatisticsAsyncAction.run(() => super.loadStatistics());
  }

  late final _$createProjectAsyncAction =
      AsyncAction('ProjectStoreBase.createProject', context: context);

  @override
  Future<bool> createProject() {
    return _$createProjectAsyncAction.run(() => super.createProject());
  }

  late final _$ProjectStoreBaseActionController =
      ActionController(name: 'ProjectStoreBase', context: context);

  @override
  void applyFilters() {
    final _$actionInfo = _$ProjectStoreBaseActionController.startAction(
        name: 'ProjectStoreBase.applyFilters');
    try {
      return super.applyFilters();
    } finally {
      _$ProjectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetFilters() {
    final _$actionInfo = _$ProjectStoreBaseActionController.startAction(
        name: 'ProjectStoreBase.resetFilters');
    try {
      return super.resetFilters();
    } finally {
      _$ProjectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetForm() {
    final _$actionInfo = _$ProjectStoreBaseActionController.startAction(
        name: 'ProjectStoreBase.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$ProjectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pagingController: ${pagingController},
isLoading: ${isLoading},
selectedProject: ${selectedProject},
statistics: ${statistics},
selectedStatus: ${selectedStatus},
selectedType: ${selectedType},
searchQuery: ${searchQuery},
nameController: ${nameController},
descriptionController: ${descriptionController},
selectedProjectType: ${selectedProjectType},
selectedPriority: ${selectedPriority},
startDate: ${startDate},
endDate: ${endDate},
budgetController: ${budgetController},
isBillable: ${isBillable},
hourlyRateController: ${hourlyRateController},
selectedColor: ${selectedColor}
    ''';
  }
}
