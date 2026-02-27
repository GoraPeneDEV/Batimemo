import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../main.dart';
import '../../../stores/project_store.dart';
import 'timesheet_form_screen.dart';

class TimesheetDetailScreen extends StatefulWidget {
  final int timesheetId;

  const TimesheetDetailScreen({super.key, required this.timesheetId});

  @override
  State<TimesheetDetailScreen> createState() => _TimesheetDetailScreenState();
}

class _TimesheetDetailScreenState extends State<TimesheetDetailScreen> {
  late ProjectStore _store;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
    _store.fetchTimesheet(widget.timesheetId);
  }

  @override
  void dispose() {
    _store.clearSelectedTimesheet();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        title: Text(
          'Supprimer la saisie',
          style: TextStyle(
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette feuille de temps ?',
          style: TextStyle(
            color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
              style: TextStyle(color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _store.deleteTimesheet(widget.timesheetId);
              if (success && mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        title: Text(
          'Soumettre pour approbation',
          style: TextStyle(
            color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
          ),
        ),
        content: Text(
          'La feuille de temps sera soumise pour approbation. Cette action est irréversible.',
          style: TextStyle(
            color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
              style: TextStyle(color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _store.submitTimesheet(widget.timesheetId);
              if (mounted) {
                if (success) {
                  _store.fetchTimesheet(widget.timesheetId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feuille de temps soumise avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Soumettre', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          'Détail de la saisie',
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
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.selectedTimesheet == null) {
            return _buildLoadingSkeleton();
          }

          if (_store.selectedTimesheet == null) {
            return const Center(child: Text('Saisie introuvable'));
          }

          final ts = _store.selectedTimesheet!;
          final statusColor = _getStatusColor(ts.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & hours header
                Container(
                  decoration: _cardDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ts.statusLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  ts.formattedHours,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                if (ts.isBillable)
                                  const Text(
                                    'Facturable',
                                    style: TextStyle(fontSize: 12, color: Colors.green),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildDetailRow('Projet', ts.projectName, Iconsax.briefcase),
                        const SizedBox(height: 12),
                        _buildDetailRow('Date', ts.date, Iconsax.calendar),
                        if (ts.description != null && ts.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow('Description', ts.description!, Iconsax.document_text),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Financial details
                if (ts.billableAmount != null) ...[
                  Container(
                    decoration: _cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Financier', style: _sectionTitleStyle()),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildFinancialItem(
                                'Montant fact.', '\$${ts.billableAmount?.toStringAsFixed(2)}', Colors.green)),
                              Expanded(child: _buildFinancialItem(
                                'Taux fact.', '\$${ts.billingRate?.toStringAsFixed(2)}/h', Colors.blue)),
                              Expanded(child: _buildFinancialItem(
                                'Coût', '\$${ts.costAmount?.toStringAsFixed(2)}', Colors.orange)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Approval info
                if (ts.approvedBy != null) ...[
                  Container(
                    decoration: _cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Approbation', style: _sectionTitleStyle()),
                          const SizedBox(height: 12),
                          _buildDetailRow('Approuvé par', ts.approvedBy!, Iconsax.user_tick),
                          if (ts.approvedAt != null) ...[
                            const SizedBox(height: 10),
                            _buildDetailRow('Date', ts.approvedAt!, Iconsax.calendar_tick),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                if (ts.canSubmit || ts.canEdit || ts.canDelete)
                  Column(
                    children: [
                      if (ts.canSubmit) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _confirmSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Iconsax.send_1, color: Colors.white),
                            label: const Text('Soumettre pour approbation',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (ts.canEdit) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Provider.value(
                                  value: _store,
                                  child: TimesheetFormScreen(timesheet: ts),
                                ),
                              ),
                            ).then((_) => _store.fetchTimesheet(widget.timesheetId)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Iconsax.edit, color: Color(0xFF10B981)),
                            label: const Text('Modifier',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (ts.canDelete)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _confirmDelete,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            label: const Text('Supprimer',
                              style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16,
          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 11,
          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
        ), textAlign: TextAlign.center),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(appStore.isDarkModeOn ? 0.3 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: appStore.isDarkModeOn ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          highlightColor: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFF9FAFB),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: appStore.isDarkModeOn ? Colors.grey[800] : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
