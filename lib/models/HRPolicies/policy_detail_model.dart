class PolicyDocumentInfo {
  final bool exists;
  final String? name;
  final int? size;
  final String? formattedSize;
  final String? type;

  PolicyDocumentInfo({
    required this.exists,
    this.name,
    this.size,
    this.formattedSize,
    this.type,
  });

  factory PolicyDocumentInfo.fromJson(Map<String, dynamic> json) {
    return PolicyDocumentInfo(
      exists: json['exists'] as bool? ?? false,
      name: json['name'] as String?,
      size: json['size'] as int?,
      formattedSize: json['formatted_size'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'name': name,
      'size': size,
      'formatted_size': formattedSize,
      'type': type,
    };
  }
}

class PolicyAcknowledgmentInfo {
  final String status;
  final String statusLabel;
  final String assignedDate;
  final String? deadlineDate;
  final String? acknowledgedDate;
  final double? daysUntilDeadline;
  final bool isOverdue;
  final String? assignmentNote;
  final String? comments;

  PolicyAcknowledgmentInfo({
    required this.status,
    required this.statusLabel,
    required this.assignedDate,
    this.deadlineDate,
    this.acknowledgedDate,
    this.daysUntilDeadline,
    required this.isOverdue,
    this.assignmentNote,
    this.comments,
  });

  factory PolicyAcknowledgmentInfo.fromJson(Map<String, dynamic> json) {
    return PolicyAcknowledgmentInfo(
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      assignedDate: json['assigned_date'] as String,
      deadlineDate: json['deadline_date'] as String?,
      acknowledgedDate: json['acknowledged_date'] as String?,
      daysUntilDeadline: json['days_until_deadline'] != null
          ? (json['days_until_deadline'] as num).toDouble()
          : null,
      isOverdue: json['is_overdue'] as bool? ?? false,
      assignmentNote: json['assignment_note'] as String?,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'status_label': statusLabel,
      'assigned_date': assignedDate,
      'deadline_date': deadlineDate,
      'acknowledged_date': acknowledgedDate,
      'days_until_deadline': daysUntilDeadline,
      'is_overdue': isOverdue,
      'assignment_note': assignmentNote,
      'comments': comments,
    };
  }
}

class PolicyCategoryInfo {
  final int id;
  final String name;
  final String? description;

  PolicyCategoryInfo({
    required this.id,
    required this.name,
    this.description,
  });

  factory PolicyCategoryInfo.fromJson(Map<String, dynamic> json) {
    return PolicyCategoryInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class PolicyDetailModel {
  final int acknowledgmentId;
  final int policyId;
  final String title;
  final String slug;
  final String? description;
  final String? content;
  final PolicyCategoryInfo category;
  final double version;
  final String effectiveDate;
  final String? expiryDate;
  final bool isMandatory;
  final bool requiresAcknowledgment;
  final PolicyDocumentInfo document;
  final PolicyAcknowledgmentInfo acknowledgment;

  PolicyDetailModel({
    required this.acknowledgmentId,
    required this.policyId,
    required this.title,
    required this.slug,
    this.description,
    this.content,
    required this.category,
    required this.version,
    required this.effectiveDate,
    this.expiryDate,
    required this.isMandatory,
    required this.requiresAcknowledgment,
    required this.document,
    required this.acknowledgment,
  });

  factory PolicyDetailModel.fromJson(Map<String, dynamic> json) {
    return PolicyDetailModel(
      acknowledgmentId: json['acknowledgment_id'] as int,
      policyId: json['policy_id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      content: json['content'] as String?,
      category: PolicyCategoryInfo.fromJson(json['category'] as Map<String, dynamic>),
      version: (json['version'] as num).toDouble(),
      effectiveDate: json['effective_date'] as String,
      expiryDate: json['expiry_date'] as String?,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      requiresAcknowledgment: json['requires_acknowledgment'] as bool? ?? true,
      document: PolicyDocumentInfo.fromJson(json['document'] as Map<String, dynamic>),
      acknowledgment: PolicyAcknowledgmentInfo.fromJson(json['acknowledgment'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acknowledgment_id': acknowledgmentId,
      'policy_id': policyId,
      'title': title,
      'slug': slug,
      'description': description,
      'content': content,
      'category': category.toJson(),
      'version': version,
      'effective_date': effectiveDate,
      'expiry_date': expiryDate,
      'is_mandatory': isMandatory,
      'requires_acknowledgment': requiresAcknowledgment,
      'document': document.toJson(),
      'acknowledgment': acknowledgment.toJson(),
    };
  }
}
