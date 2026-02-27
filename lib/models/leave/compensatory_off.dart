import 'simple_user.dart';
import 'leave_request.dart';

class CompensatoryOff {
  final int id;
  final String workedDate;
  final num hoursWorked;
  final num compOffDays;
  final String expiryDate;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isUsed;
  final bool canBeUsed;
  final String createdAt;
  final String? reason;
  final String? usedDate;
  final LeaveRequest? leaveRequest;
  final String? approvalNotes;
  final SimpleUser? approvedBy;
  final String? approvedAt;
  final String? updatedAt;

  CompensatoryOff({
    required this.id,
    required this.workedDate,
    required this.hoursWorked,
    required this.compOffDays,
    required this.expiryDate,
    required this.status,
    required this.isUsed,
    required this.canBeUsed,
    required this.createdAt,
    this.reason,
    this.usedDate,
    this.leaveRequest,
    this.approvalNotes,
    this.approvedBy,
    this.approvedAt,
    this.updatedAt,
  });

  factory CompensatoryOff.fromJson(Map<String, dynamic> json) {
    return CompensatoryOff(
      id: json['id'],
      workedDate: json['workedDate'],
      hoursWorked: _parseNum(json['hoursWorked']),
      compOffDays: _parseNum(json['compOffDays']),
      expiryDate: json['expiryDate'],
      status: json['status'],
      isUsed: json['isUsed'] ?? false,
      canBeUsed: json['canBeUsed'] ?? false,
      createdAt: json['createdAt'],
      reason: json['reason'],
      usedDate: json['usedDate'],
      leaveRequest: json['leaveRequest'] != null
          ? LeaveRequest.fromJson(json['leaveRequest'])
          : null,
      approvalNotes: json['approvalNotes'],
      approvedBy: json['approvedBy'] != null
          ? SimpleUser.fromJson(json['approvedBy'])
          : null,
      approvedAt: json['approvedAt'],
      updatedAt: json['updatedAt'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class CompensatoryOffBalance {
  final num available;
  final num totalApproved;
  final num totalUsed;
  final num totalExpired;
  final num totalPending;

  CompensatoryOffBalance({
    required this.available,
    required this.totalApproved,
    required this.totalUsed,
    required this.totalExpired,
    required this.totalPending,
  });

  factory CompensatoryOffBalance.fromJson(Map<String, dynamic> json) {
    return CompensatoryOffBalance(
      available: _parseNum(json['available']),
      totalApproved: _parseNum(json['totalApproved']),
      totalUsed: _parseNum(json['totalUsed']),
      totalExpired: _parseNum(json['totalExpired']),
      totalPending: _parseNum(json['totalPending']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class CompOffStatisticsCounts {
  final int pending;
  final int approved;
  final int rejected;

  CompOffStatisticsCounts({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory CompOffStatisticsCounts.fromJson(Map<String, dynamic> json) {
    return CompOffStatisticsCounts(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class CompOffStatisticsDays {
  final num pending;
  final num approved;
  final num used;
  final num expired;

  CompOffStatisticsDays({
    required this.pending,
    required this.approved,
    required this.used,
    required this.expired,
  });

  factory CompOffStatisticsDays.fromJson(Map<String, dynamic> json) {
    return CompOffStatisticsDays(
      pending: _parseNum(json['pending']),
      approved: _parseNum(json['approved']),
      used: _parseNum(json['used']),
      expired: _parseNum(json['expired']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class CompensatoryOffStatistics {
  final int year;
  final CompOffStatisticsCounts counts;
  final CompOffStatisticsDays days;
  final List<CompensatoryOff> recentCompOffs;

  CompensatoryOffStatistics({
    required this.year,
    required this.counts,
    required this.days,
    required this.recentCompOffs,
  });

  factory CompensatoryOffStatistics.fromJson(Map<String, dynamic> json) {
    return CompensatoryOffStatistics(
      year: _parseInt(json['year']),
      counts: CompOffStatisticsCounts.fromJson(json['counts']),
      days: CompOffStatisticsDays.fromJson(json['days']),
      recentCompOffs: (json['recentCompOffs'] as List? ?? [])
          .map((item) => CompensatoryOff.fromJson(item))
          .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return DateTime.now().year;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? DateTime.now().year;
    if (value is double) return value.toInt();
    return DateTime.now().year;
  }
}
