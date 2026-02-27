import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payroll_record_model.dart';
import 'payroll_record_detail_screen.dart';

/// Payroll Records List Screen
///
/// Displays a paginated list of all employee payroll records with:
/// - Filter by status
/// - Pull to refresh
/// - Infinite scroll pagination
/// - Navigate to detail view
/// - Shows period, gross salary, net salary, and status
class PayrollRecordsScreen extends StatefulWidget {
  const PayrollRecordsScreen({super.key});

  @override
  State<PayrollRecordsScreen> createState() => _PayrollRecordsScreenState();
}

class _PayrollRecordsScreenState extends State<PayrollRecordsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadPayrollRecords();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (payrollStore.hasMorePayrollRecords && !payrollStore.isLoading) {
        payrollStore.loadMorePayrollRecords();
      }
    }
  }

  Future<void> _loadPayrollRecords() async {
    await payrollStore.fetchPayrollRecords(status: selectedStatus);
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        title: Text(
          language.lblFilterPayrollRecords,
          style: TextStyle(
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status filter
            DropdownButtonFormField<String?>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: language.lblStatus,
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
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(language.lblAllStatus),
                ),
                DropdownMenuItem<String?>(
                  value: 'pending',
                  child: Text(language.lblPending),
                ),
                DropdownMenuItem<String?>(
                  value: 'processed',
                  child: Text(language.lblProcessed),
                ),
                DropdownMenuItem<String?>(
                  value: 'paid',
                  child: Text(language.lblPaid),
                ),
                DropdownMenuItem<String?>(
                  value: 'draft',
                  child: Text(language.lblDraft),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(language.lblCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadPayrollRecords();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              foregroundColor: Colors.white,
            ),
            child: Text(language.lblApply),
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
                      child: Observer(
                        builder: (_) {
                          if (payrollStore.isLoading &&
                              payrollStore.payrollRecords.isEmpty) {
                            return _buildLoadingSkeleton();
                          }

                          if (payrollStore.error != null &&
                              payrollStore.payrollRecords.isEmpty) {
                            return _buildErrorState();
                          }

                          if (payrollStore.payrollRecords.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: _loadPayrollRecords,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  payrollStore.payrollRecords.length +
                                  (payrollStore.hasMorePayrollRecords ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index ==
                                    payrollStore.payrollRecords.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF696CFF),
                                      ),
                                    ),
                                  );
                                }

                                final record =
                                    payrollStore.payrollRecords[index];
                                return _buildPayrollRecordCard(record);
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

  /// Simple Header with Back Button, Title, and Filter
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
              language.lblPayrollRecords,
              style: const TextStyle(
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
              icon: const Icon(Iconsax.filter, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollRecordCard(PayrollRecordModel record) {
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PayrollRecordDetailScreen(recordId: record.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with period and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF696CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Iconsax.wallet_money,
                            color: Color(0xFF696CFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.period,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: appStore.isDarkModeOn
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (record.payrollCycle != null)
                                Text(
                                  record.payrollCycle!.name,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(
                color: appStore.isDarkModeOn
                    ? Colors.grey[700]
                    : const Color(0xFFE5E7EB),
                height: 1,
              ),
              const SizedBox(height: 16),

              // Salary details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.lblGrossSalary,
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.grossSalary.formatted,
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
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.lblNetSalary,
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.netSalary.formatted,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Attendance summary
              Row(
                children: [
                  _buildInfoChip(
                    Iconsax.clock,
                    '${record.totalWorkedDays.toStringAsFixed(0)} ${language.lblDays}',
                    language.lblWorked,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Iconsax.note_remove,
                    '${record.totalLeaveDays.toStringAsFixed(0)} ${language.lblDays}',
                    language.lblLeave,
                  ),
                  const SizedBox(width: 8),
                  if (record.adjustmentsCount > 0)
                    _buildInfoChip(
                      Iconsax.document,
                      '${record.adjustmentsCount}',
                      language.lblModifiers,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF374151)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
        ],
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
                Iconsax.wallet_money,
                size: 64,
                color: appStore.isDarkModeOn
                    ? Colors.grey[600]
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblNoPayrollRecordsFound,
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
              language.lblPayrollRecordsMessage,
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
              child: const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblErrorLoadingRecords,
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
              onPressed: _loadPayrollRecords,
              icon: const Icon(Iconsax.refresh),
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
            height: 180,
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
