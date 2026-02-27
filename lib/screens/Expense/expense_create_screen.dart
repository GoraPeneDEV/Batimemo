import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/main.dart';
import 'package:open_core_hr/models/Expense/expense_type_model.dart';
import 'package:intl/intl.dart';

import 'ExpenseStore.dart';

class ExpenseCreateScreen extends StatefulWidget {
  static String tag = '/ExpenseCreateScreen';
  const ExpenseCreateScreen({super.key});

  @override
  State<ExpenseCreateScreen> createState() => _ExpenseCreateScreenState();
}

class _ExpenseCreateScreenState extends State<ExpenseCreateScreen> {
  final ExpenseStore _store = ExpenseStore();

  final _formKey = GlobalKey<FormState>();

  final _dateCont = TextEditingController();
  final _remarksCont = TextEditingController();
  final _fileUploadCont = TextEditingController();
  final _amountCont = TextEditingController();

  final _remarksFocus = FocusNode();
  final _fileUploadNode = FocusNode();
  final _dateFocus = FocusNode();
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await _store.loadExpenseTypes();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      helpText: language.lblDate,
      cancelText: language.lblCancel,
      confirmText: language.lblChoose,
      fieldLabelText: language.lblFromDate,
      fieldHintText: 'Month/Date/Year',
      errorFormatText: language.lblEnterValidDate,
      errorInvalidText: language.lblEnterDateInValidRange,
      context: context,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF696CFF),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
      initialDate: _store.today,
      firstDate: DateTime(2000),
      lastDate: _store.today,
    );
    if (picked != null && picked != _store.selectedDate) {
      _store.selectedDate = picked;
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return language.lblSelectDate;
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  void dispose() {
    _dateCont.dispose();
    _remarksCont.dispose();
    _fileUploadCont.dispose();
    _amountCont.dispose();
    _remarksFocus.dispose();
    _fileUploadNode.dispose();
    _dateFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
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
                // Header Section (56px fixed height)
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
                          icon: const Icon(Iconsax.arrow_left,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        language.lblCreateExpense,
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
                          : _store.expenseTypes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Iconsax.warning_2,
                                        size: 64,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        language.lblNoExpenseTypesAreConfigured,
                                        style: boldTextStyle(size: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Expense Details Card
                                        _buildExpenseDetailsCard(),

                                        const SizedBox(height: 16),

                                        // Document Upload Section
                                        Observer(
                                          builder: (_) =>
                                              _store.isImgRequired
                                                  ? _buildDocumentSection()
                                                  : const SizedBox.shrink(),
                                        ),

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

  // Expense Details Card
  Widget _buildExpenseDetailsCard() {
    return Observer(
      builder: (_) => Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.receipt_edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    language.lblExpenseDetails,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Picker
                  _buildDatePicker(),
                  const SizedBox(height: 16),

                  // Expense Type Dropdown
                  _buildExpenseTypeDropdown(),
                  const SizedBox(height: 16),

                  // Amount Field
                  _buildAmountField(),
                  const SizedBox(height: 16),

                  // Remarks Field
                  _buildRemarksField(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date Picker
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (_) => InkWell(
            onTap: () async {
              hideKeyboard(context);
              await selectDate(context);
              _dateCont.text = _formatDateForDisplay(_store.selectedDate);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Iconsax.calendar_1,
                        color: Color(0xFF696CFF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _dateCont.text.isEmpty
                            ? language.lblSelectDate
                            : _dateCont.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : const Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Expense Type Dropdown
  Widget _buildExpenseTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblExpenseType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (_) => Container(
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: DropdownButtonFormField<ExpenseTypeModel>(
              value: _store.selectedExpenseType,
              dropdownColor: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              decoration: InputDecoration(
                hintText: language.lblSelectExpenseType,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                prefixIcon: Icon(
                  Iconsax.category,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              items: _store.expenseTypes.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.name!),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  _store.selectedExpenseType = newValue;
                  _store.isImgRequired = newValue.isImgRequired!;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Amount Field
  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblAmount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (_) => Container(
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: _amountCont,
              focusNode: _amountFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: language.lblEnterAmount,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(
                  Iconsax.money,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                counterText: '',
              ),
              validator: (s) {
                if (s!.trim().isEmpty) {
                  return language.lblAmountIsRequired;
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Remarks Field
  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblRemarks,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (_) => Container(
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: _remarksCont,
              focusNode: _remarksFocus,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: language.lblEnterRemarksOrDescription,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Iconsax.note_text,
                    color: Color(0xFF696CFF),
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                counterText: '',
              ),
              validator: (s) {
                if (s!.trim().isEmpty) {
                  return language.lblRemarksIsRequired;
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Document Upload Section
  Widget _buildDocumentSection() {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.document_upload,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  language.lblSupportingDocument,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Upload Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Observer(
              builder: (_) => _store.fileName.isEmpty
                  ? _buildUploadButton()
                  : _buildUploadedFile(),
            ),
          ),
        ],
      ),
    );
  }

  // Upload Button
  Widget _buildUploadButton() {
    return InkWell(
      onTap: () async {
        hideKeyboard(context);
        await _store.getFile();
        if (_store.fileName.isNotEmpty) {
          _fileUploadCont.text = _store.fileName;
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF111827)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF696CFF),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Iconsax.gallery_add,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language.lblUploadReceiptDocument,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appStore.isDarkModeOn
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              language.lblTapToSelectImageFile,
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Uploaded File Display
  Widget _buildUploadedFile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.document,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblUploadedDocument,
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _store.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red),
            onPressed: () {
              setState(() {
                _store.fileName = '';
                _store.filePath = '';
                _fileUploadCont.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return Observer(
      builder: (_) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _store.isLoading
              ? null
              : () async {
                  hideKeyboard(context);
                  if (_formKey.currentState!.validate()) {
                    // Validate required fields
                    if (_dateCont.text.isEmpty) {
                      toast(language.lblPleaseSelectDate);
                      return;
                    }

                    if (_store.selectedExpenseType == null) {
                      toast(language.lblPleaseSelectExpenseType);
                      return;
                    }

                    if (_store.isImgRequired && _store.fileName.isEmpty) {
                      toast(language.lblImageIsRequired);
                      return;
                    }

                    var result = await _store.sendExpenseRequest(
                      _amountCont.text.trim(),
                      _remarksCont.text.trim(),
                    );

                    if (result) {
                      toast(language.lblSubmittedSuccessfully);
                      if (!mounted) return;
                      finish(context);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF696CFF),
            disabledBackgroundColor: const Color(0xFF696CFF).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
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
                  language.lblSubmitExpense,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
