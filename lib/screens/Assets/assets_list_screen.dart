import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../store/asset_store.dart';
import '../../models/Assets/asset_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/url_helper.dart';
import '../../main.dart';
import '../../locale/languages.dart';
import 'asset_detail_screen.dart';
import 'asset_qr_scanner_screen.dart';

class AssetsListScreen extends StatefulWidget {
  const AssetsListScreen({super.key});

  @override
  State<AssetsListScreen> createState() => _AssetsListScreenState();
}

class _AssetsListScreenState extends State<AssetsListScreen> {
  late AssetStore _assetStore;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Assigned',
    'In Repair',
    'Damaged',
  ];

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'All':
        return language.lblAll;
      case 'Assigned':
        return language.lblAssigned;
      case 'In Repair':
        return language.lblInRepair;
      case 'Damaged':
        return language.lblDamaged;
      default:
        return filter;
    }
  }

  bool _isLoadingMore = false;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _assetStore = Provider.of<AssetStore>(context, listen: false);
    _loadAssets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadAssets() async {
    String? statusFilter;
    if (_selectedFilter != 'All') {
      statusFilter = _selectedFilter.toLowerCase().replaceAll(' ', '_');
    }

    _assetStore.filterByStatus(statusFilter);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _assetStore.isLoading) return;
    if (_assetStore.assetList.length >= _assetStore.totalAssetsCount) return;

    setState(() => _isLoadingMore = true);
    await _assetStore.fetchAssignedAssets(loadMore: true);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _onRefresh() async {
    await _loadAssets();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim().isEmpty ? null : value.trim().toLowerCase();
    });
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
    _loadAssets();
  }

  void _navigateToDetail(AssetModel asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(assetId: asset.id),
      ),
    );
  }

  void _navigateToQRScanner() async {
    final result = await Navigator.push<AssetModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AssetQRScannerScreen(),
      ),
    );

    if (result != null) {
      _navigateToDetail(result);
    }
  }

  List<AssetModel> _getFilteredAssets() {
    var assets = _assetStore.assetList.toList();

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      assets = assets
          .where((asset) =>
              asset.name.toLowerCase().contains(_searchQuery!) ||
              asset.assetTag.toLowerCase().contains(_searchQuery!) ||
              asset.category.name.toLowerCase().contains(_searchQuery!) ||
              (asset.manufacturer?.toLowerCase().contains(_searchQuery!) ??
                  false) ||
              (asset.model?.toLowerCase().contains(_searchQuery!) ?? false))
          .toList();
    }

    return assets;
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
                          // Search Bar
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          // Filter Chips
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                          // Assets List
                          Expanded(
                            child: _buildAssetsList(),
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
          // Back Button
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
            language.lblMyAssets,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // QR Scan Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.scan, color: Colors.white),
              onPressed: _navigateToQRScanner,
              tooltip: language.lblScanQRCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                    appStore.isDarkModeOn ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(
              fontSize: 14,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: language.lblSearchAssets,
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              prefixIcon: const Icon(
                Iconsax.search_normal,
                color: Color(0xFF696CFF),
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
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
                label: Text(_getFilterLabel(filter)),
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

  Widget _buildAssetsList() {
    return Observer(
      builder: (_) {
        if (_assetStore.isLoading && _assetStore.assetList.isEmpty) {
          return _buildShimmerLoading();
        }

        if (_assetStore.errorMessage != null && _assetStore.assetList.isEmpty) {
          return _buildErrorState();
        }

        final filteredAssets = _getFilteredAssets();

        if (filteredAssets.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF696CFF),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: filteredAssets.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredAssets.length) {
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

              final asset = filteredAssets[index];
              return _buildAssetCard(asset);
            },
          ),
        );
      },
    );
  }

  Widget _buildAssetCard(AssetModel asset) {
    return Observer(
      builder: (_) => GestureDetector(
        onTap: () => _navigateToDetail(asset),
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
                      child: asset.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: UrlHelper.getFullUrl(asset.image!),
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
                            asset.name,
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
                            'Tag: ${asset.assetTag}',
                            style: TextStyle(
                              fontSize: 13,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.category.name,
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
                        color: _getStatusColor(asset.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(asset.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        asset.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(asset.status),
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
                    // Condition Badge
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.status,
                            size: 14,
                            color: _getConditionColor(asset.condition),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            asset.conditionLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getConditionColor(asset.condition),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Manufacturer and Model
                    if (asset.manufacturer != null || asset.model != null)
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${asset.manufacturer ?? ''} ${asset.model ?? ''}'
                              .trim(),
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                if (asset.assignedAt != null) ...[
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
                      Text(
                        '${language.lblAssigned}: ${DateParser.formatDate(DateParser.parseDate(asset.assignedAt!))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[500]
                              : const Color(0xFF9CA3AF),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.green;
      case 'available':
        return Colors.blue;
      case 'in_repair':
        return Colors.orange;
      case 'damaged':
        return Colors.red;
      case 'lost':
        return Colors.purple;
      case 'disposed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.deepOrange;
      case 'broken':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
            Iconsax.box,
            size: 80,
            color: appStore.isDarkModeOn
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery != null
                ? language.lblNoAssetsFound
                : language.lblNoAssetsAssigned,
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
            _searchQuery != null
                ? language.lblTryAdjustingYourSearch
                : language.lblNoAssetsAssigned,
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
            language.lblFailedToLoadAssets,
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
            onPressed: _loadAssets,
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
