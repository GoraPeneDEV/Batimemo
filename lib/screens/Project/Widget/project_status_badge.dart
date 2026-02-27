import 'package:flutter/material.dart';

class ProjectStatusBadge extends StatelessWidget {
  final String status;

  const ProjectStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = _scheme(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        scheme.$3,
        style: TextStyle(
          fontSize: 11,
          color: scheme.$2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color, String) _scheme(String s) {
    switch (s) {
      case 'in_progress':
        return (Colors.blue.shade100, Colors.blue.shade800, 'En cours');
      case 'completed':
        return (Colors.green.shade100, Colors.green.shade800, 'Terminé');
      case 'on_hold':
        return (Colors.orange.shade100, Colors.orange.shade800, 'En pause');
      case 'cancelled':
        return (Colors.red.shade100, Colors.red.shade800, 'Annulé');
      case 'planning':
      default:
        return (Colors.grey.shade200, Colors.grey.shade700, 'Planification');
    }
  }
}
