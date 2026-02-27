import '../leave/simple_user.dart';

class SupportingDocument {
  final String path;
  final String originalName;
  final int size;
  final String mimeType;

  SupportingDocument({
    required this.path,
    required this.originalName,
    required this.size,
    required this.mimeType,
  });

  factory SupportingDocument.fromJson(Map<String, dynamic> json) {
    return SupportingDocument(
      path: json['path'] ?? '',
      originalName: json['original_name'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mime_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'original_name': originalName,
      'size': size,
      'mime_type': mimeType,
    };
  }
}

class WarningAppeal {
  final int id;
  final String appealNumber;
  final WarningInfo? warning;
  final String appealDate;
  final String appealReason;
  final String? employeeStatement;
  final List<SupportingDocument> supportingDocuments;
  final String status; // 'pending', 'under_review', 'hearing_scheduled', 'approved', 'rejected', 'withdrawn'
  final String statusLabel;
  final String? outcome; // 'warning_revoked', 'warning_reduced', 'warning_upheld'
  final String? outcomeLabel;
  final String? reviewedAt;
  final SimpleUser? reviewedBy;
  final String? reviewComments;
  final String? decision;
  final bool hasHearingScheduled;
  final String? hearingDate;
  final String? hearingTime;
  final String? hearingLocation;
  final List<String>? hearingAttendees;
  final String createdAt;

  WarningAppeal({
    required this.id,
    required this.appealNumber,
    required this.warning,
    required this.appealDate,
    required this.appealReason,
    this.employeeStatement,
    required this.supportingDocuments,
    required this.status,
    required this.statusLabel,
    this.outcome,
    this.outcomeLabel,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewComments,
    this.decision,
    required this.hasHearingScheduled,
    this.hearingDate,
    this.hearingTime,
    this.hearingLocation,
    this.hearingAttendees,
    required this.createdAt,
  });

  factory WarningAppeal.fromJson(Map<String, dynamic> json) {
    return WarningAppeal(
      id: json['id'],
      appealNumber: json['appealNumber'] ?? '',
      warning: json['warning'] != null ? WarningInfo.fromJson(json['warning']) : null,
      appealDate: json['appealDate'] ?? '',
      appealReason: json['appealReason'] ?? '',
      employeeStatement: json['employeeStatement'],
      supportingDocuments: json['supportingDocuments'] != null
          ? (json['supportingDocuments'] as List)
              .map((doc) => doc is String
                  ? SupportingDocument(path: doc, originalName: doc, size: 0, mimeType: '')
                  : SupportingDocument.fromJson(doc))
              .toList()
          : [],
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? json['status'] ?? '',
      outcome: json['outcome'],
      outcomeLabel: json['outcomeLabel'],
      reviewedAt: json['reviewedAt'],
      reviewedBy: json['reviewedBy'] != null
          ? SimpleUser.fromJson(json['reviewedBy'])
          : null,
      reviewComments: json['reviewComments'],
      decision: json['decision'],
      hasHearingScheduled: json['hasHearingScheduled'] ?? false,
      hearingDate: json['hearingDate'],
      hearingTime: json['hearingTime'],
      hearingLocation: json['hearingLocation'],
      hearingAttendees: json['hearingAttendees'] != null
          ? List<String>.from(json['hearingAttendees'])
          : null,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appealNumber': appealNumber,
      'warning': warning?.toJson(),
      'appealDate': appealDate,
      'appealReason': appealReason,
      'employeeStatement': employeeStatement,
      'supportingDocuments': supportingDocuments.map((doc) => doc.toJson()).toList(),
      'status': status,
      'statusLabel': statusLabel,
      'outcome': outcome,
      'outcomeLabel': outcomeLabel,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy?.toJson(),
      'reviewComments': reviewComments,
      'decision': decision,
      'hasHearingScheduled': hasHearingScheduled,
      'hearingDate': hearingDate,
      'hearingTime': hearingTime,
      'hearingLocation': hearingLocation,
      'hearingAttendees': hearingAttendees,
      'createdAt': createdAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isUnderReview => status == 'under_review';
  bool get isHearingScheduled => status == 'hearing_scheduled';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isWithdrawn => status == 'withdrawn';
  bool get canWithdraw => isPending || isUnderReview;
}

class WarningInfo {
  final int id;
  final String warningNumber;
  final String subject;
  final String? warningTypeName;

  WarningInfo({
    required this.id,
    required this.warningNumber,
    required this.subject,
    this.warningTypeName,
  });

  factory WarningInfo.fromJson(Map<String, dynamic> json) {
    return WarningInfo(
      id: json['id'],
      warningNumber: json['warningNumber'] ?? '',
      subject: json['subject'] ?? '',
      warningTypeName: json['warningTypeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warningNumber': warningNumber,
      'subject': subject,
      'warningTypeName': warningTypeName,
    };
  }
}
