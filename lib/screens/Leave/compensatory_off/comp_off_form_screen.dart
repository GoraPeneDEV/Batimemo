import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../stores/leave_store.dart';
import '../../../models/leave/compensatory_off.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_widgets.dart';

class CompOffFormScreen extends StatefulWidget {
  final CompensatoryOff? compOff; // For editing

  const CompOffFormScreen({super.key, this.compOff});

  @override
  State<CompOffFormScreen> createState() => _CompOffFormScreenState();
}

class _CompOffFormScreenState extends State<CompOffFormScreen> {
  late LeaveStore _leaveStore;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  DateTime? _workedDate;
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);

    // If editing, populate fields
    if (widget.compOff != null) {
      // Parse DD-MM-YYYY format from API
      _workedDate = DateFormat('dd-MM-yyyy').parse(widget.compOff!.workedDate);
      _hoursController.text = widget.compOff!.hoursWorked.toString();
      _reasonController.text = widget.compOff!.reason ?? '';
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectWorkedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _workedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColorPrimary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _workedDate = picked);
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return language.lblSelectDate;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  num _calculateCompOffDays() {
    final hours = num.tryParse(_hoursController.text) ?? 0;
    if (hours >= 8) {
      return 1.0;
    } else if (hours >= 4) {
      return 0.5;
    }
    return 0;
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_workedDate == null) {
      toast(language.lblPleaseSelectWorkedDate);
      return false;
    }

    if (_workedDate!.isAfter(DateTime.now())) {
      toast(language.lblWorkedDateCannotBeFuture);
      return false;
    }

    final hours = num.tryParse(_hoursController.text) ?? 0;
    if (hours < 1) {
      toast(language.lblHoursWorkedMinimum);
      return false;
    }

    if (_reasonController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterReason);
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      bool success;

      if (widget.compOff != null) {
        // Update existing comp off
        success = await _leaveStore.updateCompensatoryOff(
          widget.compOff!.id,
          workedDate: _formatDateForApi(_workedDate!),
          hoursWorked: num.parse(_hoursController.text),
          reason: _reasonController.text.trim(),
        );
      } else {
        // Create new comp off request
        success = await _leaveStore.requestCompensatoryOff(
          workedDate: _formatDateForApi(_workedDate!),
          hoursWorked: num.parse(_hoursController.text),
          reason: _reasonController.text.trim(),
        );
      }

      if (success) {
        toast(widget.compOff != null
            ? language.lblCompOffUpdatedSuccess
            : language.lblCompOffRequestedSuccess);
        Navigator.pop(context, true);
      } else {
        toast(_leaveStore.error ?? language.lblFailedToSubmitCompOff);
      }
    } catch (e) {
      toast('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Modern Gradient Header (56px height)
          Container(
            height: 56 + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appStore.isDarkModeOn
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.compOff != null ? language.lblEditCompOff : language.lblRequestCompOff,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: Observer(
              builder: (_) => Container(
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF111827)
                      : const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Card
                        Container(
                          decoration: BoxDecoration(
                            color: appStore.isDarkModeOn
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.info_circle,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    language.lblCompOffCalculation,
                                    style: boldTextStyle(size: 16, color: Colors.blue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '• 8+ hours worked = 1 full day comp off\n'
                                '• 4-7 hours worked = 0.5 day comp off\n'
                                '• Less than 4 hours = Not eligible',
                                style: secondaryTextStyle(size: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Details Card
                        Container(
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.calendar_edit,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(language.lblCompOffDetails,
                                      style: boldTextStyle(size: 16)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Worked Date Field
                              CustomTextField(
                                label: language.lblDateWorked,
                                hintText: language.lblSelectDateWorkedOvertime,
                                prefixIcon: Iconsax.calendar_1,
                                controller: TextEditingController(
                                    text: _formatDateForDisplay(_workedDate)),
                                readOnly: true,
                                enabled: widget.compOff == null,
                                onTap: widget.compOff != null
                                    ? null
                                    : () => _selectWorkedDate(context),
                              ),
                              const SizedBox(height: 16),

                              // Hours Worked Field
                              CustomTextField(
                                controller: _hoursController,
                                label: language.lblHoursWorked,
                                hintText: language.lblEnterHours,
                                prefixIcon: Iconsax.clock,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  setState(
                                      () {}); // Trigger rebuild for calculation
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return language.lblPleaseEnterHoursWorked;
                                  }
                                  final hours = num.tryParse(value);
                                  if (hours == null) {
                                    return language.lblPleaseEnterValidNumber;
                                  }
                                  if (hours < 1) {
                                    return language.lblHoursMustBeAtLeastOne;
                                  }
                                  if (hours > 24) {
                                    return language.lblHoursCannotExceedTwentyFour;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Calculated Days Display
                              if (_hoursController.text.isNotEmpty) ...[
                                Observer(
                                  builder: (_) {
                                    final compOffDays = _calculateCompOffDays();
                                    return Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: compOffDays > 0
                                            ? const Color(0xFF10B981).withOpacity(0.1)
                                            : const Color(0xFFF59E0B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: compOffDays > 0
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            compOffDays > 0
                                                ? Iconsax.tick_circle
                                                : Iconsax.info_circle,
                                            color: compOffDays > 0
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  compOffDays > 0
                                                      ? language.lblCompOffDaysEarned
                                                      : language.lblNotEligible,
                                                  style: boldTextStyle(size: 13),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  compOffDays > 0
                                                      ? language.lblDaysWillBeCredited.replaceAll('%s', '$compOffDays ${compOffDays > 1 ? language.lblDays : language.lblDay}')
                                                      : language.lblMinimumFourHoursRequired,
                                                  style: secondaryTextStyle(size: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Reason Field
                              CustomTextField(
                                controller: _reasonController,
                                label: language.lblReasonForOvertime,
                                hintText: language.lblExplainOvertimeReason,
                                prefixIcon: Iconsax.note,
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return language.lblPleaseEnterReason;
                                  }
                                  if (value.trim().length < 10) {
                                    return language.lblReasonMinLength;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Important Notes Card
                        Container(
                          decoration: BoxDecoration(
                            color: appStore.isDarkModeOn
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF59E0B),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.warning_2,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    language.lblImportantNotes,
                                    style: boldTextStyle(
                                        size: 16, color: const Color(0xFFF59E0B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '• Comp off requests must be approved by manager\n'
                                '• Approved comp offs are valid for 90 days\n'
                                '• Expired comp offs cannot be used\n'
                                '• You can only request comp off for past dates',
                                style: secondaryTextStyle(size: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF696CFF),
                              disabledBackgroundColor:
                                  const Color(0xFF696CFF).withOpacity(0.5),
                              shape: buildButtonCorner(),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    widget.compOff != null
                                        ? language.lblUpdateRequest
                                        : language.lblSubmitRequest,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
}
