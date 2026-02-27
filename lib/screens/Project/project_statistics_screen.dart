import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/project_store.dart';
import 'project_detail_screen.dart';

class ProjectStatisticsScreen extends StatefulWidget {
  const ProjectStatisticsScreen({super.key});

  @override
  State<ProjectStatisticsScreen> createState() => _ProjectStatisticsScreenState();
}

class _ProjectStatisticsScreenState extends State<ProjectStatisticsScreen> {
  late ProjectStore _store;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _store.fetchProjectStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        title: Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.projectStatistics == null) {
            return _buildLoadingSkeleton();
          }

          if (_store.projectStatistics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.chart, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Aucune statistique disponible'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _store.fetchProjectStatistics(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final stats = _store.projectStatistics!;

          return RefreshIndicator(
            onRefresh: () => _store.fetchProjectStatistics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview counters
                  _buildSectionTitle('Vue d\'ensemble'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                    children: [
                      _buildCounterCard('Total', stats.overview.total.toString(), Colors.blue, Iconsax.briefcase),
                      _buildCounterCard('Actifs', stats.overview.active.toString(), const Color(0xFF10B981), Iconsax.play),
                      _buildCounterCard('Terminés', stats.overview.completed.toString(), Colors.grey, Iconsax.tick_circle),
                      _buildCounterCard('En pause', stats.overview.onHold.toString(), Colors.orange, Iconsax.pause),
                      _buildCounterCard('En retard', stats.overview.overdue.toString(), Colors.red, Iconsax.warning_2),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // My time this week
                  _buildSectionTitle('Mon temps cette semaine'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: _cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTimeItem(
                              'Heures totales',
                              '${stats.myTime.hoursThisWeek.toStringAsFixed(1)}h',
                              const Color(0xFF10B981),
                              Iconsax.clock,
                            ),
                          ),
                          Container(width: 1, height: 50,
                            color: appStore.isDarkModeOn ? Colors.grey[700] : const Color(0xFFE5E7EB)),
                          Expanded(
                            child: _buildTimeItem(
                              'Facturables',
                              '${stats.myTime.billableHoursThisWeek.toStringAsFixed(1)}h',
                              Colors.blue,
                              Iconsax.money,
                            ),
                          ),
                          Container(width: 1, height: 50,
                            color: appStore.isDarkModeOn ? Colors.grey[700] : const Color(0xFFE5E7EB)),
                          Expanded(
                            child: _buildTimeItem(
                              'En attente',
                              stats.myTime.pendingTimesheets.toString(),
                              Colors.orange,
                              Iconsax.document_text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent projects
                  if (stats.recentProjects.isNotEmpty) ...[
                    _buildSectionTitle('Projets récents'),
                    const SizedBox(height: 12),
                    ...stats.recentProjects.map((project) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Provider.value(
                              value: _store,
                              child: ProjectDetailScreen(projectId: project.id),
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: _cardDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(project.status),
                                    borderRadius: BorderRadius.circular(4),
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
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${project.code} • ${project.statusLabel}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${project.completionPercentage}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(project.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ],

                  // Overdue projects
                  if (stats.overdueProjects.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildSectionTitle('Projets en retard'),
                    const SizedBox(height: 12),
                    ...stats.overdueProjects.map((project) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Provider.value(
                              value: _store,
                              child: ProjectDetailScreen(projectId: project.id),
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(Iconsax.warning_2, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    project.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                if (project.endDate != null)
                                  Text(
                                    project.endDate!,
                                    style: const TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
      ),
    );
  }

  Widget _buildCounterCard(String label, String value, Color color, IconData icon) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planning': return Colors.blue;
      case 'in_progress': return const Color(0xFF10B981);
      case 'on_hold': return Colors.orange;
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
