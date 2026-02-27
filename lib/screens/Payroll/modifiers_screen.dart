import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payroll/modifier_record.dart';
import '../../utils/app_constants.dart';

/// Payroll Modifiers Screen
///
/// Displays a list of all payroll modifiers grouped by period with:
/// - Filter by year, month, and type (earning/deduction)
/// - Earnings displayed in green, deductions in orange/red
/// - Expandable cards showing detailed modifiers for each period
/// - Pull to refresh
/// - Beautiful UI with dark mode support
class ModifiersScreen extends StatefulWidget {
  const ModifiersScreen({super.key});

  @override
  State<ModifiersScreen> createState() => _ModifiersScreenState();
}

class _ModifiersScreenState extends State<ModifiersScreen> {
  int? selectedYear;
  int? selectedMonth;
  String? selectedType; // 'all', 'benefit', 'deduction'
  List<ModifierRecord> filteredModifiers = [];

  @override
  void initState() {
    super.initState();
    _loadModifiers();
  }

  Future<void> _loadModifiers() async {
    await payrollStore.fetchModifiers();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredModifiers = payrollStore.modifiers.where((record) {
        // Filter by year
        if (selectedYear != null) {
          final year = _extractYear(record.period);
          if (year != selectedYear) return false;
        }

        // Filter by month
        if (selectedMonth != null) {
          final month = _extractMonth(record.period);
          if (month != selectedMonth) return false;
        }

        // Filter by type
        if (selectedType != null && selectedType != 'all') {
          if (selectedType == 'benefit') {
            return record.modifiers.earnings.isNotEmpty;
          } else if (selectedType == 'deduction') {
            return record.modifiers.deductions.isNotEmpty;
          }
        }

        return true;
      }).toList();
    });
  }

  int? _extractYear(String period) {
    try {
      // Period format is like "January 2024" or "Jan 2024"
      final parts = period.split(' ');
      if (parts.length >= 2) {
        return int.tryParse(parts.last);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  int? _extractMonth(String period) {
    try {
      // Period format is like "January 2024" or "Jan 2024"
      final monthMap = {
        'january': 1, 'jan': 1,
        'february': 2, 'feb': 2,
        'march': 3, 'mar': 3,
        'april': 4, 'apr': 4,
        'may': 5,
        'june': 6, 'jun': 6,
        'july': 7, 'jul': 7,
        'august': 8, 'aug': 8,
        'september': 9, 'sep': 9,
        'october': 10, 'oct': 10,
        'november': 11, 'nov': 11,
        'december': 12, 'dec': 12,
      };

      final monthName = period.split(' ').first.toLowerCase();
      return monthMap[monthName];
    } catch (e) {
      return null;
    }
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        title: Text(
          'Filter Modifiers',
          style: TextStyle(
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year filter
              DropdownButtonFormField<int?>(
                initialValue: selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year',
                  labelStyle: TextStyle(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                style: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Years'),
                  ),
                  ...List.generate(5, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem<int?>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Month filter
              DropdownButtonFormField<int?>(
                initialValue: selectedMonth,
                decoration: InputDecoration(
                  labelText: 'Month',
                  labelStyle: TextStyle(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                style: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
                items: const [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Months'),
                  ),
                  DropdownMenuItem<int?>(value: 1, child: Text('January')),
                  DropdownMenuItem<int?>(value: 2, child: Text('February')),
                  DropdownMenuItem<int?>(value: 3, child: Text('March')),
                  DropdownMenuItem<int?>(value: 4, child: Text('April')),
                  DropdownMenuItem<int?>(value: 5, child: Text('May')),
                  DropdownMenuItem<int?>(value: 6, child: Text('June')),
                  DropdownMenuItem<int?>(value: 7, child: Text('July')),
                  DropdownMenuItem<int?>(value: 8, child: Text('August')),
                  DropdownMenuItem<int?>(value: 9, child: Text('September')),
                  DropdownMenuItem<int?>(value: 10, child: Text('October')),
                  DropdownMenuItem<int?>(value: 11, child: Text('November')),
                  DropdownMenuItem<int?>(value: 12, child: Text('December')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Type filter
              DropdownButtonFormField<String?>(
                initialValue: selectedType ?? 'all',
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                style: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: 'all',
                    child: Text('All Types'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'benefit',
                    child: Text('Earnings Only'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'deduction',
                    child: Text('Deductions Only'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value == 'all' ? null : value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedYear = null;
                selectedMonth = null;
                selectedType = null;
              });
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
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
                // Header with title and filter
                _buildSimpleHeader(),

                // Stats cards in gradient area (if data available)
                if (payrollStore.modifiers.isNotEmpty)
                  _buildStatsInGradient(),

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
                      child: Observer(
                        builder: (_) {
                          if (payrollStore.isLoadingModifiers &&
                              payrollStore.modifiers.isEmpty) {
                            return _buildLoadingSkeleton();
                          }

                          if (payrollStore.error != null &&
                              payrollStore.modifiers.isEmpty) {
                            return _buildErrorState();
                          }

                          if (filteredModifiers.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: _loadModifiers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredModifiers.length,
                              itemBuilder: (context, index) {
                                final record = filteredModifiers[index];
                                return _buildModifierCard(record);
                              },
                            ),
                          );
                        },
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
          const Expanded(
            child: Text(
              'Payroll Modifiers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Filter button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(
                Iconsax.filter,
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

  Widget _buildStatsInGradient() {
    final totalEarnings = filteredModifiers.fold<double>(
      0,
      (sum, record) => sum + record.totalEarnings.amount,
    );

    final totalDeductions = filteredModifiers.fold<double>(
      0,
      (sum, record) => sum + record.totalDeductions.amount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Total Earnings',
              value: '${getStringAsync(appCurrencySymbolPref)}${totalEarnings.toStringAsFixed(0)}',
              icon: Iconsax.arrow_up,
              valueColor: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'Total Deductions',
              value: '${getStringAsync(appCurrencySymbolPref)}${totalDeductions.toStringAsFixed(0)}',
              icon: Iconsax.arrow_down,
              valueColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierCard(ModifierRecord record) {
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF696CFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.wallet_2,
              color: Color(0xFF696CFF),
              size: 28,
            ),
          ),
          title: Text(
            record.period,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              if (record.payrollCycle != null)
                Text(
                  'Pay Date: ${record.payrollCycle!.payDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (record.modifiers.earnings.isNotEmpty) ...[
                    _buildBadge(
                      '${record.modifiers.earnings.length} Earnings',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (record.modifiers.deductions.isNotEmpty)
                    _buildBadge(
                      '${record.modifiers.deductions.length} Deductions',
                      Colors.orange,
                    ),
                ],
              ),
            ],
          ),
          children: [
            // Earnings section
            if (record.modifiers.earnings.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Iconsax.arrow_up, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'EARNINGS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    record.totalEarnings.formatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...record.modifiers.earnings.map((item) {
                return _buildModifierItem(item, Colors.green);
              }),
              const SizedBox(height: 12),
            ],

            // Deductions section
            if (record.modifiers.deductions.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Iconsax.arrow_down, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'DEDUCTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    record.totalDeductions.formatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...record.modifiers.deductions.map((item) {
                return _buildModifierItem(item, Colors.orange);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModifierItem(ModifierItem item, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${item.code}',
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (item.applicability != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Applicability: ${item.applicability}',
                    style: TextStyle(
                      fontSize: 11,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[500]
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.displayValue,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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
                Iconsax.wallet_2,
                size: 64,
                color: appStore.isDarkModeOn
                    ? Colors.grey[600]
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Modifiers Found',
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
              selectedYear != null || selectedMonth != null || selectedType != null
                  ? 'Try adjusting your filters'
                  : 'No payroll modifiers have been applied yet',
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedYear != null ||
                selectedMonth != null ||
                selectedType != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedYear = null;
                    selectedMonth = null;
                    selectedType = null;
                  });
                  _applyFilters();
                },
                icon: const Icon(Iconsax.refresh),
                label: const Text('Clear Filters'),
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
              'Error Loading Modifiers',
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
              onPressed: _loadModifiers,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
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
            height: 140,
            margin: const EdgeInsets.only(bottom: 12),
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
