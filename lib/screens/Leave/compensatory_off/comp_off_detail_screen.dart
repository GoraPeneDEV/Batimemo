import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../stores/leave_store.dart';
import '../../../models/leave/compensatory_off.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/string_extensions.dart';
import 'comp_off_form_screen.dart';

class CompOffDetailScreen extends StatefulWidget {
  final int compOffId;

  const CompOffDetailScreen({super.key, required this.compOffId});

  @override
  State<CompOffDetailScreen> createState() => _CompOffDetailScreenState();
}

class _CompOffDetailScreenState extends State<CompOffDetailScreen> {
  late LeaveStore _leaveStore;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _leaveStore.fetchCompensatoryOff(widget.compOffId);
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
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'approved':
        return const Color(0xFF10B981); // Green
      case 'rejected':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Iconsax.clock;
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  bool _isExpiringSoon(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final daysUntilExpiry = expiry.difference(DateTime.now()).inDays;
      return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
    } catch (e) {
      return false;
    }
  }

  bool _isExpired(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _getDaysUntilExpiry(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _deleteCompOff() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444).withOpacity(0.2),
                    const Color(0xFFEF4444).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.warning_2, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Text(language.lblDeleteCompOff, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          language.lblConfirmDeleteCompOff,
          style: TextStyle(
            color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              language.lblCancel,
              style: TextStyle(
                color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(language.lblDelete, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);

      final success = await _leaveStore.deleteCompensatoryOff(widget.compOffId);

      setState(() => _isDeleting = false);

      if (success) {
        toast(language.lblCompOffDeletedSuccess);
        Navigator.pop(context, true);
      } else {
        toast(_leaveStore.error ?? language.lblFailedToDeleteCompOff);
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor, Color? valueColor}) {
    final effectiveIconColor = iconColor ?? const Color(0xFF696CFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effectiveIconColor.withOpacity(0.2),
                  effectiveIconColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: effectiveIconColor),
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
                    color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? (appStore.isDarkModeOn ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(CompensatoryOff compOff) {
    final List<Map<String, dynamic>> timelineItems = [];

    // Requested
    timelineItems.add({
      'title': language.lblCompOffRequested,
      'date': _formatDateTime(compOff.createdAt),
      'icon': Iconsax.document,
      'color': const Color(0xFF3B82F6), // Blue
      'isCompleted': true,
    });

    // Approved/Rejected
    if (compOff.isApproved) {
      timelineItems.add({
        'title': language.lblApproved,
        'date': compOff.approvedAt != null
            ? _formatDateTime(compOff.approvedAt!)
            : '',
        'subtitle': compOff.approvedBy != null
            ? 'By ${compOff.approvedBy!.name}'
            : null,
        'notes': compOff.approvalNotes,
        'icon': Iconsax.tick_circle,
        'color': const Color(0xFF10B981), // Green
        'isCompleted': true,
      });

      // If used
      if (compOff.isUsed) {
        timelineItems.add({
          'title': language.lblUsed,
          'date': compOff.usedDate != null ? _formatDate(compOff.usedDate!) : '',
          'subtitle': compOff.leaveRequest != null
              ? 'For ${compOff.leaveRequest!.leaveType.name}'
              : null,
          'icon': Iconsax.tick_square,
          'color': Colors.grey,
          'isCompleted': true,
        });
      } else if (_isExpired(compOff.expiryDate)) {
        timelineItems.add({
          'title': language.lblExpired,
          'date': _formatDate(compOff.expiryDate),
          'icon': Iconsax.close_circle,
          'color': const Color(0xFFEF4444), // Red
          'isCompleted': true,
        });
      }
    } else if (compOff.isRejected) {
      timelineItems.add({
        'title': language.lblRejected,
        'date': compOff.approvedAt != null
            ? _formatDateTime(compOff.approvedAt!)
            : '',
        'subtitle': compOff.approvedBy != null
            ? 'By ${compOff.approvedBy!.name}'
            : null,
        'notes': compOff.approvalNotes,
        'icon': Iconsax.close_circle,
        'color': const Color(0xFFEF4444), // Red
        'isCompleted': true,
      });
    } else {
      timelineItems.add({
        'title': language.lblPendingApproval,
        'date': '',
        'icon': Iconsax.clock,
        'color': const Color(0xFFFF9800), // Orange
        'isCompleted': false,
      });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.2),
                        const Color(0xFF3B82F6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.clock, color: Color(0xFF3B82F6), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblStatusTimeline,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn ? Colors.white : Colors.black87,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: item['isCompleted']
                              ? LinearGradient(
                                  colors: [
                                    item['color'],
                                    item['color'].withOpacity(0.8),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade300,
                                  ],
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'],
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: item['isCompleted']
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      item['color'],
                                      timelineItems[index + 1]['isCompleted']
                                          ? timelineItems[index + 1]['color']
                                          : Colors.grey.shade300,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade300,
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (item['date'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                        if (item['subtitle'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                        if (item['notes'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              item['notes'],
                              style: TextStyle(
                                fontSize: 12,
                                color: appStore.isDarkModeOn ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                        if (!isLast) const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // Custom Header (56px)
          Container(
            height: 56 + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appStore.isDarkModeOn
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      language.lblCompOffDetails,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Observer(
                    builder: (_) {
                      final compOff = _leaveStore.selectedCompensatoryOff;
                      if (compOff != null && compOff.isPending) {
                        return PopupMenuButton(
                          icon: const Icon(Iconsax.more, color: Colors.white),
                          color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF3B82F6).withOpacity(0.2),
                                          const Color(0xFF3B82F6).withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.edit, size: 18, color: Color(0xFF3B82F6)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(language.lblEdit),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Provider.value(
                                        value: _leaveStore,
                                        child: CompOffFormScreen(compOff: compOff),
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                });
                              },
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFEF4444).withOpacity(0.2),
                                          const Color(0xFFEF4444).withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.trash, size: 18, color: Color(0xFFEF4444)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(language.lblDelete, style: const TextStyle(color: Color(0xFFEF4444))),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, _deleteCompOff);
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox(width: 16);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Observer(
                builder: (_) {
                  if (_leaveStore.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_leaveStore.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEF4444).withOpacity(0.2),
                                  const Color(0xFFEF4444).withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.close_circle, size: 48, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            language.lblErrorLoadingCompOffDetails,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appStore.isDarkModeOn ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _leaveStore.error!,
                              style: TextStyle(
                                color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Iconsax.refresh, color: Colors.white),
                              label: Text(language.lblRetry, style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final compOff = _leaveStore.selectedCompensatoryOff;
                  if (compOff == null) {
                    return Center(
                      child: Text(
                        language.lblCompOffNotFound,
                        style: TextStyle(
                          color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  final isExpiringSoon = _isExpiringSoon(compOff.expiryDate);
                  final isExpired = _isExpired(compOff.expiryDate);
                  final daysUntilExpiry = _getDaysUntilExpiry(compOff.expiryDate);
                  final statusColor = _getStatusColor(compOff.status);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card with Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor,
                                statusColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 8,
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
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getStatusIcon(compOff.status),
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        compOff.status.capitalize,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Comp Off #${compOff.id}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
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

                        // Warning for expiring/expired
                        if (compOff.isApproved && !compOff.isUsed) ...[
                          if (isExpired)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFEF4444).withOpacity(0.2),
                                    const Color(0xFFEF4444).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFEF4444).withOpacity(0.3),
                                            const Color(0xFFEF4444).withOpacity(0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Iconsax.close_circle, size: 20, color: Color(0xFFEF4444)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            language.lblCompOffExpired,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            language.lblCompOffExpiredOn.replaceAll('%s', _formatDate(compOff.expiryDate)),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (isExpiringSoon)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF9800).withOpacity(0.2),
                                    const Color(0xFFFF9800).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFFF9800).withOpacity(0.3),
                                            const Color(0xFFFF9800).withOpacity(0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Iconsax.warning_2, size: 20, color: Color(0xFFFF9800)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            language.lblExpiringSoon,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            language.lblDaysRemainingUse.replaceFirst('%s', '$daysUntilExpiry ${daysUntilExpiry > 1 ? language.lblDays : language.lblDay}').replaceFirst('%s', _formatDate(compOff.expiryDate)),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
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
                        ],

                        // Comp Off Details Card
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF696CFF).withOpacity(0.2),
                                            const Color(0xFF696CFF).withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Iconsax.document_text, color: Color(0xFF696CFF), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      language.lblCompOffDetails,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: appStore.isDarkModeOn ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildInfoRow(
                                  Iconsax.calendar_1,
                                  language.lblWorkedDate,
                                  _formatDate(compOff.workedDate),
                                  iconColor: const Color(0xFF696CFF),
                                ),
                                _buildInfoRow(
                                  Iconsax.clock,
                                  language.lblHoursWorked,
                                  '${compOff.hoursWorked} hours',
                                  iconColor: const Color(0xFF696CFF),
                                ),
                                _buildInfoRow(
                                  Iconsax.calendar,
                                  language.lblCompOffDays,
                                  '${compOff.compOffDays} ${compOff.compOffDays > 1 ? language.lblDays : language.lblDay}',
                                  iconColor: const Color(0xFF10B981),
                                  valueColor: const Color(0xFF10B981),
                                ),
                                _buildInfoRow(
                                  Iconsax.calendar_remove,
                                  language.lblExpiryDate,
                                  _formatDate(compOff.expiryDate),
                                  iconColor: isExpired
                                      ? const Color(0xFFEF4444)
                                      : (isExpiringSoon ? const Color(0xFFFF9800) : const Color(0xFF696CFF)),
                                  valueColor: isExpired
                                      ? const Color(0xFFEF4444)
                                      : (isExpiringSoon ? const Color(0xFFFF9800) : null),
                                ),
                                if (compOff.reason != null)
                                  _buildInfoRow(
                                    Iconsax.note,
                                    language.lblReason,
                                    compOff.reason!,
                                    iconColor: const Color(0xFF696CFF),
                                  ),
                                if (compOff.isUsed && compOff.usedDate != null)
                                  _buildInfoRow(
                                    Iconsax.tick_square,
                                    language.lblUsedOn,
                                    _formatDate(compOff.usedDate!),
                                    iconColor: Colors.grey,
                                    valueColor: Colors.grey,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Usage Info (if used with leave request)
                        if (compOff.isUsed && compOff.leaveRequest != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF3B82F6).withOpacity(0.2),
                                              const Color(0xFF3B82F6).withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Iconsax.document_text_1, color: Color(0xFF3B82F6), size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        language.lblUsedForLeave,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: appStore.isDarkModeOn ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow(
                                    Iconsax.category,
                                    language.lblLeaveType,
                                    compOff.leaveRequest!.leaveType.name,
                                    iconColor: const Color(0xFF3B82F6),
                                  ),
                                  _buildInfoRow(
                                    Iconsax.calendar_1,
                                    language.lblLeaveDates,
                                    '${_formatDate(compOff.leaveRequest!.fromDate)} - ${_formatDate(compOff.leaveRequest!.toDate)}',
                                    iconColor: const Color(0xFF3B82F6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Status Timeline
                        _buildStatusTimeline(compOff),

                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Observer(
        builder: (_) {
          final compOff = _leaveStore.selectedCompensatoryOff;
          if (compOff != null && compOff.isPending && !_isDeleting) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _deleteCompOff,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Iconsax.trash, color: Colors.white),
                label: Text(language.lblDelete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
