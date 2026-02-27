class WarningType {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String severity; // 'verbal', 'written', 'final', 'termination'
  final String severityLabel;
  final bool requiresAcknowledgment;
  final int? acknowledgmentDays;
  final bool allowsAppeal;
  final int? appealDays;
  final int? validityDays;

  WarningType({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.severity,
    required this.severityLabel,
    required this.requiresAcknowledgment,
    this.acknowledgmentDays,
    required this.allowsAppeal,
    this.appealDays,
    this.validityDays,
  });

  factory WarningType.fromJson(Map<String, dynamic> json) {
    return WarningType(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      severity: json['severity'] ?? '',
      severityLabel: json['severityLabel'] ?? json['severity'] ?? '',
      requiresAcknowledgment: json['requiresAcknowledgment'] ?? false,
      acknowledgmentDays: json['acknowledgmentDays'],
      allowsAppeal: json['allowsAppeal'] ?? false,
      appealDays: json['appealDays'],
      validityDays: json['validityDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'severity': severity,
      'severityLabel': severityLabel,
      'requiresAcknowledgment': requiresAcknowledgment,
      'acknowledgmentDays': acknowledgmentDays,
      'allowsAppeal': allowsAppeal,
      'appealDays': appealDays,
      'validityDays': validityDays,
    };
  }
}
