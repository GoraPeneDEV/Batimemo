class TimesheetModel {
  int? id;
  int? projectId;
  String? projectName;
  String? projectCode;
  String? date;
  num? hours;
  String? formattedHours;
  String? status;
  String? statusLabel;
  bool? isBillable;
  num? billableAmount;
  String? createdAt;

  // Detail-only fields
  String? description;
  int? taskId;
  num? billingRate;
  num? costRate;
  num? costAmount;
  num? totalAmount;
  Map<String, dynamic>? approvedBy;
  String? approvedAt;
  String? updatedAt;
  bool? canEdit;
  bool? canSubmit;
  bool? canDelete;

  TimesheetModel({
    this.id,
    this.projectId,
    this.projectName,
    this.projectCode,
    this.date,
    this.hours,
    this.formattedHours,
    this.status,
    this.statusLabel,
    this.isBillable,
    this.billableAmount,
    this.createdAt,
    this.description,
    this.taskId,
    this.billingRate,
    this.costRate,
    this.costAmount,
    this.totalAmount,
    this.approvedBy,
    this.approvedAt,
    this.updatedAt,
    this.canEdit,
    this.canSubmit,
    this.canDelete,
  });

  factory TimesheetModel.fromJson(Map<String, dynamic> json) {
    return TimesheetModel(
      id: json['id'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      projectCode: json['projectCode'],
      date: json['date'],
      hours: json['hours'] != null ? (json['hours'] as num) : null,
      formattedHours: json['formattedHours'],
      status: json['status'],
      statusLabel: json['statusLabel'],
      isBillable: json['isBillable'],
      billableAmount: json['billableAmount'] != null ? (json['billableAmount'] as num) : null,
      createdAt: json['createdAt'],
      description: json['description'],
      taskId: json['taskId'],
      billingRate: json['billingRate'] != null ? num.tryParse(json['billingRate'].toString()) : null,
      costRate: json['costRate'] != null ? num.tryParse(json['costRate'].toString()) : null,
      costAmount: json['costAmount'] != null ? (json['costAmount'] as num) : null,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num) : null,
      approvedBy: json['approvedBy'] != null ? Map<String, dynamic>.from(json['approvedBy']) : null,
      approvedAt: json['approvedAt'],
      updatedAt: json['updatedAt'],
      canEdit: json['canEdit'],
      canSubmit: json['canSubmit'],
      canDelete: json['canDelete'],
    );
  }
}

class TimesheetListResponse {
  int totalCount;
  num totalHours;
  num totalBillableHours;
  List<TimesheetModel> values;

  TimesheetListResponse({
    required this.totalCount,
    required this.totalHours,
    required this.totalBillableHours,
    required this.values,
  });

  factory TimesheetListResponse.fromJson(Map<String, dynamic> json) {
    return TimesheetListResponse(
      totalCount: json['totalCount'] ?? 0,
      totalHours: json['totalHours'] != null ? (json['totalHours'] as num) : 0,
      totalBillableHours: json['totalBillableHours'] != null ? (json['totalBillableHours'] as num) : 0,
      values: (json['values'] as List<dynamic>? ?? [])
          .map((e) => TimesheetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
