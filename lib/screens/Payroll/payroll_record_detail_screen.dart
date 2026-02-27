import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payroll_record_model.dart';

/// Payroll Record Detail Screen
///
/// Displays complete breakdown of a payroll record including:
/// - Basic salary, gross salary, net salary
/// - Tax information
/// - Earnings breakdown
/// - Deductions breakdown
/// - Attendance summary
/// - Payroll cycle information
class PayrollRecordDetailScreen extends StatefulWidget {
  final int recordId;

  const PayrollRecordDetailScreen({
    super.key,
    required this.recordId,
  });

  @override
  State<PayrollRecordDetailScreen> createState() =>
      _PayrollRecordDetailScreenState();
}

class _PayrollRecordDetailScreenState
    extends State<PayrollRecordDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecordDetails();
  }

  Future<void> _loadRecordDetails() async {
    await payrollStore.fetchPayrollRecordById(widget.recordId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF111827)
          : const Color(0xFFF3F4F6),
      body: Observer(
        builder: (_) {
          if (payrollStore.isLoading &&
              payrollStore.selectedPayrollRecord == null) {
            return _buildLoadingState();
          }

          if (payrollStore.error != null &&
              payrollStore.selectedPayrollRecord == null) {
            return _buildErrorState();
          }

          final record = payrollStore.selectedPayrollRecord;
          if (record == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadRecordDetails,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(record),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSalarySummaryCard(record),
                        const SizedBox(height: 16),
                        _buildAttendanceCard(record),
                        const SizedBox(height: 16),
                        _buildEarningsCard(record),
                        const SizedBox(height: 16),
                        _buildDeductionsCard(record),
                        const SizedBox(height: 16),
                        _buildPayrollCycleCard(record),
                        const SizedBox(height: 16),
                        if (record.rejectionReason != null)
                          _buildRejectionCard(record),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(PayrollRecordDetailModel record) {
    // Parse status color
    Color statusColor = Colors.grey;
    switch (record.status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'processed':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'draft':
        statusColor = Colors.grey;
        break;
    }

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF696CFF),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        title: Text(
          record.period,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.lblNetSalary,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.netSalary.formatted,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalarySummaryCard(PayrollRecordDetailModel record) {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.wallet_money,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblSalaryBreakdown,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSalaryRow(language.lblBasicSalary, record.basicSalary.formatted,
                isHighlighted: false),
            const SizedBox(height: 12),
            _buildSalaryRow(language.lblGrossSalary, record.grossSalary.formatted,
                isHighlighted: false),
            const SizedBox(height: 12),
            _buildSalaryRow(language.lblTaxAmount, record.taxAmount.formatted,
                isNegative: true),
            const SizedBox(height: 12),
            Divider(
              color: appStore.isDarkModeOn
                  ? Colors.grey[700]
                  : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 12),
            _buildSalaryRow(language.lblNetSalary, record.netSalary.formatted,
                isHighlighted: true, isLarge: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRow(
    String label,
    String amount, {
    bool isHighlighted = false,
    bool isNegative = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: appStore.isDarkModeOn
                ? (isHighlighted ? Colors.white : Colors.grey[400])
                : (isHighlighted
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280)),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isLarge ? 18 : 15,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isNegative
                ? Colors.red
                : (isHighlighted
                    ? const Color(0xFF4CAF50)
                    : (appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827))),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(PayrollRecordDetailModel record) {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.calendar,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblAttendanceSummary,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                Expanded(
                  child: _buildAttendanceStat(
                    Iconsax.tick_circle,
                    Colors.green,
                    record.totalWorkedDays.toStringAsFixed(0),
                    language.lblWorkedDays,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttendanceStat(
                    Iconsax.close_circle,
                    Colors.red,
                    record.totalAbsentDays.toStringAsFixed(0),
                    language.lblAbsentDays,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceStat(
                    Iconsax.note_remove,
                    Colors.orange,
                    record.totalLeaveDays.toStringAsFixed(0),
                    language.lblLeaveDays,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttendanceStat(
                    Iconsax.clock,
                    Colors.blue,
                    record.overtimeHours.toStringAsFixed(1),
                    language.lblOvertimeHours,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStat(
      IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF374151)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(PayrollRecordDetailModel record) {
    final earnings = record.adjustments.earnings;

    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.add_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.lblEarnings,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Text(
                  record.adjustments.totalEarnings,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (earnings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    language.lblNoEarningsRecorded,
                    style: TextStyle(
                      fontSize: 14,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            else
              ...earnings.map((earning) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAdjustmentItem(
                      earning.name,
                      earning.code,
                      earning.amount.formatted,
                      earning.percentage,
                      Colors.green,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard(PayrollRecordDetailModel record) {
    final deductions = record.adjustments.deductions;

    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.minus_cirlce,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.lblDeductions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Text(
                  record.adjustments.totalDeductions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (deductions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    language.lblNoDeductionsRecorded,
                    style: TextStyle(
                      fontSize: 14,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            else
              ...deductions.map((deduction) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAdjustmentItem(
                      deduction.name,
                      deduction.code,
                      deduction.amount.formatted,
                      deduction.percentage,
                      Colors.red,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentItem(
    String name,
    String code,
    String amount,
    double? percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF374151)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (percentage != null)
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCycleCard(PayrollRecordDetailModel record) {
    if (record.payrollCycleDetail == null) return const SizedBox.shrink();

    final cycle = record.payrollCycleDetail!;

    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.calendar_1,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblPayrollCycle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(language.lblCycleName, cycle.name),
            const SizedBox(height: 10),
            _buildInfoRow(language.lblCycleCode, cycle.code),
            const SizedBox(height: 10),
            _buildInfoRow(language.lblFrequency, cycle.frequency.toUpperCase()),
            const SizedBox(height: 10),
            _buildInfoRow(language.lblPeriodStart, cycle.payPeriodStart),
            const SizedBox(height: 10),
            _buildInfoRow(language.lblPeriodEnd, cycle.payPeriodEnd),
            const SizedBox(height: 10),
            _buildInfoRow(language.lblPayDate, cycle.payDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
        ),
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
    );
  }

  Widget _buildRejectionCard(PayrollRecordDetailModel record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Text(
                  language.lblRejectionReason,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.rejectionReason!,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.red.shade200
                    : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF111827)
          : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF696CFF),
        foregroundColor: Colors.white,
        title: Text(language.lblPayrollRecord),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          5,
          (index) => Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF111827)
          : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF696CFF),
        foregroundColor: Colors.white,
        title: Text(language.lblPayrollRecord),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                language.lblErrorLoadingRecord,
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
                payrollStore.error ?? language.lblUnexpectedError,
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
                onPressed: _loadRecordDetails,
                icon: const Icon(Iconsax.refresh),
                label: Text(language.lblRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF696CFF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF111827)
          : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF696CFF),
        foregroundColor: Colors.white,
        title: Text(language.lblPayrollRecord),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.wallet_money, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              language.lblRecordNotFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
}
