class TaskModel {
  int? id;
  String? title;
  String? description;
  int? statusId;
  String? statusName;
  String? statusColor;
  int? priorityId;
  String? priorityName;
  String? priorityColor;
  int? assignedToUserId;
  String? assignedToName;
  String? dueDate;
  num? estimatedHours;
  num? actualHours;
  bool? isMilestone;
  bool? isCompleted;
  bool? isRunning;
  String? completedAt;
  int? taskOrder;
  String? createdAt;

  // Detail-only fields
  int? parentTaskId;
  String? timeStartedAt;
  String? updatedAt;

  TaskModel({
    this.id,
    this.title,
    this.description,
    this.statusId,
    this.statusName,
    this.statusColor,
    this.priorityId,
    this.priorityName,
    this.priorityColor,
    this.assignedToUserId,
    this.assignedToName,
    this.dueDate,
    this.estimatedHours,
    this.actualHours,
    this.isMilestone,
    this.isCompleted,
    this.isRunning,
    this.completedAt,
    this.taskOrder,
    this.createdAt,
    this.parentTaskId,
    this.timeStartedAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      statusId: json['statusId'],
      statusName: json['statusName'],
      statusColor: json['statusColor'],
      priorityId: json['priorityId'],
      priorityName: json['priorityName'],
      priorityColor: json['priorityColor'],
      assignedToUserId: json['assignedToUserId'],
      assignedToName: json['assignedToName'],
      dueDate: json['dueDate'],
      estimatedHours: json['estimatedHours'] != null ? (json['estimatedHours'] as num) : null,
      actualHours: json['actualHours'] != null ? (json['actualHours'] as num) : null,
      isMilestone: json['isMilestone'],
      isCompleted: json['isCompleted'],
      isRunning: json['isRunning'],
      completedAt: json['completedAt'],
      taskOrder: json['taskOrder'],
      createdAt: json['createdAt'],
      parentTaskId: json['parentTaskId'],
      timeStartedAt: json['timeStartedAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class TaskListResponse {
  int totalCount;
  List<TaskModel> values;

  TaskListResponse({required this.totalCount, required this.values});

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      totalCount: json['totalCount'] ?? 0,
      values: (json['values'] as List<dynamic>? ?? [])
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
