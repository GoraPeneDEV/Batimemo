import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';

import '../../../main.dart';
import '../../../models/HRPolicies/policy_model.dart';

class PolicyItemWidget extends StatelessWidget {
  final PolicyModel policy;
  final VoidCallback onTap;

  const PolicyItemWidget({
    super.key,
    required this.policy,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'acknowledged':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDeadlineText() {
    if (policy.isOverdue) {
      final daysOverdue = (policy.daysUntilDeadline ?? 0).abs();
      return 'Overdue by ${daysOverdue.toInt()} day${daysOverdue > 1 ? 's' : ''}';
    } else if (policy.daysUntilDeadline != null) {
      final daysLeft = policy.daysUntilDeadline!.toInt();
      if (daysLeft == 0) {
        return 'Due today';
      } else if (daysLeft == 1) {
        return 'Due tomorrow';
      } else {
        return 'Due in $daysLeft days';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Observer(
      builder: (_) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  // Category Icon/Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF696CFF).withOpacity(0.8),
                          const Color(0xFF5457E6).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.document_text,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          policy.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Category name
                        Text(
                          policy.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(policy.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(policy.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      policy.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(policy.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(
                height: 1,
                color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
              ),
              const SizedBox(height: 12),

              // Info chips row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Version badge
                  _buildInfoChip(
                    icon: Iconsax.code_circle,
                    label: 'v${policy.version}',
                    color: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),

                  // Mandatory badge
                  if (policy.isMandatory)
                    _buildInfoChip(
                      icon: Iconsax.warning_2,
                      label: 'Mandatory',
                      color: Colors.red,
                      isDark: isDark,
                    ),

                  // Document badge
                  if (policy.hasDocument)
                    _buildInfoChip(
                      icon: Iconsax.document_download,
                      label: 'Has Document',
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),

                  // Deadline info
                  if (policy.deadlineDate != null && policy.status != 'acknowledged')
                    _buildInfoChip(
                      icon: policy.isOverdue ? Iconsax.clock : Iconsax.calendar,
                      label: _getDeadlineText(),
                      color: policy.isOverdue ? Colors.red : Colors.orange,
                      isDark: isDark,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
