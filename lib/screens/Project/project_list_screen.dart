import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/project_store.dart';
import '../../models/project/project.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late ProjectStore _store;
  final ScrollController _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedType;
  String? _selectedPriority;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _store.fetchProjects(
      skip: 0,
      take: _pageSize,
      status: _selectedStatus,
      type: _selectedType,
      priority: _selectedPriority,
    );
    _currentPage = 0;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_store.isLoading) {
      if (_store.projects.length < _store.totalProjectsCount) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _store.fetchProjects(
      skip: _currentPage * _pageSize,
      take: _pageSize,
      status: _selectedStatus,
      type: _selectedType,
      priority: _selectedPriority,
      loadMore: true,
    );
    setState(() => _isLoadingMore = false);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    String? tempStatus = _selectedStatus;
    String? tempType = _selectedType;
    String? tempPriority = _selectedPriority;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          child: Padding(
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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),

                // Status filter
                Text('Statut', style: _filterLabelStyle()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    null,
                    'planning',
                    'in_progress',
                    'on_hold',
                    'completed',
                    'cancelled',
                  ].map((s) {
                    final isSelected = tempStatus == s;
                    final label = s == null
                        ? 'Tous'
                        : {
                            'planning': 'Planification',
                            'in_progress': 'En cours',
                            'on_hold': 'En pause',
                            'completed': 'Terminé',
                            'cancelled': 'Annulé',
                          }[s]!;
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setModalState(() => tempStatus = s),
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Priority filter
                Text('Priorité', style: _filterLabelStyle()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [null, 'low', 'medium', 'high', 'critical']
                      .map((p) {
                    final isSelected = tempPriority == p;
                    final label = p == null
                        ? 'Toutes'
                        : {
                            'low': 'Faible',
                            'medium': 'Moyen',
                            'high': 'Élevé',
                            'critical': 'Critique',
                          }[p]!;
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setModalState(() => tempPriority = p),
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = tempStatus;
                        _selectedType = tempType;
                        _selectedPriority = tempPriority;
                      });
                      Navigator.pop(context);
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle _filterLabelStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        title: Text(
          'Mes Projets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.filter,
              color: (_selectedStatus != null || _selectedPriority != null)
                  ? const Color(0xFF10B981)
                  : (appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827)),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Provider.value(
              value: _store,
              child: const ProjectCreateScreen(),
            ),
          ),
        ).then((created) {
          if (created == true) _loadData();
        }),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'Nouveau projet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.projects.isEmpty) {
            return _buildLoadingSkeleton();
          }

          if (_store.error != null && _store.projects.isEmpty) {
            return _buildErrorState();
          }

          if (_store.projects.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _store.projects.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == _store.projects.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildProjectItem(_store.projects[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectItem(Project project) {
    final statusColor = _getStatusColor(project.status);
    final priorityColor = _getPriorityColor(project.priority);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Provider.value(
            value: _store,
            child: ProjectDetailScreen(projectId: project.id),
          ),
        ),
      ).then((_) => _loadData()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (project.isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'En retard',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      project.statusLabel,
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      project.priorityLabel,
                      style: TextStyle(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Icon(Iconsax.people, size: 14,
                    color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${project.memberCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.completionPercentage / 100,
                        backgroundColor: appStore.isDarkModeOn
                            ? Colors.grey[700]
                            : const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation(statusColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${project.completionPercentage}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              if (project.endDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Iconsax.calendar, size: 13,
                      color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      'Échéance: ${project.endDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planning': return Colors.blue;
      case 'in_progress': return Colors.green;
      case 'on_hold': return Colors.orange;
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low': return Colors.grey;
      case 'medium': return Colors.blue;
      case 'high': return Colors.orange;
      case 'urgent': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 48, color: Colors.red.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(_store.error ?? 'Une erreur est survenue'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.briefcase, size: 64,
            color: appStore.isDarkModeOn ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun projet trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
        highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
