import 'leave_type.dart';
import 'simple_user.dart';

class TeamCalendarItem {
  final int id;
  final SimpleUser user;
  final LeaveType leaveType;
  final String fromDate;
  final String toDate;
  final bool isHalfDay;
  final String? halfDayType;
  final num totalDays;

  TeamCalendarItem({
    required this.id,
    required this.user,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.isHalfDay,
    this.halfDayType,
    required this.totalDays,
  });

  factory TeamCalendarItem.fromJson(Map<String, dynamic> json) {
    return TeamCalendarItem(
      id: json['id'],
      user: SimpleUser.fromJson(json['user']),
      leaveType: LeaveType.fromJson(json['leaveType']),
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      isHalfDay: json['isHalfDay'] ?? false,
      halfDayType: json['halfDayType'],
      totalDays: _parseNum(json['totalDays']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class TeamCalendar {
  final String fromDate;
  final String toDate;
  final List<TeamCalendarItem> leaves;

  TeamCalendar({
    required this.fromDate,
    required this.toDate,
    required this.leaves,
  });

  factory TeamCalendar.fromJson(Map<String, dynamic> json) {
    return TeamCalendar(
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      leaves: (json['leaves'] as List? ?? [])
          .map((item) => TeamCalendarItem.fromJson(item))
          .toList(),
    );
  }
}
