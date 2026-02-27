import 'leave_type.dart';
import 'simple_user.dart';
import 'comp_off_detail.dart';

class LeaveRequest {
  final int id;
  final String fromDate;
  final String toDate;
  final LeaveType leaveType;
  final bool isHalfDay;
  final String? halfDayType; // 'first_half' or 'second_half'
  final num totalDays;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String createdAt;
  final String? userNotes;
  final String? emergencyContact;
  final String? emergencyPhone;
  final bool? isAbroad;
  final String? abroadLocation;
  final String? document;
  final String? documentUrl;
  // Compensatory off fields
  final bool? usesCompOff;
  final num? compOffDaysUsed;
  final List<int>? compOffIds;
  final List<CompOffDetail>? compOffDetails;
  // Approval fields
  final String? approvalNotes;
  final SimpleUser? approvedBy;
  final String? approvedAt;
  final SimpleUser? rejectedBy;
  final String? rejectedAt;
  final String? cancelReason;
  final SimpleUser? cancelledBy;
  final String? cancelledAt;
  final String? updatedAt;
  final bool? canCancel;

  LeaveRequest({
    required this.id,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.isHalfDay,
    this.halfDayType,
    required this.totalDays,
    required this.status,
    required this.createdAt,
    this.userNotes,
    this.emergencyContact,
    this.emergencyPhone,
    this.isAbroad,
    this.abroadLocation,
    this.document,
    this.documentUrl,
    this.usesCompOff,
    this.compOffDaysUsed,
    this.compOffIds,
    this.compOffDetails,
    this.approvalNotes,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.cancelReason,
    this.cancelledBy,
    this.cancelledAt,
    this.updatedAt,
    this.canCancel,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      leaveType: LeaveType.fromJson(json['leaveType']),
      isHalfDay: json['isHalfDay'] ?? false,
      halfDayType: json['halfDayType'],
      totalDays: _parseNum(json['totalDays']),
      status: json['status'],
      createdAt: json['createdAt'],
      userNotes: json['userNotes'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      isAbroad: json['isAbroad'],
      abroadLocation: json['abroadLocation'],
      document: json['document'],
      documentUrl: json['documentUrl'],
      usesCompOff: json['usesCompOff'],
      compOffDaysUsed: json['compOffDaysUsed'] != null
          ? _parseNum(json['compOffDaysUsed'])
          : null,
      compOffIds: json['compOffIds'] != null
          ? List<int>.from(json['compOffIds'])
          : null,
      compOffDetails: json['compOffDetails'] != null
          ? (json['compOffDetails'] as List)
              .map((e) => CompOffDetail.fromJson(e))
              .toList()
          : null,
      approvalNotes: json['approvalNotes'],
      approvedBy: json['approvedBy'] != null
          ? SimpleUser.fromJson(json['approvedBy'])
          : null,
      approvedAt: json['approvedAt'],
      rejectedBy: json['rejectedBy'] != null
          ? SimpleUser.fromJson(json['rejectedBy'])
          : null,
      rejectedAt: json['rejectedAt'],
      cancelReason: json['cancelReason'],
      cancelledBy: json['cancelledBy'] != null
          ? SimpleUser.fromJson(json['cancelledBy'])
          : null,
      cancelledAt: json['cancelledAt'],
      updatedAt: json['updatedAt'],
      canCancel: json['canCancel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromDate': fromDate,
      'toDate': toDate,
      'leaveType': leaveType.toJson(),
      'isHalfDay': isHalfDay,
      'halfDayType': halfDayType,
      'totalDays': totalDays,
      'status': status,
      'createdAt': createdAt,
      'userNotes': userNotes,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'isAbroad': isAbroad,
      'abroadLocation': abroadLocation,
      'document': document,
      'documentUrl': documentUrl,
      'usesCompOff': usesCompOff,
      'compOffDaysUsed': compOffDaysUsed,
      'compOffIds': compOffIds,
      'compOffDetails': compOffDetails?.map((e) => e.toJson()).toList(),
      'approvalNotes': approvalNotes,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt,
      'rejectedBy': rejectedBy?.toJson(),
      'rejectedAt': rejectedAt,
      'cancelReason': cancelReason,
      'cancelledBy': cancelledBy?.toJson(),
      'cancelledAt': cancelledAt,
      'updatedAt': updatedAt,
      'canCancel': canCancel,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
