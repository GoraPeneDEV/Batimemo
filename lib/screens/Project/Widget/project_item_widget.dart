import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../models/Project/project_model.dart';
import '../../../utils/colors.dart';
import 'project_status_badge.dart';

class ProjectItemWidget extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectItemWidget({
    Key? key,
    required this.project,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accent =
        _colorFromHex(project.colorCode) ?? Theme.of(context).primaryColor;
    final int progress = project.completionPercentage ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ProjectStatusBadge(status: project.status ?? ''),
                    ],
                  ),
                  if (project.code != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.code!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Dates + priority
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _dateRange(),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PriorityChip(priority: project.priority ?? ''),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(accent),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$progress%',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Members + type
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${project.memberCount ?? 0} membre(s)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      if (project.typeLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project.typeLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (project.isOverdue == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            'Overdue',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateRange() {
    if (project.startDate == null && project.endDate == null) return '—';
    final start = project.startDate ?? '';
    final end = project.endDate ?? '';
    if (start.isNotEmpty && end.isNotEmpty) return '$start → $end';
    if (start.isNotEmpty) return 'From $start';
    return 'Until $end';
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '');
    if (h.length != 6 && h.length != 8) return null;
    try {
      final val = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
      return Color(val);
    } catch (_) {
      return null;
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (priority) {
      case 'urgent':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      case 'high':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      case 'medium':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.isNotEmpty
            ? priority[0].toUpperCase() + priority.substring(1)
            : '',
        style: TextStyle(
          fontSize: 11,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
