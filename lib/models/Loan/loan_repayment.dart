class LoanRepayment {
  final int id;
  final String paymentNumber;
  final String? dueDate;
  final double emiAmount;
  final double principalAmount;
  final double interestAmount;
  final double? paidAmount;
  final String? paidDate;
  final String? paymentMethod;
  final String? transactionReference;
  final String status;
  final String statusLabel;
  final double remainingBalance;
  final bool isOverdue;
  final String? remarks;

  LoanRepayment({
    required this.id,
    required this.paymentNumber,
    this.dueDate,
    required this.emiAmount,
    required this.principalAmount,
    required this.interestAmount,
    this.paidAmount,
    this.paidDate,
    this.paymentMethod,
    this.transactionReference,
    required this.status,
    required this.statusLabel,
    required this.remainingBalance,
    required this.isOverdue,
    this.remarks,
  });

  factory LoanRepayment.fromJson(Map<String, dynamic> json) {
    return LoanRepayment(
      id: json['id'] as int,
      paymentNumber: json['paymentNumber'] as String,
      dueDate: json['dueDate'] as String?,
      emiAmount: (json['emiAmount'] as num).toDouble(),
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestAmount: (json['interestAmount'] as num).toDouble(),
      paidAmount: json['paidAmount'] != null ? (json['paidAmount'] as num).toDouble() : null,
      paidDate: json['paidDate'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionReference: json['transactionReference'] as String?,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      remainingBalance: (json['remainingBalance'] as num).toDouble(),
      isOverdue: json['isOverdue'] as bool,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentNumber': paymentNumber,
      'dueDate': dueDate,
      'emiAmount': emiAmount,
      'principalAmount': principalAmount,
      'interestAmount': interestAmount,
      'paidAmount': paidAmount,
      'paidDate': paidDate,
      'paymentMethod': paymentMethod,
      'transactionReference': transactionReference,
      'status': status,
      'statusLabel': statusLabel,
      'remainingBalance': remainingBalance,
      'isOverdue': isOverdue,
      'remarks': remarks,
    };
  }
}
