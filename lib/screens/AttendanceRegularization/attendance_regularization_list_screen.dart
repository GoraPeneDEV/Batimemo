import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../models/Attendance/attendance_regularization.dart';
import '../../models/Attendance/regularization_type.dart';
import '../../utils/string_extensions.dart';
import 'attendance_regularization_store.dart';
import 'attendance_regularization_form_screen.dart';
import 'attendance_regularization_detail_screen.dart';

class AttendanceRegularizationListScreen extends StatefulWidget {
  const AttendanceRegularizationListScreen({super.key});

  @override
  State<AttendanceRegularizationListScreen> createState() =>
      _AttendanceRegularizationListScreenState();
}

class _AttendanceRegularizationListScreenState
    extends State<AttendanceRegularizationListScreen>
    with SingleTickerProviderStateMixin {
  final AttendanceRegularizationStore _store =
      AttendanceRegularizationStore();

  late TabController _tabController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    _store.pagingController.addPageRequestListener((pageKey) {
      _store.fetchRegularizations(pageKey);
    });

    // Load initial data
    _store.getCounts();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          _store.setStatusFilter(null);
          _selectedStatus = null;
          break;
        case 1:
          _store.setStatusFilter('pending');
          _selectedStatus = 'pending';
          break;
        case 2:
          _store.setStatusFilter('approved');
          _selectedStatus = 'approved';
          break;
        case 3:
          _store.setStatusFilter('rejected');
          _selectedStatus = 'rejected';
          break;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _store.pagingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showFilterPopup(BuildContext context) async {
    await _store.getRegularizationTypes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF1F2937)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        String? tempType = _store.selectedType;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: appStore.isDarkModeOn
                              ? Colors.grey[700]
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language.lblFilterRegularization,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Type Filter
                    Text(
                      language.lblRegularizationType,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: appStore.isDarkModeOn
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Observer(
                      builder: (_) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(language.lblAllTypes, tempType == null, () {
                            setModalState(() => tempType = null);
                          }),
                          ..._store.regularizationTypes.map((type) {
                            return _buildFilterChip(
                              type.label,
                              tempType == type.value,
                              () {
                                setModalState(() => tempType =
                                    tempType == type.value ? null : type.value);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _store.setTypeFilter(tempType);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF696CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          language.lblApplyFilters,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF696CFF)
              : (appStore.isDarkModeOn
                  ? const Color(0xFF111827)
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF696CFF)
                : (appStore.isDarkModeOn
                    ? Colors.grey[700]!
                    : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (appStore.isDarkModeOn
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Iconsax.clock;
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'missing_checkin':
        return Iconsax.login;
      case 'missing_checkout':
        return Iconsax.logout;
      case 'wrong_time':
        return Iconsax.clock;
      case 'forgot_punch':
        return Iconsax.timer;
      case 'other':
        return Iconsax.note;
      default:
        return Iconsax.calendar_edit;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.capitalize,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularizationCard(AttendanceRegularization regularization) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appStore.isDarkModeOn
              ? Colors.grey[700]!
              : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          AttendanceRegularizationDetailScreen(regularizationId: regularization.id)
              .launch(context)
              .then((_) {
            _store.pagingController.refresh();
            _store.getCounts();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF696CFF).withOpacity(0.8),
                          const Color(0xFF5457E6).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(regularization.type),
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
                          regularization.typeLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Iconsax.calendar_1,
                              size: 14,
                              color: appStore.isDarkModeOn
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              regularization.date,
                              style: TextStyle(
                                fontSize: 13,
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[400]
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(regularization.status),
                ],
              ),
              const SizedBox(height: 12),
              if (regularization.requestedCheckInTime != null ||
                  regularization.requestedCheckOutTime != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: appStore.isDarkModeOn
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      if (regularization.requestedCheckInTime != null) ...[
                        Icon(
                          Iconsax.login,
                          size: 16,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          regularization.requestedCheckInTime!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                      if (regularization.requestedCheckInTime != null &&
                          regularization.requestedCheckOutTime != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Iconsax.arrow_right_3,
                            size: 14,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[600]
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      if (regularization.requestedCheckOutTime != null) ...[
                        Icon(
                          Iconsax.logout,
                          size: 16,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          regularization.requestedCheckOutTime!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (regularization.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  regularization.reason,
                  style: TextStyle(
                    fontSize: 13,
                    color: appStore.isDarkModeOn
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (regularization.attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Iconsax.document_text,
                      size: 14,
                      color: appStore.isDarkModeOn
                          ? Colors.grey[500]
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${regularization.attachments.length} attachment${regularization.attachments.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn
                            ? Colors.grey[500]
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
              if (regularization.isPending && regularization.canEdit) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final result = await AttendanceRegularizationFormScreen(
                          regularization: regularization,
                        ).launch(context);
                        if (result == true) {
                          _store.pagingController.refresh();
                          _store.getCounts();
                        }
                      },
                      icon: const Icon(Iconsax.edit, size: 16),
                      label: Text(
                        language.lblEdit,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF696CFF),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showConfirmDialogCustom(
                          context,
                          title: language.lblAreYouSureToDeleteRequest,
                          dialogType: DialogType.CONFIRMATION,
                          positiveText: language.lblYes,
                          negativeText: language.lblNo,
                          onAccept: (c) async {
                            final success = await _store
                                .deleteRegularization(regularization.id);
                            if (success) {
                              _store.pagingController.refresh();
                              _store.getCounts();
                            }
                          },
                        );
                      },
                      icon: const Icon(Iconsax.trash, size: 16),
                      label: Text(
                        language.lblDelete,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Shimmer.fromColors(
            baseColor: appStore.isDarkModeOn
                ? Colors.grey[800]!
                : const Color(0xFFE5E7EB),
            highlightColor: appStore.isDarkModeOn
                ? Colors.grey[700]!
                : const Color(0xFFF9FAFB),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: appStore.isDarkModeOn
                              ? Colors.grey[800]
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[800]
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 12,
                              decoration: BoxDecoration(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[800]
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: appStore.isDarkModeOn
                              ? Colors.grey[800]
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: appStore.isDarkModeOn
                          ? Colors.grey[800]
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
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
                          language.lblRegularizationRequests,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.filter, color: Colors.white),
                          onPressed: () => _showFilterPopup(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                          // Status Tabs
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appStore.isDarkModeOn
                                    ? Colors.grey[700]!
                                    : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            child: Observer(
                              builder: (_) {
                                final counts = _store.counts;
                                return Row(
                                  children: [
                                    _buildStatusTab(
                                      language.lblAll,
                                      counts?.total,
                                      _selectedStatus == null,
                                      () {
                                        _tabController.animateTo(0);
                                      },
                                    ),
                                    _buildStatusTab(
                                      language.lblPending,
                                      counts?.pending,
                                      _selectedStatus == 'pending',
                                      () {
                                        _tabController.animateTo(1);
                                      },
                                    ),
                                    _buildStatusTab(
                                      language.lblApproved,
                                      counts?.approved,
                                      _selectedStatus == 'approved',
                                      () {
                                        _tabController.animateTo(2);
                                      },
                                    ),
                                    _buildStatusTab(
                                      language.lblRejected,
                                      counts?.rejected,
                                      _selectedStatus == 'rejected',
                                      () {
                                        _tabController.animateTo(3);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // Active Filters
                          Observer(
                            builder: (_) {
                              final hasTypeFilter = _store.selectedType != null;

                              if (!hasTypeFilter) return const SizedBox();

                              return Container(
                                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF696CFF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF696CFF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.filter,
                                      size: 16,
                                      color: Color(0xFF696CFF),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Type: ${_store.regularizationTypes.firstWhere((t) => t.value == _store.selectedType, orElse: () => RegularizationType(value: '', label: 'Unknown')).label}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: appStore.isDarkModeOn
                                              ? Colors.white
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _store.setTypeFilter(null),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          language.lblClear,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // List
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                _store.pagingController.refresh();
                                await _store.getCounts();
                              },
                              child: PagedListView<int, AttendanceRegularization>(
                                padding: const EdgeInsets.all(16),
                                pagingController: _store.pagingController,
                                builderDelegate:
                                    PagedChildBuilderDelegate<AttendanceRegularization>(
                                  noItemsFoundIndicatorBuilder: (context) =>
                                      Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
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
                                                  const Color(0xFF696CFF)
                                                      .withOpacity(0.2),
                                                  const Color(0xFF696CFF)
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Iconsax.calendar_edit,
                                              size: 60,
                                              color: const Color(0xFF696CFF)
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            language.lblNoRequestsFound,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: appStore.isDarkModeOn
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            language.lblNoRegularizationRequestsFound,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: appStore.isDarkModeOn
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  firstPageProgressIndicatorBuilder: (context) =>
                                      _buildLoadingSkeleton(),
                                  itemBuilder: (context, regularization, index) {
                                    return _buildRegularizationCard(regularization);
                                  },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await const AttendanceRegularizationFormScreen().launch(context);
          if (result == true) {
            _store.pagingController.refresh();
            _store.getCounts();
          }
        },
        backgroundColor: const Color(0xFF696CFF),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          language.lblCreateRequest,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, int? count, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF696CFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count != null ? '$label ($count)' : label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : (appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }
}
