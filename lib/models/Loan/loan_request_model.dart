class LoanTypeInfo {
  final int? id;
  final String? name;

  LoanTypeInfo({
    this.id,
    this.name,
  });

  factory LoanTypeInfo.fromJson(Map<String, dynamic> json) {
    return LoanTypeInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ApprovedByInfo {
  final int id;
  final String name;

  ApprovedByInfo({
    required this.id,
    required this.name,
  });

  factory ApprovedByInfo.fromJson(Map<String, dynamic> json) {
    return ApprovedByInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LoanRequestModel {
  final int id;
  final String loanNumber;
  final LoanTypeInfo? loanType;
  final double amount;
  final double? approvedAmount;
  final double? interestRate;
  final int? tenureMonths;
  final double? monthlyEmi;
  final double? totalAmount;
  final double? totalPaid;
  final double? outstandingAmount;
  final String? purpose;
  final String? remarks;
  final String status;
  final String statusLabel;
  final String? approverRemarks;
  final String? reviewerRemarks;
  final ApprovedByInfo? approvedBy;
  final String? approvedAt;
  final String? expectedDisbursementDate;
  final String? actualDisbursementDate;
  final String? firstEmiDate;
  final String? lastEmiDate;
  final bool isFullyPaid;
  final bool canEdit;
  final bool canCancel;
  final String createdAt;
  final String updatedAt;

  LoanRequestModel({
    required this.id,
    required this.loanNumber,
    this.loanType,
    required this.amount,
    this.approvedAmount,
    this.interestRate,
    this.tenureMonths,
    this.monthlyEmi,
    this.totalAmount,
    this.totalPaid,
    this.outstandingAmount,
    this.purpose,
    this.remarks,
    required this.status,
    required this.statusLabel,
    this.approverRemarks,
    this.reviewerRemarks,
    this.approvedBy,
    this.approvedAt,
    this.expectedDisbursementDate,
    this.actualDisbursementDate,
    this.firstEmiDate,
    this.lastEmiDate,
    required this.isFullyPaid,
    required this.canEdit,
    required this.canCancel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanRequestModel.fromJson(Map<String, dynamic> json) {
    return LoanRequestModel(
      id: json['id'] as int,
      loanNumber: json['loanNumber'] as String,
      loanType: json['loanType'] != null ? LoanTypeInfo.fromJson(json['loanType']) : null,
      amount: (json['amount'] as num).toDouble(),
      approvedAmount: json['approvedAmount'] != null ? (json['approvedAmount'] as num).toDouble() : null,
      interestRate: json['interestRate'] != null ? (json['interestRate'] as num).toDouble() : null,
      tenureMonths: json['tenureMonths'] as int?,
      monthlyEmi: json['monthlyEmi'] != null ? (json['monthlyEmi'] as num).toDouble() : null,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : null,
      totalPaid: json['totalPaid'] != null ? (json['totalPaid'] as num).toDouble() : null,
      outstandingAmount: json['outstandingAmount'] != null ? (json['outstandingAmount'] as num).toDouble() : null,
      purpose: json['purpose'] as String?,
      remarks: json['remarks'] as String?,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      approverRemarks: json['approverRemarks'] as String?,
      reviewerRemarks: json['reviewerRemarks'] as String?,
      approvedBy: json['approvedBy'] != null ? ApprovedByInfo.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] as String?,
      expectedDisbursementDate: json['expectedDisbursementDate'] as String?,
      actualDisbursementDate: json['actualDisbursementDate'] as String?,
      firstEmiDate: json['firstEmiDate'] as String?,
      lastEmiDate: json['lastEmiDate'] as String?,
      isFullyPaid: json['isFullyPaid'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanNumber': loanNumber,
      'loanType': loanType?.toJson(),
      'amount': amount,
      'approvedAmount': approvedAmount,
      'interestRate': interestRate,
      'tenureMonths': tenureMonths,
      'monthlyEmi': monthlyEmi,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'outstandingAmount': outstandingAmount,
      'purpose': purpose,
      'remarks': remarks,
      'status': status,
      'statusLabel': statusLabel,
      'approverRemarks': approverRemarks,
      'reviewerRemarks': reviewerRemarks,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt,
      'expectedDisbursementDate': expectedDisbursementDate,
      'actualDisbursementDate': actualDisbursementDate,
      'firstEmiDate': firstEmiDate,
      'lastEmiDate': lastEmiDate,
      'isFullyPaid': isFullyPaid,
      'canEdit': canEdit,
      'canCancel': canCancel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class LoanRequestResponse {
  final int totalCount;
  final List<LoanRequestModel> values;

  LoanRequestResponse({
    required this.totalCount,
    required this.values,
  });

  factory LoanRequestResponse.fromJson(Map<String, dynamic> json) {
    return LoanRequestResponse(
      totalCount: json['totalCount'] as int,
      values: (json['values'] as List)
          .map((item) => LoanRequestModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'values': values.map((item) => item.toJson()).toList(),
    };
  }
}
