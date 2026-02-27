class NextEmi {
  final double amount;
  final String dueDate;
  final bool isOverdue;

  NextEmi({
    required this.amount,
    required this.dueDate,
    required this.isOverdue,
  });

  factory NextEmi.fromJson(Map<String, dynamic> json) {
    return NextEmi(
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['dueDate'] as String,
      isOverdue: json['isOverdue'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'dueDate': dueDate,
      'isOverdue': isOverdue,
    };
  }
}

class LoanStatistics {
  final int activeLoans;
  final double totalOutstanding;
  final int pendingRequests;
  final double totalBorrowed;
  final double totalRepaid;
  final NextEmi? nextEmi;

  LoanStatistics({
    required this.activeLoans,
    required this.totalOutstanding,
    required this.pendingRequests,
    required this.totalBorrowed,
    required this.totalRepaid,
    this.nextEmi,
  });

  factory LoanStatistics.fromJson(Map<String, dynamic> json) {
    return LoanStatistics(
      activeLoans: json['activeLoans'] as int,
      totalOutstanding: (json['totalOutstanding'] as num).toDouble(),
      pendingRequests: json['pendingRequests'] as int,
      totalBorrowed: (json['totalBorrowed'] as num).toDouble(),
      totalRepaid: (json['totalRepaid'] as num).toDouble(),
      nextEmi: json['nextEmi'] != null ? NextEmi.fromJson(json['nextEmi']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeLoans': activeLoans,
      'totalOutstanding': totalOutstanding,
      'pendingRequests': pendingRequests,
      'totalBorrowed': totalBorrowed,
      'totalRepaid': totalRepaid,
      'nextEmi': nextEmi?.toJson(),
    };
  }
}
