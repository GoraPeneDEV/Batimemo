import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payslip_model.dart';
import '../../utils/app_constants.dart';
import 'payslip_detail_screen.dart';

/// Payslips List Screen
///
/// Displays a paginated list of all employee payslips with:
/// - Filter by year and status
/// - Pull to refresh
/// - Infinite scroll pagination
/// - Navigate to detail view
class PayslipsListScreen extends StatefulWidget {
  const PayslipsListScreen({super.key});

  @override
  State<PayslipsListScreen> createState() => _PayslipsListScreenState();
}

class _PayslipsListScreenState extends State<PayslipsListScreen> {
  final ScrollController _scrollController = ScrollController();
  int? selectedYear;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadPayslips();
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
      if (payrollStore.hasMore && !payrollStore.isLoading) {
        payrollStore.loadMorePayslips();
      }
    }
  }

  Future<void> _loadPayslips() async {
    await payrollStore.fetchPayslips(
      year: selectedYear,
      status: selectedStatus,
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        title: Text(
          language.lblFilterPayslips,
          style: TextStyle(
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year filter
            DropdownButtonFormField<int?>(
              value: selectedYear,
              decoration: InputDecoration(
                labelText: language.lblYear,
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
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(language.lblAllYears),
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
                  value: 'generated',
                  child: Text('Generated'),
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
              _loadPayslips();
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
                              payrollStore.payslips.isEmpty) {
                            return _buildLoadingSkeleton();
                          }

                          if (payrollStore.error != null &&
                              payrollStore.payslips.isEmpty) {
                            return _buildErrorState();
                          }

                          if (payrollStore.payslips.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: _loadPayslips,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  payrollStore.payslips.length +
                                  (payrollStore.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == payrollStore.payslips.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF696CFF),
                                      ),
                                    ),
                                  );
                                }

                                final payslip = payrollStore.payslips[index];
                                return _buildPayslipCard(payslip);
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
          Expanded(
            child: Text(
              language.lblMyPayslips,
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

  Widget _buildPayslipCard(PayslipModel payslip) {
    Color statusColor = Colors.green;
    if (payslip.status?.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else if (payslip.status?.toLowerCase() == 'draft') {
      statusColor = Colors.grey;
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF696CFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.receipt_item,
            color: Color(0xFF696CFF),
            size: 28,
          ),
        ),
        title: Text(
          payslip.payrollPeriod ?? 'N/A',
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
            Text(
              'Code: ${payslip.code ?? 'N/A'}',
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              payslip.createdAt != null
                  ? '${language.lblCreatedOn}: ${payslip.createdAt}'
                  : 'N/A',
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: Color(0xFF696CFF),
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
                Iconsax.receipt_item,
                size: 64,
                color: appStore.isDarkModeOn
                    ? Colors.grey[600]
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblNoPayslipsFound,
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
              child: const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblErrorLoadingPayslips,
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
              onPressed: _loadPayslips,
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
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: appStore.isDarkModeOn
              ? Colors.grey[800]!
              : const Color(0xFFE5E7EB),
          highlightColor: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFF9FAFB),
          child: Container(
            height: 120,
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
