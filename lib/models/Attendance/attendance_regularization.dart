import 'regularization_attachment.dart';
import 'attendance_log.dart';

/// Main attendance regularization model
class AttendanceRegularization {
  final int id;
  final String date;
  final String type;
  final String typeLabel;
  final String status;
  final String statusLabel;
  final String? requestedCheckInTime;
  final String? requestedCheckOutTime;
  final String? actualCheckInTime;
  final String? actualCheckOutTime;
  final String reason;
  final String? managerComments;
  final String? approvedBy;
  final String? approvedAt;
  final List<RegularizationAttachment> attachments;
  final List<AttendanceLog>? attendanceLogs;
  final String createdAt;
  final String? updatedAt;

  AttendanceRegularization({
    required this.id,
    required this.date,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    this.requestedCheckInTime,
    this.requestedCheckOutTime,
    this.actualCheckInTime,
    this.actualCheckOutTime,
    required this.reason,
    this.managerComments,
    this.approvedBy,
    this.approvedAt,
    required this.attachments,
    this.attendanceLogs,
    required this.createdAt,
    this.updatedAt,
  });

  factory AttendanceRegularization.fromJson(Map<String, dynamic> json) {
    return AttendanceRegularization(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      typeLabel: json['typeLabel'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? '',
      requestedCheckInTime: json['requestedCheckInTime'],
      requestedCheckOutTime: json['requestedCheckOutTime'],
      actualCheckInTime: json['actualCheckInTime'],
      actualCheckOutTime: json['actualCheckOutTime'],
      reason: json['reason'] ?? '',
      managerComments: json['managerComments'],
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'],
      attachments: (json['attachments'] as List? ?? [])
          .map((item) => RegularizationAttachment.fromJson(item))
          .toList(),
      attendanceLogs: json['attendanceLogs'] != null
          ? (json['attendanceLogs'] as List)
              .map((item) => AttendanceLog.fromJson(item))
              .toList()
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'typeLabel': typeLabel,
      'status': status,
      'statusLabel': statusLabel,
      'requestedCheckInTime': requestedCheckInTime,
      'requestedCheckOutTime': requestedCheckOutTime,
      'actualCheckInTime': actualCheckInTime,
      'actualCheckOutTime': actualCheckOutTime,
      'reason': reason,
      'managerComments': managerComments,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'attendanceLogs': attendanceLogs?.map((l) => l.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Status getters
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Check if request can be edited (only pending requests)
  bool get canEdit => isPending;

  /// Check if request can be deleted (only pending requests)
  bool get canDelete => isPending;

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'approved':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get type icon
  String get typeIcon {
    switch (type) {
      case 'missing_checkin':
        return '⏰';
      case 'missing_checkout':
        return '⏱️';
      case 'wrong_time':
        return '🕐';
      case 'forgot_punch':
        return '⏲️';
      case 'other':
        return '📝';
      default:
        return '📋';
    }
  }
}
