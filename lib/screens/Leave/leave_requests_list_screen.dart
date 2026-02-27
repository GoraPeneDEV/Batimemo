import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../stores/leave_store.dart';
import '../../models/leave/leave_request.dart';
import '../../utils/app_colors.dart';
import '../../utils/string_extensions.dart';
import 'leave_request_detail_screen.dart';
import 'leave_request_form_screen.dart';

class LeaveRequestsListScreen extends StatefulWidget {
  final String? initialStatus;

  const LeaveRequestsListScreen({super.key, this.initialStatus});

  @override
  State<LeaveRequestsListScreen> createState() =>
      _LeaveRequestsListScreenState();
}

class _LeaveRequestsListScreenState extends State<LeaveRequestsListScreen> {
  late LeaveStore _leaveStore;
  final ScrollController _scrollController = ScrollController();

  String? _selectedStatus;
  int? _selectedYear;
  int? _selectedLeaveTypeId;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _leaveStore = Provider.of<LeaveStore>(context, listen: false);
    _selectedStatus = widget.initialStatus;
    _selectedYear = DateTime.now().year;
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _leaveStore.fetchLeaveRequests(
      skip: 0,
      take: _pageSize,
      status: _selectedStatus,
      year: _selectedYear,
      leaveTypeId: _selectedLeaveTypeId,
    );
    _currentPage = 0;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_leaveStore.isLoading) {
      if (_leaveStore.leaveRequests.length <
          _leaveStore.totalLeaveRequestsCount) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _leaveStore.fetchLeaveRequests(
      skip: _currentPage * _pageSize,
      take: _pageSize,
      status: _selectedStatus,
      year: _selectedYear,
      leaveTypeId: _selectedLeaveTypeId,
      loadMore: true,
    );
    setState(() => _isLoadingMore = false);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appStore.isDarkModeOn
          ? const Color(0xFF1F2937)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    String? tempStatus = _selectedStatus;
    int? tempYear = _selectedYear;
    int? tempLeaveTypeId = _selectedLeaveTypeId;

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
                    language.lblFilterLeaveRequests,
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

              // Status Filter
              Text(
                language.lblStatus,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(language.lblAll, tempStatus == null, () {
                    setModalState(() => tempStatus = null);
                  }),
                  _buildFilterChip(language.lblPending, tempStatus == 'pending', () {
                    setModalState(() =>
                        tempStatus = tempStatus == 'pending' ? null : 'pending');
                  }),
                  _buildFilterChip(language.lblApproved, tempStatus == 'approved', () {
                    setModalState(() => tempStatus =
                        tempStatus == 'approved' ? null : 'approved');
                  }),
                  _buildFilterChip(language.lblRejected, tempStatus == 'rejected', () {
                    setModalState(() => tempStatus =
                        tempStatus == 'rejected' ? null : 'rejected');
                  }),
                  _buildFilterChip(language.lblCancelled, tempStatus == 'cancelled', () {
                    setModalState(() => tempStatus =
                        tempStatus == 'cancelled' ? null : 'cancelled');
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Year Filter
              Text(
                language.lblYear,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return _buildFilterChip(
                    year.toString(),
                    tempYear == year,
                    () {
                      setModalState(
                          () => tempYear = tempYear == year ? null : year);
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Leave Type Filter
              if (_leaveStore.leaveTypes.isNotEmpty) ...[
                Text(
                  language.lblLeaveType,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkModeOn
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(language.lblAllTypes, tempLeaveTypeId == null, () {
                      setModalState(() => tempLeaveTypeId = null);
                    }),
                    ..._leaveStore.leaveTypes.map((type) {
                      return _buildFilterChip(
                        type.name,
                        tempLeaveTypeId == type.id,
                        () {
                          setModalState(() => tempLeaveTypeId =
                              tempLeaveTypeId == type.id ? null : type.id);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _selectedYear = tempYear;
                      _selectedLeaveTypeId = tempLeaveTypeId;
                    });
                    Navigator.pop(context);
                    _loadData();
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
                    style: const TextStyle(
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
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending') {
      return Colors.orange;
    } else if (statusLower == 'approved') {
      return Colors.green;
    } else if (statusLower == 'rejected') {
      return Colors.red;
    } else if (statusLower.startsWith('cancelled')) {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'pending') {
      return Iconsax.clock;
    } else if (statusLower == 'approved') {
      return Iconsax.tick_circle;
    } else if (statusLower == 'rejected') {
      return Iconsax.close_circle;
    } else if (statusLower.startsWith('cancelled')) {
      return Iconsax.minus_cirlce;
    } else {
      return Iconsax.info_circle;
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
            status.replaceAll('_', ' ').titleCase,
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: _leaveStore,
                child: LeaveRequestDetailScreen(leaveRequestId: request.id),
              ),
            ),
          ).then((_) => _loadData());
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF696CFF).withOpacity(0.2),
                          const Color(0xFF5457E6).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.calendar,
                      color: Color(0xFF696CFF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.leaveType.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Request #${request.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF111827)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          size: 16,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatDate(request.fromDate)} - ${_formatDate(request.toDate)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: appStore.isDarkModeOn
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 16,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${request.totalDays} ${request.totalDays > 1 ? language.lblDays : language.lblDay}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (request.isHalfDay) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Iconsax.timer_1,
                                  size: 12,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  language.lblHalfDay,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[600]
                              : const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
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
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 70,
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
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          language.lblMyLeaves,
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
                          onPressed: _showFilterSheet,
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
                          // Filter summary
                          if (_selectedStatus != null ||
                              _selectedLeaveTypeId != null ||
                              _selectedYear != DateTime.now().year)
                            Container(
                              margin: const EdgeInsets.all(16),
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
                                      'Filters: ${_selectedStatus?.capitalize ?? ''} ${_selectedYear != null && _selectedYear != DateTime.now().year ? 'Year $_selectedYear' : ''}',
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
                                    onTap: () {
                                      setState(() {
                                        _selectedStatus = null;
                                        _selectedYear = DateTime.now().year;
                                        _selectedLeaveTypeId = null;
                                      });
                                      _loadData();
                                    },
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
                            ),

                          // List
                          Expanded(
                            child: _buildContent(),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Provider.value(
                value: _leaveStore,
                child: const LeaveRequestFormScreen(),
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF696CFF),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          language.lblNewRequest,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_leaveStore.isLoading && _leaveStore.leaveRequests.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (_leaveStore.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.close_circle,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblErrorLoadingRequests,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _leaveStore.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Iconsax.refresh, color: Colors.white),
                label: Text(
                  language.lblRetry,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF696CFF),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_leaveStore.leaveRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: appStore.isDarkModeOn
                      ? const Color(0xFF1F2937)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.calendar_remove,
                  size: 64,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                language.lblNoLeaveRequests,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkModeOn
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language.lblApplyForLeaveToSeeHere,
                style: TextStyle(
                  fontSize: 14,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            _leaveStore.leaveRequests.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _leaveStore.leaveRequests.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      appStore.isDarkModeOn
                          ? Colors.white
                          : const Color(0xFF696CFF),
                    ),
                  ),
                ),
              ),
            );
          }

          return _buildLeaveRequestCard(_leaveStore.leaveRequests[index]);
        },
      ),
    );
  }
}
