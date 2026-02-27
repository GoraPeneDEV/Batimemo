import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/project_store.dart';
import '../../models/project/project.dart';
import 'project_create_screen.dart';
import 'project_list_screen.dart';
import 'project_detail_screen.dart';
import 'project_statistics_screen.dart';
import 'timesheets/timesheet_list_screen.dart';
import 'timesheets/timesheet_form_screen.dart';

class ProjectDashboardScreen extends StatefulWidget {
  const ProjectDashboardScreen({super.key});

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  late ProjectStore _store;

  static const Color _primaryColor = Color(0xFF10B981);
  static const Color _primaryDark = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _store.fetchProjectStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: appStore.isDarkModeOn
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [_primaryColor, _primaryDark],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Gestion de Projets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F4F6),
                      child: _store.isLoading && _store.projectStatistics == null
                          ? _buildLoadingSkeleton()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildOverviewCard(),
                                    const SizedBox(height: 16),
                                    _buildMyTimeCard(),
                                    const SizedBox(height: 16),
                                    _buildQuickActions(),
                                    const SizedBox(height: 16),
                                    if (_store.projectStatistics?.recentProjects.isNotEmpty ?? false)
                                      _buildRecentProjects(),
                                    if (_store.projectStatistics?.overdueProjects.isNotEmpty ?? false) ...[
                                      const SizedBox(height: 16),
                                      _buildOverdueProjects(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: _store,
                child: const TimesheetFormScreen(),
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: _primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'Saisir du temps',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final stats = _store.projectStatistics;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appStore.isDarkModeOn
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [_primaryColor, _primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.briefcase, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Vue d\'ensemble',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildOverviewStat('Total', stats.overview.total.toString(), Iconsax.folder),
                _buildOverviewDivider(),
                _buildOverviewStat('Actifs', stats.overview.active.toString(), Iconsax.play),
                _buildOverviewDivider(),
                _buildOverviewStat('Terminés', stats.overview.completed.toString(), Iconsax.tick_circle),
                _buildOverviewDivider(),
                _buildOverviewStat('En retard', stats.overview.overdue.toString(), Iconsax.warning_2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildMyTimeCard() {
    final myTime = _store.projectStatistics?.myTime;
    if (myTime == null) return const SizedBox.shrink();

    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon temps cette semaine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Heures totales',
                    '${myTime.hoursThisWeek.toStringAsFixed(1)}h',
                    _primaryColor,
                    Iconsax.clock,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Facturables',
                    '${myTime.billableHoursThisWeek.toStringAsFixed(1)}h',
                    Colors.blue,
                    Iconsax.money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'En attente',
                    myTime.pendingTimesheets.toString(),
                    Colors.orange,
                    Iconsax.document_text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _buildQuickActionCard(
              'Mes Projets',
              Iconsax.briefcase,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: _store,
                    child: const ProjectListScreen(),
                  ),
                ),
              ).then((_) => _loadData()),
            ),
            _buildQuickActionCard(
              'Nouveau Projet',
              Iconsax.add_circle,
              _primaryColor,
              () => Navigator.push(
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
            ),
            _buildQuickActionCard(
              'Feuilles de temps',
              Iconsax.clock,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: _store,
                    child: const TimesheetListScreen(),
                  ),
                ),
              ),
            ),
            _buildQuickActionCard(
              'Saisir du temps',
              Iconsax.edit,
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: _store,
                    child: const TimesheetFormScreen(),
                  ),
                ),
              ).then((_) => _loadData()),
            ),
            _buildQuickActionCard(
              'Statistiques',
              Iconsax.chart,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: _store,
                    child: const ProjectStatisticsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProjects() {
    final recent = _store.projectStatistics!.recentProjects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Projets récents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Provider.value(
                    value: _store,
                    child: const ProjectListScreen(),
                  ),
                ),
              ),
              child: const Text(
                'Voir tout',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recent.take(3).map((project) => _buildProjectCard(project)).toList(),
      ],
    );
  }

  Widget _buildOverdueProjects() {
    final overdue = _store.projectStatistics!.overdueProjects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Projets en retard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        ...overdue.take(3).map((project) => _buildProjectCard(project, isOverdue: true)).toList(),
      ],
    );
  }

  Widget _buildProjectCard(Project project, {bool isOverdue = false}) {
    final statusColor = _getStatusColor(project.status);
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
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isOverdue
              ? Border.all(color: Colors.red.withOpacity(0.4), width: 1.5)
              : null,
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
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    project.code.length > 3
                        ? project.code.substring(0, 3)
                        : project.code,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            project.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (project.myRole != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${project.myRole}',
                            style: TextStyle(
                              fontSize: 11,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${project.completionPercentage}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    '${project.memberCount} membres',
                    style: TextStyle(
                      fontSize: 11,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planning':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'on_hold':
        return Colors.orange;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerCard(height: 140),
          const SizedBox(height: 16),
          _buildShimmerCard(height: 110),
          const SizedBox(height: 16),
          _buildShimmerBox(width: 150, height: 20),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: List.generate(5, (_) => _buildShimmerCard(height: 100)),
          ),
          const SizedBox(height: 16),
          _buildShimmerCard(height: 200),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
      highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
      highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
