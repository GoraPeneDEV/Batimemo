class Timesheet {
  final int id;
  final int projectId;
  final String projectName;
  final String projectCode;
  final String date;
  final double hours;
  final String formattedHours;
  final String? description;
  final String status;
  final String statusLabel;
  final bool isBillable;
  final double? billableAmount;
  final double? billingRate;
  final double? costRate;
  final double? costAmount;
  final double? totalAmount;
  final String? approvedBy;
  final String? approvedAt;
  final bool canEdit;
  final bool canSubmit;
  final bool canDelete;
  final String? createdAt;
  final String? updatedAt;

  Timesheet({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    required this.date,
    required this.hours,
    required this.formattedHours,
    this.description,
    required this.status,
    required this.statusLabel,
    required this.isBillable,
    this.billableAmount,
    this.billingRate,
    this.costRate,
    this.costAmount,
    this.totalAmount,
    this.approvedBy,
    this.approvedAt,
    required this.canEdit,
    required this.canSubmit,
    required this.canDelete,
    this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isInvoiced => status == 'invoiced';

  factory Timesheet.fromJson(Map<String, dynamic> json) {
    return Timesheet(
      id: json['id'] ?? 0,
      projectId: json['projectId'] ?? 0,
      projectName: json['projectName'] ?? '',
      projectCode: json['projectCode'] ?? '',
      date: json['date'] ?? '',
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
      formattedHours: json['formattedHours'] ?? '0.00 hrs',
      description: json['description'],
      status: json['status'] ?? 'draft',
      statusLabel: json['statusLabel'] ?? json['status'] ?? '',
      isBillable: json['isBillable'] ?? false,
      billableAmount: (json['billableAmount'] as num?)?.toDouble(),
      billingRate: (json['billingRate'] as num?)?.toDouble(),
      costRate: (json['costRate'] as num?)?.toDouble(),
      costAmount: (json['costAmount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'],
      canEdit: json['canEdit'] ?? false,
      canSubmit: json['canSubmit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'date': date,
      'hours': hours,
      'description': description,
      'isBillable': isBillable,
      'billingRate': billingRate,
      'costRate': costRate,
    };
  }
}
