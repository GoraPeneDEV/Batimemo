import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/Attendance/attendance_regularization.dart';
import '../../utils/app_widgets.dart';
import '../../utils/string_extensions.dart';
import 'attendance_regularization_store.dart';

class AttendanceRegularizationFormScreen extends StatefulWidget {
  final AttendanceRegularization? regularization;

  const AttendanceRegularizationFormScreen({
    super.key,
    this.regularization,
  });

  @override
  State<AttendanceRegularizationFormScreen> createState() =>
      _AttendanceRegularizationFormScreenState();
}

class _AttendanceRegularizationFormScreenState
    extends State<AttendanceRegularizationFormScreen> {
  final AttendanceRegularizationStore _store =
      AttendanceRegularizationStore();

  bool get isEditMode => widget.regularization != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    await _store.getRegularizationTypes();

    if (isEditMode) {
      _store.loadFormFromRegularization(widget.regularization!);
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Get available dates
    await _store.getAvailableDates();

    if (_store.availableDates == null ||
        _store.availableDates!.dates.isEmpty) {
      toast(language.lblNoDatesAvailableForRegularization);
      return;
    }

    // Show date picker with available dates
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn
              ? const Color(0xFF1F2937)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    language.lblSelectDate,
                    style: boldTextStyle(size: 18),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Observer(
                    builder: (_) {
                      if (_store.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final dates = _store.availableDates?.dates ?? [];

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: dates.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final availableDate = dates[index];
                          final canSelect = availableDate.canRegularize;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: canSelect
                                  ? (appStore.isDarkModeOn
                                      ? const Color(0xFF374151)
                                      : Colors.white)
                                  : (appStore.isDarkModeOn
                                      ? const Color(0xFF1F2937)
                                      : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: canSelect
                                    ? (appStore.isDarkModeOn
                                        ? Colors.grey[600]!
                                        : const Color(0xFFE5E7EB))
                                    : Colors.grey.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              enabled: canSelect,
                              leading: Icon(
                                canSelect
                                    ? Iconsax.calendar_tick
                                    : Iconsax.calendar_remove,
                                color: canSelect
                                    ? const Color(0xFF696CFF)
                                    : Colors.grey,
                              ),
                              title: Text(
                                availableDate.date,
                                style: boldTextStyle(
                                  color: canSelect ? null : Colors.grey,
                                ),
                              ),
                              subtitle: Text(
                                availableDate.statusText,
                                style: secondaryTextStyle(
                                  color: canSelect ? null : Colors.grey,
                                ),
                              ),
                              trailing: availableDate.hasRegularizationRequest
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: availableDate
                                                    .regularizationStatus ==
                                                'rejected'
                                            ? Colors.red
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        availableDate.regularizationStatus
                                                ?.capitalize ??
                                            '',
                                        style: boldTextStyle(
                                          color: white,
                                          size: 11,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: canSelect
                                  ? () {
                                      _store.setDate(availableDate.date);
                                      Navigator.pop(context);
                                    }
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn
          ? (_store.requestedCheckInTime ?? TimeOfDay.now())
          : (_store.requestedCheckOutTime ?? TimeOfDay.now()),
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
      if (isCheckIn) {
        _store.setCheckInTime(picked);
      } else {
        _store.setCheckOutTime(picked);
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();

      // Check file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        toast(language.lblFileSizeExceeds5MB);
        return;
      }

      _store.addAttachment(file);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          final isDark = appStore.isDarkModeOn;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isEditMode
                              ? language.lblEditRegularization
                              : language.lblNewRegularizationRequest,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF3F4F6),
                        child: (_store.isLoading &&
                                _store.regularizationTypes.isEmpty)
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Form(
                                    key: _store.formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Form Card
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1F2937)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.grey[700]!
                                                  : const Color(0xFFE5E7EB),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Card Header
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          const Color(0xFF696CFF)
                                                              .withOpacity(0.2),
                                                          const Color(0xFF5457E6)
                                                              .withOpacity(0.1)
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Icon(
                                                      Iconsax.calendar_edit,
                                                      color: Color(0xFF696CFF),
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    language.lblRequestDetails,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF1F2937),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),

                                              // Date Selection
                                              Text(
                                                language.lblDate,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: isEditMode
                                                    ? null
                                                    : () =>
                                                        _selectDate(context),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: isEditMode
                                                        ? (isDark
                                                            ? const Color(
                                                                0xFF111827)
                                                            : const Color(
                                                                0xFFF3F4F6))
                                                        : (isDark
                                                            ? const Color(
                                                                0xFF1F2937)
                                                            : const Color(
                                                                0xFFF9FAFB)),
                                                    border: Border.all(
                                                      color: isDark
                                                          ? Colors.grey[700]!
                                                          : const Color(
                                                              0xFFE5E7EB),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.calendar,
                                                        color: isEditMode
                                                            ? Colors.grey
                                                            : const Color(
                                                                0xFF696CFF),
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          _store.selectedDate ??
                                                              language.lblSelectDate,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: _store.selectedDate !=
                                                                    null
                                                                ? (isDark
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF111827))
                                                                : Colors
                                                                    .grey[500],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      if (!isEditMode)
                                                        const Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.grey,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Type Selection
                                              Text(
                                                language.lblRegularizationType,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1F2937)
                                                      : const Color(0xFFF9FAFB),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.grey[700]!
                                                        : const Color(
                                                            0xFFE5E7EB),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child:
                                                    DropdownButtonFormField<
                                                        String>(
                                                  value: _store
                                                      .selectedRegularizationType,
                                                  dropdownColor: isDark
                                                      ? const Color(0xFF1F2937)
                                                      : Colors.white,
                                                  decoration: InputDecoration(
                                                    prefixIcon: const Icon(
                                                      Iconsax.document,
                                                      color: Color(0xFF696CFF),
                                                      size: 20,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                    hintText: language.lblSelectType,
                                                    hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF111827),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  items: _store
                                                      .regularizationTypes
                                                      .map((type) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: type.value,
                                                            child:
                                                                Text(type.label),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      _store
                                                          .setRegularizationType(
                                                              value);
                                                    }
                                                  },
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return language.lblPleaseSelectType;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Time Fields
                                              Row(
                                                children: [
                                                  // Check-in Time
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          language.lblCheckInTime,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF374151),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        InkWell(
                                                          onTap: () =>
                                                              _selectTime(
                                                                  context, true),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDark
                                                                  ? const Color(
                                                                      0xFF1F2937)
                                                                  : const Color(
                                                                      0xFFF9FAFB),
                                                              border:
                                                                  Border.all(
                                                                color: isDark
                                                                    ? Colors.grey[
                                                                        700]!
                                                                    : const Color(
                                                                        0xFFE5E7EB),
                                                                width: 1.5,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Iconsax
                                                                          .clock,
                                                                      color: Color(
                                                                          0xFF696CFF),
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      _store.requestedCheckInTime !=
                                                                              null
                                                                          ? _formatTimeOfDay(_store
                                                                              .requestedCheckInTime!)
                                                                          : language.lblSelect,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: _store.requestedCheckInTime !=
                                                                                null
                                                                            ? (isDark
                                                                                ? Colors.white
                                                                                : const Color(0xFF111827))
                                                                            : Colors.grey[500],
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  color: Colors
                                                                      .grey,
                                                                  size: 20,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Check-out Time
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          language.lblCheckOutTime,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF374151),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        InkWell(
                                                          onTap: () =>
                                                              _selectTime(
                                                                  context,
                                                                  false),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDark
                                                                  ? const Color(
                                                                      0xFF1F2937)
                                                                  : const Color(
                                                                      0xFFF9FAFB),
                                                              border:
                                                                  Border.all(
                                                                color: isDark
                                                                    ? Colors.grey[
                                                                        700]!
                                                                    : const Color(
                                                                        0xFFE5E7EB),
                                                                width: 1.5,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Iconsax
                                                                          .clock,
                                                                      color: Color(
                                                                          0xFF696CFF),
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      _store.requestedCheckOutTime !=
                                                                              null
                                                                          ? _formatTimeOfDay(_store
                                                                              .requestedCheckOutTime!)
                                                                          : language.lblSelect,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: _store.requestedCheckOutTime !=
                                                                                null
                                                                            ? (isDark
                                                                                ? Colors.white
                                                                                : const Color(0xFF111827))
                                                                            : Colors.grey[500],
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  color: Colors
                                                                      .grey,
                                                                  size: 20,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),

                                              // Reason
                                              Text(
                                                language.lblReason,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1F2937)
                                                      : const Color(0xFFF9FAFB),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.grey[700]!
                                                        : const Color(
                                                            0xFFE5E7EB),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: TextFormField(
                                                  controller:
                                                      _store.reasonController,
                                                  focusNode:
                                                      _store.reasonFocusNode,
                                                  maxLines: 4,
                                                  maxLength: 1000,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF111827),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        language.lblExplainReasonPlaceholder,
                                                    hintStyle: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[500],
                                                    ),
                                                    prefixIcon: const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 60),
                                                      child: Icon(
                                                        Iconsax.message_text,
                                                        color:
                                                            Color(0xFF696CFF),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                    counterText: '',
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return language.lblPleaseProvideReason;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Attachments
                                              Text(
                                                language.lblAttachmentsOptional,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: _pickFile,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(0xFF1F2937)
                                                        : Colors.white,
                                                    border: Border.all(
                                                      color: isDark
                                                          ? Colors.grey[700]!
                                                          : const Color(
                                                              0xFFE5E7EB),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Iconsax.document_upload,
                                                        color:
                                                            Color(0xFF696CFF),
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Flexible(
                                                        child: Text(
                                                          language.lblUploadDocument,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF111827),
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (_store
                                                  .attachments.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                ...List.generate(
                                                  _store.attachments.length,
                                                  (index) {
                                                    final file = _store
                                                        .attachments[index];
                                                    final fileName = file.path
                                                        .split('/')
                                                        .last;
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Iconsax.document,
                                                            color: Colors.green,
                                                            size: 24,
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              fileName,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isDark
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF111827),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Iconsax.trash,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                            onPressed: () =>
                                                                _store
                                                                    .removeAttachment(
                                                                        index),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Submit Button
                                        Observer(
                                          builder: (_) => InkWell(
                                            onTap: _store.isLoading
                                                ? null
                                                : () async {
                                                    hideKeyboard(context);
                                                    final success = isEditMode
                                                        ? await _store
                                                            .updateRegularization(
                                                                widget
                                                                    .regularization!
                                                                    .id)
                                                        : await _store
                                                            .createRegularization();

                                                    if (success) {
                                                      Navigator.pop(
                                                          context, true);
                                                    }
                                                  },
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF696CFF),
                                                    Color(0xFF5457E6)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                            0xFF696CFF)
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: _store.isLoading
                                                    ? const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            isEditMode
                                                                ? language.lblUpdateRequest
                                                                : language.lblSubmitRequest,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          const Icon(
                                                            Iconsax.send_1,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
