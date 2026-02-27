class PolicyModel {
  final int acknowledgmentId;
  final int policyId;
  final String title;
  final String? description;
  final String category;
  final int categoryId;
  final double version;
  final bool isMandatory;
  final bool requiresAcknowledgment;
  final String status;
  final String statusLabel;
  final String assignedDate;
  final String? deadlineDate;
  final String? acknowledgedDate;
  final double? daysUntilDeadline;
  final bool isOverdue;
  final bool hasDocument;

  PolicyModel({
    required this.acknowledgmentId,
    required this.policyId,
    required this.title,
    this.description,
    required this.category,
    required this.categoryId,
    required this.version,
    required this.isMandatory,
    required this.requiresAcknowledgment,
    required this.status,
    required this.statusLabel,
    required this.assignedDate,
    this.deadlineDate,
    this.acknowledgedDate,
    this.daysUntilDeadline,
    required this.isOverdue,
    required this.hasDocument,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      acknowledgmentId: json['acknowledgment_id'] as int,
      policyId: json['policy_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      categoryId: json['category_id'] as int,
      version: (json['version'] as num).toDouble(),
      isMandatory: json['is_mandatory'] as bool? ?? false,
      requiresAcknowledgment: json['requires_acknowledgment'] as bool? ?? true,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      assignedDate: json['assigned_date'] as String,
      deadlineDate: json['deadline_date'] as String?,
      acknowledgedDate: json['acknowledged_date'] as String?,
      daysUntilDeadline: json['days_until_deadline'] != null
          ? (json['days_until_deadline'] as num).toDouble()
          : null,
      isOverdue: json['is_overdue'] as bool? ?? false,
      hasDocument: json['has_document'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acknowledgment_id': acknowledgmentId,
      'policy_id': policyId,
      'title': title,
      'description': description,
      'category': category,
      'category_id': categoryId,
      'version': version,
      'is_mandatory': isMandatory,
      'requires_acknowledgment': requiresAcknowledgment,
      'status': status,
      'status_label': statusLabel,
      'assigned_date': assignedDate,
      'deadline_date': deadlineDate,
      'acknowledged_date': acknowledgedDate,
      'days_until_deadline': daysUntilDeadline,
      'is_overdue': isOverdue,
      'has_document': hasDocument,
    };
  }
}
