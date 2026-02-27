import 'earning_component.dart';
import 'deduction_component.dart';
import 'payroll_modifier.dart';

/// Enhanced model for detailed payslip information
/// This is the complete payslip that employees can view and download
class Payslip {
  final int id;
  final String code;
  final int employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String? designation;
  final String? department;

  // Period information
  final String payrollPeriod; // Format: "January 2025" or "2025-01"
  final String periodStartDate;
  final String periodEndDate;
  final String paymentDate;

  // Salary breakdown
  final double basicSalary;
  final double grossSalary;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;
  final double ctc; // Cost to Company

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

  // LOP and Overtime
  final double lopDays;
  final double lopAmount;
  final double overtimeAmount;

  // Components
  final List<EarningComponent> earningComponents;
  final List<DeductionComponent> deductionComponents;
  final List<PayrollModifier> adjustments;

  // Bank details (for display on payslip)
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;

  // Payment details
  final String paymentMode; // 'bank_transfer', 'cash', 'cheque'
  final String? transactionId;
  final String? chequeNumber;

  // YTD (Year to Date) information
  final double? ytdGross;
  final double? ytdDeductions;
  final double? ytdNet;
  final double? ytdTax;

  // Status and metadata
  final String status; // 'draft', 'generated', 'sent', 'viewed', 'downloaded'
  final String? generatedBy;
  final String? notes;
  final String? pdfUrl;
  final String createdAt;
  final String? updatedAt;
  final String? viewedAt;
  final String? downloadedAt;

  Payslip({
    required this.id,
    required this.code,
    required this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.designation,
    this.department,
    required this.payrollPeriod,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.paymentDate,
    required this.basicSalary,
    required this.grossSalary,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.ctc,
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
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    required this.paymentMode,
    this.transactionId,
    this.chequeNumber,
    this.ytdGross,
    this.ytdDeductions,
    this.ytdNet,
    this.ytdTax,
    required this.status,
    this.generatedBy,
    this.notes,
    this.pdfUrl,
    required this.createdAt,
    this.updatedAt,
    this.viewedAt,
    this.downloadedAt,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'],
      employeeCode: json['employeeCode'],
      designation: json['designation'],
      department: json['department'],
      payrollPeriod: json['payrollPeriod'] ?? '',
      periodStartDate: json['periodStartDate'] ?? '',
      periodEndDate: json['periodEndDate'] ?? '',
      paymentDate: json['paymentDate'] ?? '',
      basicSalary: _parseDouble(json['basicSalary']),
      grossSalary: _parseDouble(json['grossSalary']),
      totalEarnings: _parseDouble(json['totalEarnings']),
      totalDeductions: _parseDouble(json['totalDeductions']),
      netSalary: _parseDouble(json['netSalary']),
      ctc: _parseDouble(json['ctc']),
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
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      paymentMode: json['paymentMode'] ?? 'bank_transfer',
      transactionId: json['transactionId'],
      chequeNumber: json['chequeNumber'],
      ytdGross: json['ytdGross'] != null ? _parseDouble(json['ytdGross']) : null,
      ytdDeductions: json['ytdDeductions'] != null
          ? _parseDouble(json['ytdDeductions'])
          : null,
      ytdNet: json['ytdNet'] != null ? _parseDouble(json['ytdNet']) : null,
      ytdTax: json['ytdTax'] != null ? _parseDouble(json['ytdTax']) : null,
      status: json['status'] ?? 'draft',
      generatedBy: json['generatedBy'],
      notes: json['notes'],
      pdfUrl: json['pdfUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
      viewedAt: json['viewedAt'],
      downloadedAt: json['downloadedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeCode': employeeCode,
      'designation': designation,
      'department': department,
      'payrollPeriod': payrollPeriod,
      'periodStartDate': periodStartDate,
      'periodEndDate': periodEndDate,
      'paymentDate': paymentDate,
      'basicSalary': basicSalary,
      'grossSalary': grossSalary,
      'totalEarnings': totalEarnings,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'ctc': ctc,
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
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'paymentMode': paymentMode,
      'transactionId': transactionId,
      'chequeNumber': chequeNumber,
      'ytdGross': ytdGross,
      'ytdDeductions': ytdDeductions,
      'ytdNet': ytdNet,
      'ytdTax': ytdTax,
      'status': status,
      'generatedBy': generatedBy,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'viewedAt': viewedAt,
      'downloadedAt': downloadedAt,
    };
  }

  Payslip copyWith({
    int? id,
    String? code,
    int? employeeId,
    String? employeeName,
    String? employeeCode,
    String? designation,
    String? department,
    String? payrollPeriod,
    String? periodStartDate,
    String? periodEndDate,
    String? paymentDate,
    double? basicSalary,
    double? grossSalary,
    double? totalEarnings,
    double? totalDeductions,
    double? netSalary,
    double? ctc,
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
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? paymentMode,
    String? transactionId,
    String? chequeNumber,
    double? ytdGross,
    double? ytdDeductions,
    double? ytdNet,
    double? ytdTax,
    String? status,
    String? generatedBy,
    String? notes,
    String? pdfUrl,
    String? createdAt,
    String? updatedAt,
    String? viewedAt,
    String? downloadedAt,
  }) {
    return Payslip(
      id: id ?? this.id,
      code: code ?? this.code,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      payrollPeriod: payrollPeriod ?? this.payrollPeriod,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      paymentDate: paymentDate ?? this.paymentDate,
      basicSalary: basicSalary ?? this.basicSalary,
      grossSalary: grossSalary ?? this.grossSalary,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      ctc: ctc ?? this.ctc,
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
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      paymentMode: paymentMode ?? this.paymentMode,
      transactionId: transactionId ?? this.transactionId,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      ytdGross: ytdGross ?? this.ytdGross,
      ytdDeductions: ytdDeductions ?? this.ytdDeductions,
      ytdNet: ytdNet ?? this.ytdNet,
      ytdTax: ytdTax ?? this.ytdTax,
      status: status ?? this.status,
      generatedBy: generatedBy ?? this.generatedBy,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewedAt: viewedAt ?? this.viewedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  /// Status checks
  bool get isDraft => status == 'draft';
  bool get isGenerated => status == 'generated';
  bool get isSent => status == 'sent';
  bool get isViewed => status == 'viewed';
  bool get isDownloaded => status == 'downloaded';

  /// Get attendance percentage
  double get attendancePercentage {
    if (totalWorkingDays == 0) return 0.0;
    return (totalWorkedDays / totalWorkingDays) * 100;
  }

  /// Get total taxable earnings
  double get totalTaxableEarnings {
    return earningComponents
        .where((e) => e.isTaxable)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get total non-taxable earnings
  double get totalNonTaxableEarnings {
    return earningComponents
        .where((e) => !e.isTaxable)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get statutory deductions
  double get totalStatutoryDeductions {
    return deductionComponents
        .where((d) => d.isStatutory)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Get non-statutory deductions
  double get totalNonStatutoryDeductions {
    return deductionComponents
        .where((d) => !d.isStatutory)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Get positive adjustments (additions)
  double get totalPositiveAdjustments {
    return adjustments
        .where((a) => a.isEarning)
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  /// Get negative adjustments (deductions)
  double get totalNegativeAdjustments {
    return adjustments
        .where((a) => a.isDeduction)
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  /// Get masked account number for display (e.g., XXXX1234)
  String? get maskedAccountNumber {
    if (accountNumber == null || accountNumber!.length < 4) {
      return accountNumber;
    }
    final lastFour = accountNumber!.substring(accountNumber!.length - 4);
    return 'XXXX$lastFour';
  }

  /// Check if payslip is downloadable
  bool get canDownload => pdfUrl != null && pdfUrl!.isNotEmpty;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
