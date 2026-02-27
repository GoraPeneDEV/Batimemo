import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/Document/document_type_model.dart';
import '../../utils/app_widgets.dart';
import 'document_store.dart';

class CreateDocumentRequestScreen extends StatefulWidget {
  const CreateDocumentRequestScreen({super.key});

  @override
  State<CreateDocumentRequestScreen> createState() =>
      _CreateDocumentRequestScreenState();
}

class _CreateDocumentRequestScreenState
    extends State<CreateDocumentRequestScreen> {
  final _store = DocumentStore();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await _store.getDocumentTypes();
  }

  Future<void> _submitForm() async {
    if (!_store.formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _store.sendDocumentRequest();
      if (result) {
        toast(language.lblDocumentRequestSubmittedSuccessfully);
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        toast(language.lblFailedToSubmitForm);
      }
    } catch (e) {
      toast('${language.lblError}: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        language.lblRequestADocument,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                      child: _store.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _store.documentTypes.isEmpty
                              ? Center(
                                  child: Text(
                                    language.lblNoDocumentTypesAdded,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: appStore.isDarkModeOn
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                )
                              : Form(
                                  key: _store.formKey,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Document Request Card
                                        _buildDocumentRequestCard(),
                                        const SizedBox(height: 16),

                                        // Important Notes Card
                                        _buildImportantNotesCard(),
                                        const SizedBox(height: 24),

                                        // Submit Button
                                        _buildSubmitButton(),
                                        const SizedBox(height: 20),
                                      ],
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
    );
  }

  Widget _buildDocumentRequestCard() {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: appStore.isDarkModeOn
                      ? Colors.grey[700]!
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF696CFF).withValues(alpha: 0.2),
                        const Color(0xFF5457E6).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.document,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblRequestDetails,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Document Type Dropdown
                _buildDocumentTypeDropdown(),
                const SizedBox(height: 16),

                // Remarks Field
                CustomTextField(
                  controller: _store.commentsCont,
                  label: language.lblRemarks,
                  hintText: language.lblEnterRemarksOrReason,
                  prefixIcon: Iconsax.note_text,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return language.lblCommentsIsRequired;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblDocumentType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appStore.isDarkModeOn
                ? Colors.grey[300]
                : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: appStore.isDarkModeOn
                  ? Colors.grey[700]!
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<DocumentTypeModel>(
            initialValue: _store.documentTypes.first,
            items: _store.documentTypes.map((item) {
              return DropdownMenuItem<DocumentTypeModel>(
                value: item,
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.document_text,
                      size: 20,
                      color: Color(0xFF696CFF),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.name!,
                      style: TextStyle(
                        fontSize: 14,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                _store.selectedTypeId = newValue.id;
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
            ),
            dropdownColor: appStore.isDarkModeOn
                ? const Color(0xFF1F2937)
                : Colors.white,
            icon: const Icon(
              Iconsax.arrow_down_1,
              color: Color(0xFF696CFF),
              size: 20,
            ),
            borderRadius: BorderRadius.circular(14),
            style: TextStyle(
              fontSize: 14,
              color: appStore.isDarkModeOn
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.info_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language.lblImportantNotes,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes list
          _buildNoteItem(language.lblSelectTheTypeOfDocument),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblProvideReasonForRequest),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblRequestReviewedByHR),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblNotifiedWhenReady),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: appStore.isDarkModeOn
                  ? Colors.grey[400]
                  : const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.5),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isSubmitting
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
            color: _isSubmitting ? Colors.grey.withValues(alpha: 0.5) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    language.lblSubmit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
