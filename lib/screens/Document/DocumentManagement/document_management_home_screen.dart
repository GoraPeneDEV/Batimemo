import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Document/document_request.dart';
import 'package:shimmer/shimmer.dart';
import '../../../main.dart';
import '../../../store/document_management_store.dart';
import '../../../utils/app_colors.dart';
import 'my_documents_list_screen.dart';

/// Document Management Home Screen
/// Main hub for document requests and my documents
class DocumentManagementHomeScreen extends StatefulWidget {
  const DocumentManagementHomeScreen({super.key});

  @override
  State<DocumentManagementHomeScreen> createState() =>
      _DocumentManagementHomeScreenState();
}

class _DocumentManagementHomeScreenState
    extends State<DocumentManagementHomeScreen> {
  final DocumentManagementStore _store = DocumentManagementStore();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _store.fetchRequestStatistics(),
      _store.fetchDocumentStatistics(),
      _store.fetchExpiringDocuments(),
      _store.fetchExpiredDocuments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkModeOn;

    return Scaffold(
      body: Column(
        children: [
          // Modern Gradient Header (56px)
          Container(
            height: 56 + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
              ),
            ),
            child: Padding(
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
                      language.lblDocumentManagement,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.refresh, color: Colors.white),
                    onPressed: _loadData,
                  ),
                ],
              ),
            ),
          ),

          // Content Area with Rounded Top
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        _buildQuickActions(),
                        20.height,

                        // Document Requests Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader(language.lblRequestDocument),
                            TextButton(
                              onPressed: () => _navigateToRequests(),
                              child: Text(language.lblViewAll, style: boldTextStyle(size: 12, color: opPrimaryColor)),
                            ),
                          ],
                        ),
                        12.height,
                        Observer(
                          builder: (_) => _buildRequestStatistics(),
                        ),
                        20.height,

                        // My Documents Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader(language.lblMyDocuments),
                            TextButton(
                              onPressed: () => _navigateToMyDocuments(),
                              child: Text(language.lblViewAll, style: boldTextStyle(size: 12, color: opPrimaryColor)),
                            ),
                          ],
                        ),
                        12.height,
                        Observer(
                          builder: (_) => _buildDocumentStatistics(),
                        ),
                        20.height,

                        // Alerts Section
                        Observer(
                          builder: (_) => _buildAlertsSection(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: boldTextStyle(size: 16, weight: FontWeight.w600),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Iconsax.folder_2,
            label: language.lblMyDocuments,
            color: Colors.blue,
            onTap: () => _navigateToMyDocuments(),
          ),
        ),
        12.width,
        Expanded(
          child: _buildQuickActionButton(
            icon: Iconsax.document_text,
            label: language.lblRequestDocument,
            color: Colors.green,
            onTap: () => _navigateToRequests(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = appStore.isDarkModeOn;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            12.height,
            Text(
              label,
              style: boldTextStyle(size: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStatistics() {
    if (_store.isLoadingRequestStats) {
      return _buildLoadingSkeleton();
    }

    final stats = _store.requestStatistics;
    if (stats == null) {
      return _buildErrorCard(language.lblFailedToLoadStatistics);
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: language.lblTotal,
                value: stats.total.toString(),
                icon: Iconsax.document,
                color: Colors.blue,
                onTap: () => _navigateToRequests(),
              ),
            ),
            12.width,
            Expanded(
              child: _buildStatCard(
                title: language.lblPending,
                value: stats.pending.toString(),
                icon: Iconsax.clock,
                color: Colors.orange,
                onTap: () => _navigateToRequests(status: 'pending'),
              ),
            ),
          ],
        ),
        12.height,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: language.lblGenerated,
                value: stats.generated.toString(),
                icon: Iconsax.tick_circle,
                color: Colors.green,
                onTap: () => _navigateToRequests(status: 'generated'),
              ),
            ),
            12.width,
            Expanded(
              child: _buildStatCard(
                title: language.lblRejected,
                value: stats.rejected.toString(),
                icon: Iconsax.close_circle,
                color: Colors.red,
                onTap: () => _navigateToRequests(status: 'rejected'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentStatistics() {
    if (_store.isLoadingDocumentStats) {
      return _buildLoadingSkeleton();
    }

    final stats = _store.documentStatistics;
    if (stats == null) {
      return _buildErrorCard(language.lblFailedToLoadStatistics);
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: language.lblTotal,
                value: stats.total.toString(),
                icon: Iconsax.folder_2,
                color: Colors.blue,
                onTap: () => _navigateToMyDocuments(),
              ),
            ),
            12.width,
            Expanded(
              child: _buildStatCard(
                title: language.lblVerified,
                value: stats.verified.toString(),
                icon: Iconsax.verify,
                color: Colors.green,
                onTap: () => _navigateToMyDocuments(status: 'verified'),
              ),
            ),
          ],
        ),
        12.height,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: language.lblPending,
                value: stats.pending.toString(),
                icon: Iconsax.clock,
                color: Colors.orange,
                onTap: () => _navigateToMyDocuments(status: 'pending'),
              ),
            ),
            12.width,
            Expanded(
              child: _buildStatCard(
                title: language.lblValid,
                value: stats.valid.toString(),
                icon: Iconsax.shield_tick,
                color: Colors.teal,
                onTap: () => _navigateToMyDocuments(expiryStatus: 'valid'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    final expiringCount = _store.expiringDocumentsCount;
    final expiredCount = _store.expiredDocumentsCount;

    if (expiringCount == 0 && expiredCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(language.lblAlerts),
        12.height,
        if (expiredCount > 0)
          _buildAlertCard(
            title: language.lblExpiredDocuments,
            message: '$expiredCount document(s) have expired',
            icon: Iconsax.danger,
            color: Colors.red,
            onTap: () => _navigateToMyDocuments(expiryStatus: 'expired'),
          ),
        if (expiredCount > 0 && expiringCount > 0) 12.height,
        if (expiringCount > 0)
          _buildAlertCard(
            title: language.lblExpiringSoon,
            message: '$expiringCount document(s) expiring within 30 days',
            icon: Iconsax.warning_2,
            color: Colors.orange,
            onTap: () => _navigateToMyDocuments(expiryStatus: 'expiring_soon'),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = appStore.isDarkModeOn;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            12.height,
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF696CFF),
              ),
            ),
            4.height,
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = appStore.isDarkModeOn;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: boldTextStyle(size: 14)),
                  4.height,
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            12.width,
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
        12.height,
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            12.width,
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    final isDark = appStore.isDarkModeOn;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
      highlightColor: isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            12.height,
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            8.height,
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    final isDark = appStore.isDarkModeOn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withOpacity(0.8), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.danger, color: Colors.white, size: 20),
          ),
          12.width,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRequests({String? status}) {
    DocumentRequestScreen().launch(context);
  }

  void _navigateToMyDocuments({String? status, String? expiryStatus}) {
    MyDocumentsListScreen(
      initialStatus: status,
      initialExpiryStatus: expiryStatus,
    ).launch(context);
  }
}
