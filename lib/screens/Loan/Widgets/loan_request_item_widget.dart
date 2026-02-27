import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/Loan/loan_request_model.dart';
import 'package:open_core_hr/utils/string_extensions.dart';

import '../../../Utils/app_constants.dart';
import '../../../main.dart';

class LoanRequestItemWidget extends StatelessWidget {
  final int index;
  final LoanRequestModel model;
  final Function(BuildContext)? deleteAction;
  final VoidCallback? onTap;

  const LoanRequestItemWidget({
    super.key,
    required this.index,
    required this.model,
    this.deleteAction,
    this.onTap,
  });

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
    double result = 1.0;
    for (int i = 0; i < tenureMonths; i++) {
      result *= (1 + monthlyRate);
    }
    final emi = (amount * monthlyRate * result) / (result - 1);

    return emi;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return GestureDetector(
      onTap: onTap,
      onLongPress:
          deleteAction != null && (model.canCancel || model.status == 'draft')
          ? () => deleteAction!(context)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Title + Status Badge
            Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF696CFF).withValues(alpha: 0.2),
                        const Color(0xFF5457E6).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Iconsax.money_4,
                    size: 24,
                    color: Color(0xFF696CFF),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.loanNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      if (model.loanType?.name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          model.loanType!.name!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(isDark),
              ],
            ),
            const SizedBox(height: 16),

            // Divider
            Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 16),

            // Amount Information
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    icon: Iconsax.wallet_money,
                    label: language.lblRequestedAmount,
                    amount: model.amount,
                    isDark: isDark,
                  ),
                ),
                if (model.approvedAmount != null && model.status == 'approved')
                  Expanded(
                    child: _buildAmountInfo(
                      icon: Iconsax.tick_circle,
                      label: language.lblApprovedAmount,
                      amount: model.approvedAmount!,
                      isDark: isDark,
                      isApproved: true,
                    ),
                  ),
              ],
            ),

            // Always show Monthly EMI if we have tenure
            if (model.tenureMonths != null) ...[
              Builder(
                builder: (context) {
                  // Use backend EMI if available, otherwise calculate locally
                  final effectiveAmount = model.approvedAmount ?? model.amount;
                  final monthlyEmi =
                      model.monthlyEmi ??
                      _calculateEmi(
                        effectiveAmount,
                        model.interestRate,
                        model.tenureMonths,
                      );

                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Iconsax.wallet,
                            size: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${language.lblMonthlyEMI}: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            monthlyEmi != null
                                ? '${getStringAsync(appCurrencySymbolPref)}${monthlyEmi.toStringAsFixed(2)}'
                                : '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF696CFF),
                            ),
                          ),
                          Text(
                            ' × ${model.tenureMonths} ${language.lblMonths}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],

            if (model.outstandingAmount != null &&
                model.status == 'disbursed') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Iconsax.money_recive, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '${language.lblOutstanding}: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${getStringAsync(appCurrencySymbolPref)}${model.outstandingAmount!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],

            // Purpose if exists
            if (model.purpose != null && model.purpose!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.task,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model.purpose!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Remarks if exists
            if (model.remarks != null && model.remarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.message_text,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model.remarks!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Approver Remarks if exists
            if (model.approverRemarks != null &&
                model.approverRemarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.lblAdminRemarks,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            model.approverRemarks!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Date and Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      model.createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                // Cancel/Delete Button
                if (deleteAction != null &&
                    (model.canCancel || model.status == 'draft'))
                  TextButton.icon(
                    onPressed: () => deleteAction!(context),
                    icon: Icon(
                      model.status == 'draft'
                          ? Iconsax.trash
                          : Iconsax.close_circle,
                      size: 16,
                      color: const Color(0xFFEF4444),
                    ),
                    label: Text(
                      model.status == 'draft'
                          ? language.lblDelete
                          : language.lblCancel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build Status Badge with Icon
  Widget _buildStatusBadge(bool isDark) {
    Color backgroundColor;
    Color textColor;
    IconData statusIcon;

    switch (model.status.toLowerCase()) {
      case 'draft':
        backgroundColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        statusIcon = Iconsax.edit;
        break;
      case 'approved':
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.15);
        textColor = const Color(0xFF10B981);
        statusIcon = Iconsax.tick_circle;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
        textColor = const Color(0xFFEF4444);
        statusIcon = Iconsax.close_circle;
        break;
      case 'cancelled':
        backgroundColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        statusIcon = Iconsax.close_circle;
        break;
      case 'disbursed':
        backgroundColor = const Color(0xFF3B82F6).withValues(alpha: 0.15);
        textColor = const Color(0xFF3B82F6);
        statusIcon = Iconsax.tick_square;
        break;
      case 'closed':
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green;
        statusIcon = Iconsax.verify;
        break;
      default:
        backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        textColor = const Color(0xFFF59E0B);
        statusIcon = Iconsax.clock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            model.statusLabel.capitalize,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Build Amount Info Widget
  Widget _buildAmountInfo({
    required IconData icon,
    required String label,
    required double amount,
    required bool isDark,
    bool isApproved = false,
  }) {
    final color = isApproved
        ? const Color(0xFF10B981)
        : (isDark ? Colors.white : const Color(0xFF111827));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isApproved
              ? const Color(0xFF10B981)
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${getStringAsync(appCurrencySymbolPref)}${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
