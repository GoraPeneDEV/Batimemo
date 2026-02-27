import 'warning_type_model.dart';
import '../leave/simple_user.dart';

class Warning {
  final int id;
  final String warningNumber;
  final WarningType warningType;
  final String issueDate;
  final String effectiveDate;
  final String? expiryDate;
  final String subject;
  final String reason;
  final String? description;
  final String? improvementRequired;
  final String? consequences;
  final String status; // 'issued', 'acknowledged', 'appealed', 'expired'
  final String statusLabel;
  final SimpleUser issuedBy;
  final String? acknowledgedAt;
  final bool isAppealable;
  final String? appealDeadline;
  final bool canBeAcknowledged;
  final bool canBeAppealed;
  final bool hasActiveAppeal;
  final List<String> attachments;
  final String createdAt;

  Warning({
    required this.id,
    required this.warningNumber,
    required this.warningType,
    required this.issueDate,
    required this.effectiveDate,
    this.expiryDate,
    required this.subject,
    required this.reason,
    this.description,
    this.improvementRequired,
    this.consequences,
    required this.status,
    required this.statusLabel,
    required this.issuedBy,
    this.acknowledgedAt,
    required this.isAppealable,
    this.appealDeadline,
    required this.canBeAcknowledged,
    required this.canBeAppealed,
    required this.hasActiveAppeal,
    required this.attachments,
    required this.createdAt,
  });

  factory Warning.fromJson(Map<String, dynamic> json) {
    return Warning(
      id: json['id'],
      warningNumber: json['warningNumber'] ?? '',
      warningType: WarningType.fromJson(json['warningType']),
      issueDate: json['issueDate'] ?? '',
      effectiveDate: json['effectiveDate'] ?? '',
      expiryDate: json['expiryDate'],
      subject: json['subject'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'],
      improvementRequired: json['improvementRequired'],
      consequences: json['consequences'],
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? json['status'] ?? '',
      issuedBy: SimpleUser.fromJson(json['issuedBy']),
      acknowledgedAt: json['acknowledgedAt'],
      isAppealable: json['isAppealable'] ?? false,
      appealDeadline: json['appealDeadline'],
      canBeAcknowledged: json['canBeAcknowledged'] ?? false,
      canBeAppealed: json['canBeAppealed'] ?? false,
      hasActiveAppeal: json['hasActiveAppeal'] ?? false,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warningNumber': warningNumber,
      'warningType': warningType.toJson(),
      'issueDate': issueDate,
      'effectiveDate': effectiveDate,
      'expiryDate': expiryDate,
      'subject': subject,
      'reason': reason,
      'description': description,
      'improvementRequired': improvementRequired,
      'consequences': consequences,
      'status': status,
      'statusLabel': statusLabel,
      'issuedBy': issuedBy.toJson(),
      'acknowledgedAt': acknowledgedAt,
      'isAppealable': isAppealable,
      'appealDeadline': appealDeadline,
      'canBeAcknowledged': canBeAcknowledged,
      'canBeAppealed': canBeAppealed,
      'hasActiveAppeal': hasActiveAppeal,
      'attachments': attachments,
      'createdAt': createdAt,
    };
  }

  bool get isIssued => status == 'issued';
  bool get isAcknowledged => status == 'acknowledged';
  bool get isAppealed => status == 'appealed';
  bool get isExpired => status == 'expired';
}
