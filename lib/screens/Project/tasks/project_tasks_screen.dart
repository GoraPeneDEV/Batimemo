import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../main.dart';
import '../../../models/Project/task_model.dart';
import '../../../stores/Project/TaskStore.dart';
import '../Widget/task_item_widget.dart';
import 'project_task_create_screen.dart';

class ProjectTasksScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectTasksScreen({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen> {
  final TaskStore _store = TaskStore();

  @override
  void initState() {
    super.initState();
    _store.setProjectId(widget.projectId);
    _store.pagingController.addPageRequestListener(_store.fetchTasks);
    _store.loadMeta(widget.projectId);
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.lblTasks),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildStatusFilterBar(),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (!_store.taskSystemAvailable) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      language.lblTaskSystemIsNotEnabled,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildList();
        },
      ),
      floatingActionButton: Observer(
        builder: (_) => _store.taskSystemAvailable
            ? FloatingActionButton(
                heroTag: 'fab_task',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectTaskCreateScreen(
                        store: _store,
                        projectId: widget.projectId,
                      ),
                    ),
                  );
                  if (result == true) {
                    _store.pagingController.refresh();
                  }
                },
                child: const Icon(Icons.add),
                tooltip: language.lblNew,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildStatusFilterBar() {
    return Observer(
      builder: (_) {
        final statuses = _store.meta?.statuses ?? [];
        if (statuses.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _StatusChip(
                label: language.lblAll,
                selected: _store.selectedStatusId == null,
                onTap: () => _store.applyStatusFilter(null),
              ),
              ...statuses.map((s) => _StatusChip(
                    label: s.name,
                    selected: _store.selectedStatusId == s.id,
                    color: _colorFromHex(s.color),
                    onTap: () => _store.applyStatusFilter(s.id),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () async => _store.pagingController.refresh(),
      child: PagedListView<int, TaskModel>(
        pagingController: _store.pagingController,
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        builderDelegate: PagedChildBuilderDelegate<TaskModel>(
          itemBuilder: (context, task, index) => TaskItemWidget(
            task: task,
            onStart: task.isCompleted == true
                ? null
                : () => _store.startTask(widget.projectId, task.id!),
            onStop: task.isRunning == true
                ? () => _store.stopTask(widget.projectId, task.id!)
                : null,
            onComplete: task.isCompleted == true
                ? null
                : () => _store.completeTask(widget.projectId, task.id!),
          ),
          firstPageProgressIndicatorBuilder: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          newPageProgressIndicatorBuilder: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          ),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checklist_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    language.lblNoItemsFound,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
          firstPageErrorIndicatorBuilder: (_) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    language.lblErrorFetchingData,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _store.pagingController.refresh(),
                    child: Text(language.lblRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '');
    if (h.length != 6 && h.length != 8) return null;
    try {
      return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) {
      return null;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: chipColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? chipColor : null,
          fontWeight: selected ? FontWeight.w600 : null,
          fontSize: 12,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
