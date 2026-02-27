import 'package:flutter/material.dart';
import '../../../models/Project/timesheet_model.dart';

class TimesheetItemWidget extends StatelessWidget {
  final TimesheetModel timesheet;
  final VoidCallback? onSubmit;
  final VoidCallback? onDelete;

  const TimesheetItemWidget({
    Key? key,
    required this.timesheet,
    this.onSubmit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDraft = timesheet.status == 'draft';
    final bool isApproved = timesheet.status == 'approved';

    return Container(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timesheet.projectName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (timesheet.projectCode != null)
                        Text(
                          timesheet.projectCode!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: timesheet.status ?? ''),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${timesheet.hours?.toStringAsFixed(1) ?? '0'} h',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  timesheet.date ?? '',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                if (timesheet.isBillable == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Facturable',
                      style: TextStyle(
                          fontSize: 11, color: Colors.green.shade700),
                    ),
                  ),
              ],
            ),
            if (isDraft && (onSubmit != null || onDelete != null)) ...[
              const Divider(height: 16),
              Row(
                children: [
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      label: const Text('Supprimer',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0)),
                    ),
                  const Spacer(),
                  if (onSubmit != null)
                    ElevatedButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.send, size: 14),
                      label: const Text('Soumettre',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'approved':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = 'Approuvé';
        break;
      case 'submitted':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        label = 'Soumis';
        break;
      case 'rejected':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = 'Rejeté';
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'Brouillon';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
