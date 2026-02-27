import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/project_store.dart';
import '../../models/project/project.dart';
import 'timesheets/timesheet_list_screen.dart';
import 'timesheets/timesheet_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectStore _store;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _store.fetchProject(widget.projectId);
  }

  @override
  void dispose() {
    _store.clearSelectedProject();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.selectedProject == null) {
            return _buildLoadingSkeleton();
          }

          if (_store.selectedProject == null) {
            return const Center(child: Text('Projet introuvable'));
          }

          final project = _store.selectedProject!;
          final statusColor = _getStatusColor(project.status);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: statusColor,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [statusColor, statusColor.withOpacity(0.7)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    project.code,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    project.statusLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              project.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress card
                      _buildProgressCard(project, statusColor),
                      const SizedBox(height: 16),

                      // Info card
                      _buildInfoCard(project),
                      const SizedBox(height: 16),

                      // Financial card
                      if (project.budget != null) ...[
                        _buildFinancialCard(project),
                        const SizedBox(height: 16),
                      ],

                      // Members card
                      if (project.members.isNotEmpty) ...[
                        _buildMembersCard(project),
                        const SizedBox(height: 16),
                      ],

                      // Actions
                      _buildActionsCard(project),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(Project project, Color statusColor) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avancement',
                  style: _sectionTitleStyle(),
                ),
                Text(
                  '${project.completionPercentage}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.completionPercentage / 100,
                backgroundColor: appStore.isDarkModeOn ? Colors.grey[700] : const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(statusColor),
                minHeight: 10,
              ),
            ),
            if (project.totalHours != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Heures totales',
                    '${project.totalHours!.toStringAsFixed(1)}h', Iconsax.clock)),
                  Expanded(child: _buildInfoItem('Heures facturables',
                    '${(project.billableHours ?? 0).toStringAsFixed(1)}h', Iconsax.money)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Project project) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations', style: _sectionTitleStyle()),
            const SizedBox(height: 16),
            if (project.description != null && project.description!.isNotEmpty) ...[
              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
            ],
            _buildInfoRow('Type', project.typeLabel, Iconsax.category),
            const SizedBox(height: 12),
            _buildInfoRow('Priorité', project.priorityLabel,
              Iconsax.flag, color: _getPriorityColor(project.priority)),
            if (project.startDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Début', project.startDate!, Iconsax.calendar_1),
            ],
            if (project.endDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Échéance', project.endDate!, Iconsax.calendar_2,
                color: project.isOverdue ? Colors.red : null),
            ],
            if (project.projectManager != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Chef de projet', project.projectManager!.name, Iconsax.user),
            ],
            if (project.client != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Client', project.client!.name, Iconsax.building),
            ],
            if (project.myRole != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Mon rôle', project.myRole!, Iconsax.briefcase),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(Project project) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financier', style: _sectionTitleStyle()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Budget', '\$${project.budget}', Iconsax.wallet)),
                Expanded(child: _buildInfoItem('Coût réel', '\$${project.actualCost ?? 0}', Iconsax.money_recive)),
                Expanded(child: _buildInfoItem('Revenu', '\$${project.actualRevenue ?? 0}', Iconsax.money_send)),
              ],
            ),
            if (project.isOverBudget == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.warning_2, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Budget dépassé (${project.budgetVariancePercentage?.abs().toStringAsFixed(1)}%)',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMembersCard(Project project) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Équipe', style: _sectionTitleStyle()),
                Text(
                  '${project.members.length} membre(s)',
                  style: TextStyle(
                    fontSize: 13,
                    color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...project.members.map((member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                    child: Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          member.roleLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (member.allocationPercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${member.allocationPercentage}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(Project project) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Provider.value(
                  value: _store,
                  child: TimesheetFormScreen(preselectedProjectId: project.id),
                ),
              ),
            ).then((_) => _store.fetchProject(widget.projectId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Iconsax.clock_1, color: Colors.white),
            label: const Text(
              'Saisir du temps',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Provider.value(
                  value: _store,
                  child: TimesheetListScreen(initialProjectId: project.id),
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF10B981)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Iconsax.document_text, color: Color(0xFF10B981)),
            label: const Text(
              'Voir les feuilles de temps',
              style: TextStyle(color: Color(0xFF10B981), fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16,
          color: color ?? (appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280))),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? (appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20,
          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
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

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low': return Colors.grey;
      case 'medium': return Colors.blue;
      case 'high': return Colors.orange;
      case 'urgent': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
