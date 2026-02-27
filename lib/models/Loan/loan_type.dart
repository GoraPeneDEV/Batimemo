class LoanType {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final double? maxAmount;
  final double interestRate;
  final int? minTenureMonths;
  final int? maxTenureMonths;
  final double? processingFee;
  final String? processingFeeType;
  final String? eligibilityCriteria;
  final String? documentsRequired;

  LoanType({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.maxAmount,
    required this.interestRate,
    this.minTenureMonths,
    this.maxTenureMonths,
    this.processingFee,
    this.processingFeeType,
    this.eligibilityCriteria,
    this.documentsRequired,
  });

  factory LoanType.fromJson(Map<String, dynamic> json) {
    return LoanType(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      maxAmount: json['maxAmount'] != null ? (json['maxAmount'] as num).toDouble() : null,
      interestRate: (json['interestRate'] as num).toDouble(),
      minTenureMonths: json['minTenureMonths'] as int?,
      maxTenureMonths: json['maxTenureMonths'] as int?,
      processingFee: json['processingFee'] != null ? (json['processingFee'] as num).toDouble() : null,
      processingFeeType: json['processingFeeType'] as String?,
      eligibilityCriteria: json['eligibilityCriteria'] as String?,
      documentsRequired: json['documentsRequired'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'maxAmount': maxAmount,
      'interestRate': interestRate,
      'minTenureMonths': minTenureMonths,
      'maxTenureMonths': maxTenureMonths,
      'processingFee': processingFee,
      'processingFeeType': processingFeeType,
      'eligibilityCriteria': eligibilityCriteria,
      'documentsRequired': documentsRequired,
    };
  }
}
