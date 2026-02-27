import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';

import '../../main.dart';
import '../../api/dio_api/repositories/disciplinary_repository.dart';
import '../../models/disciplinary/warning_model.dart';
import '../../utils/app_widgets.dart';
import '../../utils/date_parser.dart';

class AppealFormScreen extends StatefulWidget {
  final Warning warning;

  const AppealFormScreen({super.key, required this.warning});

  @override
  State<AppealFormScreen> createState() => _AppealFormScreenState();
}

class _AppealFormScreenState extends State<AppealFormScreen> {
  final DisciplinaryRepository _repository = DisciplinaryRepository();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _appealReasonController = TextEditingController();
  final TextEditingController _employeeStatementController = TextEditingController();

  bool _isSubmitting = false;
  List<PlatformFile> _selectedFiles = [];

  @override
  void dispose() {
    _appealReasonController.dispose();
    _employeeStatementController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${language.lblErrorPickingFiles}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  Future<void> _submitAppeal() async {
    hideKeyboard(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get file paths from selected files
      final supportingDocs = _selectedFiles.isNotEmpty
          ? _selectedFiles.map((file) => file.path ?? '').where((path) => path.isNotEmpty).toList()
          : null;

      await _repository.createAppeal(
        widget.warning.id,
        appealReason: _appealReasonController.text.trim(),
        employeeStatement: _employeeStatementController.text.trim(),
        supportingDocumentPaths: supportingDocs,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language.lblAppealSubmittedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${language.lblFailedToSubmitAppeal}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
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
                          language.lblFileAppeal,
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
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Warning Summary Card
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.orange.withOpacity(0.2),
                                            Colors.orange.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Iconsax.warning_2,
                                                color: Colors.orange,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Warning: ${widget.warning.warningNumber}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            widget.warning.subject,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: appStore.isDarkModeOn
                                                  ? Colors.white
                                                  : const Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${language.lblIssuedOn}: ${DateParser.parseDate(widget.warning.issueDate) != null ? DateParser.formatDate(DateParser.parseDate(widget.warning.issueDate)!) : widget.warning.issueDate}',
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
                                    const SizedBox(height: 24),

                                    // Form Fields
                                    Text(
                                      language.lblAppealDetails,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: appStore.isDarkModeOn
                                            ? Colors.white
                                            : const Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Appeal Reason
                                    CustomTextField(
                                      controller: _appealReasonController,
                                      label: language.lblAppealReason,
                                      hintText: language.lblEnterAppealReason,
                                      prefixIcon: Iconsax.note,
                                      maxLines: 3,
                                      maxLength: 500,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return language.lblPleaseEnterAppealReason;
                                        }
                                        if (value.trim().length < 10) {
                                          return language.lblAppealReasonMinLength;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Employee Statement
                                    CustomTextField(
                                      controller: _employeeStatementController,
                                      label: language.lblYourStatement,
                                      hintText: language.lblProvideDetailedStatement,
                                      prefixIcon: Iconsax.document_text,
                                      maxLines: 5,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return language.lblPleaseProvideStatement;
                                        }
                                        if (value.trim().length < 20) {
                                          return language.lblStatementMinLength;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Supporting Documents
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language.lblSupportingDocumentsOptional,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: appStore.isDarkModeOn
                                                ? Colors.white
                                                : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: _pickFiles,
                                          borderRadius: BorderRadius.circular(14),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: appStore.isDarkModeOn
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFFF9FAFB),
                                              border: Border.all(
                                                color: appStore.isDarkModeOn
                                                    ? const Color(0xFF374151)
                                                    : const Color(0xFFE5E7EB),
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF696CFF).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    Iconsax.attach_circle,
                                                    color: Color(0xFF696CFF),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    _selectedFiles.isEmpty
                                                        ? language.lblTapToSelectFiles
                                                        : '${_selectedFiles.length} ${language.lblFilesSelected}',
                                                    style: TextStyle(
                                                      color: appStore.isDarkModeOn
                                                          ? Colors.grey[400]
                                                          : const Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.upload_file,
                                                  color: appStore.isDarkModeOn
                                                      ? Colors.grey[400]
                                                      : const Color(0xFF9CA3AF),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (_selectedFiles.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: appStore.isDarkModeOn
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFFF9FAFB),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(
                                                color: appStore.isDarkModeOn
                                                    ? const Color(0xFF374151)
                                                    : const Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              padding: const EdgeInsets.all(12),
                                              itemCount: _selectedFiles.length,
                                              separatorBuilder: (context, index) => Divider(
                                                height: 1,
                                                color: appStore.isDarkModeOn
                                                    ? const Color(0xFF374151)
                                                    : const Color(0xFFE5E7EB),
                                              ),
                                              itemBuilder: (context, index) {
                                                final file = _selectedFiles[index];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.document,
                                                        size: 18,
                                                        color: appStore.isDarkModeOn
                                                            ? Colors.grey[400]
                                                            : const Color(0xFF6B7280),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              file.name,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: appStore.isDarkModeOn
                                                                    ? Colors.white
                                                                    : const Color(0xFF111827),
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            if (file.size > 0)
                                                              Text(
                                                                '${(file.size / 1024).toStringAsFixed(1)} KB',
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
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 18,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () => _removeFile(index),
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          language.lblAcceptedFormats,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: appStore.isDarkModeOn
                                                ? Colors.grey[500]
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Important Information
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Iconsax.info_circle,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                language.lblImportantInformation,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: appStore.isDarkModeOn
                                                      ? Colors.white
                                                      : const Color(0xFF111827),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '• ${language.lblAppealInfoBullet1}\n'
                                            '• ${language.lblAppealInfoBullet2}\n'
                                            '• ${language.lblAppealInfoBullet3}\n'
                                            '• ${language.lblAppealInfoBullet4}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.6,
                                              color: appStore.isDarkModeOn
                                                  ? Colors.grey[400]
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 80), // Space for button
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      appStore.isDarkModeOn ? 0.3 : 0.06),
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
                                  onPressed: _isSubmitting ? null : _submitAppeal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF696CFF),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSubmitting
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
                                          language.lblSubmitAppeal,
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
}
