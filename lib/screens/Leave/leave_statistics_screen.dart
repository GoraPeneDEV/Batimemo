import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/leave_store.dart';
import '../../models/leave/leave_statistics.dart';
import '../../utils/app_colors.dart';
import 'leave_request_detail_screen.dart';

class LeaveStatisticsScreen extends StatefulWidget {
  const LeaveStatisticsScreen({super.key});

  @override
  State<LeaveStatisticsScreen> createState() => _LeaveStatisticsScreenState();
}

class _LeaveStatisticsScreenState extends State<LeaveStatisticsScreen> {
  late LeaveStore _leaveStore;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _leaveStore.fetchLeaveStatistics(year: _selectedYear),
      _leaveStore.fetchLeaveBalance(year: _selectedYear),
    ]);
  }

  void _showYearSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF1F2937)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                language.lblSelectYear,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(5, (index) {
                final year = DateTime.now().year - index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedYear = year);
                    Navigator.pop(context);
                    _loadData();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedYear == year
                          ? const Color(0xFF696CFF).withOpacity(0.15)
                          : (appStore.isDarkModeOn
                              ? const Color(0xFF111827)
                              : const Color(0xFFF9FAFB)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedYear == year
                            ? const Color(0xFF696CFF)
                            : (appStore.isDarkModeOn
                                ? Colors.grey[700]!
                                : const Color(0xFFE5E7EB)),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          color: _selectedYear == year
                              ? const Color(0xFF696CFF)
                              : (appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedYear == year
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _selectedYear == year
                                  ? const Color(0xFF696CFF)
                                  : (appStore.isDarkModeOn
                                      ? Colors.white
                                      : const Color(0xFF111827)),
                            ),
                          ),
                        ),
                        if (_selectedYear == year)
                          const Icon(
                            Iconsax.tick_circle,
                            color: Color(0xFF696CFF),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
    );
  }

  Widget _buildLeaveTypeChart(List<LeavesByType> leavesByType) {
    if (leavesByType.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF111827)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.chart,
                  size: 48,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoLeaveDataAvailable,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate total days
    final totalDays = leavesByType.fold<num>(0, (sum, item) => sum + item.totalDays);

    // Color palette for different leave types
    final colors = [
      const Color(0xFF696CFF),
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

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
                    Iconsax.chart_21,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblLeavesByType,
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
            ...leavesByType.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final color = colors[index % colors.length];
              final percentage = totalDays > 0
                  ? (item.totalDays / totalDays * 100).toStringAsFixed(1)
                  : '0.0';

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.leaveType.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: appStore.isDarkModeOn
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: totalDays > 0
                                      ? (item.totalDays / totalDays).toDouble()
                                      : 0,
                                  backgroundColor: appStore.isDarkModeOn
                                      ? Colors.grey[800]
                                      : const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    '${item.count} request${item.count > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${item.totalDays}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              Text(
                                language.lblDays,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < leavesByType.length - 1)
                    const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingLeaves(LeaveStatistics stats) {
    if (stats.upcomingLeaves.isEmpty) {
      return const SizedBox();
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.calendar_tick,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.lblUpcomingLeaves,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${stats.upcomingLeaves.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stats.upcomingLeaves.take(5).map((leave) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Provider.value(
                        value: _leaveStore,
                        child: LeaveRequestDetailScreen(leaveRequestId: leave.id),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appStore.isDarkModeOn
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: appStore.isDarkModeOn
                          ? Colors.grey[800]!
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.withOpacity(0.2),
                              Colors.green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.calendar, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave.leaveType.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: appStore.isDarkModeOn
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)}',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${leave.totalDays}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              language.lblDays,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
          // Stat cards skeleton
          Row(
            children: [
              Expanded(child: _buildSkeletonCard(height: 130)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 130)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSkeletonCard(height: 130)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 130)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 250),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 200),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: appStore.isDarkModeOn
          ? Colors.grey[800]!
          : const Color(0xFFE5E7EB),
      highlightColor: appStore.isDarkModeOn
          ? Colors.grey[700]!
          : const Color(0xFFF9FAFB),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Container(
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
                          language.lblLeaveStatistics,
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
                          icon: const Icon(Iconsax.calendar_edit, color: Colors.white),
                          onPressed: _showYearSelector,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: language.lblSelectYear,
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
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_leaveStore.isLoading && _leaveStore.leaveStatistics == null) {
      return _buildLoadingSkeleton();
    }

    if (_leaveStore.error != null) {
      return Center(
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
                language.lblErrorLoadingStatistics,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _leaveStore.leaveStatistics;
    if (stats == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF1F2937)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.chart,
                  size: 64,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoStatisticsAvailable,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF696CFF).withOpacity(0.2),
                      const Color(0xFF5457E6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF696CFF).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.calendar, color: Color(0xFF696CFF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${language.lblYear} $_selectedYear',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF696CFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Statistics
            Row(
              children: [
                _buildStatCard(
                  language.lblPending,
                  stats.totalPending.toString(),
                  Colors.orange,
                  Iconsax.clock,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  language.lblApproved,
                  stats.totalApproved.toString(),
                  Colors.green,
                  Iconsax.tick_circle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  language.lblRejected,
                  stats.totalRejected.toString(),
                  Colors.red,
                  Iconsax.close_circle,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  language.lblTotal,
                  (stats.totalPending + stats.totalApproved + stats.totalRejected)
                      .toString(),
                  const Color(0xFF696CFF),
                  Iconsax.document_text,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Leaves by Type Chart
            _buildLeaveTypeChart(stats.leavesByType),
            const SizedBox(height: 16),

            // Upcoming Leaves
            _buildUpcomingLeaves(stats),
          ],
        ),
      ),
    );
  }
}
