class PerformedBy {
  final int id;
  final String name;

  PerformedBy({
    required this.id,
    required this.name,
  });

  factory PerformedBy.fromJson(Map<String, dynamic> json) {
    return PerformedBy(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LoanHistory {
  final int id;
  final String action;
  final String description;
  final PerformedBy? performedBy;
  final String createdAt;

  LoanHistory({
    required this.id,
    required this.action,
    required this.description,
    this.performedBy,
    required this.createdAt,
  });

  factory LoanHistory.fromJson(Map<String, dynamic> json) {
    return LoanHistory(
      id: json['id'] as int,
      action: json['action'] as String,
      description: json['description'] as String,
      performedBy: json['performedBy'] != null ? PerformedBy.fromJson(json['performedBy']) : null,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'performedBy': performedBy?.toJson(),
      'createdAt': createdAt,
    };
  }
}
