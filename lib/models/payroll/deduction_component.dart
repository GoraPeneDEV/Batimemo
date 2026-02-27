/// Model representing a deduction component in payroll
/// Examples: PF, ESI, Professional Tax, Income Tax, LOP, etc.
class DeductionComponent {
  final int id;
  final String name;
  final String code;
  final String type; // 'fixed', 'percentage', 'variable'
  final double amount;
  final double? percentage;
  final bool isStatutory;
  final bool isEmployerContribution;
  final String? description;
  final int? displayOrder;
  final String createdAt;
  final String? updatedAt;

  DeductionComponent({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.amount,
    this.percentage,
    required this.isStatutory,
    required this.isEmployerContribution,
    this.description,
    this.displayOrder,
    required this.createdAt,
    this.updatedAt,
  });

  factory DeductionComponent.fromJson(Map<String, dynamic> json) {
    return DeductionComponent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'fixed',
      amount: _parseDouble(json['amount']),
      percentage: json['percentage'] != null
          ? _parseDouble(json['percentage'])
          : null,
      isStatutory: json['isStatutory'] ?? false,
      isEmployerContribution: json['isEmployerContribution'] ?? false,
      description: json['description'],
      displayOrder: json['displayOrder'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'amount': amount,
      'percentage': percentage,
      'isStatutory': isStatutory,
      'isEmployerContribution': isEmployerContribution,
      'description': description,
      'displayOrder': displayOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DeductionComponent copyWith({
    int? id,
    String? name,
    String? code,
    String? type,
    double? amount,
    double? percentage,
    bool? isStatutory,
    bool? isEmployerContribution,
    String? description,
    int? displayOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return DeductionComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      isStatutory: isStatutory ?? this.isStatutory,
      isEmployerContribution:
          isEmployerContribution ?? this.isEmployerContribution,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this is a fixed amount component
  bool get isFixed => type == 'fixed';

  /// Check if this is a percentage-based component
  bool get isPercentage => type == 'percentage';

  /// Check if this is a variable component
  bool get isVariable => type == 'variable';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
