import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../models/Attendance/attendance_regularization.dart';
import '../../../utils/string_extensions.dart';
import '../attendance_regularization_detail_screen.dart';

class RegularizationItemWidget extends StatelessWidget {
  final AttendanceRegularization model;
  final int index;
  final Function(BuildContext) deleteAction;
  final Function(BuildContext)? editAction;

  const RegularizationItemWidget({
    super.key,
    required this.model,
    required this.index,
    required this.deleteAction,
    this.editAction,
  });

  Color _getStatusColor() {
    switch (model.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (model.type) {
      case 'missing_checkin':
        return Iconsax.login;
      case 'missing_checkout':
        return Iconsax.logout;
      case 'wrong_time':
        return Iconsax.clock;
      case 'forgot_punch':
        return Iconsax.timer;
      case 'other':
        return Iconsax.note;
      default:
        return Iconsax.document;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          AttendanceRegularizationDetailScreen(regularizationId: model.id)
              .launch(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: appStore.appColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: appStore.appColorPrimary,
                      size: 24,
                    ),
                  ),
                  12.width,
                  // Type and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.typeLabel,
                          style: boldTextStyle(size: 15),
                        ),
                        4.height,
                        Text(
                          model.date,
                          style: secondaryTextStyle(size: 13),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      model.statusLabel.capitalize,
                      style: boldTextStyle(
                        color: _getStatusColor(),
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              12.height,
              // Time Info
              if (model.requestedCheckInTime != null ||
                  model.requestedCheckOutTime != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (model.requestedCheckInTime != null) ...[
                        Icon(Iconsax.login, size: 16, color: Colors.grey[700]),
                        4.width,
                        Text(
                          model.requestedCheckInTime!,
                          style: secondaryTextStyle(size: 13),
                        ),
                      ],
                      if (model.requestedCheckInTime != null &&
                          model.requestedCheckOutTime != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward,
                              size: 14, color: Colors.grey[600]),
                        ),
                      if (model.requestedCheckOutTime != null) ...[
                        Icon(Iconsax.logout, size: 16, color: Colors.grey[700]),
                        4.width,
                        Text(
                          model.requestedCheckOutTime!,
                          style: secondaryTextStyle(size: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              8.height,
              // Reason
              Text(
                model.reason,
                style: secondaryTextStyle(size: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Attachments indicator
              if (model.attachments.isNotEmpty) ...[
                8.height,
                Row(
                  children: [
                    Icon(Iconsax.document_text,
                        size: 14, color: Colors.grey[600]),
                    4.width,
                    Text(
                      '${model.attachments.length} attachment${model.attachments.length > 1 ? 's' : ''}',
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ],
              // Manager Comments (for non-pending)
              if (!model.isPending && model.managerComments != null) ...[
                8.height,
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.message_text,
                          size: 14, color: _getStatusColor()),
                      6.width,
                      Expanded(
                        child: Text(
                          model.managerComments!,
                          style: secondaryTextStyle(size: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Actions for pending requests
              if (model.isPending) ...[
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (editAction != null)
                      TextButton.icon(
                        onPressed: () => editAction!(context),
                        icon: const Icon(Iconsax.edit, size: 16),
                        label: Text(
                          language.lblEdit,
                          style: boldTextStyle(
                            color: appStore.appColorPrimary,
                            size: 13,
                          ),
                        ),
                      ),
                    8.width,
                    TextButton.icon(
                      onPressed: () => deleteAction(context),
                      icon: const Icon(Iconsax.trash, size: 16),
                      label: Text(
                        language.lblDelete,
                        style: boldTextStyle(color: Colors.red, size: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
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
}
