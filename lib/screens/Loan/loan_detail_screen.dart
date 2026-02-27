import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/dio_api/repositories/loan_repository.dart';
import '../../main.dart';
import '../../models/Loan/loan_detail_model.dart';
import '../../models/Loan/loan_history.dart';
import '../../models/Loan/loan_repayment.dart';
import '../../Utils/app_constants.dart';
import 'loan_request_screen.dart';

class LoanDetailScreen extends StatefulWidget {
  final int loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  final LoanRepository _repository = LoanRepository();
  LoanDetailResponse? _loanDetail;
  List<LoanHistory>? _loanHistory;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  /// Calculate EMI locally using standard EMI formula
  /// EMI = [P x R x (1+R)^N] / [(1+R)^N – 1]
  double? _calculateEmi(
    double? amount,
    double? interestRate,
    int? tenureMonths,
  ) {
    if (amount == null || interestRate == null || tenureMonths == null) {
      return null;
    }
    if (amount <= 0 || tenureMonths <= 0) {
      return null;
    }

    // If interest rate is 0, EMI is simply amount / tenure
    if (interestRate == 0) {
      return amount / tenureMonths;
    }

    // Monthly interest rate
    final monthlyRate = interestRate / 12 / 100;

    // EMI formula
    final emi =
        (amount * monthlyRate * _pow(1 + monthlyRate, tenureMonths)) /
        (_pow(1 + monthlyRate, tenureMonths) - 1);

    return emi;
  }

  /// Helper function for power calculation
  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLoanDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLoanDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _repository.getLoanRequest(widget.loanId);
      final history = await _repository.getLoanHistory(widget.loanId);

      setState(() {
        _loanDetail = detail;
        _loanHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      toast('${language.lblErrorLoadingLoanDetails}: $e');
    }
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
                // Header
                _buildHeader(),

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
                      child: _isLoading
                          ? _buildLoadingState()
                          : _error != null
                          ? _buildErrorState()
                          : _buildContent(),
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

  Widget _buildHeader() {
    final canEdit = _loanDetail?.loan.canEdit ?? false;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _loanDetail?.loan.loanNumber ?? language.lblLoanDetails,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Edit button - only show when canEdit is true
          if (canEdit)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Iconsax.edit, color: Colors.white),
                tooltip: language.lblEditLoanRequest,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoanRequestScreen(loanId: widget.loanId),
                    ),
                  );
                  // Reload loan details if changes were made
                  if (result == true) {
                    _loadLoanDetails();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.close_circle, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              language.lblError,
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
              _error ?? language.lblUnknownError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLoanDetails,
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
    );
  }

  Widget _buildContent() {
    final loan = _loanDetail!.loan;
    final isDark = appStore.isDarkModeOn;

    return Column(
      children: [
        // Status Card
        _buildStatusCard(loan, isDark),

        // Tabs
        Container(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF696CFF),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF696CFF),
            indicatorWeight: 3,
            tabs: [
              Tab(text: language.lblDetails),
              Tab(text: language.lblRepayments),
              Tab(text: language.lblHistory),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(loan, isDark),
              _buildRepaymentsTab(isDark),
              _buildHistoryTab(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(LoanDetailModel loan, bool isDark) {
    // Use backend EMI if available, otherwise calculate locally
    final effectiveAmount = loan.approvedAmount ?? loan.amount;
    final monthlyEmi =
        loan.monthlyEmi ??
        _calculateEmi(effectiveAmount, loan.interestRate, loan.tenureMonths);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.loanType?.name ?? language.lblLoan,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              _buildStatusBadge(loan.status, loan.statusLabel, isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAmountColumn(
                  language.lblRequested,
                  loan.amount,
                  Iconsax.wallet_money,
                  isDark,
                ),
              ),
              if (loan.approvedAmount != null)
                Expanded(
                  child: _buildAmountColumn(
                    language.lblApproved,
                    loan.approvedAmount!,
                    Iconsax.tick_circle,
                    isDark,
                    color: const Color(0xFF10B981),
                  ),
                ),
            ],
          ),
          // Always show Monthly EMI section if we have tenure
          if (loan.tenureMonths != null) ...[
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    language.lblMonthlyEMI,
                    monthlyEmi != null
                        ? '${getStringAsync(appCurrencySymbolPref)}${monthlyEmi.toStringAsFixed(2)}'
                        : '-',
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    language.lblTenure,
                    '${loan.tenureMonths} months',
                    isDark,
                  ),
                ),
              ],
            ),
          ],
          if (loan.outstandingAmount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.lblOutstandingAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    '${getStringAsync(appCurrencySymbolPref)}${loan.outstandingAmount!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label, bool isDark) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = const Color(0xFF10B981).withOpacity(0.15);
        textColor = const Color(0xFF10B981);
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.15);
        textColor = const Color(0xFFEF4444);
        break;
      case 'disbursed':
        backgroundColor = const Color(0xFF3B82F6).withOpacity(0.15);
        textColor = const Color(0xFF3B82F6);
        break;
      case 'closed':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        break;
      default:
        backgroundColor = const Color(0xFFF59E0B).withOpacity(0.15);
        textColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAmountColumn(
    String label,
    double amount,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${getStringAsync(appCurrencySymbolPref)}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.white : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(LoanDetailModel loan, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(language.lblLoanDetails, [
            _buildDetailRow(language.lblPurpose, loan.purpose ?? '-', isDark),
            if (loan.remarks != null)
              _buildDetailRow(language.lblRemarks, loan.remarks!, isDark),
            _buildDetailRow(
              language.lblInterestRate,
              '${loan.interestRate ?? 0}%',
              isDark,
            ),
            if (loan.totalAmount != null)
              _buildDetailRow(
                language.lblTotalAmount,
                '${getStringAsync(appCurrencySymbolPref)}${loan.totalAmount!.toStringAsFixed(2)}',
                isDark,
              ),
          ], isDark),
          const SizedBox(height: 16),
          if (loan.expectedDisbursementDate != null ||
              loan.actualDisbursementDate != null)
            _buildDetailCard(language.lblDisbursement, [
              if (loan.expectedDisbursementDate != null)
                _buildDetailRow(
                  language.lblExpectedDate,
                  loan.expectedDisbursementDate!,
                  isDark,
                ),
              if (loan.actualDisbursementDate != null)
                _buildDetailRow(
                  language.lblActualDate,
                  loan.actualDisbursementDate!,
                  isDark,
                ),
            ], isDark),
          const SizedBox(height: 16),
          if (loan.approverRemarks != null || loan.reviewerRemarks != null)
            _buildDetailCard(language.lblAdminRemarks, [
              if (loan.approverRemarks != null)
                _buildDetailRow(language.lblApprover, loan.approverRemarks!, isDark),
              if (loan.reviewerRemarks != null)
                _buildDetailRow(language.lblReviewer, loan.reviewerRemarks!, isDark),
            ], isDark),
          const SizedBox(height: 16),
          _buildDetailCard(language.lblTimeline, [
            _buildDetailRow(language.lblCreatedAt, loan.createdAt, isDark),
            _buildDetailRow(language.lblUpdatedAt, loan.updatedAt, isDark),
            if (loan.approvedAt != null)
              _buildDetailRow(language.lblApprovedAt, loan.approvedAt!, isDark),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildRepaymentsTab(bool isDark) {
    if (_loanDetail!.repayments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.receipt_minus,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoRepaymentsYet,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language.lblRepaymentScheduleAfterDisbursement,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _loanDetail!.repayments.length,
      itemBuilder: (context, index) {
        final repayment = _loanDetail!.repayments[index];
        return _buildRepaymentItem(repayment, isDark);
      },
    );
  }

  Widget _buildRepaymentItem(LoanRepayment repayment, bool isDark) {
    final isPaid = repayment.status.toLowerCase() == 'paid';
    final isOverdue = repayment.isOverdue && !isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? Colors.red
              : isPaid
              ? Colors.green
              : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                repayment.paymentNumber,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.15)
                      : isOverdue
                      ? Colors.red.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  repayment.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid
                        ? Colors.green
                        : isOverdue
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.lblEMIAmount,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${getStringAsync(appCurrencySymbolPref)}${repayment.emiAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? language.lblPaidOn : language.lblDueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? (repayment.paidDate ?? '-')
                          : (repayment.dueDate ?? '-'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? Colors.red
                            : (isDark ? Colors.white : const Color(0xFF111827)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${language.lblPrincipal}: ${getStringAsync(appCurrencySymbolPref)}${repayment.principalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${language.lblInterest}: ${getStringAsync(appCurrencySymbolPref)}${repayment.interestAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    if (_loanHistory == null || _loanHistory!.isEmpty) {
      return Center(
        child: Text(
          language.lblNoHistoryAvailable,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _loanHistory!.length,
      itemBuilder: (context, index) {
        final history = _loanHistory![index];
        return _buildHistoryItem(history, isDark);
      },
    );
  }

  Widget _buildHistoryItem(LoanHistory history, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF696CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getHistoryIcon(history.action),
                  size: 20,
                  color: const Color(0xFF696CFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (history.performedBy != null) ...[
            const SizedBox(height: 8),
            Text(
              'By: ${history.performedBy!.name}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getHistoryIcon(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return Iconsax.add_circle;
      case 'updated':
        return Iconsax.edit;
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      case 'cancelled':
        return Iconsax.close_square;
      case 'disbursed':
        return Iconsax.money_send;
      default:
        return Iconsax.document_text;
    }
  }

  Widget _buildDetailCard(String title, List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
