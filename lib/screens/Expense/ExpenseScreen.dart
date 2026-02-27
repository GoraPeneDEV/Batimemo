import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Expense/expense_create_screen.dart';
import 'package:open_core_hr/utils/app_widgets.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/Expense/expense_request_model.dart';
import 'ExpenseStore.dart';
import 'Widget/expense_item_widget.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseStore _store = ExpenseStore();

  @override
  void initState() {
    super.initState();
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchExpenseRequests(pageKey);
    });
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF1F2937)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[700]
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  language.lblFilters,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
                20.height,
                // Date Filter
                TextField(
                  controller: _store.dateFilterController,
                  style: TextStyle(
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    labelText: language.lblFilterByDate,
                    labelStyle: TextStyle(
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                    prefixIcon: Icon(
                      Iconsax.calendar,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                      onPressed: () {
                        _store.dateFilterController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn
                            ? Colors.grey[700]!
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn
                            ? Colors.grey[700]!
                            : const Color(0xFFE5E7EB),
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
                  readOnly: true,
                  onTap: () async {
                    hideKeyboard(context);
                    var result = await showDatePicker(
                      context: context,
                      confirmText: language.lblOk,
                      initialDate: _store.dateFilterController.text.isEmptyOrNull
                          ? DateTime.now()
                          : formDateFormatter
                              .parse(_store.dateFilterController.text),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (result != null) {
                      _store.dateFilterController.text =
                          formDateFormatter.format(result);
                    }
                  },
                ),
                16.height,
                // Status Filter
                Observer(
                  builder: (_) => DropdownButtonFormField<String>(
                    value: _store.selectedStatus,
                    style: TextStyle(
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                    dropdownColor: appStore.isDarkModeOn
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    decoration: InputDecoration(
                      labelText: language.lblSelectStatus,
                      labelStyle: TextStyle(
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                      prefixIcon: Icon(
                        Iconsax.status,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appStore.isDarkModeOn
                              ? Colors.grey[700]!
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appStore.isDarkModeOn
                              ? Colors.grey[700]!
                              : const Color(0xFFE5E7EB),
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
                    items: _store.statuses
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status.capitalizeFirstLetter()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _store.selectedStatus = value;
                    },
                  ),
                ),
                20.height,
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Clear all filters
                          _store.dateFilterController.clear();
                          _store.selectedStatus = null;
                          Navigator.pop(context);
                          _store.pagingController.refresh();
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          shape: buildButtonCorner(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          language.lblReset,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: buildButtonCorner(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _store.dateFilter = _store.dateFilterController.text;
                            _store.pagingController.refresh();
                            setState(() {});
                          },
                          child: Text(
                            language.lblApply,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                8.height,
              ],
            ),
          ),
        );
      },
    );
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
                // Header Section
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language.lblExpenseManagement,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.filter, color: Colors.white),
                        tooltip: language.lblFilterByDate,
                        onPressed: () => _showFilterPopup(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F4F6),
                      child: Column(
                        children: [
                          Observer(
                            builder: (_) {
                              return (_store.selectedStatus != null ||
                                      _store.dateFilter != '')
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (_store.selectedStatus != null)
                                            Container(
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
                                                    '${language.lblStatus}: ${_store.selectedStatus}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _store.selectedStatus = null;
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
                                          if (_store.dateFilter != '')
                                            Container(
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
                                                    '${language.lblDate}: ${_store.dateFilter}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _store.dateFilterController.clear();
                                                      _store.dateFilter = '';
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
                                        ],
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                          // Expense Requests List
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => Future.sync(
                                  () => _store.pagingController.refresh()),
                              child: PagedListView<int, ExpenseRequestModel>(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                pagingController: _store.pagingController,
                                builderDelegate:
                                    PagedChildBuilderDelegate<ExpenseRequestModel>(
                                  firstPageProgressIndicatorBuilder: (context) =>
                                      _buildLoadingSkeleton(),
                                  noItemsFoundIndicatorBuilder: (context) =>
                                      _buildEmptyState(appStore.isDarkModeOn),
                                  itemBuilder: (context, expenseRequest, index) {
                                    return ExpenseItemWidget(
                                      index: index,
                                      model: expenseRequest,
                                      deleteAction: (BuildContext context) {
                                        showConfirmDialogCustom(
                                          context,
                                          title:
                                              language.lblConfirmCancelExpense,
                                          dialogType: DialogType.CONFIRMATION,
                                          positiveText: language.lblYes,
                                          negativeText: language.lblNo,
                                          onAccept: (c) async {
                                            await _store.cancelExpense(
                                                expenseRequest.id!);
                                            _store.pagingController.refresh();
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
        backgroundColor: const Color(0xFF696CFF),
        onPressed: () async {
          await const ExpenseCreateScreen().launch(context);
          _store.pagingController.refresh();
        },
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          language.lblNewExpense,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
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
                Iconsax.money_2,
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
              language.lblYourExpenseRequestsWillAppearHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? Colors.grey[800]!
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: appStore.isDarkModeOn
            ? Colors.grey[800]!
            : const Color(0xFFE5E7EB),
        highlightColor: appStore.isDarkModeOn
            ? Colors.grey[700]!
            : const Color(0xFFF9FAFB),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with expense type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Icon placeholder
                      _buildShimmerCircle(size: 40),
                      const SizedBox(width: 12),
                      // Expense type
                      _buildShimmerBox(width: 100, height: 16),
                    ],
                  ),
                  // Status badge
                  _buildShimmerBox(width: 70, height: 24, radius: 12),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              _buildShimmerBox(width: double.infinity, height: 1, radius: 0),
              const SizedBox(height: 12),
              // Description
              _buildShimmerBox(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _buildShimmerBox(width: 180, height: 14),
              const SizedBox(height: 16),
              // Footer row with amount and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(width: 60, height: 12),
                      const SizedBox(height: 6),
                      _buildShimmerBox(width: 90, height: 18),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildShimmerBox(width: 50, height: 12),
                      const SizedBox(height: 6),
                      _buildShimmerBox(width: 80, height: 14),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? Colors.grey[800]
            : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmerCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? Colors.grey[800]
            : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
    );
  }
}
