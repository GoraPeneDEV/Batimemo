import 'package:flutter/material.dart';
import '../../../models/Project/task_model.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const TaskItemWidget({
    Key? key,
    required this.task,
    this.onStart,
    this.onStop,
    this.onComplete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRunning = task.isRunning == true;
    final bool isCompleted = task.isCompleted == true;
    final statusColor =
        _colorFromHex(task.statusColor) ?? Colors.grey;
    final priorityColor =
        _colorFromHex(task.priorityColor) ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Running indicator
                  if (isRunning)
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 6),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      task.title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  if (task.statusName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.statusName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (task.assignedToName != null) ...[
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedToName!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (task.dueDate != null) ...[
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (task.priorityName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.priorityName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (task.isMilestone == true) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.flag, size: 14, color: Colors.orange),
                  ],
                ],
              ),
              if (!isCompleted &&
                  (onStart != null || onStop != null || onComplete != null))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isRunning && onStart != null)
                        _ActionBtn(
                          icon: Icons.play_arrow,
                          label: 'Démarrer',
                          color: Colors.green,
                          onTap: onStart!,
                        ),
                      if (isRunning && onStop != null) ...[
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: Icons.stop,
                          label: 'Arrêter',
                          color: Colors.orange,
                          onTap: onStop!,
                        ),
                      ],
                      if (onComplete != null) ...[
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: Icons.check_circle_outline,
                          label: 'Terminer',
                          color: Colors.blue,
                          onTap: onComplete!,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
