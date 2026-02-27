import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../api/dio_api/repositories/disciplinary_repository.dart';
import '../../models/disciplinary/warning_model.dart';
import '../../models/disciplinary/warning_appeal_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/string_extensions.dart';
import '../../utils/url_helper.dart';
import 'appeal_form_screen.dart';
import 'appeal_details_screen.dart';

class WarningDetailsScreen extends StatefulWidget {
  final int warningId;

  const WarningDetailsScreen({super.key, required this.warningId});

  @override
  State<WarningDetailsScreen> createState() => _WarningDetailsScreenState();
}

class _WarningDetailsScreenState extends State<WarningDetailsScreen> {
  final DisciplinaryRepository _repository = DisciplinaryRepository();

  Warning? _warning;
  List<WarningAppeal> _appeals = [];
  bool _isLoading = false;
  String? _error;
  bool _isAcknowledging = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repository.getWarningDetails(widget.warningId);
      if (result != null) {
        setState(() {
          _warning = result['warning'] as Warning?;
          _appeals = result['appeals'] as List<WarningAppeal>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acknowledgeWarning() async {
    final TextEditingController commentsController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.tick_circle, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.lblAcknowledgeWarning,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.lblAcknowledgeConfirmation,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              maxLines: 3,
              style: TextStyle(
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                hintText: language.lblOptionalComments,
                hintStyle: TextStyle(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[500]
                      : const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: appStore.isDarkModeOn
                    ? const Color(0xFF111827)
                    : const Color(0xFFF9FAFB),
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
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              language.lblCancel,
              style: TextStyle(
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              language.lblAcknowledge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isAcknowledging = true);

      try {
        await _repository.acknowledgeWarning(
          widget.warningId,
          comments: commentsController.text.trim().isNotEmpty
              ? commentsController.text.trim()
              : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblWarningAcknowledgedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${language.lblFailedToAcknowledgeWarning}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isAcknowledging = false);
      }
    }
  }

  Future<void> _openAttachment(String url) async {
    try {
      final fullUrl = UrlHelper.getFullUrl(url);
      final uri = Uri.parse(fullUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblCannotOpenAttachment),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${language.lblErrorOpeningAttachment}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'issued') {
      return Colors.orange;
    } else if (statusLower == 'acknowledged') {
      return Colors.blue;
    } else if (statusLower == 'appealed') {
      return const Color(0xFF9333EA); // Purple
    } else if (statusLower == 'expired') {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'verbal':
        return Colors.blue;
      case 'written':
        return Colors.orange;
      case 'final':
        return Colors.red;
      case 'termination':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  Color _getAppealStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
      case 'hearing_scheduled':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (iconColor ?? const Color(0xFF696CFF)).withOpacity(0.2),
                  (iconColor ?? const Color(0xFF696CFF)).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? const Color(0xFF696CFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
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
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF696CFF),
                  ),
                  const SizedBox(width: 8),
                ],
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
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: appStore.isDarkModeOn
            ? Colors.grey[800]!
            : const Color(0xFFE5E7EB),
        highlightColor: appStore.isDarkModeOn
            ? Colors.grey[700]!
            : const Color(0xFFF9FAFB),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 200,
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? Colors.grey[800]
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          language.lblWarningDetails,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                      color: appStore.isDarkModeOn
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F4F6),
                      child: _buildContent(),
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

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.close_circle,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblErrorLoadingWarning,
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
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Iconsax.refresh, color: Colors.white),
                label: Text(
                  language.lblRetry,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF696CFF),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_warning == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Header Card
                _buildSectionCard(
                  language.lblWarningInformation,
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language.lblWarningNumber,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[400]
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _warning!.warningNumber,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: appStore.isDarkModeOn
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_warning!.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _warning!.statusLabel.titleCase,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(_warning!.warningType.severity)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 20,
                              color: _getSeverityColor(_warning!.warningType.severity),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _warning!.warningType.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _getSeverityColor(
                                          _warning!.warningType.severity),
                                    ),
                                  ),
                                  if (_warning!.warningType.description != null)
                                    Text(
                                      _warning!.warningType.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getSeverityColor(
                                                _warning!.warningType.severity)
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Iconsax.calendar,
                        language.lblIssueDate,
                        DateParser.parseDate(_warning!.issueDate) != null
                            ? DateParser.formatDate(
                                DateParser.parseDate(_warning!.issueDate)!)
                            : _warning!.issueDate,
                      ),
                      _buildInfoRow(
                        Iconsax.calendar_tick,
                        language.lblEffectiveDate,
                        DateParser.parseDate(_warning!.effectiveDate) != null
                            ? DateParser.formatDate(
                                DateParser.parseDate(_warning!.effectiveDate)!)
                            : _warning!.effectiveDate,
                      ),
                      if (_warning!.expiryDate != null)
                        _buildInfoRow(
                          Iconsax.calendar_remove,
                          language.lblExpiryDate,
                          DateParser.parseDate(_warning!.expiryDate!) != null
                              ? DateParser.formatDate(
                                  DateParser.parseDate(_warning!.expiryDate!)!)
                              : _warning!.expiryDate!,
                          iconColor: Colors.orange,
                        ),
                      _buildInfoRow(
                        Iconsax.user,
                        language.lblIssuedBy,
                        _warning!.issuedBy.name,
                      ),
                    ],
                  ),
                  icon: Iconsax.document,
                ),

                // Subject Card
                _buildSectionCard(
                  language.lblSubject,
                  Text(
                    _warning!.subject,
                    style: TextStyle(
                      fontSize: 15,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                  icon: Iconsax.message_text,
                ),

                // Reason Card
                _buildSectionCard(
                  language.lblReason,
                  Text(
                    _warning!.reason,
                    style: TextStyle(
                      fontSize: 15,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                  icon: Iconsax.info_circle,
                ),

                // Description Card
                if (_warning!.description != null) ...[
                  _buildSectionCard(
                    language.lblDescription,
                    Text(
                      _warning!.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    icon: Iconsax.document_text,
                  ),
                ],

                // Improvement Required Card
                if (_warning!.improvementRequired != null) ...[
                  _buildSectionCard(
                    language.lblImprovementRequired,
                    Text(
                      _warning!.improvementRequired!,
                      style: TextStyle(
                        fontSize: 15,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    icon: Iconsax.trend_up,
                  ),
                ],

                // Consequences Card
                if (_warning!.consequences != null) ...[
                  _buildSectionCard(
                    language.lblConsequences,
                    Text(
                      _warning!.consequences!,
                      style: TextStyle(
                        fontSize: 15,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    icon: Iconsax.danger,
                  ),
                ],

                // Attachments Card
                if (_warning!.attachments.isNotEmpty) ...[
                  _buildSectionCard(
                    language.lblAttachments,
                    Column(
                      children: _warning!.attachments.map((attachment) {
                        return InkWell(
                          onTap: () => _openAttachment(attachment),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[700]!
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.document,
                                  color: Color(0xFF696CFF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    attachment.split('/').last,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appStore.isDarkModeOn
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  size: 16,
                                  color: Color(0xFF696CFF),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    icon: Iconsax.attach_circle,
                  ),
                ],

                // Appeal Deadline Warning
                if (_warning!.canBeAppealed && _warning!.appealDeadline != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.clock,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.lblAppealDeadline,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${language.lblAppealDeadlineMessage} ${DateParser.parseDate(_warning!.appealDeadline!) != null ? DateParser.formatDate(DateParser.parseDate(_warning!.appealDeadline!)!) : _warning!.appealDeadline!}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appStore.isDarkModeOn
                                      ? Colors.grey[400]
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Appeals Section
                if (_appeals.isNotEmpty) ...[
                  _buildSectionCard(
                    '${language.lblAppealsCount} (${_appeals.length})',
                    Column(
                      children: _appeals.map((appeal) {
                        final statusColor = _getAppealStatusColor(appeal.status);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppealDetailsScreen(appealId: appeal.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appStore.isDarkModeOn
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appeal.appealNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: appStore.isDarkModeOn
                                            ? Colors.white
                                            : const Color(0xFF111827),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        appeal.statusLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${language.lblFiledOn}: ${appeal.appealDate}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[400]
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                if (appeal.reviewedAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${language.lblReviewedDate}: ${appeal.reviewedAt}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                                if (appeal.outcome != null && (appeal.outcomeLabel?.isNotEmpty ?? false)) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Iconsax.document_text,
                                        size: 16,
                                        color: Color(0xFF696CFF),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${language.lblOutcome}: ${appeal.outcomeLabel}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF696CFF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    icon: Iconsax.document_text_1,
                  ),
                ],

                const SizedBox(height: 80), // Space for action buttons
              ],
            ),
          ),
        ),

        // Action Buttons
        if (_warning!.canBeAcknowledged || _warning!.canBeAppealed) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (_warning!.canBeAcknowledged) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isAcknowledging ? null : _acknowledgeWarning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isAcknowledging
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                language.lblAcknowledge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    if (_warning!.canBeAppealed) const SizedBox(width: 12),
                  ],
                  if (_warning!.canBeAppealed) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppealFormScreen(warning: _warning!),
                            ),
                          ).then((_) => _loadData());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF696CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          language.lblFileAppeal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
