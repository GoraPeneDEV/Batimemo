import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_core_hr/utils/date_utils.dart';

import '../../Utils/app_widgets.dart';
import '../../main.dart';
import '../../models/holiday_model.dart';
import 'holiday_store.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen>
    with SingleTickerProviderStateMixin {
  final HolidayStore _store = HolidayStore();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchHolidays(pageKey);
    });
    _store.fetchUpcomingHolidays();
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    final isDark = appStore.isDarkModeOn;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.lblFilters, style: boldTextStyle(size: 20)),
                      20.height,
                      // Year Filter
                      TextField(
                        controller: _store.yearFilterController,
                        decoration: InputDecoration(
                          labelText: language.lblFilterByYear,
                          prefixIcon: const Icon(Iconsax.calendar),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _store.yearFilterController.clear();
                              _store.yearFilter = null;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF696CFF),
                              width: 2,
                            ),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          hideKeyboard(context);
                          showYearPicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 10),
                            initialDate: DateTime.now(),
                          ).then((value) {
                            if (value != null) {
                              _store.yearFilterController.text = value
                                  .toString();
                            }
                          });
                        },
                      ),
                      16.height,
                      // Type Filter
                      TextField(
                        controller: _store.typeFilterController,
                        decoration: InputDecoration(
                          labelText: language.lblFilterByType,
                          prefixIcon: const Icon(Iconsax.category),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _store.typeFilterController.clear();
                              _store.typeFilter = null;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF696CFF),
                              width: 2,
                            ),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          hideKeyboard(context);
                          final types = [
                            'public',
                            'religious',
                            'regional',
                            'optional',
                            'company',
                            'special',
                          ];
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(language.lblSelectType),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: types
                                    .map(
                                      (type) => ListTile(
                                        title: Text(
                                          type.capitalizeFirstLetter(),
                                        ),
                                        onTap: () {
                                          _store.typeFilterController.text =
                                              type.capitalizeFirstLetter();
                                          _store.typeFilter = type;
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      24.height,
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _store.clearFilters();
                                _store.pagingController.refresh();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                language.lblReset,
                                style: boldTextStyle(
                                  color: Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF696CFF),
                                    Color(0xFF5457E6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (_store
                                      .yearFilterController
                                      .text
                                      .isNotEmpty) {
                                    _store.yearFilter = int.parse(
                                      _store.yearFilterController.text,
                                    );
                                  }
                                  _store.pagingController.refresh();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  language.lblApply,
                                  style: boldTextStyle(
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Text(
                            language.lblHolidays,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Filter Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Iconsax.filter,
                              color: Colors.white,
                            ),
                            onPressed: () => _showFilterPopup(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content Area with TabBar
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
                        child: Column(
                          children: [
                            // TabBar inside the content area
                            Container(
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              child: TabBar(
                                controller: _tabController,
                                indicatorColor: const Color(0xFF696CFF),
                                labelColor: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                unselectedLabelColor: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                indicatorWeight: 3,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                tabs: [
                                  Tab(
                                    icon: const Icon(Iconsax.calendar_1),
                                    text: language.lblAll,
                                    height: 48,
                                  ),
                                  Tab(
                                    icon: const Icon(Iconsax.clock),
                                    text: language.lblUpcoming,
                                    height: 48,
                                  ),
                                  Tab(
                                    icon: const Icon(Iconsax.element_3),
                                    text: language.lblGrouped,
                                    height: 48,
                                  ),
                                ],
                              ),
                            ),
                            // Divider
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.grey[700]
                                  : const Color(0xFFE5E7EB),
                            ),
                            // TabBarView content
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildAllHolidaysTab(),
                                  _buildUpcomingHolidaysTab(),
                                  _buildGroupedHolidaysTab(),
                                ],
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
    );
  }

  Widget _buildAllHolidaysTab() {
    final isDark = appStore.isDarkModeOn;
    return Column(
      children: [
        Observer(
          builder: (_) {
            return _store.yearFilter != null || _store.typeFilter != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_store.yearFilter != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF696CFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${language.lblPeriod}: ${_store.yearFilter}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    _store.yearFilterController.clear();
                                    _store.yearFilter = null;
                                    _store.pagingController.refresh();
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_store.typeFilter != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF696CFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${language.lblType}: ${_store.typeFilter?.capitalizeFirstLetter()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    _store.typeFilterController.clear();
                                    _store.typeFilter = null;
                                    _store.pagingController.refresh();
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox();
          },
        ),
        Expanded(
          child: PagedListView<int, HolidayModel>(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            pagingController: _store.pagingController,
            builderDelegate: PagedChildBuilderDelegate<HolidayModel>(
              noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(
                icon: Iconsax.calendar_1,
                title: language.lblNoHolidaysFound,
                subtitle: language.lblNoHolidaysFoundForThisYear,
              ),
              firstPageProgressIndicatorBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF696CFF)),
              ),
              newPageProgressIndicatorBuilder: (context) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Color(0xFF696CFF)),
                ),
              ),
              itemBuilder: (context, holiday, index) =>
                  _buildHolidayCard(holiday),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingHolidaysTab() {
    return Observer(
      builder: (_) {
        if (_store.isLoadingUpcoming) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF696CFF)),
          );
        }

        if (_store.upcomingHolidays.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.clock,
            title: language.lblNoUpcomingHolidays,
            subtitle: language.lblNoUpcomingHolidaysMessage,
          );
        }

        return RefreshIndicator(
          onRefresh: () => _store.fetchUpcomingHolidays(),
          color: const Color(0xFF696CFF),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _store.upcomingHolidays.length,
            itemBuilder: (context, index) {
              return _buildHolidayCard(_store.upcomingHolidays[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupedHolidaysTab() {
    return Observer(
      builder: (_) {
        if (_store.groupedHolidays == null) {
          _store.fetchGroupedHolidays();
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF696CFF)),
          );
        }

        if (_store.isLoadingGrouped) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF696CFF)),
          );
        }

        if (_store.groupedHolidays!.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.element_3,
            title: language.lblNoHolidaysFound,
            subtitle: language.lblNoHolidaysToDisplay,
          );
        }

        return RefreshIndicator(
          onRefresh: () => _store.fetchGroupedHolidays(),
          color: const Color(0xFF696CFF),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _store.groupedHolidays!.length,
            itemBuilder: (context, index) {
              final month = _store.groupedHolidays!.keys.elementAt(index);
              final holidays = _store.groupedHolidays![month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(month, style: boldTextStyle(size: 18)),
                  ),
                  ...holidays.map((holiday) => _buildHolidayCard(holiday)),
                  16.height,
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = appStore.isDarkModeOn;
    return Center(
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
                  const Color(0xFF5457E6).withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: const Color(0xFF696CFF).withOpacity(0.7),
            ),
          ),
          24.height,
          Text(title, style: boldTextStyle(size: 20)),
          8.height,
          Text(
            subtitle,
            style: secondaryTextStyle(size: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Modern Card UI for each holiday
  Widget _buildHolidayCard(HolidayModel holiday) {
    final isDark = appStore.isDarkModeOn;
    final inputFormat = DateFormat('dd-MM-yyyy');
    final date = inputFormat.parse(holiday.date);
    final day = date.day;
    final month = date.monthName;

    // Parse color from API or use default
    Color cardColor = const Color(0xFF696CFF);
    if (holiday.color != null && holiday.color!.isNotEmpty) {
      try {
        cardColor = Color(int.parse(holiday.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        cardColor = const Color(0xFF696CFF);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showHolidayDetails(holiday);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Card with gradient background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor.withOpacity(0.8), cardColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      month.substring(0, 3).toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
              16.width,

              // Holiday Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            holiday.name,
                            style: boldTextStyle(size: 16),
                          ),
                        ),
                        if (holiday.isOptional == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              language.lblOptionalHoliday,
                              style: secondaryTextStyle(
                                size: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    4.height,
                    Text(holiday.day, style: secondaryTextStyle(size: 13)),
                    if (holiday.type != null) ...[
                      4.height,
                      Row(
                        children: [
                          Icon(
                            _getHolidayTypeIcon(holiday.type!),
                            size: 14,
                            color: cardColor,
                          ),
                          4.width,
                          Text(
                            holiday.type!.capitalizeFirstLetter(),
                            style: secondaryTextStyle(
                              size: 12,
                              color: cardColor,
                            ),
                          ),
                          if (holiday.isHalfDay == true) ...[
                            8.width,
                            Icon(Iconsax.clock, size: 14, color: Colors.blue),
                            4.width,
                            Text(
                              language.lblHalfDay,
                              style: secondaryTextStyle(
                                size: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (holiday.description != null &&
                        holiday.description!.isNotEmpty) ...[
                      4.height,
                      Text(
                        holiday.description!,
                        style: secondaryTextStyle(size: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getHolidayTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'public':
        return Iconsax.flag;
      case 'religious':
        return Iconsax.moon;
      case 'regional':
        return Iconsax.location;
      case 'optional':
        return Iconsax.info_circle;
      case 'company':
        return Iconsax.building;
      case 'special':
        return Iconsax.star_1;
      default:
        return Iconsax.calendar;
    }
  }

  void _showHolidayDetails(HolidayModel holiday) {
    final isDark = appStore.isDarkModeOn;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(holiday.name, style: boldTextStyle(size: 18)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', holiday.date),
              _buildDetailRow('Day', holiday.day),
              if (holiday.type != null)
                _buildDetailRow('Type', holiday.type!.capitalizeFirstLetter()),
              if (holiday.category != null)
                _buildDetailRow(
                  'Category',
                  holiday.category!.capitalizeFirstLetter(),
                ),
              if (holiday.isOptional == true)
                _buildDetailRow('Status', 'Optional Holiday'),
              if (holiday.isHalfDay == true)
                _buildDetailRow('Duration', language.lblHalfDay),
              if (holiday.description != null &&
                  holiday.description!.isNotEmpty) ...[
                16.height,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]!.withOpacity(0.3)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey[700]!
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 16,
                            color: const Color(0xFF696CFF),
                          ),
                          8.width,
                          Text('${language.lblDescription}:', style: boldTextStyle(size: 14)),
                        ],
                      ),
                      8.height,
                      Text(
                        holiday.description!,
                        style: secondaryTextStyle(size: 13),
                      ),
                    ],
                  ),
                ),
              ],
              if (holiday.notes != null && holiday.notes!.isNotEmpty) ...[
                12.height,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]!.withOpacity(0.3)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey[700]!
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.note,
                            size: 16,
                            color: const Color(0xFF696CFF),
                          ),
                          8.width,
                          Text('${language.lblNotes}:', style: boldTextStyle(size: 14)),
                        ],
                      ),
                      8.height,
                      Text(holiday.notes!, style: secondaryTextStyle(size: 13)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF696CFF), Color(0xFF5457E6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                language.lblClose,
                style: boldTextStyle(color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = appStore.isDarkModeOn;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: boldTextStyle(size: 13)),
          ),
          Expanded(child: Text(value, style: secondaryTextStyle(size: 13))),
        ],
      ),
    );
  }
}
