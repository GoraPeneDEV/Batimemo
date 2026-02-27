import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Loan/loan_request_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/Loan/loan_request_model.dart';
import 'Widgets/loan_request_item_widget.dart';
import 'loan_detail_screen.dart';
import 'loan_store.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final LoanStore _store = LoanStore();

  @override
  void initState() {
    super.initState();
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchLoanRequests(pageKey);
    });
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    final isDark = appStore.isDarkModeOn;
    // Track local selection that will be applied when user clicks Apply
    String? tempSelectedStatus = _store.selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      16.height,
                      Text(
                        language.lblFilters,
                        style: boldTextStyle(size: 18),
                      ),
                      24.height,
                      // Status Filter
                      DropdownButtonFormField<String>(
                        value: tempSelectedStatus,
                        decoration: InputDecoration(
                          labelText: language.lblSelectStatus,
                          prefixIcon: const Icon(Iconsax.status, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF696CFF),
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          // Add "All" option to clear filter
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              language.lblAll,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ),
                          ..._store.statuses.map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status.capitalizeFirstLetter()),
                              )),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tempSelectedStatus = value;
                          });
                        },
                      ),
                      24.height,
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Reset filters
                                _store.setSelectedStatus(null);
                                Navigator.pop(context);
                                _store.pagingController.refresh();
                                setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                language.lblReset,
                                style: boldTextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF696CFF), Color(0xFF696CFF)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Apply the selected filter
                                  _store.setSelectedStatus(tempSelectedStatus);
                                  Navigator.pop(context);
                                  _store.pagingController.refresh();
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  language.lblApply,
                                  style: boldTextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      16.height,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          highlightColor: isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header shimmer
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                // Content shimmer
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF696CFF).withValues(alpha: 0.2),
                    const Color(0xFF5457E6).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Iconsax.money_4,
                size: 60,
                color: const Color(0xFF696CFF).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language.lblNoRequests,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              language.lblYourLoanRequestsWillAppearHere,
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

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Observer(
        builder: (_) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                  : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header Section (56px)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                          language.lblLoans,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.filter, color: Colors.white),
                          tooltip: language.lblFilterByDate,
                          onPressed: () => _showFilterPopup(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                      child: Column(
                  children: [
                    // Active Filter Chips
                    Observer(
                      builder: (_) {
                        return _store.selectedStatus != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  bottom: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF696CFF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${language.lblStatus}: ${_store.selectedStatus!.capitalizeFirstLetter()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            _store.setSelectedStatus(null);
                                            _store.pagingController.refresh();
                                            setState(() {});
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
                    // Loan Requests List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            Future.sync(() => _store.pagingController.refresh()),
                        child: PagedListView<int, LoanRequestModel>(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          pagingController: _store.pagingController,
                          builderDelegate: PagedChildBuilderDelegate<LoanRequestModel>(
                            firstPageProgressIndicatorBuilder: (context) =>
                                _buildShimmerLoader(isDark),
                            newPageProgressIndicatorBuilder: (context) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF696CFF),
                                  ),
                                ),
                              ),
                            ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                _buildEmptyState(isDark),
                            itemBuilder: (context, loanRequest, index) {
                              return LoanRequestItemWidget(
                                index: index,
                                model: loanRequest,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoanDetailScreen(
                                        loanId: loanRequest.id,
                                      ),
                                    ),
                                  );
                                  _store.pagingController.refresh();
                                },
                                deleteAction: (BuildContext context) {
                                  final isDraft = loanRequest.status == 'draft';
                                  showConfirmDialogCustom(
                                    context,
                                    title: isDraft
                                        ? language.lblAreYouSureYouWantToDeleteThisDraft
                                        : language.lblAreYouSureYouWantToCancelThisRequest,
                                    dialogType: DialogType.CONFIRMATION,
                                    positiveText: language.lblYes,
                                    negativeText: language.lblNo,
                                    onAccept: (c) async {
                                      try {
                                        if (isDraft) {
                                          await _store.deleteLoanRequest(loanRequest.id);
                                        } else {
                                          await _store.cancelLoanRequest(loanRequest.id);
                                        }
                                        _store.pagingController.refresh();
                                        toast(isDraft ? language.lblDraftDeletedSuccessfully : language.lblLoanRequestCancelledSuccessfully);
                                      } catch (e) {
                                        toast('${language.lblError}: $e');
                                      }
                                    },
                                  );
                                },
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await const LoanRequestScreen().launch(context);
          _store.pagingController.refresh();
        },
        backgroundColor: const Color(0xFF696CFF),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          language.lblCreate,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
