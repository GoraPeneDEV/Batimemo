import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../Utils/app_constants.dart';
import '../../main.dart'; // For payrollStore and appStore
import '../../models/payslip_model.dart';

class PayslipDetailsScreen extends StatefulWidget {
  final int payslipId;
  const PayslipDetailsScreen({super.key, required this.payslipId});

  @override
  State<PayslipDetailsScreen> createState() => _PayslipDetailsScreenState();
}

class _PayslipDetailsScreenState extends State<PayslipDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPayslipDetails();
  }

  Future<void> _loadPayslipDetails() async {
    await payrollStore.fetchPayslipById(widget.payslipId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              language.lblPayslipActions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              icon: Iconsax.document_download,
              label: language.lblDownloadPDF,
              color: const Color(0xFF696CFF),
              isDark: isDark,
              onTap: () async {
                Navigator.pop(context);
                final filePath = await payrollStore.downloadPayslipPdf(
                  widget.payslipId,
                );
                if (filePath != null) {
                  toast(language.lblPayslipDownloadedSuccessfully);
                } else if (payrollStore.error != null) {
                  toast(payrollStore.error!);
                }
              },
            ),
            const SizedBox(height: 12),
            Observer(
              builder: (_) => _buildActionButton(
                icon: Iconsax.share,
                label: language.lblShare,
                color: Colors.blue,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  final payslip = payrollStore.selectedPayslip;
                  if (payslip != null) {
                    Share.share(
                      'Check out my payslip for ${payslip.payrollPeriod}',
                      subject: 'Payslip - ${payslip.payrollPeriod}',
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Iconsax.printer,
              label: language.lblPrint,
              color: Colors.orange,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                toast(language.lblPrintFeatureComingSoon);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          final isDark = appStore.isDarkModeOn;
          final isLoading = payrollStore.isLoading;
          final error = payrollStore.error;
          final payslip = payrollStore.selectedPayslip;

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
                  _buildHeader(isDark),
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
                        child: isLoading
                            ? _buildLoadingState(isDark)
                            : error != null
                            ? _buildErrorState(isDark, error)
                            : payslip == null
                            ? _buildErrorState(isDark, language.lblPayslipNotFound)
                            : _buildContent(isDark, payslip),
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
    return Observer(
      builder: (_) {
        final payslip = payrollStore.selectedPayslip;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.lblPayslipDetails,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payslip?.payrollPeriod ?? language.lblLoadingPleaseWait,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Iconsax.more, color: Colors.white),
                  onPressed: () => _showActionSheet(isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, payslip) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildSummaryCard(isDark, payslip),
        const SizedBox(height: 16),
        _buildTabBar(isDark),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDark, payslip),
              _buildEarningsTab(isDark, payslip),
              _buildDeductionsTab(isDark, payslip),
            ],
          ),
        ),
        _buildBottomButtons(isDark, payslip),
      ],
    );
  }

  Widget _buildSummaryCard(bool isDark, payslip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F2937), const Color(0xFF374151)]
              : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF696CFF))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.wallet_money,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            language.lblNetSalary,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${getStringAsync(appCurrencySymbolPref)}${payslip.netSalary?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          // Summary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  language.lblBasicSalary,
                  '${getStringAsync(appCurrencySymbolPref)}${payslip.basicSalary?.toStringAsFixed(0) ?? '0'}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  language.lblBenefits,
                  '${getStringAsync(appCurrencySymbolPref)}${payslip.totalBenefits?.toStringAsFixed(0) ?? '0'}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  language.lblDeductions,
                  '${getStringAsync(appCurrencySymbolPref)}${payslip.totalDeductions?.toStringAsFixed(0) ?? '0'}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? Colors.grey[400]
            : const Color(0xFF6B7280),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: language.lblOverview),
          Tab(text: language.lblEarnings),
          Tab(text: language.lblDeductions),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, payslip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: language.lblAttendanceSummary,
            icon: Iconsax.calendar,
            isDark: isDark,
            children: [
              _buildInfoRow(
                language.lblWorkingDays,
                '${payslip.totalWorkingDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblWorkedDays,
                '${payslip.totalWorkedDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblLeaveDays,
                '${payslip.totalLeaveDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblAbsentDays,
                '${payslip.totalAbsentDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblHolidays,
                '${payslip.totalHolidays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblWeekends,
                '${payslip.totalWeekends ?? 0}',
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: language.lblAdditionalDetails,
            icon: Iconsax.info_circle,
            isDark: isDark,
            children: [
              _buildInfoRow(
                language.lblLateDays,
                '${payslip.totalLateDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblEarlyCheckoutDays,
                '${payslip.totalEarlyCheckoutDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(
                language.lblOvertimeDays,
                '${payslip.totalOvertimeDays ?? 0}',
                isDark,
              ),
              _buildInfoRow(language.lblPayslipCode, payslip.code ?? 'N/A', isDark),
              _buildInfoRow(
                language.lblStatus,
                payslip.status ?? language.lblPaid,
                isDark,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(bool isDark, payslip) {
    final earnings =
        payslip.payrollModifiers
            ?.where((mod) => mod!.type == 'benefit')
            .toList() ??
        [];

    return earnings.isEmpty
        ? _buildEmptyTabState(
            language.lblNoEarnings,
            language.lblNoAdditionalEarnings,
            Iconsax.wallet_add,
            isDark,
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoSection(
                title: language.lblEarningsBreakdown,
                icon: Iconsax.wallet_add,
                isDark: isDark,
                children: [
                  _buildInfoRow(
                    language.lblBasicSalary,
                    '${getStringAsync(appCurrencySymbolPref)}${payslip.basicSalary?.toStringAsFixed(2) ?? '0.00'}',
                    isDark,
                  ),
                  ...earnings
                      .map((earning) => _buildModifierRow(earning!, isDark))
                      .toList(),
                  const Divider(height: 24),
                  _buildInfoRow(
                    language.lblTotalEarnings,
                    '${getStringAsync(appCurrencySymbolPref)}${((payslip.basicSalary ?? 0) + (payslip.totalBenefits ?? 0)).toStringAsFixed(2)}',
                    isDark,
                    isBold: true,
                    isLast: true,
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildDeductionsTab(bool isDark, payslip) {
    final deductions =
        payslip.payrollModifiers
            ?.where((mod) => mod!.type == 'deduction')
            .toList() ??
        [];

    return deductions.isEmpty
        ? _buildEmptyTabState(
            language.lblNoDeductions,
            language.lblNoDeductionsForPeriod,
            Iconsax.wallet_minus,
            isDark,
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoSection(
                title: language.lblDeductionsBreakdown,
                icon: Iconsax.wallet_minus,
                isDark: isDark,
                children: [
                  ...deductions
                      .map(
                        (deduction) => _buildModifierRow(deduction!, isDark),
                      )
                      .toList(),
                  const Divider(height: 24),
                  _buildInfoRow(
                    language.lblTotalDeductions,
                    '${getStringAsync(appCurrencySymbolPref)}${payslip.totalDeductions?.toStringAsFixed(2) ?? '0.00'}',
                    isDark,
                    isBold: true,
                    isLast: true,
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildEmptyTabState(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
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
              icon,
              size: 50,
              color: const Color(0xFF696CFF).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
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
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF696CFF).withOpacity(0.1),
                  const Color(0xFF5457E6).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierRow(PayrollModifier modifier, bool isDark) {
    final isDeduction = modifier.type == 'deduction';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              modifier.name ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            modifier.amount != null
                ? '${getStringAsync(appCurrencySymbolPref)}${modifier.amount}'
                : '${modifier.percentage}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDeduction ? Colors.red[600] : Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF696CFF)),
          const SizedBox(height: 16),
          Text(
            language.lblLoadingPayslipDetails,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(Iconsax.warning_2, size: 50, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblError,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPayslipDetails,
              icon: const Icon(Icons.refresh),
              label: Text(language.lblRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF696CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildBottomButtons(bool isDark, payslip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Share.share(
                    'Check out my payslip for ${payslip.payrollPeriod}',
                    subject: 'Payslip - ${payslip.payrollPeriod}',
                  );
                },
                icon: const Icon(Iconsax.share, size: 18),
                label: Text(language.lblShare),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  foregroundColor: isDark
                      ? Colors.white
                      : const Color(0xFF374151),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Observer(
                builder: (_) => Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF696CFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: payrollStore.isDownloadingPayslip
                        ? null
                        : () async {
                            final filePath = await payrollStore
                                .downloadPayslipPdf(widget.payslipId);
                            if (filePath != null) {
                              toast(language.lblPayslipDownloadedSuccessfully);
                            } else if (payrollStore.error != null) {
                              toast(payrollStore.error!);
                            }
                          },
                    icon: payrollStore.isDownloadingPayslip
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Iconsax.document_download, size: 18),
                    label: Text(
                      payrollStore.isDownloadingPayslip
                          ? language.lblDownloading
                          : language.lblDownloadPDF,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
}
