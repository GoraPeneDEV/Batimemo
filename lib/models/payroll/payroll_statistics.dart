/// Model for payroll statistics and dashboard data
/// Provides overview of payroll trends, comparisons, and summaries
class PayrollStatistics {
  // Current month statistics
  final double currentMonthGross;
  final double currentMonthNet;
  final double currentMonthDeductions;
  final double currentMonthEarnings;

  // Previous month statistics for comparison
  final double? previousMonthGross;
  final double? previousMonthNet;
  final double? previousMonthDeductions;
  final double? previousMonthEarnings;

  // Year to Date (YTD) statistics
  final double ytdGross;
  final double ytdNet;
  final double ytdDeductions;
  final double ytdEarnings;
  final double ytdTax;

  // Average statistics
  final double averageMonthlyGross;
  final double averageMonthlyNet;
  final double averageMonthlyDeductions;

  // Attendance impact
  final double currentMonthAttendancePercentage;
  final double? previousMonthAttendancePercentage;
  final double ytdAverageAttendance;

  // LOP and Overtime
  final double currentMonthLopAmount;
  final double currentMonthOvertimeAmount;
  final double ytdLopAmount;
  final double ytdOvertimeAmount;

  // Statutory deductions breakdown
  final double currentMonthPF;
  final double currentMonthESI;
  final double currentMonthProfessionalTax;
  final double currentMonthIncomeTax;
  final double ytdPF;
  final double ytdESI;
  final double ytdProfessionalTax;
  final double ytdIncomeTax;

  // Payslip counts
  final int totalPayslips;
  final int paidPayslips;
  final int pendingPayslips;

  // Salary trends (month-wise data for charts)
  final List<MonthlyPayrollSummary>? monthlyTrends;

  // Highest and lowest
  final double? highestSalaryMonth;
  final String? highestSalaryMonthName;
  final double? lowestSalaryMonth;
  final String? lowestSalaryMonthName;

  // Meta information
  final String year;
  final String currentMonth;
  final String? lastUpdated;

  PayrollStatistics({
    required this.currentMonthGross,
    required this.currentMonthNet,
    required this.currentMonthDeductions,
    required this.currentMonthEarnings,
    this.previousMonthGross,
    this.previousMonthNet,
    this.previousMonthDeductions,
    this.previousMonthEarnings,
    required this.ytdGross,
    required this.ytdNet,
    required this.ytdDeductions,
    required this.ytdEarnings,
    required this.ytdTax,
    required this.averageMonthlyGross,
    required this.averageMonthlyNet,
    required this.averageMonthlyDeductions,
    required this.currentMonthAttendancePercentage,
    this.previousMonthAttendancePercentage,
    required this.ytdAverageAttendance,
    required this.currentMonthLopAmount,
    required this.currentMonthOvertimeAmount,
    required this.ytdLopAmount,
    required this.ytdOvertimeAmount,
    required this.currentMonthPF,
    required this.currentMonthESI,
    required this.currentMonthProfessionalTax,
    required this.currentMonthIncomeTax,
    required this.ytdPF,
    required this.ytdESI,
    required this.ytdProfessionalTax,
    required this.ytdIncomeTax,
    required this.totalPayslips,
    required this.paidPayslips,
    required this.pendingPayslips,
    this.monthlyTrends,
    this.highestSalaryMonth,
    this.highestSalaryMonthName,
    this.lowestSalaryMonth,
    this.lowestSalaryMonthName,
    required this.year,
    required this.currentMonth,
    this.lastUpdated,
  });

  factory PayrollStatistics.fromJson(Map<String, dynamic> json) {
    return PayrollStatistics(
      currentMonthGross: _parseDouble(json['currentMonthGross']),
      currentMonthNet: _parseDouble(json['currentMonthNet']),
      currentMonthDeductions: _parseDouble(json['currentMonthDeductions']),
      currentMonthEarnings: _parseDouble(json['currentMonthEarnings']),
      previousMonthGross: json['previousMonthGross'] != null
          ? _parseDouble(json['previousMonthGross'])
          : null,
      previousMonthNet: json['previousMonthNet'] != null
          ? _parseDouble(json['previousMonthNet'])
          : null,
      previousMonthDeductions: json['previousMonthDeductions'] != null
          ? _parseDouble(json['previousMonthDeductions'])
          : null,
      previousMonthEarnings: json['previousMonthEarnings'] != null
          ? _parseDouble(json['previousMonthEarnings'])
          : null,
      ytdGross: _parseDouble(json['ytdGross']),
      ytdNet: _parseDouble(json['ytdNet']),
      ytdDeductions: _parseDouble(json['ytdDeductions']),
      ytdEarnings: _parseDouble(json['ytdEarnings']),
      ytdTax: _parseDouble(json['ytdTax']),
      averageMonthlyGross: _parseDouble(json['averageMonthlyGross']),
      averageMonthlyNet: _parseDouble(json['averageMonthlyNet']),
      averageMonthlyDeductions: _parseDouble(json['averageMonthlyDeductions']),
      currentMonthAttendancePercentage:
          _parseDouble(json['currentMonthAttendancePercentage']),
      previousMonthAttendancePercentage:
          json['previousMonthAttendancePercentage'] != null
              ? _parseDouble(json['previousMonthAttendancePercentage'])
              : null,
      ytdAverageAttendance: _parseDouble(json['ytdAverageAttendance']),
      currentMonthLopAmount: _parseDouble(json['currentMonthLopAmount']),
      currentMonthOvertimeAmount:
          _parseDouble(json['currentMonthOvertimeAmount']),
      ytdLopAmount: _parseDouble(json['ytdLopAmount']),
      ytdOvertimeAmount: _parseDouble(json['ytdOvertimeAmount']),
      currentMonthPF: _parseDouble(json['currentMonthPF']),
      currentMonthESI: _parseDouble(json['currentMonthESI']),
      currentMonthProfessionalTax:
          _parseDouble(json['currentMonthProfessionalTax']),
      currentMonthIncomeTax: _parseDouble(json['currentMonthIncomeTax']),
      ytdPF: _parseDouble(json['ytdPF']),
      ytdESI: _parseDouble(json['ytdESI']),
      ytdProfessionalTax: _parseDouble(json['ytdProfessionalTax']),
      ytdIncomeTax: _parseDouble(json['ytdIncomeTax']),
      totalPayslips: json['totalPayslips'] ?? 0,
      paidPayslips: json['paidPayslips'] ?? 0,
      pendingPayslips: json['pendingPayslips'] ?? 0,
      monthlyTrends: json['monthlyTrends'] != null
          ? (json['monthlyTrends'] as List)
              .map((item) => MonthlyPayrollSummary.fromJson(item))
              .toList()
          : null,
      highestSalaryMonth: json['highestSalaryMonth'] != null
          ? _parseDouble(json['highestSalaryMonth'])
          : null,
      highestSalaryMonthName: json['highestSalaryMonthName'],
      lowestSalaryMonth: json['lowestSalaryMonth'] != null
          ? _parseDouble(json['lowestSalaryMonth'])
          : null,
      lowestSalaryMonthName: json['lowestSalaryMonthName'],
      year: json['year'] ?? '',
      currentMonth: json['currentMonth'] ?? '',
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentMonthGross': currentMonthGross,
      'currentMonthNet': currentMonthNet,
      'currentMonthDeductions': currentMonthDeductions,
      'currentMonthEarnings': currentMonthEarnings,
      'previousMonthGross': previousMonthGross,
      'previousMonthNet': previousMonthNet,
      'previousMonthDeductions': previousMonthDeductions,
      'previousMonthEarnings': previousMonthEarnings,
      'ytdGross': ytdGross,
      'ytdNet': ytdNet,
      'ytdDeductions': ytdDeductions,
      'ytdEarnings': ytdEarnings,
      'ytdTax': ytdTax,
      'averageMonthlyGross': averageMonthlyGross,
      'averageMonthlyNet': averageMonthlyNet,
      'averageMonthlyDeductions': averageMonthlyDeductions,
      'currentMonthAttendancePercentage': currentMonthAttendancePercentage,
      'previousMonthAttendancePercentage': previousMonthAttendancePercentage,
      'ytdAverageAttendance': ytdAverageAttendance,
      'currentMonthLopAmount': currentMonthLopAmount,
      'currentMonthOvertimeAmount': currentMonthOvertimeAmount,
      'ytdLopAmount': ytdLopAmount,
      'ytdOvertimeAmount': ytdOvertimeAmount,
      'currentMonthPF': currentMonthPF,
      'currentMonthESI': currentMonthESI,
      'currentMonthProfessionalTax': currentMonthProfessionalTax,
      'currentMonthIncomeTax': currentMonthIncomeTax,
      'ytdPF': ytdPF,
      'ytdESI': ytdESI,
      'ytdProfessionalTax': ytdProfessionalTax,
      'ytdIncomeTax': ytdIncomeTax,
      'totalPayslips': totalPayslips,
      'paidPayslips': paidPayslips,
      'pendingPayslips': pendingPayslips,
      'monthlyTrends': monthlyTrends?.map((m) => m.toJson()).toList(),
      'highestSalaryMonth': highestSalaryMonth,
      'highestSalaryMonthName': highestSalaryMonthName,
      'lowestSalaryMonth': lowestSalaryMonth,
      'lowestSalaryMonthName': lowestSalaryMonthName,
      'year': year,
      'currentMonth': currentMonth,
      'lastUpdated': lastUpdated,
    };
  }

  /// Calculate month-over-month growth percentage for net salary
  double? get netSalaryGrowthPercentage {
    if (previousMonthNet == null || previousMonthNet == 0) return null;
    return ((currentMonthNet - previousMonthNet!) / previousMonthNet!) * 100;
  }

  /// Calculate month-over-month growth percentage for gross salary
  double? get grossSalaryGrowthPercentage {
    if (previousMonthGross == null || previousMonthGross == 0) return null;
    return ((currentMonthGross - previousMonthGross!) / previousMonthGross!) *
        100;
  }

  /// Check if current month salary is higher than previous month
  bool get isCurrentMonthHigher {
    if (previousMonthNet == null) return false;
    return currentMonthNet > previousMonthNet!;
  }

  /// Get total statutory deductions for current month
  double get currentMonthTotalStatutoryDeductions {
    return currentMonthPF +
        currentMonthESI +
        currentMonthProfessionalTax +
        currentMonthIncomeTax;
  }

  /// Get total statutory deductions for YTD
  double get ytdTotalStatutoryDeductions {
    return ytdPF + ytdESI + ytdProfessionalTax + ytdIncomeTax;
  }

  /// Get deduction percentage for current month
  double get currentMonthDeductionPercentage {
    if (currentMonthGross == 0) return 0.0;
    return (currentMonthDeductions / currentMonthGross) * 100;
  }

  /// Get average deduction percentage for YTD
  double get ytdDeductionPercentage {
    if (ytdGross == 0) return 0.0;
    return (ytdDeductions / ytdGross) * 100;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Model for monthly payroll summary (for trends/charts)
class MonthlyPayrollSummary {
  final String month; // Format: "2025-01" or "January 2025"
  final String monthName; // "January"
  final int year;
  final double grossSalary;
  final double netSalary;
  final double deductions;
  final double earnings;
  final double attendancePercentage;

  MonthlyPayrollSummary({
    required this.month,
    required this.monthName,
    required this.year,
    required this.grossSalary,
    required this.netSalary,
    required this.deductions,
    required this.earnings,
    required this.attendancePercentage,
  });

  factory MonthlyPayrollSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyPayrollSummary(
      month: json['month'] ?? '',
      monthName: json['monthName'] ?? '',
      year: json['year'] ?? 0,
      grossSalary: _parseDouble(json['grossSalary']),
      netSalary: _parseDouble(json['netSalary']),
      deductions: _parseDouble(json['deductions']),
      earnings: _parseDouble(json['earnings']),
      attendancePercentage: _parseDouble(json['attendancePercentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'monthName': monthName,
      'year': year,
      'grossSalary': grossSalary,
      'netSalary': netSalary,
      'deductions': deductions,
      'earnings': earnings,
      'attendancePercentage': attendancePercentage,
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
