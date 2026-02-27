import 'leave_type.dart';

class LeaveBalanceItem {
  final LeaveType leaveType;
  final int year;
  final int entitled;
  final int carriedForward;
  final String? carryForwardExpiry;
  final int additional;
  final num used;
  final num pending;
  final num available;
  final num total;

  LeaveBalanceItem({
    required this.leaveType,
    required this.year,
    required this.entitled,
    required this.carriedForward,
    this.carryForwardExpiry,
    required this.additional,
    required this.used,
    required this.pending,
    required this.available,
    required this.total,
  });

  factory LeaveBalanceItem.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceItem(
      leaveType: LeaveType.fromJson(json['leaveType']),
      year: _parseInt(json['year']),
      entitled: _parseIntField(json['entitled']),
      carriedForward: _parseIntField(json['carriedForward']),
      carryForwardExpiry: json['carryForwardExpiry'],
      additional: _parseIntField(json['additional']),
      used: _parseNum(json['used']),
      pending: _parseNum(json['pending']),
      available: _parseNum(json['available']),
      total: _parseNum(json['total']),
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

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class LeaveBalanceSummary {
  final int year;
  final List<LeaveBalanceItem> leaveBalances;
  final num compensatoryOffBalance;

  LeaveBalanceSummary({
    required this.year,
    required this.leaveBalances,
    required this.compensatoryOffBalance,
  });

  factory LeaveBalanceSummary.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceSummary(
      year: _parseInt(json['year']),
      leaveBalances: (json['leaveBalances'] as List)
          .map((item) => LeaveBalanceItem.fromJson(item))
          .toList(),
      compensatoryOffBalance: _parseNum(json['compensatoryOffBalance']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return DateTime.now().year;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? DateTime.now().year;
    if (value is double) return value.toInt();
    return DateTime.now().year;
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
