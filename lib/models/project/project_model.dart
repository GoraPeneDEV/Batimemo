import 'project_member_model.dart';

class ProjectModel {
  int? id;
  String? name;
  String? code;
  String? description;
  String? status;
  String? statusLabel;
  String? type;
  String? typeLabel;
  String? priority;
  String? priorityLabel;
  String? colorCode;
  bool? isBillable;
  bool? isArchived;
  bool? isOverdue;
  int? completionPercentage;
  String? startDate;
  String? endDate;
  int? daysUntilDeadline;
  Map<String, dynamic>? projectManager;
  String? myRole;
  int? memberCount;
  String? createdAt;

  // Detail-only fields
  num? budget;
  num? actualCost;
  num? actualRevenue;
  num? hourlyRate;
  num? budgetVariance;
  num? budgetVariancePercentage;
  num? profitMargin;
  num? profitMarginPercentage;
  bool? isOverBudget;
  num? totalHours;
  num? billableHours;
  String? completedAt;
  String? updatedAt;
  Map<String, dynamic>? client;
  List<ProjectMemberModel>? members;

  ProjectModel({
    this.id,
    this.name,
    this.code,
    this.description,
    this.status,
    this.statusLabel,
    this.type,
    this.typeLabel,
    this.priority,
    this.priorityLabel,
    this.colorCode,
    this.isBillable,
    this.isArchived,
    this.isOverdue,
    this.completionPercentage,
    this.startDate,
    this.endDate,
    this.daysUntilDeadline,
    this.projectManager,
    this.myRole,
    this.memberCount,
    this.createdAt,
    this.budget,
    this.actualCost,
    this.actualRevenue,
    this.hourlyRate,
    this.budgetVariance,
    this.budgetVariancePercentage,
    this.profitMargin,
    this.profitMarginPercentage,
    this.isOverBudget,
    this.totalHours,
    this.billableHours,
    this.completedAt,
    this.updatedAt,
    this.client,
    this.members,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      status: json['status'],
      statusLabel: json['statusLabel'],
      type: json['type'],
      typeLabel: json['typeLabel'],
      priority: json['priority'],
      priorityLabel: json['priorityLabel'],
      colorCode: json['colorCode'],
      isBillable: json['isBillable'],
      isArchived: json['isArchived'],
      isOverdue: json['isOverdue'],
      completionPercentage: json['completionPercentage'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      daysUntilDeadline: json['daysUntilDeadline'],
      projectManager: json['projectManager'] != null
          ? Map<String, dynamic>.from(json['projectManager'])
          : null,
      myRole: json['myRole'],
      memberCount: json['memberCount'],
      createdAt: json['createdAt'],
      budget: json['budget'] != null ? num.tryParse(json['budget'].toString()) : null,
      actualCost: json['actualCost'] != null ? num.tryParse(json['actualCost'].toString()) : null,
      actualRevenue: json['actualRevenue'] != null ? num.tryParse(json['actualRevenue'].toString()) : null,
      hourlyRate: json['hourlyRate'] != null ? num.tryParse(json['hourlyRate'].toString()) : null,
      budgetVariance: json['budgetVariance'] != null ? num.tryParse(json['budgetVariance'].toString()) : null,
      budgetVariancePercentage: json['budgetVariancePercentage'] != null
          ? num.tryParse(json['budgetVariancePercentage'].toString())
          : null,
      profitMargin: json['profitMargin'] != null ? num.tryParse(json['profitMargin'].toString()) : null,
      profitMarginPercentage: json['profitMarginPercentage'] != null
          ? num.tryParse(json['profitMarginPercentage'].toString())
          : null,
      isOverBudget: json['isOverBudget'],
      totalHours: json['totalHours'] != null ? (json['totalHours'] as num) : null,
      billableHours: json['billableHours'] != null ? (json['billableHours'] as num) : null,
      completedAt: json['completedAt'],
      updatedAt: json['updatedAt'],
      client: json['client'] != null ? Map<String, dynamic>.from(json['client']) : null,
      members: json['members'] != null
          ? (json['members'] as List<dynamic>)
              .map((e) => ProjectMemberModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class ProjectListResponse {
  int totalCount;
  List<ProjectModel> values;

  ProjectListResponse({required this.totalCount, required this.values});

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      totalCount: json['totalCount'] ?? 0,
      values: (json['values'] as List<dynamic>? ?? [])
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
