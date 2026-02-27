import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../models/Document/document_request_model.dart';

class DocumentRequestItemWidget extends StatelessWidget {
  final int index;
  final DocumentRequestModel model;
  final Function(BuildContext) cancelAction;
  final Function(BuildContext) downloadAction;

  const DocumentRequestItemWidget({
    super.key,
    required this.index,
    required this.model,
    required this.cancelAction,
    required this.downloadAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Container(
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
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - Icon + Title + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF696CFF).withValues(alpha: 0.2),
                      const Color(0xFF5457E6).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.document,
                  size: 24,
                  color: Color(0xFF696CFF),
                ),
              ),
              12.width,
              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.documentType ?? language.lblNA,
                      style: boldTextStyle(size: 16),
                    ),
                    6.height,
                    _buildStatusBadge(),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          // Divider
          Container(
            height: 1,
            color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
          ),
          16.height,
          // Info Rows
          _buildInfoRow(
            isDark,
            Iconsax.calendar_1,
            language.lblRequestedOn,
            model.requestedDate ?? language.lblNA,
          ),

          // Conditional Action Buttons
          if (model.status?.toLowerCase() == 'pending') ...[
            16.height,
            _buildCancelButton(isDark),
          ],
          if (model.status?.toLowerCase() == 'generated') ...[
            16.height,
            _buildDownloadButton(isDark),
          ],
        ],
      ),
    );
  }

  // Helper to build status badge
  Widget _buildStatusBadge() {
    final status = model.status?.toLowerCase() ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF10B981);
        statusIcon = Iconsax.tick_circle;
        statusText = language.lblApproved;
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Iconsax.close_circle;
        statusText = language.lblRejected;
        break;
      case 'generated':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Iconsax.tick_circle;
        statusText = language.lblGenerated;
        break;
      case 'cancelled':
        statusColor = const Color(0xFF6B7280);
        statusIcon = Iconsax.close_circle;
        statusText = language.lblCancelled;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Iconsax.clock;
        statusText = language.lblPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          4.width,
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build info row
  Widget _buildInfoRow(bool isDark, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        8.width,
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build cancel button
  Widget _buildCancelButton(bool isDark) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => cancelAction(context),
          icon: const Icon(Iconsax.close_circle, size: 16),
          label: Text(language.lblCancel),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build download button
  Widget _buildDownloadButton(bool isDark) {
    return Builder(
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => downloadAction(context),
          icon: const Icon(Iconsax.document_download, size: 16),
          label: Text(language.lblDownloadDocument),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
