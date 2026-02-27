/// Model for modifier record from API
/// Represents a payroll period with its associated modifiers
class ModifierRecord {
  final int payrollRecordId;
  final String period;
  final PayrollCycleInfo? payrollCycle;
  final ModifiersList modifiers;
  final AmountInfo totalEarnings;
  final AmountInfo totalDeductions;

  ModifierRecord({
    required this.payrollRecordId,
    required this.period,
    this.payrollCycle,
    required this.modifiers,
    required this.totalEarnings,
    required this.totalDeductions,
  });

  factory ModifierRecord.fromJson(Map<String, dynamic> json) {
    return ModifierRecord(
      payrollRecordId: json['payroll_record_id'] ?? 0,
      period: json['period'] ?? '',
      payrollCycle: json['payroll_cycle'] != null
          ? PayrollCycleInfo.fromJson(json['payroll_cycle'])
          : null,
      modifiers: ModifiersList.fromJson(json['modifiers'] ?? json['adjustments'] ?? {}),
      totalEarnings: AmountInfo.fromJson(json['total_earnings'] ?? {}),
      totalDeductions: AmountInfo.fromJson(json['total_deductions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payroll_record_id': payrollRecordId,
      'period': period,
      'payroll_cycle': payrollCycle?.toJson(),
      'modifiers': modifiers.toJson(),
      'total_earnings': totalEarnings.toJson(),
      'total_deductions': totalDeductions.toJson(),
    };
  }

  /// Get all modifiers (earnings + deductions) as a flat list
  List<ModifierItem> get allModifiers {
    return [...modifiers.earnings, ...modifiers.deductions];
  }

  /// Get total count of modifiers
  int get totalModifiersCount {
    return modifiers.earnings.length + modifiers.deductions.length;
  }

  /// Check if has any modifiers
  bool get hasModifiers {
    return totalModifiersCount > 0;
  }
}

/// Model for payroll cycle information
class PayrollCycleInfo {
  final String name;
  final String payDate;

  PayrollCycleInfo({
    required this.name,
    required this.payDate,
  });

  factory PayrollCycleInfo.fromJson(Map<String, dynamic> json) {
    return PayrollCycleInfo(
      name: json['name'] ?? '',
      payDate: json['pay_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pay_date': payDate,
    };
  }
}

/// Model for modifiers list (earnings and deductions)
class ModifiersList {
  final List<ModifierItem> earnings;
  final List<ModifierItem> deductions;

  ModifiersList({
    required this.earnings,
    required this.deductions,
  });

  factory ModifiersList.fromJson(Map<String, dynamic> json) {
    return ModifiersList(
      earnings: (json['earnings'] as List<dynamic>?)
              ?.map((e) => ModifierItem.fromJson(e, 'benefit'))
              .toList() ??
          [],
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => ModifierItem.fromJson(e, 'deduction'))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnings': earnings.map((e) => e.toJson()).toList(),
      'deductions': deductions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get total count of all modifiers
  int get totalCount => earnings.length + deductions.length;

  /// Check if has any modifiers
  bool get hasModifiers => totalCount > 0;
}

/// Model for individual modifier item
class ModifierItem {
  final int? id;
  final String name;
  final String code;
  final AmountInfo amount;
  final double? percentage;
  final String type; // 'benefit' or 'deduction'
  final String? applicability;

  ModifierItem({
    this.id,
    required this.name,
    required this.code,
    required this.amount,
    this.percentage,
    required this.type,
    this.applicability,
  });

  factory ModifierItem.fromJson(Map<String, dynamic> json, String type) {
    return ModifierItem(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      amount: AmountInfo.fromJson(json['amount'] ?? {}),
      percentage: json['percentage'] != null
          ? _parseDouble(json['percentage'])
          : null,
      type: type,
      applicability: json['applicability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'amount': amount.toJson(),
      'percentage': percentage,
      'type': type,
      'applicability': applicability,
    };
  }

  /// Check if this is a benefit/earning
  bool get isBenefit => type == 'benefit';

  /// Check if this is a deduction
  bool get isDeduction => type == 'deduction';

  /// Get display text with percentage if available
  String get displayValue {
    if (percentage != null && percentage! > 0) {
      return '${amount.formatted} (${percentage!.toStringAsFixed(1)}%)';
    }
    return amount.formatted;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model for amount information with formatted string
class AmountInfo {
  final double amount;
  final String formatted;

  AmountInfo({
    required this.amount,
    required this.formatted,
  });

  factory AmountInfo.fromJson(Map<String, dynamic> json) {
    return AmountInfo(
      amount: _parseDouble(json['amount'] ?? json['value'] ?? 0),
      formatted: json['formatted'] ?? '₹0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'formatted': formatted,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
