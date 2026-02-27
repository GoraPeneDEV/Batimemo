/// Model for regularization counts by status
class RegularizationCounts {
  final int pending;
  final int approved;
  final int rejected;
  final int total;

  RegularizationCounts({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  factory RegularizationCounts.fromJson(Map<String, dynamic> json) {
    return RegularizationCounts(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'total': total,
    };
  }
}
