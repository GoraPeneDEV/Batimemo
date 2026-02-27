import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/models/user.dart';
import 'package:open_core_hr/screens/Calendar/calendar_store.dart';

import '../../../main.dart';

class EventAddEditSheet extends StatefulWidget {
  final CalendarStore store;

  const EventAddEditSheet({super.key, required this.store});

  @override
  State<EventAddEditSheet> createState() => _EventAddEditSheetState();
}

class _EventAddEditSheetState extends State<EventAddEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late CalendarStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _store.titleController.text = _store.titleController.text;
    _store.locationController.text = _store.locationController.text;
    _store.descriptionController.text = _store.descriptionController.text;
  }

  // --- Date/Time Picker Logic ---
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _store.selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: language.lblStartTime,
      confirmText: language.lblOk,
      cancelText: language.lblCancel,
    );
    if (picked != null) {
      TimeOfDay? pickedTime;
      if (!_store.isAllDay) {
        pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
              _store.selectedStartDate ?? DateTime.now()),
          helpText: language.lblStartTime,
          confirmText: language.lblOk,
          cancelText: language.lblCancel,
        );
      }
      final DateTime finalDateTime = DateTime(picked.year, picked.month,
          picked.day, pickedTime?.hour ?? 0, pickedTime?.minute ?? 0);
      _store.setStartDate(finalDateTime);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime initial =
        _store.selectedEndDate ?? _store.selectedStartDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _store.selectedStartDate ?? DateTime(2000),
      lastDate: DateTime(2101),
      helpText: language.lblEndDate,
      confirmText: language.lblOk,
      cancelText: language.lblCancel,
    );
    if (picked != null) {
      TimeOfDay? pickedTime;
      if (!_store.isAllDay) {
        pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
          helpText: language.lblEndTime,
          confirmText: language.lblOk,
          cancelText: language.lblCancel,
        );
      }
      final DateTime finalDateTime = DateTime(picked.year, picked.month,
          picked.day, pickedTime?.hour ?? 0, pickedTime?.minute ?? 0);
      _store.setEndDate(finalDateTime);
    }
  }

  // --- Color Picker Widget ---
  Widget _buildColorSelector() {
    final isDark = appStore.isDarkModeOn;
    return Observer(
        builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lblEventColor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                12.height,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Default/Type Color Option
                      _buildColorRadio('', isDefault: true),
                      12.width,
                      // Fixed Color Options
                      ..._store.fixedColors.map((colorHex) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildColorRadio(colorHex),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ));
  }

  Widget _buildColorRadio(String colorHex, {bool isDefault = false}) {
    final isDark = appStore.isDarkModeOn;
    Color color = Colors.transparent;
    bool isSelected = _store.selectedColor == colorHex;

    if (!isDefault) {
      try {
        final colorValue = int.parse(colorHex.replaceAll('#', ''), radix: 16);
        color = Color(colorValue | 0xFF000000);
      } catch (e) {
        color = Colors.grey;
      }
    }

    return InkWell(
      onTap: () => _store.setSelectedColor(colorHex),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDefault ? null : color,
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF696CFF)
                  : (isDefault
                      ? (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB))
                      : color),
              width: isSelected ? 3 : (isDefault ? 1.5 : 0)),
          gradient: isDefault
              ? LinearGradient(
                  colors: [
                    const Color(0xFF696CFF).withValues(alpha: 0.2),
                    const Color(0xFF5457E6).withValues(alpha: 0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
        ),
        child: isDefault
            ? Icon(
                Iconsax.color_swatch,
                size: 20,
                color: const Color(0xFF696CFF),
              )
            : null,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF696CFF), size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF696CFF),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
        fontSize: 14,
      ),
    );
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
                          _store.editingEventId != null
                              ? language.lblEditEvent
                              : language.lblAddEvent,
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
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Form Card
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                                      borderRadius: BorderRadius.circular(16),
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
                                                        .withValues(alpha: 0.2),
                                                    const Color(0xFF5457E6)
                                                        .withValues(alpha: 0.1)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Iconsax.calendar_edit,
                                                color: Color(0xFF696CFF),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              language.lblEventDetails,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1F2937),
                                              ),
                                            ),
                                          ],
                                        ),
                                        24.height,

                                        // Title Field
                                        TextFormField(
                                          controller: _store.titleController,
                                          decoration: _buildInputDecoration(
                                              language.lblTitle,
                                              Iconsax.text,
                                              isDark),
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                          validator: (s) => s.isEmptyOrNull
                                              ? language.lblTitleIsRequired
                                              : null,
                                        ),
                                        16.height,

                                        // Event Type Dropdown
                                        Observer(
                                          builder: (_) =>
                                              DropdownButtonFormField<String>(
                                            value: _store.eventTypes.contains(
                                                    _store.selectedEventType)
                                                ? _store.selectedEventType
                                                : null,
                                            items: _store.eventTypes
                                                .map((type) => DropdownMenuItem(
                                                    value: type,
                                                    child: Text(type)))
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                _store.selectedEventType =
                                                    value;
                                              }
                                            },
                                            decoration: _buildInputDecoration(
                                                language.lblType,
                                                Iconsax.category,
                                                isDark),
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1F2937),
                                            ),
                                            dropdownColor: isDark
                                                ? const Color(0xFF1F2937)
                                                : Colors.white,
                                            validator: (s) =>
                                                s == null || s.isEmpty
                                                    ? language.lblEventTypeIsRequired
                                                    : null,
                                          ),
                                        ),
                                        16.height,

                                        // Date Row
                                        Row(
                                          children: [
                                            // Start Date
                                            Expanded(
                                              child: Observer(
                                                builder: (_) => InkWell(
                                                  onTap: () =>
                                                      _selectStartDate(context),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 16),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1F2937)
                                                          : const Color(
                                                              0xFFF9FAFB),
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
                                                        const Icon(
                                                            Iconsax.calendar,
                                                            color: Color(
                                                                0xFF696CFF),
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            _store.selectedStartDate !=
                                                                    null
                                                                ? DateFormat(
                                                                        'yyyy-MM-dd HH:mm')
                                                                    .format(_store
                                                                        .selectedStartDate!)
                                                                : language.lblStartDate,
                                                            style: TextStyle(
                                                              color: _store.selectedStartDate !=
                                                                      null
                                                                  ? (isDark
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFF1F2937))
                                                                  : (isDark
                                                                      ? Colors.grey[
                                                                          400]
                                                                      : const Color(
                                                                          0xFF6B7280)),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            16.width,
                                            // End Date
                                            Expanded(
                                              child: Observer(
                                                builder: (_) => InkWell(
                                                  onTap: () =>
                                                      _selectEndDate(context),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 16),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1F2937)
                                                          : const Color(
                                                              0xFFF9FAFB),
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
                                                        const Icon(
                                                            Iconsax.calendar,
                                                            color: Color(
                                                                0xFF696CFF),
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            _store.selectedEndDate !=
                                                                    null
                                                                ? DateFormat(
                                                                        'yyyy-MM-dd HH:mm')
                                                                    .format(_store
                                                                        .selectedEndDate!)
                                                                : language.lblEndDate,
                                                            style: TextStyle(
                                                              color: _store.selectedEndDate !=
                                                                      null
                                                                  ? (isDark
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFF1F2937))
                                                                  : (isDark
                                                                      ? Colors.grey[
                                                                          400]
                                                                      : const Color(
                                                                          0xFF6B7280)),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        16.height,

                                        // All Day Toggle
                                        Observer(
                                          builder: (_) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFFF9FAFB),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.grey[700]!
                                                    : const Color(0xFFE5E7EB),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  language.lblAllDayEvent,
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1F2937),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Switch(
                                                  value: _store.isAllDay,
                                                  onChanged: (val) => _store
                                                      .toggleAllDay(val),
                                                  activeColor:
                                                      const Color(0xFF696CFF),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        16.height,

                                        // Attendees MultiSelect
                                        Observer(
                                          builder: (_) =>
                                              MultiSelectDialogField<User>(
                                            items: _store.userList
                                                .map((user) => MultiSelectItem(
                                                    user, user.fullName))
                                                .toList(),
                                            initialValue: _store
                                                .selectedAttendees
                                                .toList(),
                                            title: Text(language.lblAttendees),
                                            searchable: true,
                                            buttonText: Text(
                                              language.lblSelectAttendees,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF6B7280),
                                                fontSize: 14,
                                              ),
                                            ),
                                            buttonIcon: const Icon(
                                                Iconsax.people,
                                                color: Color(0xFF696CFF),
                                                size: 20),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFFF9FAFB),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.grey[700]!
                                                    : const Color(0xFFE5E7EB),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            chipDisplay:
                                                MultiSelectChipDisplay(
                                              items: _store.selectedAttendees
                                                  .map((user) =>
                                                      MultiSelectItem(
                                                          user, user.fullName))
                                                  .toList(),
                                              onTap: (value) {
                                                _store.selectedAttendees
                                                    .remove(value);
                                              },
                                              chipColor: const Color(0xFF696CFF)
                                                  .withOpacity(0.1),
                                              textStyle: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF696CFF),
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF696CFF),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onConfirm: (results) {
                                              _store.updateSelectedAttendees(
                                                  results);
                                            },
                                          ),
                                        ),
                                        16.height,

                                        // Location Field
                                        TextFormField(
                                          controller: _store.locationController,
                                          decoration: _buildInputDecoration(
                                              language.lblLocation,
                                              Iconsax.location,
                                              isDark),
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        16.height,

                                        // Description Field
                                        TextFormField(
                                          controller:
                                              _store.descriptionController,
                                          decoration: _buildInputDecoration(
                                              language.lblDescription,
                                              Iconsax.note,
                                              isDark),
                                          maxLines: 3,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        20.height,

                                        // Color Selector
                                        _buildColorSelector(),
                                      ],
                                    ),
                                  ),
                                  32.height,

                                  // Submit Button
                                  Observer(
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: InkWell(
                                        onTap: _store.isLoading
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    !_store.isLoading) {
                                                  hideKeyboard(context);
                                                  bool success =
                                                      await _store.saveEvent();
                                                  if (success &&
                                                      context.mounted) {
                                                    Navigator.pop(
                                                        context, true);
                                                  }
                                                } else if (!_store.isLoading) {
                                                  toast(
                                                      language.lblPleaseFillAllRequiredFields);
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(14),
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
                                          ),
                                          child: Center(
                                            child: _store.isLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : Text(
                                                    _store.editingEventId !=
                                                            null
                                                        ? language.lblUpdate
                                                        : language.lblSubmit,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  24.height,
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
