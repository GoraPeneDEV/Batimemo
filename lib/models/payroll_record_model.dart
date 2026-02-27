/// Model representing a payroll record from the API
/// Matches the backend response structure for payroll records
class PayrollRecordModel {
  final int id;
  final String period;
  final SalaryAmount basicSalary;
  final SalaryAmount grossSalary;
  final SalaryAmount netSalary;
  final SalaryAmount taxAmount;
  final double overtimeHours;
  final double totalWorkedDays;
  final double totalAbsentDays;
  final double totalLeaveDays;
  final String status;
  final String? approvalStatus;
  final String? rejectionReason;
  final PayrollCycle? payrollCycle;
  final int adjustmentsCount;
  final String createdAt;

  PayrollRecordModel({
    required this.id,
    required this.period,
    required this.basicSalary,
    required this.grossSalary,
    required this.netSalary,
    required this.taxAmount,
    required this.overtimeHours,
    required this.totalWorkedDays,
    required this.totalAbsentDays,
    required this.totalLeaveDays,
    required this.status,
    this.approvalStatus,
    this.rejectionReason,
    this.payrollCycle,
    required this.adjustmentsCount,
    required this.createdAt,
  });

  factory PayrollRecordModel.fromJson(Map<String, dynamic> json) {
    return PayrollRecordModel(
      id: json['id'] ?? 0,
      period: json['period'] ?? '',
      basicSalary: SalaryAmount.fromJson(json['basic_salary'] ?? {}),
      grossSalary: SalaryAmount.fromJson(json['gross_salary'] ?? {}),
      netSalary: SalaryAmount.fromJson(json['net_salary'] ?? {}),
      taxAmount: SalaryAmount.fromJson(json['tax_amount'] ?? {}),
      overtimeHours: _parseDouble(json['overtime_hours']),
      totalWorkedDays: _parseDouble(json['total_worked_days']),
      totalAbsentDays: _parseDouble(json['total_absent_days']),
      totalLeaveDays: _parseDouble(json['total_leave_days']),
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'],
      rejectionReason: json['rejection_reason'],
      payrollCycle: json['payroll_cycle'] != null
          ? PayrollCycle.fromJson(json['payroll_cycle'])
          : null,
      adjustmentsCount: json['adjustments_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'basic_salary': basicSalary.toJson(),
      'gross_salary': grossSalary.toJson(),
      'net_salary': netSalary.toJson(),
      'tax_amount': taxAmount.toJson(),
      'overtime_hours': overtimeHours,
      'total_worked_days': totalWorkedDays,
      'total_absent_days': totalAbsentDays,
      'total_leave_days': totalLeaveDays,
      'status': status,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'payroll_cycle': payrollCycle?.toJson(),
      'adjustments_count': adjustmentsCount,
      'created_at': createdAt,
    };
  }

  /// Status checks
  bool get isPending => status == 'pending';
  bool get isProcessed => status == 'processed';
  bool get isPaid => status == 'paid';
  bool get isDraft => status == 'draft';

  /// Get status color for UI
  String get statusColorHex {
    switch (status.toLowerCase()) {
      case 'paid':
        return '#4CAF50'; // Green
      case 'processed':
        return '#2196F3'; // Blue
      case 'pending':
        return '#FF9800'; // Orange
      case 'draft':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model for salary amounts with formatted display
class SalaryAmount {
  final double amount;
  final String formatted;

  SalaryAmount({
    required this.amount,
    required this.formatted,
  });

  factory SalaryAmount.fromJson(Map<String, dynamic> json) {
    return SalaryAmount(
      amount: _parseDouble(json['amount']),
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

/// Model for payroll cycle information
class PayrollCycle {
  final int id;
  final String name;
  final String payPeriodStart;
  final String payPeriodEnd;
  final String payDate;

  PayrollCycle({
    required this.id,
    required this.name,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.payDate,
  });

  factory PayrollCycle.fromJson(Map<String, dynamic> json) {
    return PayrollCycle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      payPeriodStart: json['pay_period_start'] ?? '',
      payPeriodEnd: json['pay_period_end'] ?? '',
      payDate: json['pay_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pay_period_start': payPeriodStart,
      'pay_period_end': payPeriodEnd,
      'pay_date': payDate,
    };
  }
}

/// Detailed payroll record model (for detail screen)
class PayrollRecordDetailModel extends PayrollRecordModel {
  final String? approvedAt;
  final PayrollCycleDetail? payrollCycleDetail;
  final PayrollAdjustments adjustments;
  final String updatedAt;

  PayrollRecordDetailModel({
    required super.id,
    required super.period,
    required super.basicSalary,
    required super.grossSalary,
    required super.netSalary,
    required super.taxAmount,
    required super.overtimeHours,
    required super.totalWorkedDays,
    required super.totalAbsentDays,
    required super.totalLeaveDays,
    required super.status,
    super.approvalStatus,
    super.rejectionReason,
    super.payrollCycle,
    required super.adjustmentsCount,
    required super.createdAt,
    this.approvedAt,
    this.payrollCycleDetail,
    required this.adjustments,
    required this.updatedAt,
  });

  factory PayrollRecordDetailModel.fromJson(Map<String, dynamic> json) {
    return PayrollRecordDetailModel(
      id: json['id'] ?? 0,
      period: json['period'] ?? '',
      basicSalary: SalaryAmount.fromJson(json['basic_salary'] ?? {}),
      grossSalary: SalaryAmount.fromJson(json['gross_salary'] ?? {}),
      netSalary: SalaryAmount.fromJson(json['net_salary'] ?? {}),
      taxAmount: SalaryAmount.fromJson(json['tax_amount'] ?? {}),
      overtimeHours: PayrollRecordModel._parseDouble(json['overtime_hours']),
      totalWorkedDays: PayrollRecordModel._parseDouble(json['total_worked_days']),
      totalAbsentDays: PayrollRecordModel._parseDouble(json['total_absent_days']),
      totalLeaveDays: PayrollRecordModel._parseDouble(json['total_leave_days']),
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'],
      rejectionReason: json['rejection_reason'],
      payrollCycle: json['payroll_cycle'] != null
          ? PayrollCycle.fromJson(json['payroll_cycle'])
          : null,
      adjustmentsCount: json['adjustments_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      approvedAt: json['approved_at'],
      payrollCycleDetail: json['payroll_cycle'] != null
          ? PayrollCycleDetail.fromJson(json['payroll_cycle'])
          : null,
      adjustments: PayrollAdjustments.fromJson(json['modifiers'] ?? json['adjustments'] ?? {}),
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

/// Detailed payroll cycle model
class PayrollCycleDetail extends PayrollCycle {
  final String code;
  final String frequency;
  final String status;

  PayrollCycleDetail({
    required super.id,
    required super.name,
    required super.payPeriodStart,
    required super.payPeriodEnd,
    required super.payDate,
    required this.code,
    required this.frequency,
    required this.status,
  });

  factory PayrollCycleDetail.fromJson(Map<String, dynamic> json) {
    return PayrollCycleDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      payPeriodStart: json['pay_period_start'] ?? '',
      payPeriodEnd: json['pay_period_end'] ?? '',
      payDate: json['pay_date'] ?? '',
      code: json['code'] ?? '',
      frequency: json['frequency']?.toString() ?? '',
      status: json['status'] ?? '',
    );
  }
}

/// Payroll adjustments (earnings and deductions)
class PayrollAdjustments {
  final List<AdjustmentItem> earnings;
  final List<AdjustmentItem> deductions;
  final String totalEarnings;
  final String totalDeductions;

  PayrollAdjustments({
    required this.earnings,
    required this.deductions,
    required this.totalEarnings,
    required this.totalDeductions,
  });

  factory PayrollAdjustments.fromJson(Map<String, dynamic> json) {
    return PayrollAdjustments(
      earnings: (json['earnings'] as List?)
              ?.map((e) => AdjustmentItem.fromJson(e))
              .toList() ??
          [],
      deductions: (json['deductions'] as List?)
              ?.map((e) => AdjustmentItem.fromJson(e))
              .toList() ??
          [],
      totalEarnings: json['total_earnings'] ?? '₹0.00',
      totalDeductions: json['total_deductions'] ?? '₹0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnings': earnings.map((e) => e.toJson()).toList(),
      'deductions': deductions.map((e) => e.toJson()).toList(),
      'total_earnings': totalEarnings,
      'total_deductions': totalDeductions,
    };
  }
}

/// Adjustment item model
class AdjustmentItem {
  final int id;
  final String name;
  final String code;
  final SalaryAmount amount;
  final double? percentage;
  final String type;

  AdjustmentItem({
    required this.id,
    required this.name,
    required this.code,
    required this.amount,
    this.percentage,
    required this.type,
  });

  factory AdjustmentItem.fromJson(Map<String, dynamic> json) {
    return AdjustmentItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      amount: SalaryAmount.fromJson(json['amount'] ?? {}),
      percentage: json['percentage'] != null
          ? PayrollRecordModel._parseDouble(json['percentage'])
          : null,
      type: json['type'] ?? '',
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
    };
  }
}
