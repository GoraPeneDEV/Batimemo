import 'leave_balance.dart';

class LeaveType {
  final int id;
  final String name;
  final String code;
  final String? notes;
  final bool isProofRequired;
  final bool isCompOffType;
  final bool allowCarryForward;
  final int maxCarryForward;
  final int carryForwardExpiryMonths;
  final bool allowEncashment;
  final int maxEncashmentDays;
  final LeaveBalance? balance;

  LeaveType({
    required this.id,
    required this.name,
    required this.code,
    this.notes,
    required this.isProofRequired,
    required this.isCompOffType,
    required this.allowCarryForward,
    required this.maxCarryForward,
    required this.carryForwardExpiryMonths,
    required this.allowEncashment,
    required this.maxEncashmentDays,
    this.balance,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      notes: json['notes'],
      isProofRequired: json['isProofRequired'] ?? false,
      isCompOffType: json['isCompOffType'] ?? false,
      allowCarryForward: json['allowCarryForward'] ?? false,
      maxCarryForward: _parseIntOrDouble(json['maxCarryForward']),
      carryForwardExpiryMonths: _parseInt(json['carryForwardExpiryMonths']),
      allowEncashment: json['allowEncashment'] ?? false,
      maxEncashmentDays: _parseIntOrDouble(json['maxEncashmentDays']),
      balance: json['balance'] != null
          ? LeaveBalance.fromJson(json['balance'])
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int _parseIntOrDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'notes': notes,
      'isProofRequired': isProofRequired,
      'isCompOffType': isCompOffType,
      'allowCarryForward': allowCarryForward,
      'maxCarryForward': maxCarryForward,
      'carryForwardExpiryMonths': carryForwardExpiryMonths,
      'allowEncashment': allowEncashment,
      'maxEncashmentDays': maxEncashmentDays,
      'balance': balance?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
