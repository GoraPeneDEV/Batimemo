/// Model representing payroll modifiers (additions or deductions)
/// These can be one-time modifiers like bonus, penalty, advance, reimbursement, etc.
class PayrollModifier {
  final int? id;
  final String name;
  final String code;
  final String type; // 'earning' or 'deduction'
  final String calculationType; // 'fixed', 'percentage'
  final double? percentage;
  final double amount;
  final String? reason;
  final String? description;
  final bool isRecurring;
  final String? appliedMonth; // Format: YYYY-MM
  final String? createdAt;
  final String? updatedAt;

  PayrollModifier({
    this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.calculationType,
    this.percentage,
    required this.amount,
    this.reason,
    this.description,
    required this.isRecurring,
    this.appliedMonth,
    this.createdAt,
    this.updatedAt,
  });

  factory PayrollModifier.fromJson(Map<String, dynamic> json) {
    return PayrollModifier(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'earning',
      calculationType: json['calculationType'] ?? 'fixed',
      percentage: json['percentage'] != null
          ? _parseDouble(json['percentage'])
          : null,
      amount: _parseDouble(json['amount']),
      reason: json['reason'],
      description: json['description'],
      isRecurring: json['isRecurring'] ?? false,
      appliedMonth: json['appliedMonth'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'calculationType': calculationType,
      'percentage': percentage,
      'amount': amount,
      'reason': reason,
      'description': description,
      'isRecurring': isRecurring,
      'appliedMonth': appliedMonth,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PayrollModifier copyWith({
    int? id,
    String? name,
    String? code,
    String? type,
    String? calculationType,
    double? percentage,
    double? amount,
    String? reason,
    String? description,
    bool? isRecurring,
    String? appliedMonth,
    String? createdAt,
    String? updatedAt,
  }) {
    return PayrollModifier(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      calculationType: calculationType ?? this.calculationType,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      appliedMonth: appliedMonth ?? this.appliedMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this is an earning modifier
  bool get isEarning => type == 'earning';

  /// Check if this is a deduction modifier
  bool get isDeduction => type == 'deduction';

  /// Check if this is a fixed amount
  bool get isFixed => calculationType == 'fixed';

  /// Check if this is percentage-based
  bool get isPercentage => calculationType == 'percentage';

  /// Get display amount with sign
  String get displayAmount {
    final sign = isEarning ? '+' : '-';
    return '$sign ₹${amount.toStringAsFixed(2)}';
  }

  /// Get color for UI based on type
  String get colorCode {
    return isEarning ? '#4CAF50' : '#F44336'; // Green for earning, Red for deduction
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
