import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/leave_store.dart';
import '../../models/leave/leave_request.dart';
import '../../utils/string_extensions.dart';
import '../../utils/app_colors.dart';
import '../../utils/url_helper.dart';
import 'leave_request_form_screen.dart';

class LeaveRequestDetailScreen extends StatefulWidget {
  final int leaveRequestId;

  const LeaveRequestDetailScreen({super.key, required this.leaveRequestId});

  @override
  State<LeaveRequestDetailScreen> createState() =>
      _LeaveRequestDetailScreenState();
}

class _LeaveRequestDetailScreenState extends State<LeaveRequestDetailScreen> {
  late LeaveStore _leaveStore;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _leaveStore.fetchLeaveRequest(widget.leaveRequestId);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending') {
      return Colors.orange;
    } else if (statusLower == 'approved') {
      return Colors.green;
    } else if (statusLower == 'rejected') {
      return Colors.red;
    } else if (statusLower.startsWith('cancelled')) {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending') {
      return Iconsax.clock;
    } else if (statusLower == 'approved') {
      return Iconsax.tick_circle;
    } else if (statusLower == 'rejected') {
      return Iconsax.close_circle;
    } else if (statusLower.startsWith('cancelled')) {
      return Iconsax.slash;
    } else {
      return Iconsax.info_circle;
    }
  }

  Future<void> _cancelLeaveRequest() async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.warning_2, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.lblCancelLeaveRequest,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.lblConfirmCancelLeave,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: TextStyle(
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                hintText: language.lblCancellationReasonOptional,
                hintStyle: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[500]
                      : const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: appStore.isDarkModeOn
                    ? const Color(0xFF111827)
                    : const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[700]!
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[700]!
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              language.lblNoKeepIt,
              style: TextStyle(
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              language.lblYesCancel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isCancelling = true);

      final success = await _leaveStore.cancelLeaveRequest(
        widget.leaveRequestId,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : null,
      );

      setState(() => _isCancelling = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblLeaveRequestCancelledSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_leaveStore.error ?? language.lblFailedToCancelLeave),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openDocument(String url) async {
    try {
      final fullUrl = UrlHelper.getFullUrl(url);
      final uri = Uri.parse(fullUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblCannotOpenDocument),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (iconColor ?? const Color(0xFF696CFF)).withOpacity(0.2),
                  (iconColor ?? const Color(0xFF696CFF)).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? const Color(0xFF696CFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(LeaveRequest request) {
    final List<Map<String, dynamic>> timelineItems = [];

    // Requested
    timelineItems.add({
      'title': language.lblLeaveRequested,
      'date': _formatDateTime(request.createdAt),
      'icon': Iconsax.document,
      'color': Colors.blue,
      'isCompleted': true,
    });

    // Approved/Rejected
    if (request.isApproved) {
      timelineItems.add({
        'title': language.lblApproved,
        'date': request.approvedAt != null
            ? _formatDateTime(request.approvedAt!)
            : '',
        'subtitle': request.approvedBy != null
            ? 'By ${request.approvedBy!.name}'
            : null,
        'notes': request.approvalNotes,
        'icon': Iconsax.tick_circle,
        'color': Colors.green,
        'isCompleted': true,
      });
    } else if (request.isRejected) {
      timelineItems.add({
        'title': language.lblRejected,
        'date':
            request.rejectedAt != null ? _formatDateTime(request.rejectedAt!) : '',
        'subtitle':
            request.rejectedBy != null ? 'By ${request.rejectedBy!.name}' : null,
        'notes': request.approvalNotes,
        'icon': Iconsax.close_circle,
        'color': Colors.red,
        'isCompleted': true,
      });
    } else if (request.isCancelled) {
      timelineItems.add({
        'title': language.lblCancelled,
        'date': request.cancelledAt != null
            ? _formatDateTime(request.cancelledAt!)
            : '',
        'subtitle': request.cancelledBy != null
            ? 'By ${request.cancelledBy!.name}'
            : null,
        'notes': request.cancelReason,
        'icon': Iconsax.slash,
        'color': Colors.grey,
        'isCompleted': true,
      });
    } else {
      timelineItems.add({
        'title': language.lblPendingApproval,
        'date': language.lblAwaitingReview,
        'icon': Iconsax.clock,
        'color': Colors.orange,
        'isCompleted': false,
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.refresh_circle,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblStatusTimeline,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...timelineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == timelineItems.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item['isCompleted']
                              ? item['color']
                              : (appStore.isDarkModeOn
                                  ? Colors.grey[700]
                                  : Colors.grey.shade300),
                          shape: BoxShape.circle,
                          boxShadow: item['isCompleted']
                              ? [
                                  BoxShadow(
                                    color: item['color'].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          item['icon'],
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: item['isCompleted']
                                  ? [
                                      item['color'],
                                      item['color'].withOpacity(0.3),
                                    ]
                                  : [
                                      appStore.isDarkModeOn
                                          ? Colors.grey[700]!
                                          : Colors.grey.shade300,
                                      appStore.isDarkModeOn
                                          ? Colors.grey[700]!
                                          : Colors.grey.shade300,
                                    ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (item['date'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                        if (item['subtitle'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                        if (item['notes'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[800]!
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              item['notes'],
                              style: TextStyle(
                                fontSize: 13,
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[300]
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                        if (!isLast) const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status card skeleton
          Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Details card skeleton
          Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Timeline skeleton
          Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          if (_leaveStore.isLoading) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: appStore.isDarkModeOn
                      ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                      : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
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
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            language.lblLeaveRequestDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                          child: _buildLoadingSkeleton(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_leaveStore.error != null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: appStore.isDarkModeOn
                      ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                      : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
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
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            language.lblLeaveRequestDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Error Content
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
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Iconsax.close_circle,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    language.lblErrorLoadingDetails,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: appStore.isDarkModeOn
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _leaveStore.error!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _loadData,
                                    icon: const Icon(Iconsax.refresh, color: Colors.white),
                                    label: Text(
                                      language.lblRetry,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF696CFF),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
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
            );
          }

          final request = _leaveStore.selectedLeaveRequest;
          if (request == null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: appStore.isDarkModeOn
                      ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                      : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Text(
                    language.lblLeaveRequestNotFound,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appStore.isDarkModeOn
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            language.lblLeaveDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (request.isPending)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PopupMenuButton(
                              icon: const Icon(Iconsax.more, color: Colors.white),
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.edit, size: 20, color: Color(0xFF696CFF)),
                                      const SizedBox(width: 12),
                                      Text(
                                        language.lblEdit,
                                        style: TextStyle(
                                          color: appStore.isDarkModeOn
                                              ? Colors.white
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Provider.value(
                                            value: _leaveStore,
                                            child: LeaveRequestFormScreen(
                                                leaveRequest: request),
                                          ),
                                        ),
                                      ).then((_) => _loadData());
                                    });
                                  },
                                ),
                                if (request.canCancel == true)
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        const Icon(Iconsax.close_circle,
                                            size: 20, color: Colors.red),
                                        const SizedBox(width: 12),
                                        Text(language.lblCancel,
                                            style: const TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    onTap: () {
                                      Future.delayed(Duration.zero, _cancelLeaveRequest);
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content Area
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Card with Gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getStatusColor(request.status),
                                      _getStatusColor(request.status).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(request.status).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(request.status),
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              request.status.replaceAll('_', ' ').titleCase,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Request #${request.id}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Leave Details Card
                              Container(
                                decoration: BoxDecoration(
                                  color: appStore.isDarkModeOn
                                      ? const Color(0xFF1F2937)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[700]!
                                        : const Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF696CFF).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Iconsax.document_text,
                                              color: Color(0xFF696CFF),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            language.lblLeaveDetails,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: appStore.isDarkModeOn
                                                  ? Colors.white
                                                  : const Color(0xFF111827),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInfoRow(
                                        Iconsax.category,
                                        language.lblLeaveType,
                                        request.leaveType.name,
                                      ),
                                      _buildInfoRow(
                                        Iconsax.calendar_1,
                                        language.lblFromDate,
                                        _formatDate(request.fromDate),
                                      ),
                                      _buildInfoRow(
                                        Iconsax.calendar_1,
                                        language.lblToDate,
                                        _formatDate(request.toDate),
                                      ),
                                      _buildInfoRow(
                                        Iconsax.clock,
                                        language.lblTotalDays,
                                        '${request.totalDays} ${request.totalDays > 1 ? language.lblDays : language.lblDay}${request.isHalfDay ? ' (${language.lblHalfDay} - ${request.halfDayType?.replaceAll('_', ' ').capitalize})' : ''}',
                                      ),
                                      if (request.usesCompOff == true && request.compOffDaysUsed != null)
                                        _buildInfoRow(
                                          Iconsax.ticket,
                                          language.lblCompensatoryOffUsed,
                                          '${request.compOffDaysUsed} ${(request.compOffDaysUsed ?? 0) > 1 ? language.lblDays : language.lblDay}',
                                          iconColor: Colors.orange,
                                        ),
                                      if (request.userNotes != null)
                                        _buildInfoRow(
                                          Iconsax.note,
                                          language.lblReason,
                                          request.userNotes!,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Compensatory Off Details (if used)
                              if (request.usesCompOff == true &&
                                  request.compOffDetails != null &&
                                  request.compOffDetails!.isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: appStore.isDarkModeOn
                                        ? const Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[700]!
                                          : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Iconsax.ticket,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              language.lblCompensatoryOffsApplied,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: appStore.isDarkModeOn
                                                    ? Colors.white
                                                    : const Color(0xFF111827),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.orange.withOpacity(0.15),
                                                Colors.orange.withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    language.lblTotalCompOffsUsed,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: appStore.isDarkModeOn
                                                          ? Colors.white
                                                          : const Color(0xFF111827),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${request.compOffDaysUsed} ${(request.compOffDaysUsed ?? 0) > 1 ? language.lblDays : language.lblDay}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Divider(
                                                color: Colors.orange.withOpacity(0.3),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                language.lblAppliedCompOffs,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: appStore.isDarkModeOn
                                                      ? Colors.grey[400]
                                                      : const Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ...request.compOffDetails!.map((compOff) {
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 10),
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: appStore.isDarkModeOn
                                                        ? const Color(0xFF111827)
                                                        : Colors.white,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: Colors.orange.withOpacity(0.2),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Comp Off #${compOff.id}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: appStore.isDarkModeOn
                                                                  ? Colors.white
                                                                  : const Color(0xFF111827),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 10, vertical: 5),
                                                            decoration: BoxDecoration(
                                                              color: Colors.orange,
                                                              borderRadius:
                                                                  BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              '${compOff.compOffDays} day${compOff.compOffDays > 1 ? 's' : ''}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (compOff.reason.isNotEmpty) ...[
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          '${language.lblReason}: ${compOff.reason}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: appStore.isDarkModeOn
                                                                ? Colors.grey[400]
                                                                : const Color(0xFF6B7280),
                                                          ),
                                                        ),
                                                      ],
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Iconsax.calendar_remove,
                                                            size: 14,
                                                            color: Colors.red,
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            '${language.lblExpires}: ${_formatDate(compOff.expiryDate)}',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.red,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Emergency Contact (if provided)
                              if (request.emergencyContact != null ||
                                  request.emergencyPhone != null) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: appStore.isDarkModeOn
                                        ? const Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[700]!
                                          : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Iconsax.call_calling,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              language.lblEmergencyContact,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: appStore.isDarkModeOn
                                                    ? Colors.white
                                                    : const Color(0xFF111827),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        if (request.emergencyContact != null)
                                          _buildInfoRow(
                                            Iconsax.user,
                                            language.lblContactPerson,
                                            request.emergencyContact!,
                                            iconColor: Colors.red,
                                          ),
                                        if (request.emergencyPhone != null)
                                          _buildInfoRow(
                                            Iconsax.call,
                                            language.lblPhoneNumber,
                                            request.emergencyPhone!,
                                            iconColor: Colors.red,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Travel Info (if abroad)
                              if (request.isAbroad == true) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: appStore.isDarkModeOn
                                        ? const Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[700]!
                                          : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Iconsax.airplane,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              language.lblTravelInformation,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: appStore.isDarkModeOn
                                                    ? Colors.white
                                                    : const Color(0xFF111827),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _buildInfoRow(
                                          Iconsax.location,
                                          language.lblGoingAbroad,
                                          language.lblYes,
                                          iconColor: Colors.blue,
                                        ),
                                        if (request.abroadLocation != null)
                                          _buildInfoRow(
                                            Iconsax.global,
                                            language.lblDestination,
                                            request.abroadLocation!,
                                            iconColor: Colors.blue,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Document (if available)
                              if (request.documentUrl != null) ...[
                                InkWell(
                                  onTap: () => _openDocument(request.documentUrl!),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: appStore.isDarkModeOn
                                          ? const Color(0xFF1F2937)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: appStore.isDarkModeOn
                                            ? Colors.grey[700]!
                                            : const Color(0xFFE5E7EB),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.blue.withOpacity(0.2),
                                                  Colors.blue.withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Iconsax.document,
                                              color: Colors.blue,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  language.lblSupportingDocument,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: appStore.isDarkModeOn
                                                        ? Colors.white
                                                        : const Color(0xFF111827),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  language.lblTapToViewDocument,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: appStore.isDarkModeOn
                                                        ? Colors.grey[400]
                                                        : const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Iconsax.arrow_right_3,
                                            size: 20,
                                            color: appStore.isDarkModeOn
                                                ? Colors.grey[600]
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Status Timeline
                              _buildStatusTimeline(request),

                              const SizedBox(height: 80), // Space for FAB
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Observer(
        builder: (_) {
          final request = _leaveStore.selectedLeaveRequest;
          if (request != null && request.canCancel == true && !_isCancelling) {
            return FloatingActionButton.extended(
              onPressed: _cancelLeaveRequest,
              backgroundColor: Colors.red,
              icon: const Icon(Iconsax.close_circle, color: Colors.white),
              label: Text(
                language.lblCancelRequestBtn,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
