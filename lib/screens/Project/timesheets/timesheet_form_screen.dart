import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../stores/project_store.dart';
import '../../../models/project/timesheet.dart';

class TimesheetFormScreen extends StatefulWidget {
  final Timesheet? timesheet;
  final int? preselectedProjectId;

  const TimesheetFormScreen({super.key, this.timesheet, this.preselectedProjectId});

  @override
  State<TimesheetFormScreen> createState() => _TimesheetFormScreenState();
}

class _TimesheetFormScreenState extends State<TimesheetFormScreen> {
  late ProjectStore _store;
  final _formKey = GlobalKey<FormState>();

  int? _selectedProjectId;
  String _selectedProjectName = '';
  DateTime? _selectedDate;
  double _hours = 0;
  String _description = '';
  bool _isBillable = true;
  double? _billingRate;
  double? _costRate;

  bool get _isEditing => widget.timesheet != null;

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);

    if (_isEditing) {
      final ts = widget.timesheet!;
      _selectedProjectId = ts.projectId;
      _selectedProjectName = ts.projectName;
      _selectedDate = DateTime.tryParse(ts.date);
      _hours = ts.hours;
      _description = ts.description ?? '';
      _isBillable = ts.isBillable;
      _billingRate = ts.billingRate;
      _costRate = ts.costRate;
    } else {
      _selectedDate = DateTime.now();
      _selectedProjectId = widget.preselectedProjectId;
      if (_selectedProjectId != null) {
        final project = _store.projects.where((p) => p.id == _selectedProjectId).firstOrNull;
        if (project != null) _selectedProjectName = project.name;
      }
    }

    // Load projects for dropdown if not loaded yet
    if (_store.projects.isEmpty) {
      _store.fetchProjects(take: 100);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un projet'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date'), backgroundColor: Colors.red),
      );
      return;
    }

    bool success;
    if (_isEditing) {
      success = await _store.updateTimesheet(
        widget.timesheet!.id,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        hours: _hours,
        description: _description,
        isBillable: _isBillable,
        billingRate: _billingRate,
        costRate: _costRate,
      );
    } else {
      success = await _store.createTimesheet(
        projectId: _selectedProjectId!,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        hours: _hours,
        description: _description,
        isBillable: _isBillable,
        billingRate: _billingRate,
        costRate: _costRate,
      );
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_store.error ?? 'Une erreur est survenue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Modifier la saisie' : 'Saisir du temps',
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
        builder: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project selection
                if (!_isEditing && widget.preselectedProjectId == null) ...[
                  _buildSectionLabel('Projet *'),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => Container(
                      decoration: _inputDecoration(),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedProjectId,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Sélectionner un projet',
                              style: TextStyle(
                                color: appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          dropdownColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
                          items: _store.projects.map((project) {
                            return DropdownMenuItem<int>(
                              value: project.id,
                              child: Text(
                                project.name,
                                style: TextStyle(
                                  color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() {
                            _selectedProjectId = val;
                            _selectedProjectName = _store.projects
                                .firstWhere((p) => p.id == val, orElse: () => _store.projects.first)
                                .name;
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Show project name if preselected
                if (widget.preselectedProjectId != null && _selectedProjectName.isNotEmpty) ...[
                  _buildSectionLabel('Projet'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _inputDecoration(),
                    child: Text(
                      _selectedProjectName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Date
                _buildSectionLabel('Date *'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _inputDecoration(),
                    child: Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: 20,
                          color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDate != null
                                ? (appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827))
                                : (appStore.isDarkModeOn ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hours
                _buildSectionLabel('Heures travaillées *'),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _hours > 0 ? _hours.toString() : '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'ex: 7.5',
                    prefixIcon: Icon(Iconsax.clock, color: const Color(0xFF10B981)),
                    suffixText: 'hrs',
                    filled: true,
                    fillColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Champ obligatoire';
                    final n = double.tryParse(val);
                    if (n == null || n <= 0 || n > 24) return 'Entrez un nombre d\'heures valide (0-24)';
                    return null;
                  },
                  onSaved: (val) => _hours = double.tryParse(val ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),

                // Description
                _buildSectionLabel('Description *'),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _description,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Décrivez le travail effectué...',
                    filled: true,
                    fillColor: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'La description est obligatoire';
                    return null;
                  },
                  onSaved: (val) => _description = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // Billable toggle
                Container(
                  decoration: _inputDecoration(),
                  child: SwitchListTile(
                    title: Text(
                      'Heures facturables',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: appStore.isDarkModeOn ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      'Ces heures seront comptabilisées dans la facturation',
                      style: TextStyle(
                        fontSize: 12,
                        color: appStore.isDarkModeOn ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                    ),
                    value: _isBillable,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _isBillable = val),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _store.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _store.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isEditing ? 'Enregistrer' : 'Créer la saisie',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: appStore.isDarkModeOn ? Colors.grey[300] : const Color(0xFF374151),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: appStore.isDarkModeOn ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: appStore.isDarkModeOn ? Colors.grey[700]! : const Color(0xFFE5E7EB),
      ),
    );
  }
}
