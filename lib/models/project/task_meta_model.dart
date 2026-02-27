class TaskStatusOption {
  int id;
  String name;
  String? color;

  TaskStatusOption({required this.id, required this.name, this.color});

  factory TaskStatusOption.fromJson(Map<String, dynamic> json) {
    return TaskStatusOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'],
    );
  }
}

class TaskPriorityOption {
  int id;
  String name;
  String? color;

  TaskPriorityOption({required this.id, required this.name, this.color});

  factory TaskPriorityOption.fromJson(Map<String, dynamic> json) {
    return TaskPriorityOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'],
    );
  }
}

class TaskMemberOption {
  int userId;
  String name;

  TaskMemberOption({required this.userId, required this.name});

  factory TaskMemberOption.fromJson(Map<String, dynamic> json) {
    return TaskMemberOption(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class TaskMetaModel {
  List<TaskStatusOption> statuses;
  List<TaskPriorityOption> priorities;
  List<TaskMemberOption> members;

  TaskMetaModel({
    required this.statuses,
    required this.priorities,
    required this.members,
  });

  factory TaskMetaModel.fromJson(Map<String, dynamic> json) {
    return TaskMetaModel(
      statuses: (json['statuses'] as List<dynamic>? ?? [])
          .map((e) => TaskStatusOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      priorities: (json['priorities'] as List<dynamic>? ?? [])
          .map((e) => TaskPriorityOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => TaskMemberOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
