import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payslip_model.dart';
import '../../components/custom_app_bar.dart';
import '../../utils/app_constants.dart';
import 'payslips_list_screen.dart';
import 'payslip_detail_screen.dart';
import 'salary_structure_screen.dart';
import 'payroll_records_screen.dart';
import 'modifiers_screen.dart';

/// Payroll Dashboard Screen
///
/// Main entry point for all payroll-related features including:
/// - Payroll statistics (total earnings, deductions, net pay)
/// - Quick access to payslips, salary structure, payroll records, and modifiers
/// - Recent payslips list
class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({super.key});

  @override
  State<PayrollDashboardScreen> createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      payrollStore.fetchPayrollStatistics(),
      payrollStore.fetchPayslips(take: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: appStore.isDarkModeOn
                  ? [
                      const Color(0xFF1F2937),
                      const Color(0xFF111827),
                    ]
                  : [
                      const Color(0xFF696CFF),
                      const Color(0xFF5457E6),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Simple Header
                _buildSimpleHeader(),

                // Main Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: appStore.isDarkModeOn
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                      ),
                      child: payrollStore.isLoading
                          ? _buildLoadingSkeleton()
                          : payrollStore.error != null
                              ? _buildErrorState()
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    await payrollStore.refreshPayrollData();
                                  },
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Statistics Cards (scrollable)
                                        _buildStatisticsCards(),
                                        const SizedBox(height: 16),

                                        // Quick Actions
                                        _buildQuickActions(),
                                        const SizedBox(height: 16),

                                        // Recent Payslips
                                        _buildRecentPayslips(),
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
    );
  }

  Widget _buildSimpleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Iconsax.arrow_left,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              language.lblPayroll,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Year badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateTime.now().year.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final statistics = payrollStore.payrollStatistics;
    final currentMonth = statistics?['current_month'] as Map<String, dynamic>?;

    // Extract amounts from nested objects
    final netPay = _extractAmount(currentMonth?['net_salary']) ?? 0.0;
    final grossSalary = _extractAmount(currentMonth?['gross_salary']) ?? 0.0;

    // Calculate deductions (gross - net)
    final totalDeductions = grossSalary - netPay;
    final totalEarnings = grossSalary;

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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.wallet_3,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblCurrentMonthOverview,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Net Pay - Highlighted
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.lblNetPay,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${getStringAsync(appCurrencySymbolPref)}${netPay.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.tick_circle,
                      color: Colors.greenAccent,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Earnings and Deductions
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    language.lblTotalEarnings,
                    '${getStringAsync(appCurrencySymbolPref)}${totalEarnings.toStringAsFixed(2)}',
                    Iconsax.arrow_up,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    language.lblTotalDeductions,
                    '${getStringAsync(appCurrencySymbolPref)}${totalDeductions.toStringAsFixed(2)}',
                    Iconsax.arrow_down,
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
              language.lblMyPayslips,
              Iconsax.receipt_item,
              const Color(0xFF4F46E5),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PayslipsListScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblSalaryStructure,
              Iconsax.chart,
              const Color(0xFF059669),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalaryStructureScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblPayrollRecords,
              Iconsax.document_text,
              const Color(0xFFDC2626),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PayrollRecordsScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              language.lblModifiers,
              Iconsax.edit_2,
              const Color(0xFFEA580C),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModifiersScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
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
          color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                appStore.isDarkModeOn ? 0.3 : 0.04,
              ),
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

  Widget _buildRecentPayslips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.lblRecentPayslips,
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
                    builder: (context) => const PayslipsListScreen(),
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

        // Empty state or payslips list
        if (payrollStore.payslips.isEmpty)
          _buildEmptyState()
        else
          ...payrollStore.payslips.map((payslip) => _buildPayslipCard(payslip)),
      ],
    );
  }

  Widget _buildPayslipCard(PayslipModel payslip) {
    // Get status color
    Color statusColor = Colors.green;
    if (payslip.status?.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else if (payslip.status?.toLowerCase() == 'draft') {
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
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
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF696CFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.receipt_item,
            color: Color(0xFF696CFF),
            size: 24,
          ),
        ),
        title: Text(
          payslip.payrollPeriod ?? 'N/A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              payslip.createdAt != null
                  ? '${language.lblCreatedOn} ${payslip.createdAt}'
                  : 'N/A',
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                payslip.status?.toUpperCase() ?? 'N/A',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${getStringAsync(appCurrencySymbolPref)}${(payslip.netSalary?.toDouble() ?? 0.0).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayslipDetailScreen(payslip: payslip),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF111827)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Iconsax.receipt_item,
                size: 48,
                color: appStore.isDarkModeOn
                    ? Colors.grey[600]
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblNoPayslipsAvailable,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              language.lblPayslipsWillAppearMessage,
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

  Widget _buildErrorState() {
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
                Iconsax.warning_2,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblErrorLoadingData,
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
              payrollStore.error ?? 'An unexpected error occurred',
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Iconsax.refresh),
              label: Text(language.lblRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF696CFF),
                foregroundColor: Colors.white,
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

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Card Skeleton
          _buildStatisticsCardShimmer(),
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
            childAspectRatio: 1.2,
            children: List.generate(
              4,
              (index) => _buildShimmerCard(height: 100),
            ),
          ),
          const SizedBox(height: 16),

          // Recent Payslips Title Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 150, height: 20),
              _buildShimmerBox(width: 70, height: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Payslips List Skeleton
          ...List.generate(3, (index) {
            return Column(
              children: [
                _buildShimmerCard(height: 90),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatisticsCardShimmer() {
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
                    width: 180,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Net Pay shimmer
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Container(
                height: 120,
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
            const SizedBox(height: 16),

            // Earnings and Deductions shimmer
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: Container(
                      height: 100,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: Container(
                      height: 100,
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
                ),
              ],
            ),
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

  /// Helper method to extract amount from nested objects
  /// Handles API responses like {"amount": 2679, "formatted": "$2,679.00"}
  double? _extractAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is Map<String, dynamic>) {
      final amount = value['amount'];
      if (amount is num) return amount.toDouble();
    }
    return null;
  }
}
