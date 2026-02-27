import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/attendance_history_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/string_extensions.dart';
import '../../../main.dart';
import 'attendance_history_store.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final _store = AttendanceHistoryStore();

  @override
  void initState() {
    super.initState();
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.getAttendanceHistory(pageKey);
    });
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    final isDark = appStore.isDarkModeOn;
    DateTimeRange? selectedRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.lblFilters,
                        style: boldTextStyle(size: 20),
                      ),
                      20.height,
                      // Date Range Picker
                      TextField(
                        readOnly: true,
                        controller: _store.dateRangeController,
                        decoration: InputDecoration(
                          labelText: language.lblSelectDateRange,
                          hintText: '${language.lblStart} - ${language.lblEnd}',
                          prefixIcon: const Icon(Iconsax.calendar),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _store.dateRangeController.clear();
                              selectedRange = null;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF696CFF),
                              width: 2,
                            ),
                          ),
                        ),
                        onTap: () async {
                          final DateTimeRange? range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2021),
                            lastDate: DateTime.now(),
                            helpText: language.lblSelectDateRange,
                            confirmText: language.lblConfirm,
                          );
                          if (range != null) {
                            setState(() {
                              selectedRange = range;
                            });
                            _store.dateRangeController.text =
                                '${_formatDate(range.start)} - ${_formatDate(range.end)}';
                          }
                        },
                      ),
                      24.height,
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                selectedRange = null;
                                _store.startRange = null;
                                _store.endRange = null;
                                _store.dateRangeController.clear();
                                _store.pagingController.refresh();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                language.lblReset,
                                style: boldTextStyle(
                                  color: Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF696CFF),
                                    Color(0xFF5457E6)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (selectedRange != null) {
                                    _store.startRange =
                                        _formatDate(selectedRange!.start);
                                    _store.endRange =
                                        _formatDate(selectedRange!.end);
                                  }
                                  _store.pagingController.refresh();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  language.lblApply,
                                  style: boldTextStyle(
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Function to Format Dates
  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          final isDark = appStore.isDarkModeOn;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section (56px fixed height)
                  _buildHeader(isDark),
                  // Content Area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Container(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        child: _buildContent(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              language.lblAttendanceHistory,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.filter, color: Colors.white),
              onPressed: () => _showFilterPopup(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _store.pagingController.refresh()),
      color: const Color(0xFF696CFF),
      child: CustomScrollView(
        slivers: [
          // Filter Chips
          SliverToBoxAdapter(
            child: Observer(
              builder: (_) {
                return _store.startRange != null && _store.endRange != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF696CFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${language.lblRange}: ${_store.startRange} - ${_store.endRange}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  _store.startRange = _store.endRange = null;
                                  _store.dateRangeController.clear();
                                  _store.pagingController.refresh();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ),
          // Attendance List
          PagedSliverList<int, AttendanceHistory>(
            pagingController: _store.pagingController,
            builderDelegate: PagedChildBuilderDelegate<AttendanceHistory>(
              noItemsFoundIndicatorBuilder: (context) =>
                  _buildEmptyState(isDark),
              firstPageProgressIndicatorBuilder: (context) =>
                  _buildShimmerLoader(isDark),
              newPageProgressIndicatorBuilder: (context) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF696CFF),
                  ),
                ),
              ),
              itemBuilder: (context, history, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: index == 0 ? 8 : 0,
                    bottom: 12,
                  ),
                  child: _buildAttendanceCard(history, isDark),
                );
              },
            ),
          ),
          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF696CFF).withOpacity(0.2),
                  const Color(0xFF5457E6).withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Iconsax.calendar_2,
              size: 60,
              color: const Color(0xFF696CFF).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            language.lblNoAttendanceRecords,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language.lblAttendanceRecordsWillAppearHere,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader(bool isDark) {
    return Column(
      children: List.generate(
        6,
        (index) => Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            top: index == 0 ? 8 : 0,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor:
                      isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                  highlightColor:
                      isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                        highlightColor:
                            isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
                        child: Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                        highlightColor:
                            isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
                        child: Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Attendance Card Widget
  Widget _buildAttendanceCard(AttendanceHistory data, bool isDark) {
    return Container(
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
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(data.status).withOpacity(0.8),
                  _getStatusColor(data.status),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(data.status),
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.date,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    4.height,
                    Text(
                      data.dayName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(data.status, data.statusLabel, isDark),
                  if (data.overtime > 0) ...[
                    4.height,
                    Text(
                      '+${data.overtime}${language.lblHoursOT}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Iconsax.clock,
                  size: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                6.width,
                Expanded(
                  child: Text(
                    '${data.checkInTime ?? '--'} - ${data.checkOutTime ?? '--'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.width,
                Icon(
                  Iconsax.timer,
                  size: 14,
                  color: Colors.green,
                ),
                4.width,
                Text(
                  data.workingHours,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          children: [
            _buildExpandedContent(data, isDark),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'checked_in':
        return Colors.blue;
      case 'checked_out':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.orange;
      case 'holiday':
        return const Color(0xFF696CFF);
      case 'weekend':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'checked_in':
        return Iconsax.login;
      case 'checked_out':
        return Iconsax.logout;
      case 'absent':
        return Iconsax.close_circle;
      case 'leave':
        return Iconsax.calendar_remove;
      case 'holiday':
        return Iconsax.calendar_tick;
      case 'weekend':
        return Iconsax.calendar;
      default:
        return Iconsax.clock;
    }
  }

  // Status Chip Widget
  Widget _buildStatusChip(String status, String label, bool isDark) {
    final chipColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  // Expanded Content
  Widget _buildExpandedContent(AttendanceHistory data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
          thickness: 1,
        ),
        12.height,

        // Shift Information
        if (data.shift != null) ...[
          _buildSectionTitle(language.lblShiftInformation, isDark),
          8.height,
          _buildInfoRow(
            Iconsax.buildings,
            language.lblShift,
            '${data.shift!.name} (${data.shift!.startTime} - ${data.shift!.endTime})',
            isDark,
          ),
          12.height,
        ],

        // Hours Breakdown
        _buildSectionTitle(language.lblHoursBreakdown, isDark),
        8.height,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                language.lblWorking,
                data.workingHours,
                Colors.green,
                Iconsax.clock,
                isDark,
              ),
            ),
            12.width,
            Expanded(
              child: _buildStatCard(
                language.lblBreaks,
                data.breakHoursFormatted,
                Colors.orange,
                Iconsax.coffee,
                isDark,
              ),
            ),
            if (data.overtime > 0) ...[
              12.width,
              Expanded(
                child: _buildStatCard(
                  language.lblOvertime,
                  '${data.overtime}h',
                  Colors.blue,
                  Iconsax.timer,
                  isDark,
                ),
              ),
            ],
          ],
        ),
        16.height,

        // Late/Early Checkout Info
        if (data.lateMinutes > 0 || data.earlyCheckoutMinutes > 0) ...[
          _buildSectionTitle(language.lblTimingIssues, isDark),
          8.height,
          if (data.lateMinutes > 0)
            _buildInfoRow(
              Iconsax.warning_2,
              language.lblLateBy,
              '${data.lateMinutes} min${data.lateReason != null ? ' - ${data.lateReason}' : ''}',
              isDark,
              valueColor: Colors.red,
            ),
          if (data.earlyCheckoutMinutes > 0)
            _buildInfoRow(
              Iconsax.warning_2,
              language.lblEarlyCheckoutBy,
              '${data.earlyCheckoutMinutes} min${data.earlyCheckoutReason != null ? ' - ${data.earlyCheckoutReason}' : ''}',
              isDark,
              valueColor: Colors.red,
            ),
          12.height,
        ],

        // Multiple Check-Ins
        if (data.isMultipleCheckIn && data.checkInOutPairs.isNotEmpty) ...[
          _buildSectionTitle(
              'Check-In/Out Timeline (${data.totalCheckIns} check-ins)', isDark),
          8.height,
          ...data.checkInOutPairs.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.3)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${language.lblSession} ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        const Icon(Iconsax.login, size: 16, color: Colors.green),
                        6.width,
                        Text(
                          pair.checkIn ?? '--',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        16.width,
                        const Icon(Iconsax.logout, size: 16, color: Colors.red),
                        6.width,
                        Text(
                          pair.checkOut ?? '--',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    if (pair.checkInLocation?.address != null) ...[
                      6.height,
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: 12,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          4.width,
                          Expanded(
                            child: Text(
                              pair.checkInLocation!.address!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          12.height,
        ],

        // Break Details
        if (data.breaks.isNotEmpty) ...[
          _buildSectionTitle('${language.lblBreaks} (${data.breaks.length})', isDark),
          8.height,
          ...data.breaks.map((breakInfo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.coffee, size: 16, color: Colors.orange),
                        8.width,
                        Text(
                          breakInfo.type.capitalize,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${breakInfo.startTime} - ${breakInfo.endTime ?? language.lblOngoing} (${breakInfo.duration.round()}m)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          12.height,
        ],

        // Activity Counters (if relevant - can be commented out for HR-only app)
        if (data.visitsCount > 0 ||
            data.ordersCount > 0 ||
            data.formsCount > 0) ...[
          _buildSectionTitle(language.lblDailyActivities, isDark),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (data.visitsCount > 0)
                _buildActivityCounter(
                  Iconsax.location,
                  language.lblVisits,
                  data.visitsCount,
                  Colors.blue,
                  isDark,
                ),
              if (data.ordersCount > 0)
                _buildActivityCounter(
                  Iconsax.box,
                  language.lblOrders,
                  data.ordersCount,
                  Colors.green,
                  isDark,
                ),
              if (data.formsCount > 0)
                _buildActivityCounter(
                  Iconsax.document,
                  language.lblForms,
                  data.formsCount,
                  const Color(0xFF696CFF),
                  isDark,
                ),
            ],
          ),
          12.height,
        ],

        // Regularization Status
        if (data.hasRegularization) ...[
          _buildSectionTitle(language.lblRegularization, isDark),
          8.height,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRegularizationColor(data.regularizationStatus)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRegularizationColor(data.regularizationStatus)
                    .withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRegularizationIcon(data.regularizationStatus),
                  size: 18,
                  color: _getRegularizationColor(data.regularizationStatus),
                ),
                10.width,
                Text(
                  '${language.lblRegularization} ${data.regularizationStatus?.capitalize ?? language.lblPending}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getRegularizationColor(data.regularizationStatus),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF696CFF),
      ),
    );
  }

  // Info Row Widget
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF696CFF),
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
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          6.height,
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          4.height,
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Activity Counter Widget
  Widget _buildActivityCounter(
    IconData icon,
    String label,
    int count,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        8.height,
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        4.height,
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Regularization helpers
  Color _getRegularizationColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getRegularizationIcon(String? status) {
    switch (status) {
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.timer_1;
    }
  }
}
