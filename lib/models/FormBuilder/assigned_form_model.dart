import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'form_field_model.dart';

part 'assigned_form_model.g.dart';

/// Status enum for assigned forms
enum AssignedFormStatus {
  pending,
  submitted,
  overdue,
}

@HiveType(typeId: 102)
class AssignedFormModel {
  @HiveField(0)
  final int assignmentId;

  @HiveField(1)
  final int formId;

  @HiveField(2)
  final String formName;

  @HiveField(3)
  final String? formDescription;

  @HiveField(4)
  final List<FormFieldModel> formFields;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final DateTime? dueDate;

  @HiveField(7)
  final DateTime? submittedDate;

  @HiveField(8)
  final bool isOverdue;

  @HiveField(9)
  final DateTime assignedOn;

  @HiveField(10)
  final String? assignedBy;

  @HiveField(11)
  final String? assignedByName;

  @HiveField(12)
  final String? remarks;

  @HiveField(13)
  final int? priority;

  @HiveField(14)
  final Map<String, dynamic>? submissionData;

  @HiveField(15)
  final List<String>? attachmentUrls;

  AssignedFormModel({
    required this.assignmentId,
    required this.formId,
    required this.formName,
    this.formDescription,
    required this.formFields,
    required this.status,
    this.dueDate,
    this.submittedDate,
    required this.isOverdue,
    required this.assignedOn,
    this.assignedBy,
    this.assignedByName,
    this.remarks,
    this.priority,
    this.submissionData,
    this.attachmentUrls,
  });

  factory AssignedFormModel.fromJson(Map<String, dynamic> json) {
    return AssignedFormModel(
      assignmentId: json['assignmentId'] as int? ?? json['id'] as int? ?? 0,
      formId: json['formId'] as int? ?? 0,
      formName: json['formName'] as String? ?? '',
      formDescription: json['formDescription'] as String?,
      formFields: json['formFields'] != null
          ? (json['formFields'] as List)
              .map((field) => FormFieldModel.fromJson(field as Map<String, dynamic>))
              .toList()
          : [],
      status: json['status'] as String? ?? 'pending',
      dueDate: _parseDate(json['dueDate']),
      submittedDate: _parseDate(json['submittedDate']),
      isOverdue: json['isOverdue'] as bool? ?? false,
      assignedOn: _parseDate(json['assignedOn']) ?? DateTime.now(),
      assignedBy: json['assignedBy']?.toString(),
      assignedByName: json['assignedByName'] as String?,
      remarks: json['remarks'] as String?,
      priority: json['priority'] as int?,
      submissionData: json['submissionData'] as Map<String, dynamic>?,
      attachmentUrls: json['attachmentUrls'] != null
          ? List<String>.from(json['attachmentUrls'] as List)
          : null,
    );
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        try {
          final dateOnlyRegex = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$');
          final dateOnlyMatch = dateOnlyRegex.firstMatch(dateValue);
          if (dateOnlyMatch != null) {
            final day = int.parse(dateOnlyMatch.group(1)!);
            final month = int.parse(dateOnlyMatch.group(2)!);
            final year = int.parse(dateOnlyMatch.group(3)!);
            return DateTime(year, month, day);
          }

          final dateTimeRegex = RegExp(
            r'^(\d{1,2})-(\d{1,2})-(\d{4})\s+(\d{1,2}):(\d{2})\s+(AM|PM)$',
            caseSensitive: false,
          );
          final dateTimeMatch = dateTimeRegex.firstMatch(dateValue);
          if (dateTimeMatch != null) {
            final day = int.parse(dateTimeMatch.group(1)!);
            final month = int.parse(dateTimeMatch.group(2)!);
            final year = int.parse(dateTimeMatch.group(3)!);
            var hour = int.parse(dateTimeMatch.group(4)!);
            final minute = int.parse(dateTimeMatch.group(5)!);
            final period = dateTimeMatch.group(6)!.toUpperCase();

            if (period == 'PM' && hour != 12) {
              hour += 12;
            } else if (period == 'AM' && hour == 12) {
              hour = 0;
            }

            return DateTime(year, month, day, hour, minute);
          }

          try {
            return DateFormat('dd-MM-yyyy').parse(dateValue);
          } catch (e) {
            return DateFormat('dd-MM-yyyy hh:mm a').parse(dateValue);
          }
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'formId': formId,
      'formName': formName,
      'formDescription': formDescription,
      'formFields': formFields.map((field) => field.toJson()).toList(),
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'submittedDate': submittedDate?.toIso8601String(),
      'isOverdue': isOverdue,
      'assignedOn': assignedOn.toIso8601String(),
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
      'remarks': remarks,
      'priority': priority,
      'submissionData': submissionData,
      'attachmentUrls': attachmentUrls,
    };
  }

  AssignedFormModel copyWith({
    int? assignmentId,
    int? formId,
    String? formName,
    String? formDescription,
    List<FormFieldModel>? formFields,
    String? status,
    DateTime? dueDate,
    DateTime? submittedDate,
    bool? isOverdue,
    DateTime? assignedOn,
    String? assignedBy,
    String? assignedByName,
    String? remarks,
    int? priority,
    Map<String, dynamic>? submissionData,
    List<String>? attachmentUrls,
  }) {
    return AssignedFormModel(
      assignmentId: assignmentId ?? this.assignmentId,
      formId: formId ?? this.formId,
      formName: formName ?? this.formName,
      formDescription: formDescription ?? this.formDescription,
      formFields: formFields ?? this.formFields,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      submittedDate: submittedDate ?? this.submittedDate,
      isOverdue: isOverdue ?? this.isOverdue,
      assignedOn: assignedOn ?? this.assignedOn,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedByName: assignedByName ?? this.assignedByName,
      remarks: remarks ?? this.remarks,
      priority: priority ?? this.priority,
      submissionData: submissionData ?? this.submissionData,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }

  AssignedFormStatus get formStatus {
    switch (status.toLowerCase()) {
      case 'submitted':
        return AssignedFormStatus.submitted;
      case 'overdue':
        return AssignedFormStatus.overdue;
      default:
        return AssignedFormStatus.pending;
    }
  }

  bool get isPending => formStatus == AssignedFormStatus.pending;
  bool get isSubmitted => formStatus == AssignedFormStatus.submitted;
  bool get hasOverdue => formStatus == AssignedFormStatus.overdue || isOverdue;

  bool get isDueSoon {
    if (dueDate == null || isSubmitted) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inHours <= 24 && difference.inHours > 0;
  }

  int? get daysUntilDue {
    if (dueDate == null || isSubmitted) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dueDate!);
  }

  String get formattedSubmittedDate {
    if (submittedDate == null) return 'Not submitted';
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(submittedDate!);
  }

  String get formattedAssignedDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(assignedOn);
  }

  String get priorityLabel {
    switch (priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
        return 'Low';
      default:
        return 'Normal';
    }
  }

  int get requiredFieldsCount {
    return formFields.where((field) => field.required).length;
  }

  int get inputFieldsCount {
    return formFields.where((field) => field.acceptsInput).length;
  }

  @override
  String toString() {
    return 'AssignedFormModel(assignmentId: $assignmentId, formName: $formName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssignedFormModel &&
        other.assignmentId == assignmentId &&
        other.formId == formId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return assignmentId.hashCode ^ formId.hashCode ^ status.hashCode;
  }
}
