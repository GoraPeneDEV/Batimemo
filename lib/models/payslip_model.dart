class PayslipModel {
  int? id;
  String? code;
  num? basicSalary;
  num? totalDeductions;
  num? totalBenefits;
  num? netSalary;
  num? totalWorkedDays;
  num? totalAbsentDays;
  num? totalLeaveDays;
  num? totalLateDays;
  num? totalEarlyCheckoutDays;
  num? totalOvertimeDays;
  num? totalHolidays;
  num? totalWeekends;
  num? totalWorkingDays;
  List<PayrollModifier>? payrollModifiers;
  String? status;
  String? payrollPeriod;
  String? createdAt;

  PayslipModel(
      {this.id,
      this.code,
      this.basicSalary,
      this.totalDeductions,
      this.totalBenefits,
      this.netSalary,
      this.totalWorkedDays,
      this.totalAbsentDays,
      this.totalLeaveDays,
      this.totalLateDays,
      this.totalEarlyCheckoutDays,
      this.totalOvertimeDays,
      this.totalHolidays,
      this.totalWeekends,
      this.totalWorkingDays,
      required this.payrollModifiers,
      this.status,
      this.payrollPeriod,
      this.createdAt});

  //Deserialize the data
  PayslipModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];

    // Handle nested salary objects (e.g., {"amount": 1900, "formatted": "$1,900.00"})
    basicSalary = _extractAmount(json['basic_salary'] ?? json['basicSalary']);
    totalDeductions = _extractAmount(json['total_deductions'] ?? json['totalDeductions']);
    totalBenefits = _extractAmount(json['total_benefits'] ?? json['totalBenefits']);
    netSalary = _extractAmount(json['net_salary'] ?? json['netSalary']);

    totalWorkedDays = json['total_worked_days'] ?? json['totalWorkedDays'];
    totalAbsentDays = json['total_absent_days'] ?? json['totalAbsentDays'];
    totalLeaveDays = json['total_leave_days'] ?? json['totalLeaveDays'];
    totalLateDays = json['total_late_days'] ?? json['totalLateDays'];
    totalEarlyCheckoutDays = json['total_early_checkout_days'] ?? json['totalEarlyCheckoutDays'];
    totalOvertimeDays = json['total_overtime_days'] ?? json['totalOvertimeDays'];
    totalHolidays = json['total_holidays'] ?? json['totalHolidays'];
    totalWeekends = json['total_weekends'] ?? json['totalWeekends'];
    totalWorkingDays = json['total_working_days'] ?? json['totalWorkingDays'];

    // Handle both old 'payroll_adjustments' key and new 'payroll_modifiers' key for backward compatibility
    if (json['payroll_modifiers'] != null || json['payrollModifiers'] != null ||
        json['payroll_adjustments'] != null || json['payrollAdjustments'] != null) {
      payrollModifiers = <PayrollModifier>[];
      final modifiers = json['payroll_modifiers'] ?? json['payrollModifiers'] ??
                        json['payroll_adjustments'] ?? json['payrollAdjustments'];
      if (modifiers is List) {
        modifiers.forEach((v) {
          payrollModifiers!.add(PayrollModifier.fromJson(v));
        });
      }
    }

    status = json['status'];
    payrollPeriod = json['period'] ?? json['payrollPeriod'];
    createdAt = json['created_at'] ?? json['createdAt'];
  }

  // Helper method to extract amount from nested objects or return direct value
  static num? _extractAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is Map<String, dynamic>) {
      return value['amount'] as num?;
    }
    return null;
  }

  //Serialize the data
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['code'] = code;
    data['basicSalary'] = basicSalary;
    data['totalDeductions'] = totalDeductions;
    data['totalBenefits'] = totalBenefits;
    data['netSalary'] = netSalary;
    data['totalWorkedDays'] = totalWorkedDays;
    data['totalAbsentDays'] = totalAbsentDays;
    data['totalLeaveDays'] = totalLeaveDays;
    data['totalLateDays'] = totalLateDays;
    data['totalEarlyCheckoutDays'] = totalEarlyCheckoutDays;
    data['totalOvertimeDays'] = totalOvertimeDays;
    data['totalHolidays'] = totalHolidays;
    data['totalWeekends'] = totalWeekends;
    data['totalWorkingDays'] = totalWorkingDays;
    data['payrollModifiers'] = payrollModifiers != null
        ? payrollModifiers!.map((v) => v?.toJson()).toList()
        : null;
    data['status'] = status;
    data['payrollPeriod'] = payrollPeriod;
    data['createdAt'] = createdAt;
    return data;
  }
}

class PayrollModifier {
  String? name;
  String? code;
  int? percentage;
  int? amount;
  String? type;

  PayrollModifier(
      {this.name, this.code, this.percentage, this.amount, this.type});

  PayrollModifier.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    percentage = json['percentage'];
    amount = json['amount'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['code'] = code;
    data['percentage'] = percentage;
    data['amount'] = amount;
    data['type'] = type;
    return data;
  }
}
