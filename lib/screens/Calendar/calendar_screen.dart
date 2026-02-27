import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/screens/Calendar/calendar_store.dart'; // Adjust import path
import 'package:open_core_hr/screens/Calendar/widgets/event_add_edit_sheet.dart'; // Create this widget
import 'package:open_core_hr/screens/Calendar/widgets/event_view_sheet.dart'; // Create this widget
import 'package:open_core_hr/utils/app_widgets.dart'; // Your common widgets
import 'package:table_calendar/table_calendar.dart';

import '../../main.dart'; // For language, appStore etc.
import '../../models/calendar_event_model.dart'; // Event model

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarStore _store = CalendarStore();

  @override
  void initState() {
    super.initState();
    _store.init(); // Fetch initial data
  }

  // Function to show event details bottom sheet
  void _showEventDetails(CalendarEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take more height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EventViewSheet(
        event: event,
        store: _store,
        onEdit: _showAddEditSheet,
      ), // Pass event and store
    );
  }

  // Function to show add/edit bottom sheet
  void _showAddEditSheet({DateTime? selectedDate, CalendarEventModel? event}) {
    if (event != null) {
      _store.prepareEditEvent(event); // Prepare store for editing
    } else {
      _store.prepareAddEvent(selectedDate); // Prepare store for adding
    }

    EventAddEditSheet(store: _store).launch(context).then((value) {
      if (value == true) {
        // Check if sheet indicated success
        _store.onPageChanged(_store.focusedDay);
      }
    });
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
                  // Header Section (56px fixed height)
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          language.lblCalendar,
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
                        color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                        child: Column(
                          children: [
                            // Calendar Section
                            Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TableCalendar<CalendarEventModel>(
                                firstDay: DateTime.utc(2010, 1, 1),
                                lastDay: DateTime.utc(2040, 12, 31),
                                focusedDay: _store.focusedDay,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_store.selectedDay, day),
                                rangeStartDay: _store.rangeStart,
                                rangeEndDay: _store.rangeEnd,
                                calendarFormat: _store.calendarFormat,
                                rangeSelectionMode: RangeSelectionMode.toggledOff,
                                eventLoader: _store.getEventsForDay,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF696CFF).withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF696CFF),
                                    shape: BoxShape.circle,
                                  ),
                                  defaultTextStyle: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  weekendTextStyle: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                  outsideTextStyle: TextStyle(
                                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                                  ),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                  formatButtonShowsNext: false,
                                  formatButtonDecoration: BoxDecoration(
                                    color: const Color(0xFF696CFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  formatButtonTextStyle: const TextStyle(
                                    color: Color(0xFF696CFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  titleTextStyle: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  weekendStyle: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onDaySelected: _store.onDaySelected,
                                onRangeSelected: _store.onRangeSelected,
                                onFormatChanged: _store.onFormatChanged,
                                onPageChanged: _store.onPageChanged,
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, date, events) {
                                    if (events.isNotEmpty) {
                                      return Positioned(
                                        right: 1,
                                        bottom: 1,
                                        child: _buildEventsMarker(date, events),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            // Events List Section
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: _store.isLoading && _store.selectedDayEvents.isEmpty
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: const Color(0xFF696CFF),
                                        ),
                                      )
                                    : _store.selectedDayEvents.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xFF696CFF).withOpacity(0.2),
                                                        const Color(0xFF696CFF).withOpacity(0.1),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Iconsax.calendar,
                                                    size: 60,
                                                    color: const Color(0xFF696CFF).withOpacity(0.7),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  language.lblNoEvents,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  language.lblNoEventsForSelectedDate,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: _store.selectedDayEvents.length,
                                            padding: const EdgeInsets.only(bottom: 80),
                                            itemBuilder: (context, index) {
                                              final event = _store.selectedDayEvents[index];
                                              final eventColor = _getEventColor(event);

                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1F2937)
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.grey[700]!
                                                        : const Color(0xFFE5E7EB),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: isDark
                                                          ? Colors.black.withOpacity(0.2)
                                                          : Colors.black.withOpacity(0.03),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(16),
                                                    onTap: () => _showEventDetails(event),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: Row(
                                                        children: [
                                                          // Gradient Icon Container
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  eventColor.withOpacity(0.8),
                                                                  eventColor.withOpacity(0.6),
                                                                ],
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                              Iconsax.calendar_1,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          // Event Details
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  event.title ?? language.lblNoTitle,
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: isDark
                                                                        ? Colors.white
                                                                        : Colors.black,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Iconsax.clock,
                                                                      size: 14,
                                                                      color: isDark
                                                                          ? Colors.grey[400]
                                                                          : Colors.grey[600],
                                                                    ),
                                                                    const SizedBox(width: 6),
                                                                    Text(
                                                                      DateFormat.jm().format(event.start!) +
                                                                          (event.end != null
                                                                              ? ' - ${DateFormat.jm().format(event.end!)}'
                                                                              : ''),
                                                                      style: TextStyle(
                                                                        fontSize: 13,
                                                                        color: isDark
                                                                            ? Colors.grey[400]
                                                                            : Colors.grey[600],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.chevron_right,
                                                            color: isDark
                                                                ? Colors.grey[600]
                                                                : Colors.grey[400],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
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
          );
        },
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton.extended(
          backgroundColor: const Color(0xFF696CFF),
          onPressed: () => _showAddEditSheet(
            selectedDate: _store.selectedDay ?? DateTime.now(),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            language.lblCreate,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build event markers (e.g., dots)
  Widget _buildEventsMarker(DateTime date, List<CalendarEventModel> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF696CFF),
      ),
      width: 6.0,
      height: 6.0,
    );
  }

  // Helper to get event color for list tile
  Color _getEventColor(CalendarEventModel event) {
    final manualColorHex = event.color;
    final manualColor = event.color;
    final eventType = event.eventType;
    String? typeColorHex =
        _store.eventTypeColors[eventType ?? '']; // Access store map

    Color finalColor = Colors.grey.shade600; // Default

    try {
      String? colorToParse = manualColor != null && manualColor.isNotEmpty
          ? manualColor
          : typeColorHex;
      if (colorToParse != null && colorToParse.isNotEmpty) {
        // Ensure # prefix and correct length
        colorToParse =
            colorToParse.startsWith('#') ? colorToParse : '#$colorToParse';
        if (colorToParse.length == 7) {
          // #RRGGBB
          final colorValue = int.parse(colorToParse.substring(1), radix: 16);
          finalColor = Color(colorValue | 0xFF000000); // Add alpha
        } else if (colorToParse.length == 4) {
          // #RGB
          final r = colorToParse[1];
          final g = colorToParse[2];
          final b = colorToParse[3];
          final colorValue = int.parse('$r$r$g$g$b$b', radix: 16);
          finalColor = Color(colorValue | 0xFF000000);
        }
      }
    } catch (e) {
      log("Error parsing color for event ${event.id}: $e");
      // Keep default grey if parsing fails
    }
    return finalColor;
  }
}
