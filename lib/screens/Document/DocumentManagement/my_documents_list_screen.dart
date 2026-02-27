import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import '../../../store/document_management_store.dart';
import '../../../utils/app_colors.dart';
import '../../../models/Document/my_document_model.dart';
import 'my_document_detail_screen.dart';

/// My Documents List Screen
/// Displays employee's personal documents with filtering and search
class MyDocumentsListScreen extends StatefulWidget {
  final String? initialStatus;
  final String? initialExpiryStatus;
  final int? initialCategoryId;

  const MyDocumentsListScreen({
    super.key,
    this.initialStatus,
    this.initialExpiryStatus,
    this.initialCategoryId,
  });

  @override
  State<MyDocumentsListScreen> createState() => _MyDocumentsListScreenState();
}

class _MyDocumentsListScreenState extends State<MyDocumentsListScreen> {
  final DocumentManagementStore _store = DocumentManagementStore();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedExpiryStatus;
  int? _selectedCategoryId;
  bool _isLoadingMore = false;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedExpiryStatus = widget.initialExpiryStatus;
    _selectedCategoryId = widget.initialCategoryId;

    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _store.fetchDocumentCategories(),
      _store.fetchMyDocuments(
        status: _selectedStatus,
        expiryStatus: _selectedExpiryStatus,
        categoryId: _selectedCategoryId,
      ),
    ]);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _store.documentCurrentPage < _store.documentTotalPages) {
      _loadMoreDocuments();
    }
  }

  Future<void> _loadMoreDocuments() async {
    setState(() => _isLoadingMore = true);
    await _store.fetchMyDocuments(
      status: _selectedStatus,
      expiryStatus: _selectedExpiryStatus,
      categoryId: _selectedCategoryId,
      search: _searchController.text,
      page: _store.documentCurrentPage + 1,
    );
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshDocuments() async {
    await _store.fetchMyDocuments(
      status: _selectedStatus,
      expiryStatus: _selectedExpiryStatus,
      categoryId: _selectedCategoryId,
      search: _searchController.text,
      page: 1,
    );
  }

  void _applyFilters() {
    _store.fetchMyDocuments(
      status: _selectedStatus,
      expiryStatus: _selectedExpiryStatus,
      categoryId: _selectedCategoryId,
      search: _searchController.text,
      page: 1,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedExpiryStatus = null;
      _selectedCategoryId = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch && _searchController.text.isNotEmpty) {
        _searchController.clear();
        _applyFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        language.lblMyDocuments,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.search_normal, color: Colors.white),
                      onPressed: _toggleSearchBar,
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.filter, color: Colors.white),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Area with rounded top corners
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
                    // Search Bar (collapsible)
                    if (_showSearch) _buildSearchBar(),

                    // Active Filters Chips
                    Observer(
                      builder: (_) => _buildActiveFiltersChips(),
                    ),

                    // Documents List
                    Expanded(
                      child: Observer(
                        builder: (_) => _buildDocumentsList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = appStore.isDarkModeOn;

    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: language.lblSearchByTitleOrNumber,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF696CFF),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _applyFilters();
            }
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final hasFilters = _selectedStatus != null ||
        _selectedExpiryStatus != null ||
        _selectedCategoryId != null;

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedStatus != null)
            _buildFilterChip(
              'Status: ${_selectedStatus!.capitalizeFirstLetter()}',
              () => setState(() => _selectedStatus = null),
            ),
          if (_selectedExpiryStatus != null)
            _buildFilterChip(
              'Expiry: ${_selectedExpiryStatus!.replaceAll('_', ' ').capitalizeFirstLetter()}',
              () => setState(() => _selectedExpiryStatus = null),
            ),
          if (_selectedCategoryId != null)
            _buildFilterChip(
              'Category: ${_getCategoryName(_selectedCategoryId!)}',
              () => setState(() => _selectedCategoryId = null),
            ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Iconsax.close_circle, size: 16, color: Color(0xFF696CFF)),
            label: Text(
              language.lblClearAll,
              style: const TextStyle(color: Color(0xFF696CFF), fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF696CFF),
        ),
      ),
      deleteIcon: const Icon(
        Iconsax.close_circle,
        size: 16,
        color: Color(0xFF696CFF),
      ),
      onDeleted: () {
        onDelete();
        _applyFilters();
      },
      backgroundColor: const Color(0xFF696CFF).withOpacity(0.1),
      side: const BorderSide(
        color: Color(0xFF696CFF),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_store.isLoadingDocuments && _store.myDocuments.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (_store.myDocuments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshDocuments,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _store.myDocuments.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _store.myDocuments.length) {
            return _buildLoadingMoreIndicator();
          }
          return _buildDocumentCard(_store.myDocuments[index]);
        },
      ),
    );
  }

  Widget _buildDocumentCard(MyDocumentModel document) {
    final isDark = appStore.isDarkModeOn;

    return InkWell(
      onTap: () => _navigateToDetail(document),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getExpiryBorderColor(document.expiryInfo),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Gradient Category Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF696CFF).withOpacity(0.2),
                        const Color(0xFF5457E6).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(document.category),
                    color: const Color(0xFF696CFF),
                    size: 24,
                  ),
                ),
                12.width,
                // Title & Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title ?? language.lblNA,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(
                        document.category ?? language.lblNA,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Verification Status Badge
                _buildStatusBadge(document.verificationStatus ?? 'pending'),
              ],
            ),
            12.height,

            // Document Details
            if (document.number != null && document.number!.isNotEmpty) ...[
              _buildDetailRow(
                Iconsax.document_text,
                language.lblNumber,
                document.number!,
              ),
              8.height,
            ],

            // Expiry Information
            if (document.expiryInfo != null) ...[
              _buildExpiryRow(document.expiryInfo!),
              8.height,
            ],

            // Issue & Expiry Dates
            Row(
              children: [
                if (document.issueDate != null)
                  Expanded(
                    child: _buildDetailRow(
                      Iconsax.calendar_add,
                      language.lblIssued,
                      document.issueDate!,
                    ),
                  ),
                if (document.expiryDate != null)
                  Expanded(
                    child: _buildDetailRow(
                      Iconsax.calendar_remove,
                      language.lblExpires,
                      document.expiryDate!,
                    ),
                  ),
              ],
            ),

            // Action Button
            if (document.canDownload ?? false) ...[
              12.height,
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _downloadDocument(document),
                  icon: const Icon(
                    Iconsax.document_download,
                    size: 16,
                    color: Color(0xFF696CFF),
                  ),
                  label: Text(
                    language.lblDownload,
                    style: const TextStyle(
                      color: Color(0xFF696CFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF696CFF).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF696CFF),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'verified':
        color = Colors.green;
        icon = Iconsax.verify;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Iconsax.close_circle;
        break;
      default:
        color = Colors.orange;
        icon = Iconsax.clock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          4.width,
          Text(
            status.capitalizeFirstLetter(),
            style: boldTextStyle(size: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryRow(DocumentExpiryInfo expiryInfo) {
    Color color;
    IconData icon;

    if (expiryInfo.isExpired) {
      color = Colors.red;
      icon = Iconsax.danger;
    } else if (expiryInfo.isExpiringSoon) {
      color = Colors.orange;
      icon = Iconsax.warning_2;
    } else {
      color = Colors.green;
      icon = Iconsax.shield_tick;
    }

    String message;
    if (expiryInfo.isExpired) {
      message = '${language.lblExpired} ${expiryInfo.daysUntilExpiry?.abs() ?? 0} days ago';
    } else if (expiryInfo.isExpiringSoon) {
      message = '${language.lblExpires} in ${expiryInfo.daysUntilExpiry} days';
    } else {
      message = language.lblValid;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          8.width,
          Expanded(
            child: Text(
              message,
              style: boldTextStyle(size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isDark = appStore.isDarkModeOn;

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        6.width,
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    final isDark = appStore.isDarkModeOn;

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
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    12.width,
                    // Title placeholder
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          8.height,
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge placeholder
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                16.height,
                // Details placeholder
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                8.height,
                Container(
                  height: 12,
                  width: 150,
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

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    final isDark = appStore.isDarkModeOn;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF696CFF).withOpacity(0.2),
                  const Color(0xFF5457E6).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Iconsax.folder_open,
              size: 60,
              color: const Color(0xFF696CFF).withOpacity(0.7),
            ),
          ),
          24.height,
          Text(
            language.lblNoDocuments,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          8.height,
          Text(
            language.lblDocumentsWillAppearHere,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryBorderColor(DocumentExpiryInfo? expiryInfo) {
    final isDark = appStore.isDarkModeOn;
    final defaultColor = isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB);

    if (expiryInfo == null) return defaultColor;
    if (expiryInfo.isExpired) return Colors.red.withOpacity(0.5);
    if (expiryInfo.isExpiringSoon) return Colors.orange.withOpacity(0.5);
    return defaultColor;
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Iconsax.document;
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('passport')) return Iconsax.airplane;
    if (categoryLower.contains('id') || categoryLower.contains('identity')) {
      return Iconsax.card;
    }
    if (categoryLower.contains('license') || categoryLower.contains('driving')) {
      return Iconsax.driving;
    }
    if (categoryLower.contains('certificate')) return Iconsax.medal_star;
    if (categoryLower.contains('visa')) return Iconsax.ticket;

    return Iconsax.document;
  }

  String _getCategoryName(int categoryId) {
    try {
      final category = _store.documentCategories.firstWhere(
        (cat) => cat.id == categoryId,
      );
      return category.name ?? language.lblUnknown;
    } catch (e) {
      return language.lblUnknown;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    final isDark = appStore.isDarkModeOn;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language.lblFilters,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                16.height,

                // Verification Status Filter
                Text(
                  language.lblVerificationStatus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                8.height,
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChoiceChip(
                      language.lblAll,
                      _selectedStatus == null,
                      () => setModalState(() => _selectedStatus = null),
                    ),
                    _buildFilterChoiceChip(
                      language.lblVerified,
                      _selectedStatus == 'verified',
                      () => setModalState(() => _selectedStatus = 'verified'),
                    ),
                    _buildFilterChoiceChip(
                      language.lblPending,
                      _selectedStatus == 'pending',
                      () => setModalState(() => _selectedStatus = 'pending'),
                    ),
                    _buildFilterChoiceChip(
                      language.lblRejected,
                      _selectedStatus == 'rejected',
                      () => setModalState(() => _selectedStatus = 'rejected'),
                    ),
                  ],
                ),
                16.height,

                // Expiry Status Filter
                Text(
                  language.lblExpiryStatus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                8.height,
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChoiceChip(
                      language.lblAll,
                      _selectedExpiryStatus == null,
                      () => setModalState(() => _selectedExpiryStatus = null),
                    ),
                    _buildFilterChoiceChip(
                      language.lblValid,
                      _selectedExpiryStatus == 'valid',
                      () => setModalState(() => _selectedExpiryStatus = 'valid'),
                    ),
                    _buildFilterChoiceChip(
                      language.lblExpiringSoon,
                      _selectedExpiryStatus == 'expiring_soon',
                      () => setModalState(() => _selectedExpiryStatus = 'expiring_soon'),
                    ),
                    _buildFilterChoiceChip(
                      language.lblExpired,
                      _selectedExpiryStatus == 'expired',
                      () => setModalState(() => _selectedExpiryStatus = 'expired'),
                    ),
                  ],
                ),
                16.height,

                // Category Filter
                Observer(
                  builder: (_) {
                    if (_store.documentCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.lblCategory,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        8.height,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChoiceChip(
                              language.lblAll,
                              _selectedCategoryId == null,
                              () => setModalState(() => _selectedCategoryId = null),
                            ),
                            ..._store.documentCategories.map((category) {
                              return _buildFilterChoiceChip(
                                category.name ?? language.lblUnknown,
                                _selectedCategoryId == category.id,
                                () => setModalState(() => _selectedCategoryId = category.id),
                              );
                            }).toList(),
                          ],
                        ),
                        16.height,
                      ],
                    );
                  },
                ),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Update parent state
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF696CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      language.lblApplyFilters,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = appStore.isDarkModeOn;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF696CFF).withOpacity(0.2),
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? const Color(0xFF696CFF)
            : (isDark ? Colors.grey[400] : Colors.grey[700]),
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF696CFF)
            : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _navigateToDetail(MyDocumentModel document) {
    MyDocumentDetailScreen(documentId: document.id!).launch(context);
  }

  Future<void> _downloadDocument(MyDocumentModel document) async {
    try {
      toast(language.lblDownloadingDocument);
      final downloadUrl = await _store.getDocumentDownloadUrl(document.id!);

      if (downloadUrl != null && downloadUrl['file_url'] != null) {
        final url = downloadUrl['file_url'];
        final fileName = downloadUrl['file_name'] ?? 'document';

        // Open the URL in browser for download
        await launchUrl(
          Uri.parse(url!),
          mode: LaunchMode.externalApplication,
        );

        toast('${language.lblDownload}: $fileName');
      } else {
        toast(language.lblDocumentFileNotAvailable);
      }
    } catch (e) {
      toast(language.lblFailedToDownloadDocument);
    }
  }
}
