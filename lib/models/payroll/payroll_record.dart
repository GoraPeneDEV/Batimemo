import 'earning_component.dart';
import 'deduction_component.dart';
import 'payroll_modifier.dart';

/// Model representing a payroll record for a specific period
/// Contains all earnings, deductions, and attendance details for salary calculation
class PayrollRecord {
  final int id;
  final String payrollCode;
  final int employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String payrollPeriod; // Format: YYYY-MM or similar
  final String periodStartDate;
  final String periodEndDate;

  // Salary breakdown
  final double basicSalary;
  final double grossSalary;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;

  // Attendance details
  final double totalWorkingDays;
  final double totalWorkedDays;
  final double totalAbsentDays;
  final double totalLeaveDays;
  final double totalPaidLeaveDays;
  final double totalUnpaidLeaveDays;
  final double totalLateDays;
  final double totalEarlyCheckoutDays;
  final double totalOvertimeDays;
  final double totalOvertimeHours;
  final double totalHolidays;
  final double totalWeekends;

  // LOP (Loss of Pay)
  final double lopDays;
  final double lopAmount;

  // Overtime
  final double overtimeAmount;

  // Components
  final List<EarningComponent> earningComponents;
  final List<DeductionComponent> deductionComponents;
  final List<PayrollModifier> adjustments;

  // Status and metadata
  final String status; // 'draft', 'processing', 'approved', 'paid', 'rejected'
  final String? approvedBy;
  final String? approvedAt;
  final String? paidAt;
  final String? rejectionReason;
  final String? notes;
  final String createdAt;
  final String? updatedAt;

  PayrollRecord({
    required this.id,
    required this.payrollCode,
    required this.employeeId,
    this.employeeName,
    this.employeeCode,
    required this.payrollPeriod,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.basicSalary,
    required this.grossSalary,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.totalWorkingDays,
    required this.totalWorkedDays,
    required this.totalAbsentDays,
    required this.totalLeaveDays,
    required this.totalPaidLeaveDays,
    required this.totalUnpaidLeaveDays,
    required this.totalLateDays,
    required this.totalEarlyCheckoutDays,
    required this.totalOvertimeDays,
    required this.totalOvertimeHours,
    required this.totalHolidays,
    required this.totalWeekends,
    required this.lopDays,
    required this.lopAmount,
    required this.overtimeAmount,
    required this.earningComponents,
    required this.deductionComponents,
    required this.adjustments,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.paidAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: json['id'] ?? 0,
      payrollCode: json['payrollCode'] ?? '',
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'],
      employeeCode: json['employeeCode'],
      payrollPeriod: json['payrollPeriod'] ?? '',
      periodStartDate: json['periodStartDate'] ?? '',
      periodEndDate: json['periodEndDate'] ?? '',
      basicSalary: _parseDouble(json['basicSalary']),
      grossSalary: _parseDouble(json['grossSalary']),
      totalEarnings: _parseDouble(json['totalEarnings']),
      totalDeductions: _parseDouble(json['totalDeductions']),
      netSalary: _parseDouble(json['netSalary']),
      totalWorkingDays: _parseDouble(json['totalWorkingDays']),
      totalWorkedDays: _parseDouble(json['totalWorkedDays']),
      totalAbsentDays: _parseDouble(json['totalAbsentDays']),
      totalLeaveDays: _parseDouble(json['totalLeaveDays']),
      totalPaidLeaveDays: _parseDouble(json['totalPaidLeaveDays']),
      totalUnpaidLeaveDays: _parseDouble(json['totalUnpaidLeaveDays']),
      totalLateDays: _parseDouble(json['totalLateDays']),
      totalEarlyCheckoutDays: _parseDouble(json['totalEarlyCheckoutDays']),
      totalOvertimeDays: _parseDouble(json['totalOvertimeDays']),
      totalOvertimeHours: _parseDouble(json['totalOvertimeHours']),
      totalHolidays: _parseDouble(json['totalHolidays']),
      totalWeekends: _parseDouble(json['totalWeekends']),
      lopDays: _parseDouble(json['lopDays']),
      lopAmount: _parseDouble(json['lopAmount']),
      overtimeAmount: _parseDouble(json['overtimeAmount']),
      earningComponents: (json['earningComponents'] as List? ?? [])
          .map((item) => EarningComponent.fromJson(item))
          .toList(),
      deductionComponents: (json['deductionComponents'] as List? ?? [])
          .map((item) => DeductionComponent.fromJson(item))
          .toList(),
      adjustments: (json['adjustments'] as List? ?? [])
          .map((item) => PayrollModifier.fromJson(item))
          .toList(),
      status: json['status'] ?? 'draft',
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'],
      paidAt: json['paidAt'],
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payrollCode': payrollCode,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeCode': employeeCode,
      'payrollPeriod': payrollPeriod,
      'periodStartDate': periodStartDate,
      'periodEndDate': periodEndDate,
      'basicSalary': basicSalary,
      'grossSalary': grossSalary,
      'totalEarnings': totalEarnings,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'totalWorkingDays': totalWorkingDays,
      'totalWorkedDays': totalWorkedDays,
      'totalAbsentDays': totalAbsentDays,
      'totalLeaveDays': totalLeaveDays,
      'totalPaidLeaveDays': totalPaidLeaveDays,
      'totalUnpaidLeaveDays': totalUnpaidLeaveDays,
      'totalLateDays': totalLateDays,
      'totalEarlyCheckoutDays': totalEarlyCheckoutDays,
      'totalOvertimeDays': totalOvertimeDays,
      'totalOvertimeHours': totalOvertimeHours,
      'totalHolidays': totalHolidays,
      'totalWeekends': totalWeekends,
      'lopDays': lopDays,
      'lopAmount': lopAmount,
      'overtimeAmount': overtimeAmount,
      'earningComponents': earningComponents.map((e) => e.toJson()).toList(),
      'deductionComponents':
          deductionComponents.map((d) => d.toJson()).toList(),
      'adjustments': adjustments.map((a) => a.toJson()).toList(),
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'paidAt': paidAt,
      'rejectionReason': rejectionReason,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PayrollRecord copyWith({
    int? id,
    String? payrollCode,
    int? employeeId,
    String? employeeName,
    String? employeeCode,
    String? payrollPeriod,
    String? periodStartDate,
    String? periodEndDate,
    double? basicSalary,
    double? grossSalary,
    double? totalEarnings,
    double? totalDeductions,
    double? netSalary,
    double? totalWorkingDays,
    double? totalWorkedDays,
    double? totalAbsentDays,
    double? totalLeaveDays,
    double? totalPaidLeaveDays,
    double? totalUnpaidLeaveDays,
    double? totalLateDays,
    double? totalEarlyCheckoutDays,
    double? totalOvertimeDays,
    double? totalOvertimeHours,
    double? totalHolidays,
    double? totalWeekends,
    double? lopDays,
    double? lopAmount,
    double? overtimeAmount,
    List<EarningComponent>? earningComponents,
    List<DeductionComponent>? deductionComponents,
    List<PayrollModifier>? adjustments,
    String? status,
    String? approvedBy,
    String? approvedAt,
    String? paidAt,
    String? rejectionReason,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return PayrollRecord(
      id: id ?? this.id,
      payrollCode: payrollCode ?? this.payrollCode,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      payrollPeriod: payrollPeriod ?? this.payrollPeriod,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      basicSalary: basicSalary ?? this.basicSalary,
      grossSalary: grossSalary ?? this.grossSalary,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      totalWorkedDays: totalWorkedDays ?? this.totalWorkedDays,
      totalAbsentDays: totalAbsentDays ?? this.totalAbsentDays,
      totalLeaveDays: totalLeaveDays ?? this.totalLeaveDays,
      totalPaidLeaveDays: totalPaidLeaveDays ?? this.totalPaidLeaveDays,
      totalUnpaidLeaveDays: totalUnpaidLeaveDays ?? this.totalUnpaidLeaveDays,
      totalLateDays: totalLateDays ?? this.totalLateDays,
      totalEarlyCheckoutDays:
          totalEarlyCheckoutDays ?? this.totalEarlyCheckoutDays,
      totalOvertimeDays: totalOvertimeDays ?? this.totalOvertimeDays,
      totalOvertimeHours: totalOvertimeHours ?? this.totalOvertimeHours,
      totalHolidays: totalHolidays ?? this.totalHolidays,
      totalWeekends: totalWeekends ?? this.totalWeekends,
      lopDays: lopDays ?? this.lopDays,
      lopAmount: lopAmount ?? this.lopAmount,
      overtimeAmount: overtimeAmount ?? this.overtimeAmount,
      earningComponents: earningComponents ?? this.earningComponents,
      deductionComponents: deductionComponents ?? this.deductionComponents,
      adjustments: adjustments ?? this.adjustments,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      paidAt: paidAt ?? this.paidAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Status checks
  bool get isDraft => status == 'draft';
  bool get isProcessing => status == 'processing';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';

  /// Get attendance percentage
  double get attendancePercentage {
    if (totalWorkingDays == 0) return 0.0;
    return (totalWorkedDays / totalWorkingDays) * 100;
  }

  /// Get total paid adjustments (bonuses, incentives, etc.)
  double get totalPositiveAdjustments {
    return adjustments
        .where((a) => a.isEarning)
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  /// Get total deduction adjustments (penalties, advances, etc.)
  double get totalNegativeAdjustments {
    return adjustments
        .where((a) => a.isDeduction)
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case 'draft':
        return '#9E9E9E'; // Grey
      case 'processing':
        return '#2196F3'; // Blue
      case 'approved':
        return '#FF9800'; // Orange
      case 'paid':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
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
