import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../store/asset_store.dart';
import '../../models/Assets/asset_model.dart';
import '../../models/Assets/asset_assignment_model.dart';
import '../../models/Assets/asset_document_model.dart';
import '../../models/Assets/asset_maintenance_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/url_helper.dart';
import '../../main.dart';
import '../../locale/languages.dart';
import 'report_issue_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final int assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  late AssetStore _assetStore;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _assetStore = Provider.of<AssetStore>(context, listen: false);
    _tabController = TabController(length: 3, vsync: this);
    _loadAssetDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssetDetails() async {
    await _assetStore.fetchAssetDetails(widget.assetId);
  }

  void _navigateToReportIssue() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIssueScreen(
          assetId: widget.assetId,
          asset: _assetStore.currentAsset!,
        ),
      ),
    );

    if (result == true) {
      _loadAssetDetails();
    }
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
                      child: _assetStore.isLoadingDetails &&
                              _assetStore.currentAsset == null
                          ? _buildLoadingState()
                          : _assetStore.currentAsset == null
                              ? _buildErrorState()
                              : _buildContent(),
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
          Expanded(
            child: Text(
              _assetStore.currentAsset?.name ?? language.lblAssetDetails,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_assetStore.currentAsset != null) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Iconsax.warning_2, color: Colors.white),
                onPressed: _navigateToReportIssue,
                tooltip: language.lblReportIssue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    final asset = _assetStore.currentAsset!;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Hero Image/Icon
        _buildHeroImage(asset),
        const SizedBox(height: 20),
        // TabBar
        _buildTabBar(),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(asset),
              _buildResourcesTab(asset),
              _buildHistoryTab(asset),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(AssetModel asset) {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: asset.image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: UrlHelper.getFullUrl(asset.image!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Iconsax.box,
                    size: 100,
                    color: Color(0xFF696CFF),
                  ),
                ),
              )
            : const Icon(
                Iconsax.box,
                size: 100,
                color: Color(0xFF696CFF),
              ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF696CFF),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelColor: Colors.white,
            unselectedLabelColor: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                height: 40,
                child: Text(language.lblDetails),
              ),
              Tab(
                height: 40,
                child: Text(language.lblResources),
              ),
              Tab(
                height: 40,
                child: Text(language.lblHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(AssetModel asset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Observer(
        builder: (_) => Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.lblAssetInformation,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(language.lblAssetTag, asset.assetTag),
              _buildDetailRow(language.lblCategory, asset.category.name),
              if (asset.manufacturer != null)
                _buildDetailRow(language.lblManufacturer, asset.manufacturer!),
              if (asset.model != null)
                _buildDetailRow(language.lblModel, asset.model!),
              if (asset.serialNumber != null)
                _buildDetailRow(language.lblSerialNumber, asset.serialNumber!),
              _buildDetailRow(language.lblStatus, asset.statusLabel,
                  valueColor: _getStatusColor(asset.status)),
              _buildDetailRow(language.lblCondition, asset.conditionLabel,
                  valueColor: _getConditionColor(asset.condition)),
              if (asset.location != null)
                _buildDetailRow(language.lblLocation, asset.location!),
              if (asset.department != null)
                _buildDetailRow('Department', asset.department!.name),
              if (asset.purchaseDate != null)
                _buildDetailRow(language.lblPurchaseDate,
                    DateParser.formatDate(DateParser.parseApiDate(asset.purchaseDate!))),
              if (asset.warrantyExpiry != null) ...[
                _buildDetailRow(
                  language.lblWarrantyExpiry,
                  DateParser.formatDate(DateParser.parseApiDate(asset.warrantyExpiry!)),
                  valueColor: asset.isWarrantyExpiringSoon
                      ? Colors.orange
                      : (asset.isUnderWarranty ? Colors.green : Colors.red),
                ),
                if (asset.isWarrantyExpiringSoon)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.warning_2,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Warranty expires in ${asset.warrantyDaysRemaining} days',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              if (asset.assignedAt != null)
                _buildDetailRow(language.lblAssignedOn,
                    DateParser.formatDate(DateParser.parseDate(asset.assignedAt!))),
              if (asset.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  language.lblNotes,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  asset.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ??
                      (appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827)),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab(AssetModel asset) {
    return Observer(
      builder: (_) {
        // Load maintenance history when tab is first opened
        if (_assetStore.maintenanceHistory.isEmpty &&
            !_assetStore.isLoadingMaintenance) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _assetStore.fetchMaintenanceHistory(asset.id);
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issues Section
              _buildResourcesSection(
                title: language.lblIssuesAndMaintenance,
                icon: Iconsax.warning_2,
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildIssuesSection(asset),

              const SizedBox(height: 24),

              // Documents Section
              _buildResourcesSection(
                title: 'Documents',
                icon: Iconsax.document,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildDocumentsSection(asset),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourcesSection({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Observer(
      builder: (_) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesSection(AssetModel asset) {
    return Observer(
      builder: (_) {
        if (_assetStore.isLoadingMaintenance &&
            _assetStore.maintenanceHistory.isEmpty) {
          return _buildSectionLoading();
        }

        if (_assetStore.maintenanceHistory.isEmpty) {
          return _buildEmptyIssuesCard();
        }

        // Show first 3 issues
        final displayCount = _assetStore.maintenanceHistory.length > 3
            ? 3
            : _assetStore.maintenanceHistory.length;

        return Column(
          children: [
            ...List.generate(displayCount, (index) {
              return _buildMaintenanceItem(
                  _assetStore.maintenanceHistory[index]);
            }),
            if (_assetStore.maintenanceHistory.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // Switch to a full issues view or expand
                    _showAllIssues(asset);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF696CFF),
                  ),
                  child: Text(
                    'View all ${_assetStore.maintenanceHistory.length} issues',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentsSection(AssetModel asset) {
    final documents = asset.documents ?? [];

    return Observer(
      builder: (_) {
        if (documents.isEmpty) {
          return _buildEmptyDocumentsCard();
        }

        return Column(
          children: documents.map((doc) => _buildDocumentCard(doc)).toList(),
        );
      },
    );
  }

  Widget _buildSectionLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                appStore.isDarkModeOn ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
        ),
      ),
    );
  }

  Widget _buildEmptyIssuesCard() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Iconsax.info_circle,
              size: 48,
              color: appStore.isDarkModeOn
                  ? Colors.grey[600]
                  : Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              language.lblNoIssuesReported,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              language.lblReportIssuesPrompt,
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn
                    ? Colors.grey[500]
                    : const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsCard() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Iconsax.document,
              size: 48,
              color: appStore.isDarkModeOn
                  ? Colors.grey[600]
                  : Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              language.lblNoDocumentsAvailable,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllIssues(AssetModel asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Observer(
            builder: (_) => Container(
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF111827)
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: appStore.isDarkModeOn
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          language.lblAllIssuesAndMaintenance,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Issues list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _assetStore.maintenanceHistory.length +
                          (_assetStore.hasMoreMaintenance ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _assetStore.maintenanceHistory.length) {
                          // Load more
                          if (!_assetStore.isLoadingMore) {
                            _assetStore.fetchMaintenanceHistory(asset.id,
                                loadMore: true);
                          }
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF696CFF)),
                              ),
                            ),
                          );
                        }

                        return _buildMaintenanceItem(
                            _assetStore.maintenanceHistory[index]);
                      },
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

  Widget _buildDocumentCard(AssetDocumentModel document) {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDocumentTypeColor(document.documentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDocumentTypeIcon(document.documentType),
              color: _getDocumentTypeColor(document.documentType),
              size: 24,
            ),
          ),
          title: Text(
            document.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${document.documentTypeLabel} • ${document.fileSizeFormatted ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
              if (document.expiryDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 12,
                      color: document.isExpired
                          ? Colors.red
                          : (document.isExpiringSoon
                              ? Colors.orange
                              : (appStore.isDarkModeOn
                                  ? Colors.grey[500]
                                  : const Color(0xFF9CA3AF))),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${DateParser.formatDate(DateParser.parseDate(document.expiryDate!))}',
                      style: TextStyle(
                        fontSize: 11,
                        color: document.isExpired
                            ? Colors.red
                            : (document.isExpiringSoon
                                ? Colors.orange
                                : (appStore.isDarkModeOn
                                    ? Colors.grey[500]
                                    : const Color(0xFF9CA3AF))),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Iconsax.arrow_down),
            color: const Color(0xFF696CFF),
            onPressed: () => _downloadDocument(document),
          ),
        ),
      ),
    );
  }

  IconData _getDocumentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return Iconsax.receipt;
      case 'warranty':
        return Iconsax.shield_tick;
      case 'manual':
        return Iconsax.book;
      case 'photo':
        return Iconsax.gallery;
      case 'insurance':
        return Iconsax.security_safe;
      default:
        return Iconsax.document;
    }
  }

  Color _getDocumentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return Colors.blue;
      case 'warranty':
        return Colors.green;
      case 'manual':
        return Colors.purple;
      case 'photo':
        return Colors.orange;
      case 'insurance':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _downloadDocument(AssetDocumentModel document) async {
    final url = document.fullFileUrl;
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toast('Could not open document');
    }
  }

  Widget _buildEmptyDocuments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document,
            size: 80,
            color: appStore.isDarkModeOn
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No documents available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(AssetModel asset) {
    // Mock history - replace with actual API call when available
    final history = <AssetAssignmentModel>[];

    return Observer(
      builder: (_) => history.isEmpty
          ? _buildEmptyHistory()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final assignment = history[index];
                return _buildHistoryItem(assignment, index == history.length - 1);
              },
            ),
    );
  }

  Widget _buildHistoryItem(AssetAssignmentModel assignment, bool isLast) {
    return Observer(
      builder: (_) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: assignment.isCurrentlyAssigned
                      ? const Color(0xFF696CFF)
                      : (appStore.isDarkModeOn
                          ? Colors.grey[600]
                          : Colors.grey[400]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appStore.isDarkModeOn
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]
                      : const Color(0xFFE5E7EB),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        appStore.isDarkModeOn ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        assignment.isCurrentlyAssigned ? 'Assigned' : 'Returned',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: assignment.isCurrentlyAssigned
                              ? const Color(0xFF696CFF)
                              : (appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280)),
                        ),
                      ),
                      if (assignment.isCurrentlyAssigned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
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
                        DateParser.formatDate(DateParser.parseDate(assignment.assignedAt)),
                        style: TextStyle(
                          fontSize: 12,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      if (assignment.returnedAt != null) ...[
                        Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[500]
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          DateParser.formatDate(DateParser.parseDate(assignment.returnedAt!)),
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (assignment.conditionAtAssignment != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Condition: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[500]
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          assignment.conditionAtAssignment!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (assignment.conditionAtReturn != null) ...[
                          Text(
                            ' → ',
                            style: TextStyle(
                              fontSize: 12,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[500]
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            assignment.conditionAtReturn!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
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
            'No history available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
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

  Widget _buildMaintenanceItem(AssetMaintenanceModel maintenance) {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMaintenanceTypeColor(maintenance.maintenanceType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    maintenance.maintenanceTypeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getMaintenanceTypeColor(maintenance.maintenanceType),
                    ),
                  ),
                ),
                if (maintenance.performedAt != null)
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        maintenance.performedAt!,
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
            ),
            const SizedBox(height: 12),
            // Details
            Text(
              maintenance.details,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            // Cost and provider
            if (maintenance.cost != null || maintenance.provider != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (maintenance.cost != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.dollar_square,
                          size: 14,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[500]
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${maintenance.cost!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  if (maintenance.provider != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.building,
                          size: 14,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[500]
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          maintenance.provider!,
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
              ),
            ],
            // Completed by
            if (maintenance.completedBy != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Iconsax.user,
                    size: 14,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[500]
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reported by ${maintenance.completedBy!.name}',
                    style: TextStyle(
                      fontSize: 11,
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
    );
  }

  Color _getMaintenanceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'repair':
        return Colors.orange;
      case 'upgrade':
        return Colors.blue;
      case 'cleaning':
        return Colors.green;
      case 'calibration':
        return Colors.purple;
      case 'scheduled_maintenance':
        return Colors.teal;
      case 'inspection':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
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
            'Failed to load asset details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAssetDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
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
