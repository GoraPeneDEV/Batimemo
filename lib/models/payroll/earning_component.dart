/// Model representing an earning component in payroll
/// Examples: Basic Salary, HRA, Conveyance Allowance, Special Allowance, etc.
class EarningComponent {
  final int id;
  final String name;
  final String code;
  final String type; // 'fixed', 'percentage', 'variable'
  final double amount;
  final double? percentage;
  final bool isTaxable;
  final bool isStatutory;
  final String? description;
  final int? displayOrder;
  final String createdAt;
  final String? updatedAt;

  EarningComponent({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.amount,
    this.percentage,
    required this.isTaxable,
    required this.isStatutory,
    this.description,
    this.displayOrder,
    required this.createdAt,
    this.updatedAt,
  });

  factory EarningComponent.fromJson(Map<String, dynamic> json) {
    return EarningComponent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 'fixed',
      amount: _parseDouble(json['amount']),
      percentage: json['percentage'] != null
          ? _parseDouble(json['percentage'])
          : null,
      isTaxable: json['isTaxable'] ?? false,
      isStatutory: json['isStatutory'] ?? false,
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
      'isTaxable': isTaxable,
      'isStatutory': isStatutory,
      'description': description,
      'displayOrder': displayOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  EarningComponent copyWith({
    int? id,
    String? name,
    String? code,
    String? type,
    double? amount,
    double? percentage,
    bool? isTaxable,
    bool? isStatutory,
    String? description,
    int? displayOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return EarningComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      isTaxable: isTaxable ?? this.isTaxable,
      isStatutory: isStatutory ?? this.isStatutory,
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
