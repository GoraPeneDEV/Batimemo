import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/leave_store.dart';
import '../../models/leave/team_calendar_item.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';

class TeamCalendarScreen extends StatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  State<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<TeamCalendarScreen> {
  late LeaveStore _leaveStore;
  DateTime _selectedMonth = DateTime.now();
  String _viewMode = 'list'; // 'list' or 'calendar'

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    await _leaveStore.fetchTeamCalendar(
      fromDate: DateFormat('yyyy-MM-dd').format(firstDay),
      toDate: DateFormat('yyyy-MM-dd').format(lastDay),
    );
  }

  void _changeMonth(int monthDelta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + monthDelta,
        1,
      );
    });
    _loadData();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateShort(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Map<String, List<TeamCalendarItem>> _groupLeavesByDate(
      List<TeamCalendarItem> leaves) {
    final Map<String, List<TeamCalendarItem>> grouped = {};

    for (var leave in leaves) {
      // Parse dates
      final fromDate = DateTime.parse(leave.fromDate);
      final toDate = DateTime.parse(leave.toDate);

      // Generate all dates in the range
      for (var date = fromDate;
          date.isBefore(toDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(leave);
      }
    }

    return grouped;
  }

  Widget _buildLeaveCard(TeamCalendarItem leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // User Avatar
            userProfileWidget(
              leave.user.name,
              size: 20,
              imageUrl: leave.user.profileImage,
              hideStatus: true,
            ),
            const SizedBox(width: 12),

            // Leave Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.user.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF696CFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          leave.leaveType.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF696CFF),
                          ),
                        ),
                      ),
                      if (leave.isHalfDay) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.timer_1, size: 10, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                language.lblHalfDay,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDateShort(leave.fromDate)} - ${_formatDateShort(leave.toDate)}',
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

            // Duration Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF696CFF).withOpacity(0.2),
                    const Color(0xFF696CFF).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '${leave.totalDays}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF696CFF),
                    ),
                  ),
                  Text(
                    leave.totalDays > 1 ? language.lblDays : language.lblDay,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF696CFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<TeamCalendarItem> leaves) {
    if (leaves.isEmpty) {
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
                  Iconsax.calendar_remove,
                  size: 64,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoTeamLeaves,
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
                language.lblNoTeamLeavesMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final groupedLeaves = _groupLeavesByDate(leaves);
    final sortedDates = groupedLeaves.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateLeaves = groupedLeaves[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF696CFF).withOpacity(0.15),
                    const Color(0xFF5457E6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF696CFF).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF696CFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF696CFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(date),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language.lblTeamMembersOnLeave.replaceAll('%s', '${dateLeaves.length}'),
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
                ],
              ),
            ),

            // Leaves on this date
            ...dateLeaves.map((leave) => _buildLeaveCard(leave)),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView(List<TeamCalendarItem> leaves) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final groupedLeaves = _groupLeavesByDate(leaves);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar Grid
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
                children: [
                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[400]
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Calendar days
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: firstWeekday - 1 + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday - 1) {
                        return const SizedBox();
                      }

                      final day = index - firstWeekday + 2;
                      final date = DateTime(
                          _selectedMonth.year, _selectedMonth.month, day);
                      final dateKey = DateFormat('yyyy-MM-dd').format(date);
                      final hasLeaves = groupedLeaves.containsKey(dateKey);
                      final leaveCount =
                          hasLeaves ? groupedLeaves[dateKey]!.length : 0;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;

                      return Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF696CFF).withOpacity(0.15)
                              : (hasLeaves
                                  ? Colors.green.withOpacity(0.1)
                                  : (appStore.isDarkModeOn
                                      ? const Color(0xFF111827)
                                      : const Color(0xFFF9FAFB))),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF696CFF)
                                : (hasLeaves
                                    ? Colors.green
                                    : (appStore.isDarkModeOn
                                        ? Colors.grey[800]!
                                        : const Color(0xFFE5E7EB))),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? const Color(0xFF696CFF)
                                      : (hasLeaves
                                          ? Colors.green
                                          : (appStore.isDarkModeOn
                                              ? Colors.white
                                              : const Color(0xFF111827))),
                                ),
                              ),
                            ),
                            if (hasLeaves)
                              Positioned(
                                bottom: 3,
                                right: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    leaveCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
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
                          Iconsax.info_circle,
                          color: Color(0xFF696CFF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        language.lblLegend,
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
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF696CFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF696CFF),
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        language.lblToday,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        language.lblHasLeaves,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          if (leaves.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF696CFF).withOpacity(0.15),
                    const Color(0xFF5457E6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF696CFF).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.lblThisMonthSummary,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF696CFF),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF696CFF).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Iconsax.document_text,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  leaves.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  language.lblTotalLeaves,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Iconsax.people,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  leaves
                                      .map((l) => l.user.id)
                                      .toSet()
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  language.lblTeamMembers,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (index) {
          return Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }),
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
                          language.lblTeamCalendar,
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
                          icon: Icon(
                            _viewMode == 'list'
                                ? Iconsax.calendar
                                : Iconsax.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _viewMode =
                                  _viewMode == 'list' ? 'calendar' : 'list';
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip:
                              _viewMode == 'list' ? language.lblCalendarView : language.lblListView,
                        ),
                      ),
                    ],
                  ),
                ),

                // Month Selector
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.arrow_left_2,
                            color: Colors.white, size: 20),
                        onPressed: () => _changeMonth(-1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_3,
                            color: Colors.white, size: 20),
                        onPressed: () => _changeMonth(1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
    if (_leaveStore.isLoading && _leaveStore.teamCalendar == null) {
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
                language.lblErrorLoadingCalendar,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    final teamCalendar = _leaveStore.teamCalendar;
    if (teamCalendar == null) {
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
                  Iconsax.calendar,
                  size: 64,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoCalendarData,
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
      child: _viewMode == 'list'
          ? _buildListView(teamCalendar.leaves)
          : _buildCalendarView(teamCalendar.leaves),
    );
  }
}
