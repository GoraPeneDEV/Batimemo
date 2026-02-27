// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TaskStore on TaskStoreBase, Store {
  late final _$pagingControllerAtom =
      Atom(name: 'TaskStoreBase.pagingController', context: context);

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
      Atom(name: 'TaskStoreBase.isLoading', context: context);

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

  late final _$taskSystemAvailableAtom =
      Atom(name: 'TaskStoreBase.taskSystemAvailable', context: context);

  @override
  bool get taskSystemAvailable {
    _$taskSystemAvailableAtom.reportRead();
    return super.taskSystemAvailable;
  }

  @override
  set taskSystemAvailable(bool value) {
    _$taskSystemAvailableAtom.reportWrite(value, super.taskSystemAvailable, () {
      super.taskSystemAvailable = value;
    });
  }

  late final _$metaAtom = Atom(name: 'TaskStoreBase.meta', context: context);

  @override
  InvalidType get meta {
    _$metaAtom.reportRead();
    return super.meta;
  }

  @override
  set meta(InvalidType value) {
    _$metaAtom.reportWrite(value, super.meta, () {
      super.meta = value;
    });
  }

  late final _$selectedStatusIdAtom =
      Atom(name: 'TaskStoreBase.selectedStatusId', context: context);

  @override
  int? get selectedStatusId {
    _$selectedStatusIdAtom.reportRead();
    return super.selectedStatusId;
  }

  @override
  set selectedStatusId(int? value) {
    _$selectedStatusIdAtom.reportWrite(value, super.selectedStatusId, () {
      super.selectedStatusId = value;
    });
  }

  late final _$titleControllerAtom =
      Atom(name: 'TaskStoreBase.titleController', context: context);

  @override
  TextEditingController get titleController {
    _$titleControllerAtom.reportRead();
    return super.titleController;
  }

  @override
  set titleController(TextEditingController value) {
    _$titleControllerAtom.reportWrite(value, super.titleController, () {
      super.titleController = value;
    });
  }

  late final _$descriptionControllerAtom =
      Atom(name: 'TaskStoreBase.descriptionController', context: context);

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

  late final _$selectedFormStatusIdAtom =
      Atom(name: 'TaskStoreBase.selectedFormStatusId', context: context);

  @override
  int? get selectedFormStatusId {
    _$selectedFormStatusIdAtom.reportRead();
    return super.selectedFormStatusId;
  }

  @override
  set selectedFormStatusId(int? value) {
    _$selectedFormStatusIdAtom.reportWrite(value, super.selectedFormStatusId,
        () {
      super.selectedFormStatusId = value;
    });
  }

  late final _$selectedFormPriorityIdAtom =
      Atom(name: 'TaskStoreBase.selectedFormPriorityId', context: context);

  @override
  int? get selectedFormPriorityId {
    _$selectedFormPriorityIdAtom.reportRead();
    return super.selectedFormPriorityId;
  }

  @override
  set selectedFormPriorityId(int? value) {
    _$selectedFormPriorityIdAtom
        .reportWrite(value, super.selectedFormPriorityId, () {
      super.selectedFormPriorityId = value;
    });
  }

  late final _$selectedAssignedUserIdAtom =
      Atom(name: 'TaskStoreBase.selectedAssignedUserId', context: context);

  @override
  int? get selectedAssignedUserId {
    _$selectedAssignedUserIdAtom.reportRead();
    return super.selectedAssignedUserId;
  }

  @override
  set selectedAssignedUserId(int? value) {
    _$selectedAssignedUserIdAtom
        .reportWrite(value, super.selectedAssignedUserId, () {
      super.selectedAssignedUserId = value;
    });
  }

  late final _$dueDateAtom =
      Atom(name: 'TaskStoreBase.dueDate', context: context);

  @override
  DateTime? get dueDate {
    _$dueDateAtom.reportRead();
    return super.dueDate;
  }

  @override
  set dueDate(DateTime? value) {
    _$dueDateAtom.reportWrite(value, super.dueDate, () {
      super.dueDate = value;
    });
  }

  late final _$estimatedHoursControllerAtom =
      Atom(name: 'TaskStoreBase.estimatedHoursController', context: context);

  @override
  TextEditingController get estimatedHoursController {
    _$estimatedHoursControllerAtom.reportRead();
    return super.estimatedHoursController;
  }

  @override
  set estimatedHoursController(TextEditingController value) {
    _$estimatedHoursControllerAtom
        .reportWrite(value, super.estimatedHoursController, () {
      super.estimatedHoursController = value;
    });
  }

  late final _$isMilestoneAtom =
      Atom(name: 'TaskStoreBase.isMilestone', context: context);

  @override
  bool get isMilestone {
    _$isMilestoneAtom.reportRead();
    return super.isMilestone;
  }

  @override
  set isMilestone(bool value) {
    _$isMilestoneAtom.reportWrite(value, super.isMilestone, () {
      super.isMilestone = value;
    });
  }

  late final _$loadMetaAsyncAction =
      AsyncAction('TaskStoreBase.loadMeta', context: context);

  @override
  Future<void> loadMeta(int projectId) {
    return _$loadMetaAsyncAction.run(() => super.loadMeta(projectId));
  }

  late final _$fetchTasksAsyncAction =
      AsyncAction('TaskStoreBase.fetchTasks', context: context);

  @override
  Future<void> fetchTasks(int pageKey) {
    return _$fetchTasksAsyncAction.run(() => super.fetchTasks(pageKey));
  }

  late final _$createTaskAsyncAction =
      AsyncAction('TaskStoreBase.createTask', context: context);

  @override
  Future<bool> createTask(int projectId) {
    return _$createTaskAsyncAction.run(() => super.createTask(projectId));
  }

  late final _$completeTaskAsyncAction =
      AsyncAction('TaskStoreBase.completeTask', context: context);

  @override
  Future<bool> completeTask(int projectId, int taskId) {
    return _$completeTaskAsyncAction
        .run(() => super.completeTask(projectId, taskId));
  }

  late final _$startTaskAsyncAction =
      AsyncAction('TaskStoreBase.startTask', context: context);

  @override
  Future<bool> startTask(int projectId, int taskId) {
    return _$startTaskAsyncAction.run(() => super.startTask(projectId, taskId));
  }

  late final _$stopTaskAsyncAction =
      AsyncAction('TaskStoreBase.stopTask', context: context);

  @override
  Future<bool> stopTask(int projectId, int taskId) {
    return _$stopTaskAsyncAction.run(() => super.stopTask(projectId, taskId));
  }

  late final _$TaskStoreBaseActionController =
      ActionController(name: 'TaskStoreBase', context: context);

  @override
  void applyStatusFilter(int? statusId) {
    final _$actionInfo = _$TaskStoreBaseActionController.startAction(
        name: 'TaskStoreBase.applyStatusFilter');
    try {
      return super.applyStatusFilter(statusId);
    } finally {
      _$TaskStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetForm() {
    final _$actionInfo = _$TaskStoreBaseActionController.startAction(
        name: 'TaskStoreBase.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$TaskStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pagingController: ${pagingController},
isLoading: ${isLoading},
taskSystemAvailable: ${taskSystemAvailable},
meta: ${meta},
selectedStatusId: ${selectedStatusId},
titleController: ${titleController},
descriptionController: ${descriptionController},
selectedFormStatusId: ${selectedFormStatusId},
selectedFormPriorityId: ${selectedFormPriorityId},
selectedAssignedUserId: ${selectedAssignedUserId},
dueDate: ${dueDate},
estimatedHoursController: ${estimatedHoursController},
isMilestone: ${isMilestone}
    ''';
  }
}
