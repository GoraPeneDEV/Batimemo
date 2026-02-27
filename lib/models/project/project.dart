class ProjectSimpleUser {
  final int id;
  final String name;

  ProjectSimpleUser({required this.id, required this.name});

  factory ProjectSimpleUser.fromJson(Map<String, dynamic> json) {
    return ProjectSimpleUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Project {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String status;
  final String statusLabel;
  final String type;
  final String typeLabel;
  final String priority;
  final String priorityLabel;
  final String? colorCode;
  final bool isBillable;
  final bool isArchived;
  final bool isOverdue;
  final int completionPercentage;
  final String? startDate;
  final String? endDate;
  final int? daysUntilDeadline;
  final ProjectSimpleUser? projectManager;
  final ProjectSimpleUser? client;
  final String? myRole;
  final int memberCount;
  final String? budget;
  final String? actualCost;
  final String? actualRevenue;
  final String? hourlyRate;
  final String? budgetVariance;
  final double? budgetVariancePercentage;
  final String? profitMargin;
  final double? profitMarginPercentage;
  final bool? isOverBudget;
  final double? totalHours;
  final double? billableHours;
  final String? completedAt;
  final String? createdAt;
  final List<ProjectMember> members;

  Project({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.status,
    required this.statusLabel,
    required this.type,
    required this.typeLabel,
    required this.priority,
    required this.priorityLabel,
    this.colorCode,
    required this.isBillable,
    required this.isArchived,
    required this.isOverdue,
    required this.completionPercentage,
    this.startDate,
    this.endDate,
    this.daysUntilDeadline,
    this.projectManager,
    this.client,
    this.myRole,
    required this.memberCount,
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
    this.createdAt,
    this.members = const [],
  });

  bool get isPlanning => status == 'planning';
  bool get isInProgress => status == 'in_progress';
  bool get isOnHold => status == 'on_hold';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'planning',
      statusLabel: json['statusLabel'] ?? json['status'] ?? '',
      type: json['type'] ?? 'internal',
      typeLabel: json['typeLabel'] ?? json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      priorityLabel: json['priorityLabel'] ?? json['priority'] ?? '',
      colorCode: json['colorCode'],
      isBillable: json['isBillable'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
      completionPercentage: json['completionPercentage'] ?? 0,
      startDate: json['startDate'],
      endDate: json['endDate'],
      daysUntilDeadline: json['daysUntilDeadline'],
      projectManager: json['projectManager'] != null
          ? ProjectSimpleUser.fromJson(json['projectManager'])
          : null,
      client: json['client'] != null
          ? ProjectSimpleUser.fromJson(json['client'])
          : null,
      myRole: json['myRole'],
      memberCount: json['memberCount'] ?? 0,
      budget: json['budget']?.toString(),
      actualCost: json['actualCost']?.toString(),
      actualRevenue: json['actualRevenue']?.toString(),
      hourlyRate: json['hourlyRate']?.toString(),
      budgetVariance: json['budgetVariance']?.toString(),
      budgetVariancePercentage: (json['budgetVariancePercentage'] as num?)?.toDouble(),
      profitMargin: json['profitMargin']?.toString(),
      profitMarginPercentage: (json['profitMarginPercentage'] as num?)?.toDouble(),
      isOverBudget: json['isOverBudget'],
      totalHours: (json['totalHours'] as num?)?.toDouble(),
      billableHours: (json['billableHours'] as num?)?.toDouble(),
      completedAt: json['completedAt'],
      createdAt: json['createdAt'],
      members: json['members'] != null
          ? (json['members'] as List)
              .map((m) => ProjectMember.fromJson(m))
              .toList()
          : [],
    );
  }
}

class ProjectMember {
  final int id;
  final int userId;
  final String name;
  final String? email;
  final String role;
  final String roleLabel;
  final String? hourlyRate;
  final double? effectiveHourlyRate;
  final int? allocationPercentage;
  final double? weeklyCapacityHours;
  final String? joinedAt;

  ProjectMember({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    required this.role,
    required this.roleLabel,
    this.hourlyRate,
    this.effectiveHourlyRate,
    this.allocationPercentage,
    this.weeklyCapacityHours,
    this.joinedAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'member',
      roleLabel: json['roleLabel'] ?? json['role'] ?? '',
      hourlyRate: json['hourlyRate']?.toString(),
      effectiveHourlyRate: (json['effectiveHourlyRate'] as num?)?.toDouble(),
      allocationPercentage: json['allocationPercentage'],
      weeklyCapacityHours: (json['weeklyCapacityHours'] as num?)?.toDouble(),
      joinedAt: json['joinedAt'],
    );
  }
}
