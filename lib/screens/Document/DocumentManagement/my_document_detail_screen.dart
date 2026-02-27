import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import '../../../api/dio_api/repositories/my_documents_repository.dart';
import '../../../models/Document/my_document_model.dart';
import '../../../utils/app_colors.dart';

/// My Document Detail Screen
/// Displays full details of a personal document
class MyDocumentDetailScreen extends StatefulWidget {
  final int documentId;

  const MyDocumentDetailScreen({super.key, required this.documentId});

  @override
  State<MyDocumentDetailScreen> createState() => _MyDocumentDetailScreenState();
}

class _MyDocumentDetailScreenState extends State<MyDocumentDetailScreen> {
  final MyDocumentsRepository _repository = MyDocumentsRepository();
  MyDocumentModel? _document;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final document = await _repository.getDocument(widget.documentId);
      setState(() {
        _document = document;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      toast('Failed to load document: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final isDark = appStore.isDarkModeOn;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
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
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            language.lblDocumentDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (_document?.canDownload ?? false)
                          IconButton(
                            icon: const Icon(
                              Iconsax.document_download,
                              color: Colors.white,
                            ),
                            onPressed: _isDownloading
                                ? null
                                : _downloadDocument,
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
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        child: _buildBody(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildLoadingSkeleton(isDark);
    }

    if (_hasError || _document == null) {
      return _buildErrorState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadDocument,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Preview Card
            _buildPreviewCard(isDark),
            const SizedBox(height: 16),

            // Document Information Card
            _buildInformationCard(isDark),
            const SizedBox(height: 16),

            // Verification Status Card
            _buildVerificationCard(isDark),
            const SizedBox(height: 16),

            // Expiry Information Card
            if (_document!.expiryInfo != null) ...[
              _buildExpiryCard(isDark),
              const SizedBox(height: 16),
            ],

            // Issuing Information Card
            if (_hasIssuingInfo()) ...[
              _buildIssuingInfoCard(isDark),
              const SizedBox(height: 16),
            ],

            // Notes Card
            if (_document!.notes != null && _document!.notes!.isNotEmpty) ...[
              _buildNotesCard(isDark),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (_document!.canDownload ?? false) ...[
              _buildActionButtons(isDark),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          // Gradient Icon Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(_document!.category),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // Document Name
          Text(
            _document!.title ?? language.lblNA,
            style: boldTextStyle(size: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _document!.category ?? language.lblNA,
            style: secondaryTextStyle(size: 13),
            textAlign: TextAlign.center,
          ),

          // Document Number Badge
          if (_document!.number != null && _document!.number!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF696CFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF696CFF).withOpacity(0.3),
                ),
              ),
              child: Text(
                _document!.number!,
                style: boldTextStyle(size: 12, color: const Color(0xFF696CFF)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInformationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header with gradient icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.info_circle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(language.lblDocumentInformation, style: boldTextStyle(size: 16)),
            ],
          ),
          const SizedBox(height: 16),

          // Information rows
          if (_document!.title != null)
            _buildInfoRow(
              isDark,
              Iconsax.document,
              language.lblFileName,
              _document!.title!,
            ),
          if (_document!.category != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.document_text,
              language.lblFileType,
              _document!.category!,
            ),
          ],
          if (_document!.fileSize != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.archive,
              language.lblFileSize,
              _document!.fileSize!,
            ),
          ],
          if (_document!.issueDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.calendar,
              language.lblIssueDate,
              _document!.issueDate!,
            ),
          ],
          if (_document!.expiryDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.calendar,
              language.lblExpiryDate,
              _document!.expiryDate!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: secondaryTextStyle(size: 12)),
              const SizedBox(height: 2),
              Text(value, style: primaryTextStyle(size: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard(bool isDark) {
    final status = _document!.verificationStatus ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Iconsax.verify;
        statusText = language.lblVerified;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Iconsax.close_circle;
        statusText = language.lblRejected;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Iconsax.clock;
        statusText = language.lblPendingVerification;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header with gradient icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(language.lblVerificationStatus, style: boldTextStyle(size: 16)),
            ],
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: boldTextStyle(size: 12, color: statusColor),
                ),
              ],
            ),
          ),

          if (_document!.verificationNotes != null &&
              _document!.verificationNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Text('${language.lblNotes}:', style: boldTextStyle(size: 13)),
            const SizedBox(height: 4),
            Text(
              _document!.verificationNotes!,
              style: secondaryTextStyle(size: 13),
            ),
          ],
          if (_document!.verifiedBy != null) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.user,
              language.lblVerifiedBy,
              _document!.verifiedBy!,
            ),
            if (_document!.verifiedDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                isDark,
                Iconsax.calendar,
                language.lblVerifiedOn,
                _document!.verifiedDate!,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExpiryCard(bool isDark) {
    final expiryInfo = _document!.expiryInfo!;
    Color color;
    IconData icon;
    String title;
    String message;

    if (expiryInfo.isExpired) {
      color = Colors.red;
      icon = Iconsax.danger;
      title = language.lblDocumentExpired;
      message =
          '${language.lblDocumentExpired} ${expiryInfo.daysUntilExpiry?.abs() ?? 0} days ago. ${language.lblPleaseTryAgain}';
    } else if (expiryInfo.isExpiringSoon) {
      color = Colors.orange;
      icon = Iconsax.warning_2;
      title = language.lblExpiringSoon;
      message =
          '${language.lblExpires} in ${expiryInfo.daysUntilExpiry} days. Consider renewing it soon.';
    } else {
      color = Colors.green;
      icon = Iconsax.shield_tick;
      title = language.lblDocumentValid;
      message = 'This document is currently ${language.lblValid.toLowerCase()}.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: boldTextStyle(size: 16, color: color)),
                const SizedBox(height: 4),
                Text(message, style: secondaryTextStyle(size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuingInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header with gradient icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.building,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(language.lblIssuingInformation, style: boldTextStyle(size: 16)),
            ],
          ),
          const SizedBox(height: 16),

          if (_document!.issuingAuthority != null)
            _buildInfoRow(
              isDark,
              Iconsax.building,
              language.lblIssuingAuthority,
              _document!.issuingAuthority!,
            ),
          if (_document!.issuingCountry != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.global,
              language.lblCountry,
              _document!.issuingCountry!,
            ),
          ],
          if (_document!.issuingPlace != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              isDark,
              Iconsax.location,
              language.lblPlace,
              _document!.issuingPlace!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header with gradient icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.note_text,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(language.lblAdditionalNotes, style: boldTextStyle(size: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_document!.notes!, style: secondaryTextStyle(size: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Download Button (Primary)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isDownloading ? null : _downloadDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.document_download, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        language.lblDownloadDocument,
                        style: boldTextStyle(size: 15, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Preview Card Skeleton
          _buildShimmerCard(isDark, 200),
          const SizedBox(height: 16),

          // Information Card Skeleton
          _buildShimmerCard(isDark, 250),
          const SizedBox(height: 16),

          // Other Cards Skeleton
          _buildShimmerCard(isDark, 150),
          const SizedBox(height: 16),
          _buildShimmerCard(isDark, 150),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark, double height) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
      highlightColor: isDark ? Colors.grey[700]! : const Color(0xFFF9FAFB),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.red.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Iconsax.document_cloud, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            language.lblFailedToLoadStatistics,
            style: boldTextStyle(size: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(language.lblPleaseTryAgain, style: secondaryTextStyle(size: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF696CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                Text(
                  language.lblRetry,
                  style: boldTextStyle(size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Iconsax.document;
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('passport')) return Iconsax.airplane;
    if (categoryLower.contains('id') || categoryLower.contains('identity')) {
      return Iconsax.card;
    }
    if (categoryLower.contains('license') ||
        categoryLower.contains('driving')) {
      return Iconsax.driving;
    }
    if (categoryLower.contains('certificate')) return Iconsax.medal_star;
    if (categoryLower.contains('visa')) return Iconsax.ticket;

    return Iconsax.document;
  }

  bool _hasIssuingInfo() {
    return _document!.issuingAuthority != null ||
        _document!.issuingCountry != null ||
        _document!.issuingPlace != null;
  }

  Future<void> _downloadDocument() async {
    setState(() => _isDownloading = true);

    try {
      toast(language.lblPreparingDownload);
      final downloadUrl = await _repository.getDownloadUrl(widget.documentId);

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
    } finally {
      setState(() => _isDownloading = false);
    }
  }
}
