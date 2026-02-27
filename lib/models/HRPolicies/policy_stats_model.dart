class PolicyStatsModel {
  final int total;
  final int pending;
  final int acknowledged;
  final int overdue;

  PolicyStatsModel({
    required this.total,
    required this.pending,
    required this.acknowledged,
    required this.overdue,
  });

  factory PolicyStatsModel.fromJson(Map<String, dynamic> json) {
    return PolicyStatsModel(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      acknowledged: json['acknowledged'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'acknowledged': acknowledged,
      'overdue': overdue,
    };
  }
}
