import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../stores/project_store.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  late ProjectStore _store;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String _selectedType = 'internal';
  String _selectedPriority = 'medium';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isBillable = true;
  String _selectedColor = '#10B981';

  static const Color _primaryColor = Color(0xFF10B981);

  // Types acceptés par l'API
  final List<Map<String, String>> _types = [
    {'value': 'internal', 'label': 'Interne'},
    {'value': 'client', 'label': 'Client'},
    {'value': 'renovation', 'label': 'Rénovation'},
    {'value': 'other', 'label': 'Autre'},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Faible', 'color': Colors.grey},
    {'value': 'medium', 'label': 'Moyen', 'color': Colors.blue},
    {'value': 'high', 'label': 'Élevé', 'color': Colors.orange},
    {'value': 'critical', 'label': 'Critique', 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'value': '#10B981', 'color': const Color(0xFF10B981), 'label': 'Vert'},
    {'value': '#3B82F6', 'color': const Color(0xFF3B82F6), 'label': 'Bleu'},
    {'value': '#F59E0B', 'color': const Color(0xFFF59E0B), 'label': 'Orange'},
    {'value': '#EF4444', 'color': const Color(0xFFEF4444), 'label': 'Rouge'},
    {'value': '#8B5CF6', 'color': const Color(0xFF8B5CF6), 'label': 'Violet'},
    {'value': '#EC4899', 'color': const Color(0xFFEC4899), 'label': 'Rose'},
    {'value': '#06B6D4', 'color': const Color(0xFF06B6D4), 'label': 'Cyan'},
    {'value': '#6B7280', 'color': const Color(0xFF6B7280), 'label': 'Gris'},
  ];

  @override
  void initState() {
    super.initState();
    _store = Provider.of<ProjectStore>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final first = isStart ? DateTime(2020) : (_startDate ?? DateTime(2020));
    final last = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final budgetText = _budgetController.text.trim();
    final hourlyRateText = _hourlyRateController.text.trim();

    final project = await _store.createProject(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      priority: _selectedPriority,
      startDate: _startDate != null
          ? DateFormat('yyyy-MM-dd').format(_startDate!)
          : null,
      endDate: _endDate != null
          ? DateFormat('yyyy-MM-dd').format(_endDate!)
          : null,
      budget: budgetText.isNotEmpty ? double.tryParse(budgetText) : null,
      isBillable: _isBillable,
      hourlyRate: hourlyRateText.isNotEmpty ? double.tryParse(hourlyRateText) : null,
      colorCode: _selectedColor,
    );

    if (mounted) {
      if (project != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet créé avec succès'),
            backgroundColor: _primaryColor,
          ),
        );
        Navigator.pop(context, true);
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
    final isDark = appStore.isDarkModeOn;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        title: Text(
          'Nouveau Projet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
              color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Observer(
            builder: (_) => _store.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryColor,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: const Text(
                      'Créer',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Informations de base ──────────────────────────────────────
              _buildCard(
                title: 'Informations',
                icon: Iconsax.briefcase,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom du projet *',
                    hint: 'Ex: Rénovation cuisine Dupont',
                    icon: Iconsax.text,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Le nom est obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Décrivez le projet...',
                    icon: Iconsax.document_text,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Type ──────────────────────────────────────────────────────
              _buildCard(
                title: 'Type de projet',
                icon: Iconsax.category,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _types.map((t) {
                      final selected = _selectedType == t['value'];
                      return ChoiceChip(
                        label: Text(t['label']!),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedType = t['value']!),
                        selectedColor: _primaryColor.withOpacity(0.15),
                        checkmarkColor: _primaryColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? _primaryColor
                              : (isDark ? Colors.grey[300] : const Color(0xFF374151)),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Priorité ──────────────────────────────────────────────────
              _buildCard(
                title: 'Priorité',
                icon: Iconsax.flag,
                children: [
                  Row(
                    children: _priorities.map((p) {
                      final selected = _selectedPriority == p['value'];
                      final color = p['color'] as Color;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPriority = p['value'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.15)
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Iconsax.flag, color: color, size: 18),
                                const SizedBox(height: 4),
                                Text(
                                  p['label'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected
                                        ? color
                                        : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Dates ────────────────────────────────────────────────────
              _buildCard(
                title: 'Planification',
                icon: Iconsax.calendar,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: 'Date de début',
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                          icon: Iconsax.calendar_1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          label: 'Date de fin',
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                          icon: Iconsax.calendar_2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Financier ────────────────────────────────────────────────
              _buildCard(
                title: 'Financier',
                icon: Iconsax.wallet,
                children: [
                  // Facturable toggle
                  Row(
                    children: [
                      Icon(Iconsax.money,
                          size: 18,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Projet facturable',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ),
                      Switch(
                        value: _isBillable,
                        onChanged: (v) => setState(() => _isBillable = v),
                        activeColor: _primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _budgetController,
                          label: 'Budget',
                          hint: '0.00',
                          icon: Iconsax.wallet,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          prefix: '\$ ',
                        ),
                      ),
                      if (_isBillable) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _hourlyRateController,
                            label: 'Taux horaire',
                            hint: '0.00',
                            icon: Iconsax.clock,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            suffix: '/h',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Couleur ──────────────────────────────────────────────────
              _buildCard(
                title: 'Couleur',
                icon: Iconsax.colorfilter,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _colors.map((c) {
                      final color = c['color'] as Color;
                      final value = c['value'] as String;
                      final selected = _selectedColor == value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = value),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                    width: 3)
                                : null,
                            boxShadow: selected
                                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Bouton créer ──────────────────────────────────────────────
              Observer(
                builder: (_) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _store.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _store.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Iconsax.add_circle, color: Colors.white),
                    label: Text(
                      _store.isLoading ? 'Création en cours...' : 'Créer le projet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = appStore.isDarkModeOn;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: _primaryColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    String? suffix,
  }) {
    final isDark = appStore.isDarkModeOn;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF111827),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 18, color: _primaryColor),
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : const Color(0xFF9CA3AF),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final isDark = appStore.isDarkModeOn;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null ? _primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: date != null ? _primaryColor : (isDark ? Colors.grey[400] : const Color(0xFF9CA3AF))),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date)
                        : 'Sélectionner',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                      color: date != null
                          ? (isDark ? Colors.white : const Color(0xFF111827))
                          : (isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
