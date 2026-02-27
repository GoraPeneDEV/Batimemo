import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../main.dart';
import '../../../stores/project_store.dart';
import '../../../models/project/timesheet.dart';
import 'timesheet_detail_screen.dart';
import 'timesheet_form_screen.dart';

class TimesheetListScreen extends StatefulWidget {
  final int? initialProjectId;

  const TimesheetListScreen({super.key, this.initialProjectId});

  @override
  State<TimesheetListScreen> createState() => _TimesheetListScreenState();
}

class _TimesheetListScreenState extends State<TimesheetListScreen> {
  late ProjectStore _store;
  final ScrollController _scrollController = ScrollController();

  String? _selectedStatus;
  int? _selectedProjectId;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _selectedProjectId = widget.initialProjectId;
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _store.fetchTimesheets(
      skip: 0,
      take: _pageSize,
      status: _selectedStatus,
      projectId: _selectedProjectId,
    );
    _currentPage = 0;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_store.isLoading) {
      if (_store.timesheets.length < _store.totalTimesheetsCount) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _store.fetchTimesheets(
      skip: _currentPage * _pageSize,
      take: _pageSize,
      status: _selectedStatus,
      projectId: _selectedProjectId,
      loadMore: true,
    );
    setState(() => _isLoadingMore = false);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String? tempStatus = _selectedStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filtrer les feuilles de temps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Statut',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      null, 'draft', 'submitted', 'approved', 'rejected', 'invoiced'
                    ].map((s) {
                      final isSelected = tempStatus == s;
                      final label = s == null ? 'Tous' : {
                        'draft': 'Brouillon',
                        'submitted': 'Soumis',
                        'approved': 'Approuvé',
                        'rejected': 'Rejeté',
                        'invoiced': 'Facturé',
                      }[s]!;
                      return FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => setModalState(() => tempStatus = s),
                        selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF10B981),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedStatus = tempStatus);
                        Navigator.pop(context);
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Appliquer',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        title: Text(
          'Feuilles de temps',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.filter,
              color: _selectedStatus != null
                  ? const Color(0xFF10B981)
                  : (appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827)),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.timesheets.isEmpty) {
            return _buildLoadingSkeleton();
          }

          if (_store.error != null && _store.timesheets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 48, color: Colors.red.withOpacity(0.7)),
                  const SizedBox(height: 16),
                  Text(_store.error ?? 'Erreur'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Réessayer')),
                ],
              ),
            );
          }

          if (_store.timesheets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.document_text, size: 64,
                    color: appStore.isDarkModeOn ? Colors.grey[600] : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune feuille de temps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _store.timesheets.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == _store.timesheets.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                return _buildTimesheetCard(_store.timesheets[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Provider.value(
              value: _store,
              child: const TimesheetFormScreen(),
            ),
          ),
        ).then((_) => _loadData()),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text('Nouveau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTimesheetCard(Timesheet ts) {
    final statusColor = _getStatusColor(ts.status);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Provider.value(
            value: _store,
            child: TimesheetDetailScreen(timesheetId: ts.id),
          ),
        ),
      ).then((_) => _loadData()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.clock, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ts.projectName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Iconsax.calendar, size: 12,
                          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          ts.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                        if (ts.description != null && ts.description!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ts.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ts.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ts.formattedHours,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (ts.isBillable)
                    Row(
                      children: [
                        Icon(Iconsax.money, size: 12, color: Colors.green),
                        const SizedBox(width: 2),
                        const Text('Facturable', style: TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft': return Colors.grey;
      case 'submitted': return Colors.blue;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'invoiced': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
        highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
