import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/leave_store.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import 'leave_requests_list_screen.dart';
import 'leave_request_form_screen.dart';
import 'leave_statistics_screen.dart';
import 'team_calendar_screen.dart';
import 'compensatory_off/comp_off_list_screen.dart';

class LeaveDashboardScreen extends StatefulWidget {
  const LeaveDashboardScreen({super.key});

  @override
  State<LeaveDashboardScreen> createState() => _LeaveDashboardScreenState();
}

class _LeaveDashboardScreenState extends State<LeaveDashboardScreen> {
  late LeaveStore _leaveStore;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _leaveStore.fetchLeaveTypes(),
      _leaveStore.fetchLeaveBalance(),
      _leaveStore.fetchLeaveStatistics(),
      _leaveStore.fetchCompensatoryOffBalance(),
    ]);
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
                  child: Text(
                    language.lblLeaveManagement,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      child: _leaveStore.isLoading && _leaveStore.leaveTypes.isEmpty
                          ? _buildLoadingSkeleton()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Leave Balance Summary
                                    _buildBalanceSummaryCard(),
                                    const SizedBox(height: 16),

                                    // Quick Actions
                                    _buildQuickActions(),
                                    const SizedBox(height: 16),

                                    // Statistics Overview
                                    if (_leaveStore.leaveStatistics != null)
                                      _buildStatisticsOverview(),
                                    const SizedBox(height: 16),

                                    // Upcoming Leaves
                                    if (_leaveStore.leaveStatistics?.upcomingLeaves.isNotEmpty ??
                                        false)
                                      _buildUpcomingLeaves(),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: _leaveStore,
                child: const LeaveRequestFormScreen(),
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF696CFF),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          language.lblNewLeave,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummaryCard() {
    final leaveBalances = _leaveStore.leaveBalanceSummary?.leaveBalances ?? [];
    final hasBalances = leaveBalances.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appStore.isDarkModeOn
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF696CFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.calendar_tick,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.lblLeaveBalance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_leaveStore.leaveBalanceSummary != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${language.lblYear} ${_leaveStore.leaveBalanceSummary!.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (!hasBalances)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Iconsax.calendar_remove,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        language.lblNoLeaveBalanceAvailable,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Show first 3 leave types
              ...leaveBalances.take(3).map((balance) {
                return Column(
                  children: [
                    _buildBalanceItem(
                      balance.leaveType.name,
                      balance.available.toString(),
                      balance.entitled.toString(),
                      balance.used.toString(),
                      _getBalancePercentage(balance.available, balance.total),
                    ),
                    if (balance != leaveBalances.take(3).last ||
                        (_leaveStore.compOffBalance != null &&
                            _leaveStore.compOffBalance!.available > 0) ||
                        leaveBalances.length > 3)
                      Divider(
                        height: 24,
                        color: Colors.white.withOpacity(0.2),
                      ),
                  ],
                );
              }).toList(),

              // Comp Off if available
              if (_leaveStore.compOffBalance != null &&
                  _leaveStore.compOffBalance!.available > 0) ...[
                _buildBalanceItem(
                  language.lblCompOff,
                  _leaveStore.compOffBalance!.available.toString(),
                  _leaveStore.compOffBalance!.totalApproved.toString(),
                  _leaveStore.compOffBalance!.totalUsed.toString(),
                  _leaveStore.compOffBalance!.available /
                      _leaveStore.compOffBalance!.totalApproved,
                ),
                if (leaveBalances.length > 3)
                  Divider(
                    height: 24,
                    color: Colors.white.withOpacity(0.2),
                  ),
              ],

              // View All button if more than 3 leave types
              if (leaveBalances.length > 3)
                InkWell(
                  onTap: () => _showAllBalances(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          language.lblViewAllLeaveTypes,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllBalances(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF1F2937)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language.lblAllLeaveBalances,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF696CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${language.lblYear} ${_leaveStore.leaveBalanceSummary!.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF696CFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: appStore.isDarkModeOn
                    ? Colors.grey[700]
                    : const Color(0xFFE5E7EB),
              ),
              // List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount:
                      _leaveStore.leaveBalanceSummary!.leaveBalances.length +
                          (_leaveStore.compOffBalance != null &&
                                  _leaveStore.compOffBalance!.available > 0
                              ? 1
                              : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index <
                        _leaveStore.leaveBalanceSummary!.leaveBalances.length) {
                      final balance =
                          _leaveStore.leaveBalanceSummary!.leaveBalances[index];
                      return _buildExpandedBalanceCard(
                        balance.leaveType.name,
                        balance.leaveType.code,
                        balance.available,
                        balance.total,
                        balance.used,
                        balance.entitled,
                        balance.carriedForward,
                        balance.additional,
                        _getBalanceColor(balance.available, balance.total),
                      );
                    } else {
                      return _buildExpandedBalanceCard(
                        language.lblCompensatoryOff,
                        'CO',
                        _leaveStore.compOffBalance!.available,
                        _leaveStore.compOffBalance!.totalApproved,
                        _leaveStore.compOffBalance!.totalUsed,
                        _leaveStore.compOffBalance!.totalApproved.toInt(),
                        0,
                        0,
                        appColorPrimary,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceItem(
    String type,
    String available,
    String total,
    String used,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${language.lblUsed}: $used ${language.lblOf} $total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    available,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    language.lblAvailable,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                percentage > 0.5
                    ? Colors.greenAccent
                    : percentage > 0.25
                        ? Colors.orangeAccent
                        : Colors.redAccent,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  double _getBalancePercentage(num available, num total) {
    if (total == 0) return 0;
    return (available / total).toDouble();
  }

  Color _getBalanceColor(num available, num total) {
    final percentage = (available / total) * 100;
    if (percentage > 50) return Colors.green;
    if (percentage > 25) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblQuickActions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildQuickActionCard(
              language.lblMyLeaves,
              Iconsax.calendar,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: _leaveStore,
                      child: const LeaveRequestsListScreen(),
                    ),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblStatistics,
              Iconsax.chart,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: _leaveStore,
                      child: const LeaveStatisticsScreen(),
                    ),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblTeamCalendar,
              Iconsax.people,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: _leaveStore,
                      child: const TeamCalendarScreen(),
                    ),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblCompOff,
              Iconsax.clock,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: _leaveStore,
                      child: const CompOffListScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedBalanceCard(
    String name,
    String code,
    num available,
    num total,
    num used,
    int entitled,
    int carriedForward,
    int additional,
    Color color,
  ) {
    final percentage = total > 0 ? (available / total) : 0;

    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF111827)
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      available.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      language.lblAvailable,
                      style: TextStyle(
                        fontSize: 11,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage.toDouble(),
                backgroundColor: appStore.isDarkModeOn
                    ? Colors.grey[800]
                    : const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(language.lblEntitled, entitled.toString(), Iconsax.award),
                      Container(
                        width: 1,
                        height: 40,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[700]
                            : const Color(0xFFE5E7EB),
                      ),
                      _buildStatItem(language.lblUsed, used.toString(), Iconsax.tick_circle),
                      Container(
                        width: 1,
                        height: 40,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[700]
                            : const Color(0xFFE5E7EB),
                      ),
                      _buildStatItem(language.lblTotal, total.toString(), Iconsax.calendar_1),
                    ],
                  ),
                  if (carriedForward > 0 || additional > 0) ...[
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[700]
                          : const Color(0xFFE5E7EB),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (carriedForward > 0)
                          _buildStatItem(language.lblCarriedForward, carriedForward.toString(), Iconsax.import_1),
                        if (carriedForward > 0 && additional > 0)
                          Container(
                            width: 1,
                            height: 40,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[700]
                                : const Color(0xFFE5E7EB),
                          ),
                        if (additional > 0)
                          _buildStatItem(language.lblAdditional, additional.toString(), Iconsax.add_circle),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    final stats = _leaveStore.leaveStatistics!;
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.lblThisYearOverview,
              style: TextStyle(
                fontSize: 18,
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
                  child: _buildStatCard(
                    language.lblPending,
                    stats.totalPending.toString(),
                    Colors.orange,
                    Iconsax.clock,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    language.lblApproved,
                    stats.totalApproved.toString(),
                    Colors.green,
                    Iconsax.tick_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    language.lblRejected,
                    stats.totalRejected.toString(),
                    Colors.red,
                    Iconsax.close_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
    );
  }

  Widget _buildUpcomingLeaves() {
    final upcoming = _leaveStore.leaveStatistics!.upcomingLeaves;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.lblUpcomingLeaves,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: _leaveStore,
                      child: const LeaveRequestsListScreen(
                        initialStatus: 'approved',
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                language.lblViewAll,
                style: const TextStyle(
                  color: Color(0xFF696CFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...upcoming.take(3).map((leave) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Iconsax.calendar, color: Colors.green),
              ),
              title: Text(
                leave.leaveType.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              subtitle: Text(
                '${leave.fromDate} - ${leave.toDate}',
                style: TextStyle(
                  fontSize: 12,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
              trailing: Text(
                '${leave.totalDays} ${leave.totalDays > 1 ? language.lblDays : language.lblDay}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Summary Skeleton - Gradient card with shimmer content
          _buildBalanceCardShimmer(),
          const SizedBox(height: 16),

          // Quick Actions Title Skeleton
          _buildShimmerBox(width: 150, height: 20),
          const SizedBox(height: 12),

          // Quick Actions Grid Skeleton
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(4, (index) => _buildShimmerCard(height: 100)),
          ),
          const SizedBox(height: 16),

          // Statistics Skeleton
          _buildShimmerCard(height: 150),
        ],
      ),
    );
  }

  Widget _buildBalanceCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appStore.isDarkModeOn
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF696CFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.3),
                  child: Container(
                    width: 70,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Balance items shimmer
            ...List.generate(3, (index) {
              return Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  if (index < 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.2),
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

  Widget _buildShimmerCard({required double height}) {
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
          color: appStore.isDarkModeOn
              ? Colors.grey[800]
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: appStore.isDarkModeOn
          ? Colors.grey[800]!
          : const Color(0xFFE5E7EB),
      highlightColor: appStore.isDarkModeOn
          ? Colors.grey[700]!
          : const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? Colors.grey[800]
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
