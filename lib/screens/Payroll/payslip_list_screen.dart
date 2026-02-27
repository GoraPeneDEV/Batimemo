import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Payroll/payslip_details_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/payslip_model.dart';

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({super.key});

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = 'All';
  bool _isSearching = false;

  final List<String> _months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (payrollStore.hasMore && !payrollStore.isLoading) {
        payrollStore.loadMorePayslips();
      }
    }
  }

  Future<void> init() async {
    final year = selectedYear != 'All' ? int.tryParse(selectedYear) : null;
    await payrollStore.fetchPayslips(year: year);
  }

  List<PayslipModel> get _filteredPayslips {
    List<PayslipModel> filtered = payrollStore.payslips;

    // Filter by month
    if (selectedMonth != 'All') {
      filtered = filtered.where((payslip) {
        return payslip.payrollPeriod?.toLowerCase().contains(
              selectedMonth.toLowerCase(),
            ) ??
            false;
      }).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((payslip) {
        return (payslip.payrollPeriod?.toLowerCase().contains(searchTerm) ??
                false) ||
            (payslip.code?.toLowerCase().contains(searchTerm) ?? false) ||
            (payslip.status?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    return filtered;
  }

  Future<void> _applyYearFilter(String year) async {
    setState(() {
      selectedYear = year;
    });

    final yearInt = year != 'All' ? int.tryParse(year) : null;
    await payrollStore.fetchPayslips(year: yearInt);
  }

  void _showFilterBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              language.lblFilterPayslips,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            // Year Filter
            Text(
              language.lblSelectYear,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'All',
                        ...List.generate(
                          5,
                          (index) => (DateTime.now().year - index).toString(),
                        ),
                      ]
                      .map(
                        (year) => _buildFilterChip(
                          year,
                          selectedYear == year,
                          isDark,
                          () {
                            Navigator.pop(context);
                            _applyYearFilter(year);
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
            // Month Filter
            Text(
              language.lblSelectMonth,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _months
                  .map(
                    (month) => _buildFilterChip(
                      month,
                      selectedMonth == month,
                      isDark,
                      () {
                        setState(() => selectedMonth = month);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Reset and Apply buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedMonth = 'All';
                      });
                      _applyYearFilter(DateTime.now().year.toString());
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey[700]!
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      language.lblReset,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
          ),
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
                        child: _buildContent(isDark),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Top bar with back button and actions
          Row(
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
                child: Text(
                  _isSearching ? '' : language.lblPayslips,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!_isSearching) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isSearching = true);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Iconsax.filter, color: Colors.white),
                    onPressed: () => _showFilterBottomSheet(isDark),
                  ),
                ),
              ],
            ],
          ),
          // Search bar
          if (_isSearching) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: language.lblSearchPayslips,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Observer(
      builder: (_) {
        if (payrollStore.isLoading && payrollStore.payslips.isEmpty) {
          return _buildShimmerLoader(isDark);
        }

        if (payrollStore.error != null && payrollStore.payslips.isEmpty) {
          return _buildErrorState(isDark);
        }

        final filteredPayslips = _filteredPayslips;

        return Column(
          children: [
            // Active filters chips
            if (selectedYear != DateTime.now().year.toString() ||
                selectedMonth != 'All')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedYear != DateTime.now().year.toString())
                      _buildActiveFilterChip('Year: $selectedYear', () {
                        _applyYearFilter(DateTime.now().year.toString());
                      }),
                    if (selectedMonth != 'All')
                      _buildActiveFilterChip('Month: $selectedMonth', () {
                        setState(() => selectedMonth = 'All');
                      }),
                  ],
                ),
              ),
            // Payslip list
            Expanded(
              child: filteredPayslips.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                      onRefresh: () async {
                        await payrollStore.refreshPayrollData();
                      },
                      color: const Color(0xFF696CFF),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 24,
                        ),
                        itemCount:
                            filteredPayslips.length +
                            (payrollStore.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredPayslips.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildPayslipCard(
                            filteredPayslips[index],
                            isDark,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: const Color(0xFF696CFF)),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              language.lblFailedToLoadPayslips,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              payrollStore.error ?? 'An unexpected error occurred',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await init();
              },
              icon: const Icon(Icons.refresh, size: 18),
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

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF696CFF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipCard(PayslipModel payslip, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (payslip.id != null) {
              PayslipDetailsScreen(payslipId: payslip.id!).launch(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF696CFF).withOpacity(0.8),
                        const Color(0xFF5457E6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF696CFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.document_text,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Payslip Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payslip.payrollPeriod ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
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
                              children: [
                                Icon(
                                  Iconsax.wallet_money,
                                  size: 14,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${payslip.netSalary?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF696CFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              payslip.status ?? 'Paid',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF696CFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Download Button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.document_download,
                      color: Color(0xFF696CFF),
                      size: 20,
                    ),
                    onPressed: () async {
                      if (payslip.id == null) {
                        toast(language.lblInvalidPayslipId);
                        return;
                      }

                      toast(language.lblDownloadingPayslip);
                      final filePath = await payrollStore.downloadPayslipPdf(
                        payslip.id!,
                      );

                      if (filePath != null) {
                        toast(language.lblPayslipDownloadSuccess);
                      } else if (payrollStore.error != null) {
                        toast('${language.lblPayslipDownloadFailed}: ${payrollStore.error}');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
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
              Iconsax.document_text,
              size: 70,
              color: const Color(0xFF696CFF).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            language.lblNoPayslipsFound,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchController.text.isNotEmpty
                  ? language.lblNoPayslipsMatch
                  : language.lblPayslipsWillAppearMessage,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_searchController.text.isNotEmpty ||
              selectedMonth != 'All' ||
              selectedYear != DateTime.now().year.toString()) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  selectedMonth = 'All';
                });
                _applyYearFilter(DateTime.now().year.toString());
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(language.lblClearFilters),
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
    );
  }

  Widget _buildShimmerLoader(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: isDark
                      ? Colors.grey[800]!
                      : const Color(0xFFE5E7EB),
                  highlightColor: isDark
                      ? Colors.grey[700]!
                      : const Color(0xFFF9FAFB),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey[800]!
                            : const Color(0xFFE5E7EB),
                        highlightColor: isDark
                            ? Colors.grey[700]!
                            : const Color(0xFFF9FAFB),
                        child: Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey[800]!
                            : const Color(0xFFE5E7EB),
                        highlightColor: isDark
                            ? Colors.grey[700]!
                            : const Color(0xFFF9FAFB),
                        child: Container(
                          height: 14,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
