import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/dio_api/repositories/loan_repository.dart';
import '../../main.dart';
import '../../models/Loan/loan_detail_model.dart';
import '../../models/Loan/loan_type.dart';
import '../../utils/app_widgets.dart';
import '../../utils/date_parser.dart';
import 'loan_store.dart';

class LoanRequestScreen extends StatefulWidget {
  final int? loanId; // For editing existing loan
  const LoanRequestScreen({super.key, this.loanId});

  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final _store = LoanStore();
  final _repository = LoanRepository();
  Map<String, dynamic>? _calculatedEmi;
  bool _isLoadingLoan = false;
  LoanDetailModel? _existingLoan;

  bool get _isEditMode => widget.loanId != null;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _store.init();

    // If editing, load existing loan data
    if (_isEditMode) {
      await _loadExistingLoan();
    }
  }

  Future<void> _loadExistingLoan() async {
    setState(() {
      _isLoadingLoan = true;
    });

    try {
      final response = await _repository.getLoanRequest(widget.loanId!);
      if (response != null) {
        _existingLoan = response.loan;

        // Pre-fill form fields with existing data
        _store.amountController.text = _existingLoan!.amount.toStringAsFixed(0);
        _store.tenureController.text = _existingLoan!.tenureMonths?.toString() ?? '';
        _store.purposeController.text = _existingLoan!.purpose ?? '';
        _store.remarksController.text = _existingLoan!.remarks ?? '';
        _store.expectedDisbursementDateController.text =
            _existingLoan!.expectedDisbursementDate ?? '';

        // Find and select the matching loan type
        if (_existingLoan!.loanType != null && _store.loanTypes.isNotEmpty) {
          final matchingType = _store.loanTypes.firstWhere(
            (type) => type.id == _existingLoan!.loanType!.id,
            orElse: () => _store.loanTypes.first,
          );
          _store.setSelectedLoanType(matchingType);
        }
      }
    } catch (e) {
      toast('${language.lblErrorLoadingLoanDetails}: $e');
    } finally {
      setState(() {
        _isLoadingLoan = false;
      });
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    hideKeyboard(context);
    final initialDate = DateTime.now().add(const Duration(days: 7));
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) {
      _store.expectedDisbursementDateController.text = DateParser.formatDateForApi(result);
    }
  }

  Future<void> _calculateEmi() async {
    if (!_store.formKey.currentState!.validate()) return;

    try {
      final result = await _store.calculateEmi();
      setState(() {
        _calculatedEmi = result;
      });
    } catch (e) {
      toast('${language.lblErrorCalculatingEMI}: $e');
    }
  }

  Future<void> _submitForm({bool saveAsDraft = false}) async {
    if (!_store.formKey.currentState!.validate()) return;

    try {
      Map<String, dynamic>? result;

      if (_isEditMode) {
        // Update existing loan request
        // If it's a draft, saveAsDraft means keep as draft; !saveAsDraft means submit
        final isDraft = _existingLoan?.status == 'draft';
        result = await _store.updateLoanRequest(
          widget.loanId!,
          submit: isDraft && !saveAsDraft, // Submit if it was a draft and user clicked submit
        );
      } else {
        // Create new loan request
        result = await _store.createLoanRequest(saveAsDraft: saveAsDraft);
      }

      final message = _isEditMode
          ? language.lblLoanRequestUpdatedSuccessfully
          : saveAsDraft
              ? language.lblLoanRequestSavedAsDraft
              : result?['message'] ?? language.lblSubmitRequest;

      toast(message);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      toast('${language.lblError}: $e');
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
                // Header Section (56px)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _isEditMode ? language.lblEditLoanRequest : language.lblRequestLoan,
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
                      child: _isLoadingLoan
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF696CFF),
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
                                    // Loan Type Selection
                                    _buildLoanTypeSelectionCard(),
                                    const SizedBox(height: 16),

                                    // Loan Details Card
                                    _buildLoanDetailsCard(),
                                    const SizedBox(height: 16),

                                    // EMI Calculator Card
                                    if (_calculatedEmi != null) ...[
                                      _buildEmiResultCard(),
                                      const SizedBox(height: 16),
                                    ],

                                    // Important Notes Card
                                    _buildImportantNotesCard(),
                                    const SizedBox(height: 24),

                                    // Action Buttons
                                    _buildActionButtons(),
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

  Widget _buildLoanTypeSelectionCard() {
    return Observer(
      builder: (_) => Container(
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.category,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    language.lblSelectLoanType,
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
            ),

            // Loan Types List
            if (_store.loanTypes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  language.lblLoadingLoanTypes,
                  style: TextStyle(
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _store.loanTypes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final loanType = _store.loanTypes[index];
                  final isSelected = _store.selectedLoanType?.id == loanType.id;
                  return _buildLoanTypeItem(loanType, isSelected);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTypeItem(LoanType loanType, bool isSelected) {
    return InkWell(
      onTap: () {
        _store.setSelectedLoanType(loanType);
        setState(() {
          _calculatedEmi = null; // Reset EMI calculation
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF696CFF).withOpacity(0.1)
              : (appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF696CFF)
                : (appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF696CFF) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF696CFF) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loanType.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                  if (loanType.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      loanType.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('${loanType.interestRate}% ${language.lblInterest}'),
                      if (loanType.maxAmount != null)
                        _buildInfoChip('${language.lblMax}: ₹${loanType.maxAmount!.toStringAsFixed(0)}'),
                      if (loanType.maxTenureMonths != null)
                        _buildInfoChip('${language.lblUpTo} ${loanType.maxTenureMonths} ${language.lblMonths}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF696CFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF696CFF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoanDetailsCard() {
    return Observer(
      builder: (_) {
        final selectedType = _store.selectedLoanType;
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.document_text,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      language.lblLoanDetails,
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
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Amount Field
                    CustomTextField(
                      controller: _store.amountController,
                      label: language.lblLoanAmount,
                      hintText: language.lblEnterLoanAmount,
                      prefixIcon: Iconsax.money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() => _calculatedEmi = null),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return language.lblAmountCannotBeEmpty;
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return language.lblPleaseEnterValidAmount;
                        }
                        if (selectedType?.maxAmount != null && amount > selectedType!.maxAmount!) {
                          return '${language.lblAmountExceedsMaximumLimit} ₹${selectedType.maxAmount}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tenure Field
                    CustomTextField(
                      controller: _store.tenureController,
                      label: language.lblTenureMonths,
                      hintText: language.lblEnterTenure,
                      prefixIcon: Iconsax.calendar,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _calculatedEmi = null),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return language.lblTenureCannotBeEmpty;
                        }
                        final tenure = int.tryParse(value.trim());
                        if (tenure == null || tenure <= 0) {
                          return language.lblPleaseEnterValidTenure;
                        }
                        if (selectedType?.minTenureMonths != null && tenure < selectedType!.minTenureMonths!) {
                          return '${language.lblMinimumTenure} ${selectedType.minTenureMonths} ${language.lblMonths}';
                        }
                        if (selectedType?.maxTenureMonths != null && tenure > selectedType!.maxTenureMonths!) {
                          return '${language.lblMaximumTenure} ${selectedType.maxTenureMonths} ${language.lblMonths}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Calculate EMI Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _calculateEmi,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF696CFF),
                          side: const BorderSide(color: Color(0xFF696CFF), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Iconsax.calculator, size: 18),
                        label: Text(
                          language.lblCalculateEMI,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Purpose Field
                    CustomTextField(
                      controller: _store.purposeController,
                      label: language.lblPurpose,
                      hintText: language.lblEnterPurpose,
                      prefixIcon: Iconsax.task,
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return language.lblPurposeIsRequired;
                        }
                        if (value.trim().length < 5) {
                          return language.lblPurposeMustBeAtLeast5Characters;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Remarks Field
                    CustomTextField(
                      controller: _store.remarksController,
                      label: language.lblRemarksOptional,
                      hintText: language.lblEnterRemarks,
                      prefixIcon: Iconsax.note_text,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Expected Disbursement Date Field
                    CustomTextField(
                      controller: _store.expectedDisbursementDateController,
                      label: language.lblExpectedDisbursementDate,
                      hintText: language.lblSelectDate,
                      prefixIcon: Iconsax.calendar_1,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmiResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : const Color(0xFF696CFF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF696CFF),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.calculator,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language.lblEMICalculation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF696CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEmiInfoItem(
                  language.lblMonthlyEMI,
                  '₹${_calculatedEmi!['emi'].toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildEmiInfoItem(
                  language.lblTotalAmount,
                  '₹${_calculatedEmi!['totalAmount'].toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEmiInfoItem(
            language.lblTotalInterest,
            '₹${_calculatedEmi!['totalInterest'].toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildEmiInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: appStore.isDarkModeOn
                ? Colors.grey[400]
                : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn
                ? Colors.white
                : const Color(0xFF111827),
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
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildNoteItem(language.lblYourLoanRequestWillBeReviewedByManagement),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblApprovalTimeMayVaryBasedOnLoanAmount),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblYouWillBeNotifiedOnceRequestIsProcessed),
          const SizedBox(height: 8),
          _buildNoteItem(language.lblEnsureAllDetailsAreAccurateBeforeSubmitting),
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

  Widget _buildActionButtons() {
    final isDraft = _existingLoan?.status == 'draft';
    final buttonText = _isEditMode
        ? (isDraft ? language.lblSubmitRequest : language.lblUpdateRequest)
        : language.lblSubmitRequest;

    return Observer(
      builder: (_) => Column(
        children: [
          // Main submit/update button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _store.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF696CFF),
                disabledBackgroundColor: const Color(0xFF696CFF).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _store.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          // Save as draft button (only for drafts being edited)
          if (_isEditMode && isDraft) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _store.isLoading ? null : () => _submitForm(saveAsDraft: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF696CFF),
                  side: const BorderSide(color: Color(0xFF696CFF), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  language.lblSaveAsDraft,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
