class ProjectMemberModel {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? role;
  String? roleLabel;
  num? hourlyRate;
  num? effectiveHourlyRate;
  int? allocationPercentage;
  num? weeklyCapacityHours;
  String? joinedAt;

  ProjectMemberModel({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.role,
    this.roleLabel,
    this.hourlyRate,
    this.effectiveHourlyRate,
    this.allocationPercentage,
    this.weeklyCapacityHours,
    this.joinedAt,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      roleLabel: json['roleLabel'],
      hourlyRate: json['hourlyRate'] != null ? num.tryParse(json['hourlyRate'].toString()) : null,
      effectiveHourlyRate: json['effectiveHourlyRate'] != null
          ? num.tryParse(json['effectiveHourlyRate'].toString())
          : null,
      allocationPercentage: json['allocationPercentage'],
      weeklyCapacityHours: json['weeklyCapacityHours'] != null
          ? (json['weeklyCapacityHours'] as num)
          : null,
      joinedAt: json['joinedAt'],
    );
  }
}
