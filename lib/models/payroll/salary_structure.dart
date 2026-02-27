import 'earning_component.dart';
import 'deduction_component.dart';

/// Model representing an employee's salary structure
/// Contains all earning and deduction components that make up the salary
class SalaryStructure {
  final int id;
  final String name;
  final String? description;
  final double ctc; // Cost to Company
  final double grossSalary;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;
  final List<EarningComponent> earningComponents;
  final List<DeductionComponent> deductionComponents;
  final String effectiveFrom;
  final String? effectiveTo;
  final String status; // 'active', 'inactive', 'draft'
  final String createdAt;
  final String? updatedAt;

  SalaryStructure({
    required this.id,
    required this.name,
    this.description,
    required this.ctc,
    required this.grossSalary,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.earningComponents,
    required this.deductionComponents,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory SalaryStructure.fromJson(Map<String, dynamic> json) {
    return SalaryStructure(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      ctc: _parseDouble(json['ctc']),
      grossSalary: _parseDouble(json['grossSalary']),
      totalEarnings: _parseDouble(json['totalEarnings']),
      totalDeductions: _parseDouble(json['totalDeductions']),
      netSalary: _parseDouble(json['netSalary']),
      earningComponents: (json['earningComponents'] as List? ?? [])
          .map((item) => EarningComponent.fromJson(item))
          .toList(),
      deductionComponents: (json['deductionComponents'] as List? ?? [])
          .map((item) => DeductionComponent.fromJson(item))
          .toList(),
      effectiveFrom: json['effectiveFrom'] ?? '',
      effectiveTo: json['effectiveTo'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ctc': ctc,
      'grossSalary': grossSalary,
      'totalEarnings': totalEarnings,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'earningComponents':
          earningComponents.map((e) => e.toJson()).toList(),
      'deductionComponents':
          deductionComponents.map((d) => d.toJson()).toList(),
      'effectiveFrom': effectiveFrom,
      'effectiveTo': effectiveTo,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  SalaryStructure copyWith({
    int? id,
    String? name,
    String? description,
    double? ctc,
    double? grossSalary,
    double? totalEarnings,
    double? totalDeductions,
    double? netSalary,
    List<EarningComponent>? earningComponents,
    List<DeductionComponent>? deductionComponents,
    String? effectiveFrom,
    String? effectiveTo,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return SalaryStructure(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ctc: ctc ?? this.ctc,
      grossSalary: grossSalary ?? this.grossSalary,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      earningComponents: earningComponents ?? this.earningComponents,
      deductionComponents: deductionComponents ?? this.deductionComponents,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if structure is active
  bool get isActive => status == 'active';

  /// Check if structure is inactive
  bool get isInactive => status == 'inactive';

  /// Check if structure is in draft
  bool get isDraft => status == 'draft';

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

  /// Get monthly CTC (if annual CTC is provided)
  double get monthlyCTC => ctc / 12;

  /// Get monthly gross salary
  double get monthlyGrossSalary => grossSalary / 12;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
