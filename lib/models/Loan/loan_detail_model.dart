import 'loan_request_model.dart';
import 'loan_repayment.dart';

class ReviewedByInfo {
  final int id;
  final String name;

  ReviewedByInfo({
    required this.id,
    required this.name,
  });

  factory ReviewedByInfo.fromJson(Map<String, dynamic> json) {
    return ReviewedByInfo(
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

class LoanDetailModel {
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
  final ReviewedByInfo? reviewedBy;
  final String? approvedAt;
  final String? reviewedAt;
  final String? expectedDisbursementDate;
  final String? actualDisbursementDate;
  final String? firstEmiDate;
  final String? lastEmiDate;
  final bool isFullyPaid;
  final List<String>? supportingDocuments;
  final bool canEdit;
  final bool canCancel;
  final String createdAt;
  final String updatedAt;

  LoanDetailModel({
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
    this.reviewedBy,
    this.approvedAt,
    this.reviewedAt,
    this.expectedDisbursementDate,
    this.actualDisbursementDate,
    this.firstEmiDate,
    this.lastEmiDate,
    required this.isFullyPaid,
    this.supportingDocuments,
    required this.canEdit,
    required this.canCancel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    return LoanDetailModel(
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
      reviewedBy: json['reviewedBy'] != null ? ReviewedByInfo.fromJson(json['reviewedBy']) : null,
      approvedAt: json['approvedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      expectedDisbursementDate: json['expectedDisbursementDate'] as String?,
      actualDisbursementDate: json['actualDisbursementDate'] as String?,
      firstEmiDate: json['firstEmiDate'] as String?,
      lastEmiDate: json['lastEmiDate'] as String?,
      isFullyPaid: json['isFullyPaid'] as bool? ?? false,
      supportingDocuments: json['supportingDocuments'] != null
        ? List<String>.from(json['supportingDocuments'] as List)
        : null,
      canEdit: json['canEdit'] as bool? ?? false,
      canCancel: json['canCancel'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class LoanDetailResponse {
  final LoanDetailModel loan;
  final List<LoanRepayment> repayments;
  final List<Map<String, dynamic>>? repaymentSchedule;

  LoanDetailResponse({
    required this.loan,
    required this.repayments,
    this.repaymentSchedule,
  });

  factory LoanDetailResponse.fromJson(Map<String, dynamic> json) {
    return LoanDetailResponse(
      loan: LoanDetailModel.fromJson(json['loan']),
      repayments: (json['repayments'] as List)
          .map((item) => LoanRepayment.fromJson(item as Map<String, dynamic>))
          .toList(),
      repaymentSchedule: json['repaymentSchedule'] != null
          ? List<Map<String, dynamic>>.from(json['repaymentSchedule'] as List)
          : null,
    );
  }
}
