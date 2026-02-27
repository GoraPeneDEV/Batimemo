import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/Project/project_model.dart';
import '../../stores/Project/ProjectStore.dart';
import '../../stores/project_store.dart' as legacy;
import 'project_create_screen.dart';
import 'project_detail_screen.dart';
import 'Widget/project_item_widget.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({Key? key}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ProjectStore _store = ProjectStore();
  final legacy.ProjectStore _legacyStore = legacy.ProjectStore();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store.pagingController.addPageRequestListener(_store.fetchProjects);
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.lblProjectManagement),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: language.lblFilters,
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_project',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: _legacyStore,
                child: const ProjectCreateScreen(),
              ),
            ),
          );
          if (result == true) {
            _store.pagingController.refresh();
          }
        },
        child: const Icon(Icons.add),
        tooltip: language.lblNewProject,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '${language.lblSearch}...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: Observer(
            builder: (_) => _store.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _store.searchQuery = '';
                      _store.applyFilters();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        onChanged: (v) {
          _store.searchQuery = v;
          _store.applyFilters();
        },
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () async => _store.pagingController.refresh(),
      child: PagedListView<int, ProjectModel>(
        pagingController: _store.pagingController,
        padding: const EdgeInsets.only(bottom: 88),
        builderDelegate: PagedChildBuilderDelegate<ProjectModel>(
          itemBuilder: (context, project, index) => ProjectItemWidget(
            project: project,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Provider.value(
                  value: _legacyStore,
                  child: ProjectDetailScreen(projectId: project.id ?? 0),
                ),
              ),
            ).then((_) => _store.pagingController.refresh()),
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
                  Icon(Icons.folder_open_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    language.lblNoProjectsFound,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
          firstPageErrorIndicatorBuilder: (ctx) => Center(
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ProjectFilterSheet(store: _store),
    );
  }
}

class _ProjectFilterSheet extends StatefulWidget {
  final ProjectStore store;
  const _ProjectFilterSheet({required this.store});

  @override
  State<_ProjectFilterSheet> createState() => _ProjectFilterSheetState();
}

class _ProjectFilterSheetState extends State<_ProjectFilterSheet> {
  final List<Map<String, String>> _statusOptions = [
    {'value': 'planning', 'label': 'Planification'},
    {'value': 'in_progress', 'label': 'En cours'},
    {'value': 'on_hold', 'label': 'En pause'},
    {'value': 'completed', 'label': 'Terminé'},
    {'value': 'cancelled', 'label': 'Annulé'},
  ];

  final List<Map<String, String>> _typeOptions = [
    {'value': 'internal', 'label': 'Interne'},
    {'value': 'client', 'label': 'Client'},
    {'value': 'other', 'label': 'Autre'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(language.lblFilters,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  widget.store.resetFilters();
                  Navigator.pop(context);
                },
                child: Text(language.lblReset),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(language.lblStatus,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _statusOptions.map((opt) {
              return Observer(
                builder: (_) => ChoiceChip(
                  label: Text(opt['label']!),
                  selected: widget.store.selectedStatus == opt['value'],
                  onSelected: (val) {
                    widget.store.selectedStatus =
                        val ? opt['value'] : null;
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(language.lblType,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _typeOptions.map((opt) {
              return Observer(
                builder: (_) => ChoiceChip(
                  label: Text(opt['label']!),
                  selected: widget.store.selectedType == opt['value'],
                  onSelected: (val) {
                    widget.store.selectedType =
                        val ? opt['value'] : null;
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.store.applyFilters();
                Navigator.pop(context);
              },
              child: Text(language.lblApply),
            ),
          ),
        ],
      ),
    );
  }
}
