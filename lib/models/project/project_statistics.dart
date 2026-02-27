import 'project.dart';

class ProjectOverview {
  final int total;
  final int active;
  final int completed;
  final int onHold;
  final int overdue;

  ProjectOverview({
    required this.total,
    required this.active,
    required this.completed,
    required this.onHold,
    required this.overdue,
  });

  factory ProjectOverview.fromJson(Map<String, dynamic> json) {
    return ProjectOverview(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      completed: json['completed'] ?? 0,
      onHold: json['onHold'] ?? 0,
      overdue: json['overdue'] ?? 0,
    );
  }
}

class MyTimeStats {
  final double hoursThisWeek;
  final double billableHoursThisWeek;
  final int pendingTimesheets;

  MyTimeStats({
    required this.hoursThisWeek,
    required this.billableHoursThisWeek,
    required this.pendingTimesheets,
  });

  factory MyTimeStats.fromJson(Map<String, dynamic> json) {
    return MyTimeStats(
      hoursThisWeek: (json['hoursThisWeek'] as num?)?.toDouble() ?? 0.0,
      billableHoursThisWeek:
          (json['billableHoursThisWeek'] as num?)?.toDouble() ?? 0.0,
      pendingTimesheets: json['pendingTimesheets'] ?? 0,
    );
  }
}

class ProjectStatistics {
  final ProjectOverview overview;
  final MyTimeStats myTime;
  final List<Project> recentProjects;
  final List<Project> overdueProjects;

  ProjectStatistics({
    required this.overview,
    required this.myTime,
    required this.recentProjects,
    required this.overdueProjects,
  });

  factory ProjectStatistics.fromJson(Map<String, dynamic> json) {
    return ProjectStatistics(
      overview: ProjectOverview.fromJson(json['overview'] ?? {}),
      myTime: MyTimeStats.fromJson(json['myTime'] ?? {}),
      recentProjects: json['recentProjects'] != null
          ? (json['recentProjects'] as List)
              .map((p) => Project.fromJson(p))
              .toList()
          : [],
      overdueProjects: json['overdueProjects'] != null
          ? (json['overdueProjects'] as List)
              .map((p) => Project.fromJson(p))
              .toList()
          : [],
    );
  }
}
