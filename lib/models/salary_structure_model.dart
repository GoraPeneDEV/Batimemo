/// Salary Structure Model
///
/// Represents the complete salary structure for an employee including:
/// - Earnings (salary components that add to total salary)
/// - Deductions (salary components that reduce total salary)
/// - Component details (name, code, calculation type, value)
///
/// This model maps to the backend API response from:
/// GET /api/V1/payroll/my-salary-structure
class SalaryStructureModel {
  List<SalaryStructureComponent>? earnings;
  List<SalaryStructureComponent>? deductions;
  int? totalComponents;

  SalaryStructureModel({
    this.earnings,
    this.deductions,
    this.totalComponents,
  });

  SalaryStructureModel.fromJson(Map<String, dynamic> json) {
    if (json['earnings'] != null) {
      earnings = <SalaryStructureComponent>[];
      json['earnings'].forEach((v) {
        earnings!.add(SalaryStructureComponent.fromJson(v));
      });
    }

    if (json['deductions'] != null) {
      deductions = <SalaryStructureComponent>[];
      json['deductions'].forEach((v) {
        deductions!.add(SalaryStructureComponent.fromJson(v));
      });
    }

    totalComponents = json['total_components'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (earnings != null) {
      data['earnings'] = earnings!.map((v) => v.toJson()).toList();
    }
    if (deductions != null) {
      data['deductions'] = deductions!.map((v) => v.toJson()).toList();
    }

    data['total_components'] = totalComponents;
    return data;
  }

  /// Get total number of earnings components
  int get totalEarnings => earnings?.length ?? 0;

  /// Get total number of deductions components
  int get totalDeductions => deductions?.length ?? 0;

  /// Check if structure has any components
  bool get hasComponents => totalComponents != null && totalComponents! > 0;

  /// Check if structure has earnings
  bool get hasEarnings => earnings != null && earnings!.isNotEmpty;

  /// Check if structure has deductions
  bool get hasDeductions => deductions != null && deductions!.isNotEmpty;
}

/// Salary Structure Component
///
/// Represents a single component of the salary structure (earning or deduction)
/// Each component has:
/// - Component details (id, code, name, description, tax status)
/// - Calculation type (fixed amount or percentage)
/// - Value (amount or percentage value)
/// - Effective dates (from when to when this component is active)
class SalaryStructureComponent {
  int? id;
  PayrollComponent? component;
  String? calculationType; // 'fixed' or 'percentage'
  num? value;
  String? formattedValue; // Pre-formatted value from API (e.g., "₹5000.00" or "10%")
  String? effectiveFrom;
  String? effectiveTo;

  SalaryStructureComponent({
    this.id,
    this.component,
    this.calculationType,
    this.value,
    this.formattedValue,
    this.effectiveFrom,
    this.effectiveTo,
  });

  SalaryStructureComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (json['component'] != null) {
      component = PayrollComponent.fromJson(json['component']);
    }

    calculationType = json['calculation_type'];

    // Handle value as string or number (API can return both)
    final valueData = json['value'];
    if (valueData != null) {
      if (valueData is num) {
        value = valueData;
      } else if (valueData is String) {
        value = num.tryParse(valueData);
      }
    }

    formattedValue = json['formatted_value'];
    effectiveFrom = json['effective_from'];
    effectiveTo = json['effective_to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    if (component != null) {
      data['component'] = component!.toJson();
    }

    data['calculation_type'] = calculationType;
    data['value'] = value;
    data['formatted_value'] = formattedValue;
    data['effective_from'] = effectiveFrom;
    data['effective_to'] = effectiveTo;
    return data;
  }

  /// Check if this component is percentage-based
  bool get isPercentage => calculationType?.toLowerCase() == 'percentage';

  /// Check if this component is fixed amount
  bool get isFixed => calculationType?.toLowerCase() == 'fixed';

  /// Check if this component is currently active
  bool get isActive => effectiveTo == null;

  /// Get display name (component name or fallback)
  String get displayName => component?.name ?? 'Unknown Component';

  /// Get display code (component code or fallback)
  String get displayCode => component?.code ?? 'N/A';

  /// Get display value (formatted value or fallback)
  String get displayValue => formattedValue ?? (value?.toString() ?? '0');
}

/// Payroll Component Details
///
/// Represents the details of a payroll component
/// This is the base definition of a salary component (e.g., HRA, PF, etc.)
class PayrollComponent {
  int? id;
  String? code;
  String? name;
  String? description;
  bool? isTaxable;

  PayrollComponent({
    this.id,
    this.code,
    this.name,
    this.description,
    this.isTaxable,
  });

  PayrollComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    description = json['description'];
    isTaxable = json['is_taxable'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['description'] = description;
    data['is_taxable'] = isTaxable;
    return data;
  }

  /// Get short code for display (first 3 characters)
  String get shortCode => code != null && code!.length > 3
      ? code!.substring(0, 3).toUpperCase()
      : (code ?? 'N/A');
}
