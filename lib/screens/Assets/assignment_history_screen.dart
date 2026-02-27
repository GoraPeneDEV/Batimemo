import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../store/asset_store.dart';
import '../../models/Assets/asset_assignment_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/url_helper.dart';
import '../../main.dart';
import 'asset_detail_screen.dart';

class AssignmentHistoryScreen extends StatefulWidget {
  const AssignmentHistoryScreen({super.key});

  @override
  State<AssignmentHistoryScreen> createState() =>
      _AssignmentHistoryScreenState();
}

class _AssignmentHistoryScreenState extends State<AssignmentHistoryScreen> {
  late AssetStore _assetStore;
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All';
  List<String> get _filterOptions => [
    language.lblAll,
    language.lblActive,
    language.lblReturned,
  ];

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _assetStore = Provider.of<AssetStore>(context, listen: false);
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadHistory() async {
    await _assetStore.fetchAssignmentHistory();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _assetStore.isLoading) return;
    if (_assetStore.assignmentHistory.length >=
        _assetStore.totalHistoryCount) return;

    setState(() => _isLoadingMore = true);
    await _assetStore.fetchAssignmentHistory(loadMore: true);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh() async {
    await _loadHistory();
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    // Note: Filter logic would need to be implemented in the store or locally
    _loadHistory();
  }

  List<AssetAssignmentModel> _getFilteredHistory() {
    var history = _assetStore.assignmentHistory.toList();

    if (_selectedFilter == language.lblActive) {
      history = history.where((h) => h.isCurrentlyAssigned).toList();
    } else if (_selectedFilter == language.lblReturned) {
      history = history.where((h) => !h.isCurrentlyAssigned).toList();
    }

    return history;
  }

  void _navigateToAssetDetail(int assetId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(assetId: assetId),
      ),
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
                _buildHeader(),

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
                          const SizedBox(height: 20),
                          // Filter Chips
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          // History List
                          Expanded(
                            child: _buildHistoryList(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            language.lblAssignmentHistory,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return Observer(
            builder: (_) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => _onFilterChanged(filter),
                backgroundColor: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                selectedColor: const Color(0xFF696CFF),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827)),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF696CFF)
                        : (appStore.isDarkModeOn
                            ? Colors.grey[700]!
                            : const Color(0xFFE5E7EB)),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    return Observer(
      builder: (_) {
        if (_assetStore.isLoading && _assetStore.assignmentHistory.isEmpty) {
          return _buildShimmerLoading();
        }

        if (_assetStore.errorMessage != null &&
            _assetStore.assignmentHistory.isEmpty) {
          return _buildErrorState();
        }

        final filteredHistory = _getFilteredHistory();

        if (filteredHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF696CFF),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: filteredHistory.length +
                (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredHistory.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
                    ),
                  ),
                );
              }

              final assignment = filteredHistory[index];
              return _buildAssignmentCard(assignment);
            },
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(AssetAssignmentModel assignment) {
    return Observer(
      builder: (_) => GestureDetector(
        onTap: () => _navigateToAssetDetail(assignment.assetId),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                    appStore.isDarkModeOn ? 0.3 : 0.04),
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
                Row(
                  children: [
                    // Asset Image/Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF696CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: assignment.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl:
                                    UrlHelper.getFullUrl(assignment.image!),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF696CFF)),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Iconsax.box,
                                  color: Color(0xFF696CFF),
                                  size: 28,
                                ),
                              ),
                            )
                          : const Icon(
                              Iconsax.box,
                              color: Color(0xFF696CFF),
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Asset Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.assetName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appStore.isDarkModeOn
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tag: ${assignment.assetTag}',
                            style: TextStyle(
                              fontSize: 13,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[500]
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: assignment.isCurrentlyAssigned
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: assignment.isCurrentlyAssigned
                              ? Colors.green
                              : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        assignment.isCurrentlyAssigned ? language.lblActive : language.lblReturned,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: assignment.isCurrentlyAssigned
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : const Color(0xFFE5E7EB),
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 14,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[500]
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${language.lblAssigned}: ${DateParser.formatDate(DateParser.parseDate(assignment.assignedAt))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                if (assignment.returnedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${language.lblReturned}: ${DateParser.formatDate(DateParser.parseDate(assignment.returnedAt!))}',
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${language.lblDuration}: ${assignment.formattedDuration}',
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : Colors.grey[300]!,
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : Colors.grey[100]!,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.clock,
            size: 80,
            color: appStore.isDarkModeOn
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            language.lblNoHistoryFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language.lblNoAssignmentHistory,
            style: TextStyle(
              fontSize: 14,
              color: appStore.isDarkModeOn
                  ? Colors.grey[500]
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 80,
            color: appStore.isDarkModeOn
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            language.lblFailedToLoadHistory,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _assetStore.errorMessage ?? language.lblSomethingWentWrong,
            style: TextStyle(
              fontSize: 14,
              color: appStore.isDarkModeOn
                  ? Colors.grey[500]
                  : const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              language.lblRetry,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
