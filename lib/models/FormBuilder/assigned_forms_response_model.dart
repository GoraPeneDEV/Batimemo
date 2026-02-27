import 'assigned_form_model.dart';

/// API response wrapper for assigned forms list
class AssignedFormsResponseModel {
  final int totalCount;
  final List<AssignedFormModel> values;

  AssignedFormsResponseModel({
    required this.totalCount,
    required this.values,
  });

  factory AssignedFormsResponseModel.fromJson(Map<String, dynamic> json) {
    return AssignedFormsResponseModel(
      totalCount: json['totalCount'] as int? ?? 0,
      values: json['values'] != null
          ? (json['values'] as List)
              .map((form) => AssignedFormModel.fromJson(form as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'values': values.map((form) => form.toJson()).toList(),
    };
  }

  /// Check if response has any forms
  bool get hasData => values.isNotEmpty;

  /// Check if response is empty
  bool get isEmpty => values.isEmpty;

  /// Get count of pending forms
  int get pendingCount {
    return values.where((form) => form.isPending).length;
  }

  /// Get count of submitted forms
  int get submittedCount {
    return values.where((form) => form.isSubmitted).length;
  }

  /// Get count of overdue forms
  int get overdueCount {
    return values.where((form) => form.hasOverdue).length;
  }

  /// Get all pending forms
  List<AssignedFormModel> get pendingForms {
    return values.where((form) => form.isPending).toList();
  }

  /// Get all submitted forms
  List<AssignedFormModel> get submittedForms {
    return values.where((form) => form.isSubmitted).toList();
  }

  /// Get all overdue forms
  List<AssignedFormModel> get overdueForms {
    return values.where((form) => form.hasOverdue).toList();
  }

  /// Get forms that are due soon (within 24 hours)
  List<AssignedFormModel> get dueSoonForms {
    return values.where((form) => form.isDueSoon).toList();
  }

  /// Get forms sorted by due date (earliest first)
  List<AssignedFormModel> get sortedByDueDate {
    final formsWithDueDate = values.where((form) => form.dueDate != null).toList();
    formsWithDueDate.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return formsWithDueDate;
  }

  /// Get forms sorted by priority (highest first)
  List<AssignedFormModel> get sortedByPriority {
    final formsWithPriority = values.where((form) => form.priority != null).toList();
    formsWithPriority.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    return formsWithPriority;
  }

  /// Get high priority forms
  List<AssignedFormModel> get highPriorityForms {
    return values.where((form) => form.priority == 3).toList();
  }

  AssignedFormsResponseModel copyWith({
    int? totalCount,
    List<AssignedFormModel>? values,
  }) {
    return AssignedFormsResponseModel(
      totalCount: totalCount ?? this.totalCount,
      values: values ?? this.values,
    );
  }

  @override
  String toString() {
    return 'AssignedFormsResponseModel(totalCount: $totalCount, values: ${values.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedFormsResponseModel &&
        other.totalCount == totalCount &&
        other.values.length == values.length;
  }

  @override
  int get hashCode => totalCount.hashCode ^ values.hashCode;
}
