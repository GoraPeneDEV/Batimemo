import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../stores/leave_store.dart';
import '../../models/leave/leave_type.dart';
import '../../models/leave/leave_request.dart';
import '../../models/leave/compensatory_off.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_parser.dart';
import '../../utils/app_widgets.dart';
import '../../main.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  final LeaveRequest? leaveRequest; // For editing

  const LeaveRequestFormScreen({super.key, this.leaveRequest});

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  late LeaveStore _leaveStore;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  LeaveType? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isHalfDay = false;
  String? _halfDayType; // 'first_half' or 'second_half'
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  bool _isAbroad = false;
  final TextEditingController _abroadLocationController =
      TextEditingController();
  File? _selectedDocument;
  String? _documentFileName;

  // Compensatory off fields
  bool _useCompOff = false;
  List<int> _selectedCompOffIds = [];
  num _totalCompOffDays = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _leaveStore.fetchLeaveTypes().then((_) {
      if (widget.leaveRequest != null && mounted) {
        setState(() {
          try {
            _selectedLeaveType = _leaveStore.leaveTypes.firstWhere(
              (type) => type.id == widget.leaveRequest!.leaveType.id,
            );
          } catch (e) {
            _selectedLeaveType = widget.leaveRequest!.leaveType;
          }
        });
      }
    }).catchError((error) {
      if (mounted) {
        toast(language.lblErrorLoadingLeaveTypes);
      }
    });

    if (widget.leaveRequest == null) {
      _leaveStore.fetchCompensatoryOffBalance().catchError((error) {});
      _leaveStore.fetchCompensatoryOffs(status: 'approved').catchError((error) {});
    }

    if (widget.leaveRequest != null) {
      try {
        _fromDate = DateParser.parseDate(widget.leaveRequest!.fromDate);
        _toDate = DateParser.parseDate(widget.leaveRequest!.toDate);
        _isHalfDay = widget.leaveRequest!.isHalfDay;
        _halfDayType = widget.leaveRequest!.halfDayType;
        _reasonController.text = widget.leaveRequest!.userNotes ?? '';
        _emergencyContactController.text =
            widget.leaveRequest!.emergencyContact ?? '';
        _emergencyPhoneController.text = widget.leaveRequest!.emergencyPhone ?? '';
        _isAbroad = widget.leaveRequest!.isAbroad ?? false;
        _abroadLocationController.text =
            widget.leaveRequest!.abroadLocation ?? '';
        _documentFileName = widget.leaveRequest!.documentUrl?.split('/').last;
      } catch (error) {
        toast(language.lblErrorLoadingFormData);
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          toast(language.lblFileSizeLimit);
          return;
        }

        setState(() {
          _selectedDocument = file;
          _documentFileName = result.files.single.name;
        });
      }
    } catch (e) {
      toast('Error picking file: $e');
    }
  }

  void _removeDocument() {
    setState(() {
      _selectedDocument = null;
      _documentFileName = null;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _abroadLocationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? _fromDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
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
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_isHalfDay) {
            _toDate = picked;
          } else {
            if (_toDate != null && _toDate!.isBefore(picked)) {
              _toDate = null;
            }
          }
        } else {
          _toDate = picked;
        }

        if (_useCompOff && _fromDate != null && _toDate != null) {
          _autoSelectCompOffs();
        }
      });
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return language.lblSelectDate;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  num _calculateTotalDays() {
    if (_fromDate == null || _toDate == null) return 0;
    if (_isHalfDay) return 0.5;

    final days = _toDate!.difference(_fromDate!).inDays + 1;
    return days;
  }

  num _getAvailableBalance() {
    if (_selectedLeaveType == null) return 0;
    if (_leaveStore.leaveBalanceSummary == null) return 0;

    try {
      final balances = _leaveStore.leaveBalanceSummary!.leaveBalances
          .where((b) => b.leaveType.id == _selectedLeaveType!.id)
          .toList();

      if (balances.isEmpty) return 0;

      return balances.first.available;
    } catch (e) {
      return 0;
    }
  }

  num _getAvailableCompOffBalance() {
    return _leaveStore.compOffBalance?.available ?? 0;
  }

  List<dynamic> _getAvailableCompOffs() {
    try {
      final now = DateTime.now();
      return _leaveStore.compensatoryOffs
          .where((co) =>
              co.isApproved &&
              !co.isUsed &&
              co.canBeUsed &&
              DateParser.parseDate(co.expiryDate).isAfter(now))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void _autoSelectCompOffs() {
    try {
      final totalLeaveDays = _calculateTotalDays();
      final availableCompOffs = _getAvailableCompOffs();

      if (availableCompOffs.isEmpty || totalLeaveDays <= 0) {
        setState(() {
          _selectedCompOffIds = [];
          _totalCompOffDays = 0;
        });
        return;
      }

      num remainingDays = totalLeaveDays;
      final selectedIds = <int>[];
      num totalDays = 0;

      for (var compOff in availableCompOffs) {
        if (remainingDays <= 0) break;

        selectedIds.add(compOff.id);
        totalDays += compOff.compOffDays;
        remainingDays -= compOff.compOffDays;
      }

      setState(() {
        _selectedCompOffIds = selectedIds;
        _totalCompOffDays = totalDays > totalLeaveDays ? totalLeaveDays : totalDays;
      });
    } catch (e) {
      setState(() {
        _selectedCompOffIds = [];
        _totalCompOffDays = 0;
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_selectedLeaveType == null) {
      toast(language.lblPleaseSelectLeaveType);
      return false;
    }

    if (_fromDate == null) {
      toast(language.lblPleaseSelectFromDate);
      return false;
    }

    if (_toDate == null) {
      toast(language.lblPleaseSelectToDate);
      return false;
    }

    if (_isHalfDay && _fromDate != _toDate) {
      toast(language.lblHalfDayDateError);
      return false;
    }

    if (_isHalfDay && _halfDayType == null) {
      toast(language.lblPleaseSelectHalfDayType);
      return false;
    }

    if (_reasonController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterReasonForLeave);
      return false;
    }

    if (_selectedLeaveType?.isProofRequired == true &&
        _selectedDocument == null &&
        widget.leaveRequest?.documentUrl == null) {
      toast(language.lblDocumentRequired);
      return false;
    }

    final totalDays = _calculateTotalDays();
    final availableBalance = _getAvailableBalance();

    if (widget.leaveRequest == null) {
      final compOffDaysToUse = _useCompOff ? _totalCompOffDays : 0;
      final requiredLeaveBalance = totalDays - compOffDaysToUse;

      if (requiredLeaveBalance > availableBalance) {
        toast(language.lblInsufficientBalance.replaceAll('%s', '$availableBalance').replaceFirst('%s', '$requiredLeaveBalance'));
        return false;
      }
    } else {
      if (widget.leaveRequest!.usesCompOff != true) {
        if (totalDays > availableBalance) {
          toast(language.lblInsufficientBalance.replaceAll('%s', '$availableBalance').replaceFirst('%s', '$totalDays'));
          return false;
        }
      }
    }

    if (_useCompOff) {
      if (_selectedCompOffIds.isEmpty) {
        toast(language.lblSelectCompensatoryOffs);
        return false;
      }

      if (_totalCompOffDays > totalDays) {
        toast(language.lblCompOffDaysCannotExceed);
        return false;
      }
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      bool success;

      if (widget.leaveRequest != null) {
        success = await _leaveStore.updateLeaveRequest(
          widget.leaveRequest!.id,
          fromDate: _formatDateForApi(_fromDate!),
          toDate: _formatDateForApi(_toDate!),
          userNotes: _reasonController.text.trim(),
          isHalfDay: _isHalfDay,
          halfDayType: _isHalfDay ? _halfDayType : null,
          emergencyContact: _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : null,
          emergencyPhone: _emergencyPhoneController.text.trim().isNotEmpty
              ? _emergencyPhoneController.text.trim()
              : null,
          isAbroad: _isAbroad,
          abroadLocation: _isAbroad && _abroadLocationController.text.trim().isNotEmpty
              ? _abroadLocationController.text.trim()
              : null,
          document: _selectedDocument,
        );
      } else {
        success = await _leaveStore.createLeaveRequest(
          leaveTypeId: _selectedLeaveType!.id,
          fromDate: _formatDateForApi(_fromDate!),
          toDate: _formatDateForApi(_toDate!),
          userNotes: _reasonController.text.trim(),
          isHalfDay: _isHalfDay,
          halfDayType: _isHalfDay ? _halfDayType : null,
          emergencyContact: _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : null,
          emergencyPhone: _emergencyPhoneController.text.trim().isNotEmpty
              ? _emergencyPhoneController.text.trim()
              : null,
          isAbroad: _isAbroad,
          abroadLocation: _isAbroad && _abroadLocationController.text.trim().isNotEmpty
              ? _abroadLocationController.text.trim()
              : null,
          document: _selectedDocument,
          useCompOff: _useCompOff,
          compOffIds: _useCompOff && _selectedCompOffIds.isNotEmpty
              ? _selectedCompOffIds
              : null,
        );
      }

      if (success) {
        toast(widget.leaveRequest != null
            ? language.lblLeaveRequestUpdatedSuccess
            : language.lblLeaveRequestSubmittedSuccess);
        Navigator.pop(context, true);
      } else {
        final errorMsg = _leaveStore.error ?? language.lblFailedToSubmitLeaveRequest;
        toast(errorMsg);
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
                        widget.leaveRequest != null
                            ? language.lblEditLeaveRequest
                            : language.lblNewLeaveRequest,
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
                      child: _leaveStore.isLoading && _leaveStore.leaveTypes.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Leave Type Selection
                                    _buildLeaveTypeDropdown(),
                                    const SizedBox(height: 16),

                                    // Available Balance
                                    if (_selectedLeaveType != null)
                                      _buildAvailableBalanceCard(),

                                    // Compensatory Off Section (read-only for edit mode)
                                    if (widget.leaveRequest != null &&
                                        widget.leaveRequest!.usesCompOff == true &&
                                        widget.leaveRequest!.compOffDetails != null &&
                                        widget.leaveRequest!.compOffDetails!.isNotEmpty)
                                      _buildCompOffReadOnly(),

                                    // Compensatory Off Section (for new requests)
                                    if (widget.leaveRequest == null &&
                                        _getAvailableCompOffBalance() > 0)
                                      _buildCompOffSection(),

                                    // Half Day Toggle
                                    _buildHalfDayToggle(),

                                    // Half Day Type
                                    if (_isHalfDay) _buildHalfDayType(),

                                    // From Date
                                    _buildDatePicker(
                                      label: language.lblFromDate,
                                      date: _fromDate,
                                      onTap: () => _selectDate(context, true),
                                    ),

                                    // To Date
                                    _buildDatePicker(
                                      label: language.lblToDate,
                                      date: _toDate ?? _fromDate,
                                      onTap: _isHalfDay ? null : () => _selectDate(context, false),
                                      enabled: !_isHalfDay,
                                    ),

                                    // Total Days Display
                                    if (_fromDate != null && _toDate != null)
                                      _buildTotalDaysCard(),

                                    // Reason
                                    CustomTextField(
                                      controller: _reasonController,
                                      label: language.lblReasonForLeave,
                                      hintText: language.lblEnterReasonForLeave,
                                      prefixIcon: Iconsax.note,
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return language.lblPleaseEnterReasonForLeave;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Emergency Contact
                                    CustomTextField(
                                      controller: _emergencyContactController,
                                      label: language.lblEmergencyContactOptional,
                                      hintText: language.lblContactPersonName,
                                      prefixIcon: Iconsax.user,
                                    ),
                                    const SizedBox(height: 16),

                                    // Emergency Phone
                                    CustomTextField(
                                      controller: _emergencyPhoneController,
                                      label: language.lblEmergencyPhoneOptional,
                                      hintText: language.lblContactPhoneNumber,
                                      prefixIcon: Iconsax.call,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 16),

                                    // Going Abroad Toggle
                                    _buildAbroadToggle(),

                                    // Abroad Location
                                    if (_isAbroad) ...[
                                      CustomTextField(
                                        controller: _abroadLocationController,
                                        label: language.lblAbroadLocation,
                                        hintText: language.lblEnterDestination,
                                        prefixIcon: Iconsax.location,
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Document Upload Section
                                    if (_selectedLeaveType != null)
                                      _buildDocumentSection(),

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

  // Widget builders for cleaner code
  Widget _buildLeaveTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.lblLeaveType,
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
            child: DropdownButtonFormField<LeaveType>(
              value: _selectedLeaveType,
              dropdownColor: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              decoration: InputDecoration(
                hintText: _leaveStore.leaveTypes.isEmpty
                    ? language.lblLoadingLeaveTypes
                    : language.lblSelectLeaveType,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                prefixIcon: const Icon(
                  Iconsax.category,
                  color: Color(0xFF696CFF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
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
              items: _leaveStore.leaveTypes.isEmpty
                  ? null
                  : _leaveStore.leaveTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
              onChanged: widget.leaveRequest != null ||
                      _leaveStore.leaveTypes.isEmpty
                  ? null
                  : (value) {
                      setState(() => _selectedLeaveType = value);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableBalanceCard() {
    try {
      final balance = _getAvailableBalance();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.wallet, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.lblAvailableBalanceDays.replaceAll('%s', '$balance'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language.lblUnableToLoadBalance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompOffReadOnly() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.ticket, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                language.lblCompensatoryOffsApplied,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${language.lblTotal}: ${widget.leaveRequest!.compOffDaysUsed} ${(widget.leaveRequest!.compOffDaysUsed ?? 0) > 1 ? language.lblDays : language.lblDay}',
            style: TextStyle(
              fontSize: 13,
              color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    language.lblCompOffsCannotBeModified,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompOffSection() {
    return Column(
      children: [
        Observer(
          builder: (_) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                    Text(
                      language.lblUseCompensatoryOff,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_getAvailableCompOffBalance()} days',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _useCompOff,
                  onChanged: (value) {
                    setState(() {
                      _useCompOff = value;
                      if (value) {
                        _autoSelectCompOffs();
                      } else {
                        _selectedCompOffIds = [];
                        _totalCompOffDays = 0;
                      }
                    });
                  },
                  activeColor: const Color(0xFF696CFF),
                ),
              ],
            ),
          ),
        ),
        if (_useCompOff)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.info_circle, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      language.lblCompOffWillBeApplied,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  language.lblCompOffsSelected.replaceAll('%s', '${_selectedCompOffIds.length}'),
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '${language.lblTotal}: $_totalCompOffDays ${_totalCompOffDays > 1 ? language.lblDays : language.lblDay}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_fromDate != null && _toDate != null) ...[
                  const SizedBox(height: 8),
                  Divider(
                    color: appStore.isDarkModeOn ? Colors.grey[700] : const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 8),
                  _buildCompOffBreakdown(),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCompOffBreakdown() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.lblLeaveDays,
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
            Text(
              '${_calculateTotalDays()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.lblCompOffApplied,
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
            Text(
              '-$_totalCompOffDays',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.lblFromLeaveBalance,
              style: TextStyle(
                fontSize: 12,
                color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
            Text(
              '${_calculateTotalDays() - _totalCompOffDays}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHalfDayToggle() {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(
              language.lblHalfDayLeave,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Switch(
              value: _isHalfDay,
              onChanged: (value) {
                setState(() {
                  _isHalfDay = value;
                  if (value && _fromDate != null) {
                    _toDate = _fromDate;
                  }
                });
              },
              activeColor: const Color(0xFF696CFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfDayType() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn
            ? const Color(0xFF1F2937)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? const Color(0xFF374151)
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.lblHalfDayType,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(language.lblFirstHalf),
                  value: 'first_half',
                  groupValue: _halfDayType,
                  onChanged: (value) {
                    setState(() => _halfDayType = value);
                  },
                  activeColor: const Color(0xFF696CFF),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(language.lblSecondHalf),
                  value: 'second_half',
                  groupValue: _halfDayType,
                  onChanged: (value) {
                    setState(() => _halfDayType = value);
                  },
                  activeColor: const Color(0xFF696CFF),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (_) => InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: enabled
                    ? (appStore.isDarkModeOn
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFF9FAFB))
                    : (appStore.isDarkModeOn
                        ? const Color(0xFF111827)
                        : const Color(0xFFF3F4F6)),
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
                      Icon(
                        Iconsax.calendar_1,
                        color: enabled ? const Color(0xFF696CFF) : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDateForDisplay(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: enabled
                              ? (appStore.isDarkModeOn
                                  ? Colors.white
                                  : const Color(0xFF111827))
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (enabled)
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTotalDaysCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF696CFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF696CFF), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.clock, color: Color(0xFF696CFF), size: 24),
          const SizedBox(width: 12),
          Text(
            '${language.lblTotal}: ${_calculateTotalDays()} ${_calculateTotalDays() > 1 ? language.lblDays : language.lblDay}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF696CFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbroadToggle() {
    return Observer(
      builder: (_) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(
              language.lblGoingAbroad,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Switch(
              value: _isAbroad,
              onChanged: (value) {
                setState(() => _isAbroad = value);
              },
              activeColor: const Color(0xFF696CFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              language.lblSupportingDocument,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (_selectedLeaveType?.isProofRequired == true) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedLeaveType?.isProofRequired == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              language.lblDocumentRequired,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        if (_selectedDocument != null || _documentFileName != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  _documentFileName?.toLowerCase().endsWith('.pdf') == true
                      ? Iconsax.document
                      : Iconsax.gallery,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _documentFileName ?? language.lblUploadedDocument,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                  onPressed: _removeDocument,
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: _pickDocument,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? const Color(0xFF1F2937)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedLeaveType?.isProofRequired == true
                      ? Colors.red
                      : (appStore.isDarkModeOn
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB)),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.document_upload,
                    color: Color(0xFF696CFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      language.lblUploadDocument,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
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
          backgroundColor: const Color(0xFF696CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.leaveRequest != null ? language.lblUpdateRequest : language.lblSubmitRequest,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
