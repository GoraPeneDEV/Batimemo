import 'package:hive/hive.dart';

part 'my_document_model.g.dart';

@HiveType(typeId: 52)
class MyDocumentModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? number;

  @HiveField(4)
  final String? issueDate;

  @HiveField(5)
  final String? expiryDate;

  @HiveField(6)
  final String? issuingAuthority;

  @HiveField(7)
  final String? issuingCountry;

  @HiveField(8)
  final String? issuingPlace;

  @HiveField(9)
  final String verificationStatus;

  @HiveField(10)
  final String? verificationNotes;

  @HiveField(11)
  final String? verifiedBy;

  @HiveField(12)
  final String? verifiedDate;

  @HiveField(13)
  final DocumentExpiryInfo? expiryInfo;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final String? fileSize;

  @HiveField(16)
  final bool canDownload;

  MyDocumentModel({
    required this.id,
    required this.category,
    required this.title,
    this.number,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.issuingCountry,
    this.issuingPlace,
    required this.verificationStatus,
    this.verificationNotes,
    this.verifiedBy,
    this.verifiedDate,
    this.expiryInfo,
    this.notes,
    this.fileSize,
    required this.canDownload,
  });

  factory MyDocumentModel.fromJson(Map<String, dynamic> json) {
    // Handle nested category object
    String categoryName = '';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        categoryName = json['category']['name'] ?? '';
      } else if (json['category'] is String) {
        categoryName = json['category'];
      }
    }

    // Handle verification object
    String verificationStatus = 'pending';
    String? verificationNotes;
    String? verifiedBy;
    String? verifiedDate;

    if (json['verification'] != null && json['verification'] is Map) {
      verificationStatus = json['verification']['status'] ?? 'pending';
      verificationNotes = json['verification']['notes'];

      // Handle verifiedBy which can be an object or string
      if (json['verification']['verifiedBy'] != null) {
        if (json['verification']['verifiedBy'] is Map) {
          verifiedBy = json['verification']['verifiedBy']['name'];
        } else {
          verifiedBy = json['verification']['verifiedBy'].toString();
        }
      }
      verifiedDate = json['verification']['verifiedAt'];
    }

    // Handle file object
    String? fileSize;
    bool canDownload = false;
    if (json['file'] != null && json['file'] is Map) {
      fileSize = json['file']['sizeFormatted'];
      canDownload = json['file']['url'] != null;
    }

    return MyDocumentModel(
      id: json['id'] ?? 0,
      category: categoryName,
      title: json['document_title'] ?? json['documentTitle'] ?? json['title'] ?? '',
      number: json['document_number'] ?? json['documentNumber'] ?? json['number'],
      issueDate: json['issue_date'] ?? json['issueDate'],
      expiryDate: json['expiry_date'] ?? json['expiryDate'],
      issuingAuthority: json['issuing_authority'] ?? json['issuingAuthority'],
      issuingCountry: json['issuing_country'] ?? json['issuingCountry'],
      issuingPlace: json['issuing_place'] ?? json['issuingPlace'],
      verificationStatus: verificationStatus,
      verificationNotes: verificationNotes,
      verifiedBy: verifiedBy,
      verifiedDate: verifiedDate,
      expiryInfo: json['expiryInfo'] != null || json['expiry_info'] != null
          ? DocumentExpiryInfo.fromJson(json['expiryInfo'] ?? json['expiry_info'])
          : null,
      notes: json['notes'],
      fileSize: fileSize ?? json['file_size'],
      canDownload: canDownload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'number': number,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'issuing_authority': issuingAuthority,
      'issuing_country': issuingCountry,
      'issuing_place': issuingPlace,
      'verification_status': verificationStatus,
      'notes': notes,
      'file_size': fileSize,
      'can_download': canDownload,
    };
  }
}

@HiveType(typeId: 53)
class DocumentExpiryInfo extends HiveObject {
  @HiveField(0)
  final int? daysUntilExpiry;

  @HiveField(1)
  final String status;

  @HiveField(2)
  final String statusColor;

  @HiveField(3)
  final bool isExpiringSoon;

  @HiveField(4)
  final bool isExpired;

  DocumentExpiryInfo({
    this.daysUntilExpiry,
    required this.status,
    required this.statusColor,
    required this.isExpiringSoon,
    required this.isExpired,
  });

  factory DocumentExpiryInfo.fromJson(Map<String, dynamic> json) {
    return DocumentExpiryInfo(
      daysUntilExpiry: json['daysUntilExpiry'] ?? json['days_until_expiry'],
      status: json['status'] ?? 'valid',
      statusColor: json['statusColor'] ?? json['status_color'] ?? 'success',
      isExpiringSoon: json['isExpiringSoon'] ?? json['is_expiring_soon'] ?? false,
      isExpired: json['isExpired'] ?? json['is_expired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days_until_expiry': daysUntilExpiry,
      'status': status,
      'status_color': statusColor,
      'is_expiring_soon': isExpiringSoon,
      'is_expired': isExpired,
    };
  }
}

@HiveType(typeId: 54)
class MyDocumentStatistics extends HiveObject {
  @HiveField(0)
  final int total;

  @HiveField(1)
  final int pending;

  @HiveField(2)
  final int verified;

  @HiveField(3)
  final int rejected;

  @HiveField(4)
  final int expired;

  @HiveField(5)
  final int expiringSoon;

  @HiveField(6)
  final int valid;

  @HiveField(7)
  final int noExpiry;

  MyDocumentStatistics({
    required this.total,
    required this.pending,
    required this.verified,
    required this.rejected,
    required this.expired,
    required this.expiringSoon,
    required this.valid,
    required this.noExpiry,
  });

  factory MyDocumentStatistics.fromJson(Map<String, dynamic> json) {
    final byVerification = json['by_verification_status'] ?? {};
    final byExpiry = json['by_expiry_status'] ?? {};

    return MyDocumentStatistics(
      total: json['total'] ?? 0,
      pending: byVerification['pending'] ?? 0,
      verified: byVerification['verified'] ?? 0,
      rejected: byVerification['rejected'] ?? 0,
      expired: byExpiry['expired'] ?? 0,
      expiringSoon: byExpiry['expiring_soon'] ?? 0,
      valid: byExpiry['valid'] ?? 0,
      noExpiry: byExpiry['no_expiry'] ?? 0,
    );
  }
}
