import 'leave_request.dart';
import 'leave_type.dart';

class LeavesByType {
  final LeaveType leaveType;
  final num totalDays;
  final int count;

  LeavesByType({
    required this.leaveType,
    required this.totalDays,
    required this.count,
  });

  factory LeavesByType.fromJson(Map<String, dynamic> json) {
    return LeavesByType(
      leaveType: LeaveType.fromJson(json['leaveType']),
      totalDays: _parseNum(json['totalDays']),
      count: json['count'] ?? 0,
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class LeaveStatistics {
  final int year;
  final int totalPending;
  final int totalApproved;
  final int totalRejected;
  final List<LeaveRequest> upcomingLeaves;
  final List<LeavesByType> leavesByType;

  LeaveStatistics({
    required this.year,
    required this.totalPending,
    required this.totalApproved,
    required this.totalRejected,
    required this.upcomingLeaves,
    required this.leavesByType,
  });

  factory LeaveStatistics.fromJson(Map<String, dynamic> json) {
    return LeaveStatistics(
      year: _parseInt(json['year']),
      totalPending: _parseIntField(json['totalPending']),
      totalApproved: _parseIntField(json['totalApproved']),
      totalRejected: _parseIntField(json['totalRejected']),
      upcomingLeaves: (json['upcomingLeaves'] as List? ?? [])
          .map((item) => LeaveRequest.fromJson(item))
          .toList(),
      leavesByType: (json['leavesByType'] as List? ?? [])
          .map((item) => LeavesByType.fromJson(item))
          .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return DateTime.now().year;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? DateTime.now().year;
    if (value is double) return value.toInt();
    return DateTime.now().year;
  }

  static int _parseIntField(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }
}
