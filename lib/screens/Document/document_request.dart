import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/Utils/app_widgets.dart';
import 'package:open_core_hr/screens/Document/create_document_request_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/Document/document_request_model.dart';
import 'document_store.dart';
import 'widget/document_request_item_widget.dart';

class DocumentRequestScreen extends StatefulWidget {
  const DocumentRequestScreen({super.key});

  @override
  State<DocumentRequestScreen> createState() => _DocumentRequestScreenState();
}

class _DocumentRequestScreenState extends State<DocumentRequestScreen> {
  final _store = DocumentStore();

  @override
  void initState() {
    super.initState();
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchDocumentRequests(pageKey);
    });
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    final isDark = appStore.isDarkModeOn;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  12.height,
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  20.height,
                  Text(
                    language.lblFilters,
                    style: boldTextStyle(size: 18),
                  ),
                  24.height,

                  // Date Filter
                  TextField(
                    controller: _store.dateFilterController,
                    decoration: InputDecoration(
                      labelText: language.lblFilterByDate,
                      prefixIcon: const Icon(Iconsax.calendar, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _store.dateFilterController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
                  20.height,

                  // Status Filter
                  Observer(
                    builder: (_) => DropdownButtonFormField<String>(
                      initialValue: _store.selectedStatus,
                      decoration: InputDecoration(
                        labelText: language.lblSelectStatus,
                        prefixIcon: const Icon(Iconsax.status, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
                  24.height,

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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            language.lblReset,
                            style: boldTextStyle(color: Colors.red, size: 15),
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
                            onPressed: () {
                              Navigator.pop(context);
                              _store.dateFilter = _store.dateFilterController.text;
                              _store.pagingController.refresh();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              language.lblApply,
                              style: boldTextStyle(color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    12.width,
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
                          8.height,
                          Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                16.height,
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
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
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.document,
              size: 60,
              color: const Color(0xFF696CFF).withValues(alpha: 0.7),
            ),
          ),
          24.height,
          Text(
            language.lblNoDocumentRequestsFound,
            style: boldTextStyle(size: 20),
          ),
          8.height,
          Text(
            language.lblEnterRemarksOrReason,
            style: secondaryTextStyle(size: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      body: Column(
        children: [
          // Modern Header
          Container(
            height: 56 + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 20,
              right: 20,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
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
                16.width,
                Expanded(
                  child: Text(
                    language.lblDocumentRequests,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.filter, color: Colors.white),
                  tooltip: language.lblFilter,
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
                color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                child: Observer(
                  builder: (_) => _store.isDownloadLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(language.lblDownloadingFilePleaseWait),
                              loadingWidgetMaker(),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Active Filter Chips
                            Observer(
                              builder: (_) {
                                return (_store.selectedStatus != null ||
                                        _store.dateFilter != '')
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            if (_store.selectedStatus != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF696CFF),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${language.lblStatus}: ${_store.selectedStatus}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    6.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        _store.selectedStatus = null;
                                                        _store.pagingController
                                                            .refresh();
                                                        setState(() {});
                                                      },
                                                      child: const Icon(
                                                        Icons.close,
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
                                                    horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF696CFF),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${language.lblDate}: ${_store.dateFilter}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    6.width,
                                                    GestureDetector(
                                                      onTap: () {
                                                        _store.dateFilterController
                                                            .clear();
                                                        _store.dateFilter = '';
                                                        _store.pagingController
                                                            .refresh();
                                                        setState(() {});
                                                      },
                                                      child: const Icon(
                                                        Icons.close,
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

                            // Document Requests List
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => Future.sync(
                                    () => _store.pagingController.refresh()),
                                child: PagedListView<int, DocumentRequestModel>(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  pagingController: _store.pagingController,
                                  builderDelegate:
                                      PagedChildBuilderDelegate<DocumentRequestModel>(
                                    firstPageProgressIndicatorBuilder: (context) =>
                                        _buildShimmerLoader(isDark),
                                    noItemsFoundIndicatorBuilder: (context) =>
                                        _buildEmptyState(isDark),
                                    itemBuilder:
                                        (context, documentRequest, index) {
                                      return DocumentRequestItemWidget(
                                        index: index,
                                        model: documentRequest,
                                        cancelAction: (BuildContext context) {
                                          showConfirmDialogCustom(
                                            context,
                                            title: language
                                                .lblAreYouSureYouWantToCancelThisRequest,
                                            dialogType: DialogType.CONFIRMATION,
                                            positiveText: language.lblYes,
                                            negativeText: language.lblNo,
                                            onAccept: (c) async {
                                              await _store
                                                  .cancelDocumentRequest(
                                                      documentRequest.id!);
                                              _store.pagingController.refresh();
                                            },
                                          );
                                        },
                                        downloadAction: (BuildContext context) {
                                          _store.getDocumentFileUrl(
                                              documentRequest.id!);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF696CFF),
        onPressed: () async {
          await const CreateDocumentRequestScreen().launch(context);
          _store.pagingController.refresh();
        },
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
