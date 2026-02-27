import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/dio_api/repositories/hr_policies_repository.dart';
import '../../main.dart';
import '../../models/HRPolicies/policy_detail_model.dart';
import '../../utils/app_widgets.dart';
import '../../utils/date_parser.dart';
import 'hr_policies_store.dart';

class HRPolicyDetailScreen extends StatefulWidget {
  final int policyId;
  final HRPoliciesStore store;

  const HRPolicyDetailScreen({
    super.key,
    required this.policyId,
    required this.store,
  });

  @override
  State<HRPolicyDetailScreen> createState() => _HRPolicyDetailScreenState();
}

class _HRPolicyDetailScreenState extends State<HRPolicyDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();
  final HRPoliciesRepository _hrPoliciesRepository = HRPoliciesRepository();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isAcknowledging = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPolicyDetails();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadPolicyDetails() async {
    await widget.store.fetchPolicyDetails(widget.policyId);
  }

  String _formatDisplayDate(String dateStr) {
    try {
      // Try parsing ISO format first (YYYY-MM-DD or YYYY-MM-DD HH:mm:ss from API)
      DateTime date;
      if (dateStr.contains('-') && dateStr.split('-')[0].length == 4) {
        // ISO format from API
        date = DateTime.parse(dateStr);
      } else {
        // DD-MM-YYYY format
        date = DateParser.parseDate(dateStr);
      }
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'company policies': const Color(0xFF3B82F6),
      'hr policies': const Color(0xFF10B981),
      'it policies': const Color(0xFF8B5CF6),
      'finance policies': const Color(0xFFF59E0B),
      'security policies': const Color(0xFFEF4444),
    };
    return colors[categoryName.toLowerCase()] ?? const Color(0xFF696CFF);
  }

  IconData _getCategoryIcon(String categoryName) {
    final icons = {
      'company policies': Iconsax.building,
      'hr policies': Iconsax.people,
      'it policies': Iconsax.monitor,
      'finance policies': Iconsax.dollar_circle,
      'security policies': Iconsax.shield_tick,
    };
    return icons[categoryName.toLowerCase()] ?? Iconsax.document_text;
  }

  void _showAcknowledgeDialog() {
    showDialog(
      context: context,
      builder: (context) => Observer(
        builder: (_) => AlertDialog(
          backgroundColor: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            language.lblAcknowledgePolicy,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblAcknowledgePolicyConfirm,
                  style: TextStyle(
                    fontSize: 14,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _commentsController,
                  label: language.lblComments,
                  hintText: language.lblAddComments,
                  prefixIcon: Iconsax.message_text,
                  maxLines: 3,
                  maxLength: 1000,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isAcknowledging
                  ? null
                  : () {
                      _commentsController.clear();
                      Navigator.pop(context);
                    },
              child: Text(
                language.lblCancel,
                style: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: _isAcknowledging ? null : _acknowledgePolicy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAcknowledging
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        language.lblAcknowledge,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acknowledgePolicy() async {
    setState(() => _isAcknowledging = true);

    try {
      final policy = widget.store.currentPolicyDetail;
      if (policy == null) return;

      final result = await widget.store.acknowledgePolicy(
        policy.acknowledgmentId,
        _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      );

      if (result != null) {
        toast(language.lblPolicyAcknowledged);
        Navigator.pop(context); // Close dialog
        Navigator.pop(context, true); // Close screen with success
      } else {
        toast(widget.store.errorMessage ?? language.lblFailedToAcknowledgePolicy);
      }
    } catch (e) {
      toast('Error: ${e.toString()}');
    } finally {
      setState(() => _isAcknowledging = false);
    }
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  Future<void> _downloadPolicyDocument() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final policy = widget.store.currentPolicyDetail;
      if (policy == null) return;

      // Check and request storage permission
      if (Platform.isAndroid) {
        PermissionStatus status;

        // For Android 13+ (API 33+), we don't need storage permission for Downloads
        if (await _getAndroidVersion() >= 33) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted) {
          toast(language.lblStoragePermissionRequired);
          setState(() => _isDownloading = false);
          return;
        }
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find downloads directory');
      }

      // Generate sanitized filename from policy title and document name
      String sanitizedPolicyTitle = policy.title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .trim();

      String documentName = policy.document.name ?? 'policy_document.pdf';

      final fileName = '${sanitizedPolicyTitle}_$documentName';
      final savePath = '${directory.path}/$fileName';

      // Download the document
      await _hrPoliciesRepository.downloadPolicyDocument(
        policy.policyId,
        savePath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() => _isDownloading = false);

      // Show success message
      if (!mounted) return;

      // Determine user-friendly directory name
      String locationText = Platform.isAndroid
          ? language.lblDownloadsFolder
          : language.lblDocumentsFolder;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${language.lblDocumentDownloadedTo} $locationText'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: language.lblOpen,
            textColor: Colors.white,
            onPressed: () => _openDocument(savePath),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isDownloading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${language.lblFailedToDownloadDocument}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _openDocument(String path) async {
    try {
      final result = await OpenFilex.open(path);

      // Handle result types
      if (result.type == ResultType.noAppToOpen) {
        toast('No app found to open this file. Please install a file viewer.');
      } else if (result.type == ResultType.fileNotFound) {
        toast(language.lblFileNotFound);
      } else if (result.type == ResultType.error) {
        toast('${language.lblFailedToOpenPDF}: ${result.message}');
      }
      // ResultType.done means success - no action needed
    } catch (e) {
      toast('${language.lblFailedToOpenPDF}: $e');
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
                _buildHeader(),
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
                      child: widget.store.isLoading
                          ? _buildLoadingState()
                          : widget.store.errorMessage != null
                          ? _buildErrorState()
                          : widget.store.currentPolicyDetail == null
                          ? _buildEmptyState()
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
              icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              language.lblPolicyDetails,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF696CFF)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.close_circle, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              language.lblError,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.store.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPolicyDetails,
              icon: const Icon(Iconsax.refresh),
              label: Text(language.lblRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF696CFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        language.lblPolicyNotFound,
        style: TextStyle(
          fontSize: 16,
          color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final policy = widget.store.currentPolicyDetail!;
    final isDark = appStore.isDarkModeOn;
    final isAcknowledged = policy.acknowledgment.status == 'acknowledged';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: isAcknowledged ? 16 : 96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(policy, isDark),
              const SizedBox(height: 16),
              _buildPolicyInfoCard(policy, isDark),
              const SizedBox(height: 16),
              _buildPolicyContentCard(policy, isDark),
              if (policy.document.exists) ...[
                const SizedBox(height: 16),
                _buildDocumentCard(policy, isDark),
              ],
              if (isAcknowledged) ...[
                const SizedBox(height: 16),
                _buildAcknowledgmentInfoCard(policy, isDark),
              ],
            ],
          ),
        ),
        if (!isAcknowledged) _buildBottomActionBar(policy),
      ],
    );
  }

  Widget _buildHeaderCard(PolicyDetailModel policy, bool isDark) {
    final categoryColor = _getCategoryColor(policy.category.name);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            policy.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Category chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(policy.category.name),
                      size: 16,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      policy.category.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Version badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'v${policy.version}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              // Status badge
              _buildStatusBadge(
                policy.acknowledgment.status,
                policy.acknowledgment.statusLabel,
              ),
              // Mandatory badge
              if (policy.isMandatory)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        language.lblMandatory,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'acknowledged':
        backgroundColor = const Color(0xFF10B981).withOpacity(0.15);
        textColor = const Color(0xFF10B981);
        break;
      case 'overdue':
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.15);
        textColor = const Color(0xFFEF4444);
        break;
      default:
        backgroundColor = const Color(0xFFF59E0B).withOpacity(0.15);
        textColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPolicyInfoCard(PolicyDetailModel policy, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.lblPolicyInformation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Iconsax.calendar,
            language.lblEffectiveDatePolicy,
            _formatDisplayDate(policy.effectiveDate),
            isDark,
          ),
          if (policy.expiryDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Iconsax.calendar_remove,
              language.lblExpiryDatePolicy,
              _formatDisplayDate(policy.expiryDate!),
              isDark,
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            Iconsax.calendar_tick,
            language.lblAssignedDate,
            _formatDisplayDate(policy.acknowledgment.assignedDate),
            isDark,
          ),
          if (policy.acknowledgment.deadlineDate != null) ...[
            const SizedBox(height: 12),
            _buildDeadlineRow(policy, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF696CFF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineRow(PolicyDetailModel policy, bool isDark) {
    final isOverdue = policy.acknowledgment.isOverdue;
    final daysUntilDeadline = policy.acknowledgment.daysUntilDeadline ?? 0;
    final deadlineText = isOverdue
        ? '${daysUntilDeadline.abs().toInt()} days overdue'
        : '${daysUntilDeadline.toInt()} days left';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFEF4444).withOpacity(0.1)
            : const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Iconsax.warning_2 : Iconsax.clock,
            size: 20,
            color: isOverdue
                ? const Color(0xFFEF4444)
                : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblDeadline,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatDisplayDate(policy.acknowledgment.deadlineDate!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        deadlineText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyContentCard(PolicyDetailModel policy, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.document_text,
                size: 20,
                color: Color(0xFF696CFF),
              ),
              const SizedBox(width: 8),
              Text(
                language.lblPolicyContent,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (policy.description != null && policy.description!.isNotEmpty) ...[
            Text(
              policy.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
          ],
          // Render HTML content
          if (policy.content != null && policy.content!.isNotEmpty)
            Html(
              data: policy.content!,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14),
                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                  lineHeight: const LineHeight(1.6),
                ),
                "p": Style(margin: Margins.only(bottom: 12)),
                "h1": Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 16, bottom: 12),
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                "h2": Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 14, bottom: 10),
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                "h3": Style(
                  fontSize: FontSize(16),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 12, bottom: 8),
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                "ul": Style(margin: Margins.only(bottom: 12, left: 16)),
                "ol": Style(margin: Margins.only(bottom: 12, left: 16)),
                "li": Style(margin: Margins.only(bottom: 6)),
                "strong": Style(fontWeight: FontWeight.bold),
                "em": Style(fontStyle: FontStyle.italic),
                "a": Style(
                  color: const Color(0xFF696CFF),
                  textDecoration: TextDecoration.underline,
                ),
                "blockquote": Style(
                  margin: Margins.only(left: 16, top: 8, bottom: 8),
                  padding: HtmlPaddings.only(left: 12),
                  border: Border(
                    left: BorderSide(
                      color: isDark
                          ? Colors.grey[600]!
                          : const Color(0xFFE5E7EB),
                      width: 4,
                    ),
                  ),
                ),
                "code": Style(
                  backgroundColor: isDark
                      ? Colors.grey[800]
                      : const Color(0xFFF3F4F6),
                  padding: HtmlPaddings.symmetric(horizontal: 6, vertical: 2),
                  fontFamily: 'monospace',
                  fontSize: FontSize(13),
                ),
                "pre": Style(
                  backgroundColor: isDark
                      ? Colors.grey[800]
                      : const Color(0xFFF3F4F6),
                  padding: HtmlPaddings.all(12),
                  margin: Margins.only(bottom: 12),
                  fontFamily: 'monospace',
                  fontSize: FontSize(13),
                ),
              },
            )
          else
            Text(
              language.lblNoContentAvailable,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(PolicyDetailModel policy, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.document, size: 20, color: Color(0xFF696CFF)),
              const SizedBox(width: 8),
              Text(
                language.lblAttachment,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF696CFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF696CFF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696CFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.document_text,
                    size: 24,
                    color: Color(0xFF696CFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.document.name ?? 'Document',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policy.document.formattedSize ??
                            _formatFileSize(policy.document.size),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: _isDownloading
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                          ),
                    color: _isDownloading ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: _isDownloading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                              value: _downloadProgress > 0
                                  ? _downloadProgress
                                  : null,
                            ),
                          )
                        : const Icon(Iconsax.document_download, size: 20),
                    color: Colors.white,
                    onPressed: _isDownloading ? null : _downloadPolicyDocument,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgmentInfoCard(PolicyDetailModel policy, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.tick_circle,
                size: 24,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                language.lblAcknowledgmentDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Iconsax.calendar_tick,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '${language.lblAcknowledgedOn}: ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                _formatDisplayDate(policy.acknowledgment.acknowledgedDate!),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          if (policy.acknowledgment.comments != null &&
              policy.acknowledgment.comments!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.grey[700] : const Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Text(
              language.lblYourComments,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              policy.acknowledgment.comments!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(PolicyDetailModel policy) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  (appStore.isDarkModeOn
                          ? const Color(0xFF1F2937)
                          : Colors.white)
                      .withOpacity(0.9),
              border: Border(
                top: BorderSide(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]!
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _showAcknowledgeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        language.lblAcknowledgePolicy,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
