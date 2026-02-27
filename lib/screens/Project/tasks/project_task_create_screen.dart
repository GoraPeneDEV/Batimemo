import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../stores/Project/TaskStore.dart';

class ProjectTaskCreateScreen extends StatefulWidget {
  final TaskStore store;
  final int projectId;

  const ProjectTaskCreateScreen({
    Key? key,
    required this.store,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ProjectTaskCreateScreen> createState() =>
      _ProjectTaskCreateScreenState();
}

class _ProjectTaskCreateScreenState extends State<ProjectTaskCreateScreen> {
  TaskStore get _store => widget.store;

  @override
  void dispose() {
    _store.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.lblNewTask),
        elevation: 0,
      ),
      body: Observer(
        builder: (_) => _store.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _label(language.lblTaskTitle, required: true),
          const SizedBox(height: 6),
          TextField(
            controller: _store.titleController,
            decoration: _inputDeco(language.lblPleaseEnterTaskTitle),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Description
          _label(language.lblDescription),
          const SizedBox(height: 6),
          TextField(
            controller: _store.descriptionController,
            decoration: _inputDeco(language.lblEnterDescription),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Status
          _label(language.lblStatus, required: true),
          const SizedBox(height: 6),
          Observer(builder: (_) {
            final statuses = _store.meta?.statuses ?? [];
            if (statuses.isEmpty) {
              return Text(
                language.lblTaskSystemIsNotEnabled,
                style: const TextStyle(color: Colors.red),
              );
            }
            return DropdownButtonFormField<int>(
              value: _store.selectedFormStatusId,
              decoration: _inputDeco(language.lblSelectTaskStatus),
              items: statuses
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (v) => _store.selectedFormStatusId = v,
            );
          }),
          const SizedBox(height: 16),

          // Priority
          _label(language.lblPriority),
          const SizedBox(height: 6),
          Observer(builder: (_) {
            final priorities = _store.meta?.priorities ?? [];
            if (priorities.isEmpty) return const SizedBox.shrink();
            return DropdownButtonFormField<int>(
              value: _store.selectedFormPriorityId,
              decoration: _inputDeco(language.lblSelectPriority),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('— ${language.lblNone} —'),
                ),
                ...priorities.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    )),
              ],
              onChanged: (v) => _store.selectedFormPriorityId = v,
            );
          }),
          const SizedBox(height: 16),

          // Assigned to
          _label(language.lblAssignTo),
          const SizedBox(height: 6),
          Observer(builder: (_) {
            final members = _store.meta?.members ?? [];
            if (members.isEmpty) return const SizedBox.shrink();
            return DropdownButtonFormField<int>(
              value: _store.selectedAssignedUserId,
              decoration: _inputDeco(language.lblSelectMember),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('— ${language.lblNone} —'),
                ),
                ...members.map((m) => DropdownMenuItem(
                      value: m.userId,
                      child: Text(m.name),
                    )),
              ],
              onChanged: (v) => _store.selectedAssignedUserId = v,
            );
          }),
          const SizedBox(height: 16),

          // Due date
          _label(language.lblDueDate),
          const SizedBox(height: 6),
          Observer(builder: (_) {
            return GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _store.dueDate != null
                          ? DateFormat('dd/MM/yyyy').format(_store.dueDate!)
                          : language.lblSelectDate,
                      style: TextStyle(
                        color: _store.dueDate != null
                            ? null
                            : Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    if (_store.dueDate != null)
                      GestureDetector(
                        onTap: () => _store.dueDate = null,
                        child: const Icon(Icons.clear,
                            size: 18, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Estimated hours
          _label(language.lblEstimatedHours),
          const SizedBox(height: 6),
          TextField(
            controller: _store.estimatedHoursController,
            decoration: _inputDeco('ex: 8.5'),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),

          // Milestone toggle
          Observer(builder: (_) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(language.lblMilestone),
              value: _store.isMilestone,
              onChanged: (v) => _store.isMilestone = v,
            );
          }),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(language.lblCreateTask,
                  style: const TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _store.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      _store.dueDate = picked;
    }
  }

  Future<void> _submit() async {
    final success = await _store.createTask(widget.projectId);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
