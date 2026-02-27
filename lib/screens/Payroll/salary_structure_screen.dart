import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/salary_structure_model.dart';

/// Salary Structure Screen
///
/// Displays the employee's salary structure breakdown including:
/// - Earnings components (benefits, allowances, etc.)
/// - Deductions components (taxes, PF, etc.)
/// - Component details (name, code, type, value)
/// - Calculation types (fixed amount or percentage)
/// - Effective dates
///
/// Features:
/// - Pull to refresh
/// - Loading skeleton states
/// - Error handling with retry
/// - Dark mode support
/// - Beautiful gradient cards matching app theme
class SalaryStructureScreen extends StatefulWidget {
  const SalaryStructureScreen({super.key});

  @override
  State<SalaryStructureScreen> createState() => _SalaryStructureScreenState();
}

class _SalaryStructureScreenState extends State<SalaryStructureScreen> {
  @override
  void initState() {
    super.initState();
    _loadSalaryStructure();
  }

  Future<void> _loadSalaryStructure() async {
    await payrollStore.fetchSalaryStructure();
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
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Simple Header
                _buildSimpleHeader(),

                // Main Content with rounded top corners
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
              language.lblSalaryStructure,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Refresh button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _loadSalaryStructure,
              icon: const Icon(
                Iconsax.refresh,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Observer(
      builder: (_) {
        if (payrollStore.isLoading && payrollStore.salaryStructure == null) {
          return _buildLoadingSkeleton();
        }

        if (payrollStore.error != null &&
            payrollStore.salaryStructure == null) {
          return _buildErrorState();
        }

        if (payrollStore.salaryStructure == null ||
            !payrollStore.salaryStructure!.hasComponents) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadSalaryStructure,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(),
                const SizedBox(height: 20),

                // Earnings Section
                if (payrollStore.salaryStructure!.hasEarnings) ...[
                  _buildSectionHeader(
                    language.lblEarnings,
                    payrollStore.salaryStructure!.totalEarnings,
                    Colors.green,
                    Iconsax.arrow_up,
                  ),
                  const SizedBox(height: 12),
                  ...payrollStore.salaryStructure!.earnings!
                      .map((component) => _buildComponentCard(
                            component,
                            Colors.green,
                          ))
                      .toList(),
                  const SizedBox(height: 20),
                ],

                // Deductions Section
                if (payrollStore.salaryStructure!.hasDeductions) ...[
                  _buildSectionHeader(
                    language.lblDeductions,
                    payrollStore.salaryStructure!.totalDeductions,
                    Colors.orange,
                    Iconsax.arrow_down,
                  ),
                  const SizedBox(height: 12),
                  ...payrollStore.salaryStructure!.deductions!
                      .map((component) => _buildComponentCard(
                            component,
                            Colors.orange,
                          ))
                      .toList(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final structure = payrollStore.salaryStructure!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.wallet_3,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.lblTotalComponents,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.lblYourSalaryBreakdown,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${structure.totalComponents}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    language.lblEarnings,
                    '${structure.totalEarnings}',
                    Iconsax.arrow_up,
                    Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    language.lblDeductions,
                    '${structure.totalDeductions}',
                    Iconsax.arrow_down,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ${language.lblComponentsCount}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentCard(
    SalaryStructureComponent component,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Component Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    component.displayCode,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    component.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
                if (component.component?.isTaxable == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      language.lblTaxable,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),

            // Description
            if (component.component?.description != null &&
                component.component!.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                component.component!.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              color: appStore.isDarkModeOn
                  ? Colors.grey[700]
                  : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 12),

            // Component Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    language.lblType,
                    component.isPercentage ? language.lblPercentage : language.lblFixed,
                    Iconsax.setting_2,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: _buildDetailItem(
                    language.lblValue,
                    component.displayValue,
                    Iconsax.wallet_3,
                    valueColor: accentColor,
                  ),
                ),
              ],
            ),

            // Effective Dates
            if (component.effectiveFrom != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF111827)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[700]!
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 16,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${language.lblEffectiveFrom} ${component.effectiveFrom}',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    if (!component.isActive) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${language.lblEffectiveTo} ${component.effectiveTo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (component.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          language.lblActive,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          language.lblInactive,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: appStore.isDarkModeOn
              ? Colors.grey[400]
              : const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827)),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Iconsax.wallet_3,
                size: 64,
                color: appStore.isDarkModeOn
                    ? Colors.grey[600]
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblNoSalaryStructureFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              language.lblSalaryStructureNotConfigured,
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
              language.lblErrorLoadingSalaryStructure,
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
              payrollStore.error ?? language.lblSomethingWentWrong,
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
              onPressed: _loadSalaryStructure,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: appStore.isDarkModeOn
              ? Colors.grey[800]!
              : const Color(0xFFE5E7EB),
          highlightColor: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFF9FAFB),
          child: Container(
            height: index == 0 ? 180 : 140,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? Colors.grey[800]
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
