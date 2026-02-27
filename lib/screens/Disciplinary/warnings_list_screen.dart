import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../api/dio_api/repositories/disciplinary_repository.dart';
import '../../locale/languages.dart';
import '../../models/disciplinary/warning_model.dart';
import '../../models/disciplinary/warning_type_model.dart';
import '../../utils/date_parser.dart';
import '../../utils/string_extensions.dart';
import 'warning_details_screen.dart';

class WarningsListScreen extends StatefulWidget {
  const WarningsListScreen({super.key});

  @override
  State<WarningsListScreen> createState() => _WarningsListScreenState();
}

class _WarningsListScreenState extends State<WarningsListScreen> {
  final DisciplinaryRepository _repository = DisciplinaryRepository();
  final ScrollController _scrollController = ScrollController();

  List<Warning> _warnings = [];
  List<WarningType> _warningTypes = [];
  Map<String, dynamic>? _statistics;
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String? _selectedStatus;
  int? _selectedWarningTypeId;
  DateTime? _fromDate;
  DateTime? _toDate;

  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadWarningTypes();
    _loadStatistics();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repository.getWarnings(
        skip: 0,
        take: _pageSize,
        status: _selectedStatus,
        warningTypeId: _selectedWarningTypeId,
        fromDate: _fromDate != null ? DateParser.formatDateForApi(_fromDate!) : null,
        toDate: _toDate != null ? DateParser.formatDateForApi(_toDate!) : null,
      );

      setState(() {
        _warnings = result['values'] ?? [];
        _totalCount = result['totalCount'] ?? 0;
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWarningTypes() async {
    try {
      final types = await _repository.getWarningTypes();
      setState(() {
        _warningTypes = types;
      });
    } catch (e) {
      // Silent fail for warning types
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _repository.getStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      // Silent fail for statistics
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading) {
      if (_warnings.length < _totalCount) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final result = await _repository.getWarnings(
        skip: _currentPage * _pageSize,
        take: _pageSize,
        status: _selectedStatus,
        warningTypeId: _selectedWarningTypeId,
        fromDate: _fromDate != null ? DateParser.formatDateForApi(_fromDate!) : null,
        toDate: _toDate != null ? DateParser.formatDateForApi(_toDate!) : null,
      );

      setState(() {
        _warnings.addAll(result['values'] ?? []);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
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
    int? tempWarningTypeId = _selectedWarningTypeId;
    DateTime? tempFromDate = _fromDate;
    DateTime? tempToDate = _toDate;

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
                      language.lblFilterWarnings,
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
                    _buildFilterChip(language.lblAllTypes, tempStatus == null, () {
                      setModalState(() => tempStatus = null);
                    }),
                    _buildFilterChip(language.lblIssued, tempStatus == 'issued', () {
                      setModalState(() => tempStatus = tempStatus == 'issued' ? null : 'issued');
                    }),
                    _buildFilterChip(language.lblAcknowledged, tempStatus == 'acknowledged', () {
                      setModalState(() => tempStatus = tempStatus == 'acknowledged' ? null : 'acknowledged');
                    }),
                    _buildFilterChip(language.lblAppealed, tempStatus == 'appealed', () {
                      setModalState(() => tempStatus = tempStatus == 'appealed' ? null : 'appealed');
                    }),
                    _buildFilterChip(language.lblExpired, tempStatus == 'expired', () {
                      setModalState(() => tempStatus = tempStatus == 'expired' ? null : 'expired');
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Warning Type Filter
                if (_warningTypes.isNotEmpty) ...[
                  Text(
                    language.lblWarningType,
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
                      _buildFilterChip(language.lblAllTypes, tempWarningTypeId == null, () {
                        setModalState(() => tempWarningTypeId = null);
                      }),
                      ..._warningTypes.map((type) {
                        return _buildFilterChip(
                          type.name,
                          tempWarningTypeId == type.id,
                          () {
                            setModalState(() => tempWarningTypeId =
                                tempWarningTypeId == type.id ? null : type.id);
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
                        _selectedWarningTypeId = tempWarningTypeId;
                        _fromDate = tempFromDate;
                        _toDate = tempToDate;
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
    if (statusLower == 'issued') {
      return Colors.orange;
    } else if (statusLower == 'acknowledged') {
      return Colors.blue;
    } else if (statusLower == 'appealed') {
      return const Color(0xFF9333EA); // Purple
    } else if (statusLower == 'expired') {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status, String statusLabel) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel.titleCase,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox.shrink();

    final pendingAcknowledgment = _statistics!['pendingAcknowledgment'] ?? 0;
    final activeWarnings = _statistics!['activeWarnings'] ?? 0;

    if (pendingAcknowledgment == 0 && activeWarnings == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appStore.isDarkModeOn
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFF696CFF), const Color(0xFF5457E6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (pendingAcknowledgment > 0) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingAcknowledgment',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.lblPendingAcknowledgment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pendingAcknowledgment > 0 && activeWarnings > 0)
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white24,
            ),
          if (activeWarnings > 0) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$activeWarnings',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language.lblActiveWarnings,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningCard(Warning warning) {
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
              builder: (_) => WarningDetailsScreen(warningId: warning.id),
            ),
          ).then((_) {
            _loadData();
            _loadStatistics();
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.warning_2,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warning.subject,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warning.warningNumber,
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
                  _buildStatusBadge(warning.status, warning.statusLabel),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(warning.warningType.severity)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            warning.warningType.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(warning.warningType.severity),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Iconsax.calendar,
                          size: 14,
                          color: appStore.isDarkModeOn
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateParser.parseDate(warning.issueDate) != null
                              ? DateParser.formatDate(
                                  DateParser.parseDate(warning.issueDate)!)
                              : warning.issueDate,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : const Color(0xFF111827),
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
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'verbal':
        return Colors.blue;
      case 'written':
        return Colors.orange;
      case 'final':
        return Colors.red;
      case 'termination':
        return Colors.black;
      default:
        return Colors.grey;
    }
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 40,
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
                          language.lblDisciplinaryWarnings,
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
                          // Statistics Card
                          _buildStatisticsCard(),

                          // Filter summary
                          if (_selectedStatus != null || _selectedWarningTypeId != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                      'Filters: ${_selectedStatus?.capitalize ?? 'All'}',
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
                                        _selectedWarningTypeId = null;
                                        _fromDate = null;
                                        _toDate = null;
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
    );
  }

  Widget _buildContent() {
    if (_isLoading && _warnings.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
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
                language.lblErrorLoadingWarnings,
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
                _error!,
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

    if (_warnings.isEmpty) {
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
                  Iconsax.document,
                  size: 64,
                  color: appStore.isDarkModeOn
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Warnings',
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
                'You have no disciplinary warnings',
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
        itemCount: _warnings.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _warnings.length) {
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

          return _buildWarningCard(_warnings[index]);
        },
      ),
    );
  }
}
