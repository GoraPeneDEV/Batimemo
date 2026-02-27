class LeaveBalance {
  final int entitled;
  final int carriedForward;
  final int additional;
  final num used;
  final num available;

  LeaveBalance({
    required this.entitled,
    required this.carriedForward,
    required this.additional,
    required this.used,
    required this.available,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      entitled: _parseIntField(json['entitled']),
      carriedForward: _parseIntField(json['carriedForward']),
      additional: _parseIntField(json['additional']),
      used: _parseNum(json['used']),
      available: _parseNum(json['available']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'entitled': entitled,
      'carriedForward': carriedForward,
      'additional': additional,
      'used': used,
      'available': available,
    };
  }

  num get total => entitled + carriedForward + additional;
}
