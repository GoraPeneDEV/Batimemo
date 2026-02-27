import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/Utils/app_constants.dart';
import 'package:open_core_hr/models/Expense/expense_request_model.dart';

import '../../../main.dart';
import '../../../utils/string_extensions.dart';

class ExpenseItemWidget extends StatelessWidget {
  final int index;
  final ExpenseRequestModel model;
  final Function(BuildContext) deleteAction;

  const ExpenseItemWidget({
    super.key,
    required this.index,
    required this.model,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        deleteAction(context);
      },
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
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title/Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient Icon Container
                _buildGradientIconContainer(),
                12.width,

                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type/Title
                      Text(
                        model.type ?? language.lblExpense,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      6.height,

                      // Status Badge
                      _buildStatusBadge(isDark),
                    ],
                  ),
                ),
              ],
            ),
            16.height,

            // Requested On
            _buildInfoRow(
              icon: Iconsax.calendar,
              label: language.lblRequestedOn,
              value: model.createdAt ?? '',
              isDark: isDark,
            ),
            10.height,

            // For Date
            _buildInfoRow(
              icon: Iconsax.calendar,
              label: language.lblForDate,
              value: model.date ?? '',
              isDark: isDark,
            ),
            16.height,

            // Divider
            Divider(
              color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
              height: 1,
            ),
            16.height,

            // Amount Information
            Row(
              children: [
                // Claimed Amount
                Expanded(
                  child: _buildAmountInfo(
                    icon: Iconsax.money,
                    label: language.lblClaimed,
                    amount: model.actualAmount?.toString() ?? '0',
                    isDark: isDark,
                  ),
                ),

                // Approved Amount (if approved)
                if (model.status?.toLowerCase() == 'approved')
                  Expanded(
                    child: _buildAmountInfo(
                      icon: Iconsax.tick_circle,
                      label: language.lblApproved,
                      amount: model.approvedAmount?.toString() ??
                              model.actualAmount?.toString() ?? '0',
                      isDark: isDark,
                      isApproved: true,
                    ),
                  ),
              ],
            ),

            // Cancel Button (for pending status)
            if (model.status?.toLowerCase() == 'pending') ...[
              16.height,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => deleteAction(context),
                  icon: const Icon(
                    Iconsax.close_circle,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  label: Text(
                    language.lblCancel,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build Gradient Icon Container
  Widget _buildGradientIconContainer() {
    IconData expenseIcon = _getExpenseIcon(model.type);

    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF696CFF).withValues(alpha: 0.2),
            const Color(0xFF5457E6).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        expenseIcon,
        size: 24,
        color: const Color(0xFF696CFF),
      ),
    );
  }

  // Get Expense Icon based on type
  IconData _getExpenseIcon(String? type) {
    if (type == null) return Iconsax.receipt_item;

    final typeLower = type.toLowerCase();
    if (typeLower.contains('travel')) return Iconsax.airplane;
    if (typeLower.contains('food') || typeLower.contains('meal')) {
      return Iconsax.cake;
    }
    if (typeLower.contains('transport') || typeLower.contains('fuel')) {
      return Iconsax.car;
    }
    if (typeLower.contains('accommodation') || typeLower.contains('hotel')) {
      return Iconsax.building;
    }

    return Iconsax.receipt_item;
  }

  // Build Status Badge
  Widget _buildStatusBadge(bool isDark) {
    final status = model.status?.toLowerCase() ?? 'pending';

    Color backgroundColor;
    Color textColor;
    IconData statusIcon;

    switch (status) {
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
          Icon(
            statusIcon,
            size: 14,
            color: textColor,
          ),
          6.width,
          Text(
            model.status?.capitalize ?? language.lblPending,
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

  // Build Info Row (for dates)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final greyColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: greyColor,
        ),
        8.width,
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: greyColor,
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build Amount Info
  Widget _buildAmountInfo({
    required IconData icon,
    required String label,
    required String amount,
    required bool isDark,
    bool isApproved = false,
  }) {
    final greyColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final amountColor = isApproved
        ? const Color(0xFF10B981)
        : (isDark ? Colors.white : const Color(0xFF111827));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: greyColor,
            ),
            6.width,
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: greyColor,
              ),
            ),
          ],
        ),
        6.height,
        Text(
          '${getStringAsync(appCurrencySymbolPref)}$amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
