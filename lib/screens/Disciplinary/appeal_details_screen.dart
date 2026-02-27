import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../api/dio_api/repositories/disciplinary_repository.dart';
import '../../models/disciplinary/warning_appeal_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/string_extensions.dart';
import '../../utils/url_helper.dart';

class AppealDetailsScreen extends StatefulWidget {
  final int appealId;

  const AppealDetailsScreen({super.key, required this.appealId});

  @override
  State<AppealDetailsScreen> createState() => _AppealDetailsScreenState();
}

class _AppealDetailsScreenState extends State<AppealDetailsScreen> {
  final DisciplinaryRepository _repository = DisciplinaryRepository();

  WarningAppeal? _appeal;
  bool _isLoading = false;
  String? _error;
  bool _isWithdrawing = false;

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
      final appeal = await _repository.getAppealDetails(widget.appealId);
      setState(() {
        _appeal = appeal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _withdrawAppeal() async {
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
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.warning_2, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.lblWithdrawAppeal,
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
        content: Text(
          language.lblWithdrawAppealConfirmation,
          style: TextStyle(
            fontSize: 14,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
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
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              language.lblYesWithdraw,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isWithdrawing = true);

      try {
        await _repository.withdrawAppeal(widget.appealId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblAppealWithdrawnSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${language.lblFailedToWithdrawAppeal}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isWithdrawing = false);
      }
    }
  }

  Future<void> _openDocument(String path) async {
    try {
      final fullUrl = UrlHelper.getFullUrl(path);
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.lblCouldNotOpenDocument),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${language.lblErrorOpeningDocument}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending') {
      return Colors.orange;
    } else if (statusLower == 'under_review') {
      return Colors.blue;
    } else if (statusLower == 'approved') {
      return Colors.green;
    } else if (statusLower == 'rejected') {
      return Colors.red;
    } else if (statusLower == 'withdrawn') {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  Color _getOutcomeColor(String? outcome) {
    if (outcome == null) return Colors.grey;
    final outcomeLower = outcome.toLowerCase();
    if (outcomeLower.contains('revoked')) {
      return Colors.green;
    } else if (outcomeLower.contains('reduced')) {
      return Colors.blue;
    } else if (outcomeLower.contains('upheld')) {
      return Colors.red;
    }
    return Colors.grey;
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
                          language.lblAppealDetails,
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
                language.lblErrorLoadingAppeal,
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

    if (_appeal == null) {
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
                // Appeal Header Card
                _buildSectionCard(
                  language.lblAppealInformation,
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language.lblAppealNumber,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: appStore.isDarkModeOn
                                        ? Colors.grey[400]
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _appeal!.appealNumber,
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
                              color: _getStatusColor(_appeal!.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _appeal!.statusLabel.titleCase,
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
                      _buildInfoRow(
                        Iconsax.calendar,
                        language.lblAppealDate,
                        DateParser.parseDate(_appeal!.appealDate) != null
                            ? DateParser.formatDate(
                                DateParser.parseDate(_appeal!.appealDate)!)
                            : _appeal!.appealDate,
                      ),
                    ],
                  ),
                  icon: Iconsax.shield_tick,
                ),

                // Related Warning Card
                if (_appeal!.warning != null) ...[
                  _buildSectionCard(
                    language.lblRelatedWarning,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appeal!.warning!.warningNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _appeal!.warning!.subject,
                          style: TextStyle(
                            fontSize: 14,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    icon: Iconsax.warning_2,
                  ),
                ],

                // Appeal Reason Card
                _buildSectionCard(
                  language.lblAppealReason,
                  Text(
                    _appeal!.appealReason,
                    style: TextStyle(
                      fontSize: 15,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                  icon: Iconsax.note,
                ),

                // Employee Statement Card
                if (_appeal!.employeeStatement != null) ...[
                  _buildSectionCard(
                    language.lblYourStatement,
                    Text(
                      _appeal!.employeeStatement!,
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

                // Supporting Documents Card
                if (_appeal!.supportingDocuments.isNotEmpty) ...[
                  _buildSectionCard(
                    language.lblSupportingDocumentsOptional,
                    Column(
                      children: _appeal!.supportingDocuments.map((doc) {
                        return InkWell(
                          onTap: () => _openDocument(doc.path),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.originalName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: appStore.isDarkModeOn
                                              ? Colors.white
                                              : const Color(0xFF111827),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(doc.size / 1024).toStringAsFixed(1)} KB',
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
                                const Icon(
                                  Icons.arrow_forward_ios,
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

                // Review Section (if reviewed)
                if (_appeal!.reviewedAt != null) ...[
                  _buildSectionCard(
                    language.lblReviewDecision,
                    Column(
                      children: [
                        if (_appeal!.outcome != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: _getOutcomeColor(_appeal!.outcome)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _getOutcomeColor(_appeal!.outcome)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _appeal!.outcome!.toLowerCase().contains('revoked')
                                      ? Iconsax.tick_circle
                                      : _appeal!.outcome!
                                              .toLowerCase()
                                              .contains('reduced')
                                          ? Iconsax.info_circle
                                          : Iconsax.close_circle,
                                  color: _getOutcomeColor(_appeal!.outcome),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _appeal!.outcomeLabel ?? _appeal!.outcome!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getOutcomeColor(_appeal!.outcome),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_appeal!.reviewedBy != null)
                          _buildInfoRow(
                            Iconsax.user,
                            language.lblReviewedBy,
                            _appeal!.reviewedBy!.name,
                          ),
                        _buildInfoRow(
                          Iconsax.calendar_tick,
                          language.lblReviewedDate,
                          DateParser.parseDate(_appeal!.reviewedAt!) != null
                              ? DateParser.formatDate(
                                  DateParser.parseDate(_appeal!.reviewedAt!)!)
                              : _appeal!.reviewedAt!,
                        ),
                        if (_appeal!.reviewComments != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.lblReviewComments,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appStore.isDarkModeOn
                                      ? Colors.grey[400]
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: appStore.isDarkModeOn
                                      ? const Color(0xFF111827)
                                      : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _appeal!.reviewComments!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: appStore.isDarkModeOn
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    icon: Iconsax.clipboard_tick,
                  ),
                ],

                // Hearing Information (if scheduled)
                if (_appeal!.hasHearingScheduled && _appeal!.hearingDate != null) ...[
                  _buildSectionCard(
                    language.lblHearingInformation,
                    Column(
                      children: [
                        _buildInfoRow(
                          Iconsax.calendar,
                          language.lblHearingDate,
                          DateParser.parseDate(_appeal!.hearingDate!) != null
                              ? DateParser.formatDate(
                                  DateParser.parseDate(_appeal!.hearingDate!)!)
                              : _appeal!.hearingDate!,
                          iconColor: Colors.blue,
                        ),
                        if (_appeal!.hearingTime != null)
                          _buildInfoRow(
                            Iconsax.clock,
                            language.lblTime,
                            _appeal!.hearingTime!,
                          ),
                        if (_appeal!.hearingLocation != null)
                          _buildInfoRow(
                            Iconsax.location,
                            language.lblLocation,
                            _appeal!.hearingLocation!,
                          ),
                        if (_appeal!.hearingAttendees != null &&
                            _appeal!.hearingAttendees!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.lblAttendees,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appStore.isDarkModeOn
                                      ? Colors.grey[400]
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._appeal!.hearingAttendees!.map((attendee) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: appStore.isDarkModeOn
                                        ? const Color(0xFF111827)
                                        : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Iconsax.user,
                                        size: 16,
                                        color: Color(0xFF696CFF),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        attendee,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: appStore.isDarkModeOn
                                              ? Colors.white
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                    icon: Iconsax.people,
                  ),
                ],

                const SizedBox(height: 80), // Space for button
              ],
            ),
          ),
        ),

        // Withdraw Button
        if (_appeal!.canWithdraw) ...[
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isWithdrawing ? null : _withdrawAppeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isWithdrawing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          language.lblWithdrawAppeal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
