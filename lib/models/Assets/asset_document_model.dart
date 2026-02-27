import 'package:hive/hive.dart';
import 'package:open_core_hr/utils/date_parser.dart';
import 'package:open_core_hr/utils/url_helper.dart';

part 'asset_document_model.g.dart';

/// Asset Document Type Enum
enum AssetDocumentType {
  invoice,
  warranty,
  manual,
  photo,
  insurance,
  receipt,
  other;

  /// Get document type label for display
  String get label {
    switch (this) {
      case AssetDocumentType.invoice:
        return 'Invoice';
      case AssetDocumentType.warranty:
        return 'Warranty';
      case AssetDocumentType.manual:
        return 'Manual';
      case AssetDocumentType.photo:
        return 'Photo';
      case AssetDocumentType.insurance:
        return 'Insurance';
      case AssetDocumentType.receipt:
        return 'Receipt';
      case AssetDocumentType.other:
        return 'Other';
    }
  }

  /// Get document type from string value (API response)
  static AssetDocumentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'invoice':
        return AssetDocumentType.invoice;
      case 'warranty':
        return AssetDocumentType.warranty;
      case 'manual':
        return AssetDocumentType.manual;
      case 'photo':
        return AssetDocumentType.photo;
      case 'insurance':
        return AssetDocumentType.insurance;
      case 'receipt':
        return AssetDocumentType.receipt;
      case 'other':
        return AssetDocumentType.other;
      default:
        return AssetDocumentType.other;
    }
  }

  /// Convert to API value
  String toApiValue() => name;
}

@HiveType(typeId: 66)
class AssetDocumentModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String uuid;

  @HiveField(2)
  final int assetId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String documentType;

  @HiveField(6)
  final String documentTypeLabel;

  @HiveField(7)
  final String fileName;

  @HiveField(8)
  final String filePath;

  @HiveField(9)
  final String? fileUrl;

  @HiveField(10)
  final String fileSize;

  @HiveField(11)
  final String? fileSizeFormatted;

  @HiveField(12)
  final String? mimeType;

  @HiveField(13)
  final String? fileExtension;

  @HiveField(14)
  final String? documentDate;

  @HiveField(15)
  final String? expiryDate;

  @HiveField(16)
  final bool hasExpiry;

  @HiveField(17)
  final DocumentExpiryInfo? expiryInfo;

  @HiveField(18)
  final String? referenceNumber;

  @HiveField(19)
  final String? issuedBy;

  @HiveField(20)
  final String? notes;

  @HiveField(21)
  final UploadedByInfo? uploadedBy;

  @HiveField(22)
  final bool canDownload;

  @HiveField(23)
  final bool canDelete;

  @HiveField(24)
  final String createdAt;

  @HiveField(25)
  final String updatedAt;

  AssetDocumentModel({
    required this.id,
    required this.uuid,
    required this.assetId,
    required this.title,
    this.description,
    required this.documentType,
    required this.documentTypeLabel,
    required this.fileName,
    required this.filePath,
    this.fileUrl,
    required this.fileSize,
    this.fileSizeFormatted,
    this.mimeType,
    this.fileExtension,
    this.documentDate,
    this.expiryDate,
    required this.hasExpiry,
    this.expiryInfo,
    this.referenceNumber,
    this.issuedBy,
    this.notes,
    this.uploadedBy,
    required this.canDownload,
    required this.canDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetDocumentModel.fromJson(Map<String, dynamic> json) {
    return AssetDocumentModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      assetId: json['assetId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      documentType: json['documentType'] as String,
      documentTypeLabel: json['documentTypeLabel'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'].toString(),
      fileSizeFormatted: json['fileSizeFormatted'] as String?,
      mimeType: json['mimeType'] as String?,
      fileExtension: json['fileExtension'] as String?,
      documentDate: json['documentDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
      hasExpiry: json['hasExpiry'] as bool? ?? false,
      expiryInfo: json['expiryInfo'] != null
          ? DocumentExpiryInfo.fromJson(json['expiryInfo'] as Map<String, dynamic>)
          : null,
      referenceNumber: json['referenceNumber'] as String?,
      issuedBy: json['issuedBy'] as String?,
      notes: json['notes'] as String?,
      uploadedBy: json['uploadedBy'] != null
          ? UploadedByInfo.fromJson(json['uploadedBy'] as Map<String, dynamic>)
          : null,
      canDownload: json['canDownload'] as bool? ?? true,
      canDelete: json['canDelete'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'assetId': assetId,
      'title': title,
      'description': description,
      'documentType': documentType,
      'documentTypeLabel': documentTypeLabel,
      'fileName': fileName,
      'filePath': filePath,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileSizeFormatted': fileSizeFormatted,
      'mimeType': mimeType,
      'fileExtension': fileExtension,
      'documentDate': documentDate,
      'expiryDate': expiryDate,
      'hasExpiry': hasExpiry,
      'expiryInfo': expiryInfo?.toJson(),
      'referenceNumber': referenceNumber,
      'issuedBy': issuedBy,
      'notes': notes,
      'uploadedBy': uploadedBy?.toJson(),
      'canDownload': canDownload,
      'canDelete': canDelete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get AssetDocumentType enum from documentType string
  AssetDocumentType get documentTypeEnum =>
      AssetDocumentType.fromString(documentType);

  /// Get full URL for file download
  String get fullFileUrl {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      return UrlHelper.getFullUrl(fileUrl!);
    }
    return UrlHelper.getFullUrl(filePath);
  }

  /// Check if document is expired
  bool get isExpired {
    if (expiryInfo != null) {
      return expiryInfo!.isExpired;
    }
    if (expiryDate == null) return false;
    try {
      final expiry = DateParser.parseDate(expiryDate!);
      return expiry.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Check if document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (expiryInfo != null) {
      return expiryInfo!.isExpiringSoon;
    }
    if (expiryDate == null) return false;
    try {
      final expiry = DateParser.parseDate(expiryDate!);
      final now = DateTime.now();
      final daysUntilExpiry = expiry.difference(now).inDays;
      return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
    } catch (e) {
      return false;
    }
  }

  /// Get days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    try {
      final expiry = DateParser.parseDate(expiryDate!);
      return expiry.difference(DateTime.now()).inDays;
    } catch (e) {
      return null;
    }
  }

  /// Check if file is an image
  bool get isImage {
    if (mimeType != null) {
      return mimeType!.startsWith('image/');
    }
    if (fileExtension != null) {
      final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
      return imageExtensions.contains(fileExtension!.toLowerCase());
    }
    return false;
  }

  /// Check if file is a PDF
  bool get isPdf {
    if (mimeType != null) {
      return mimeType == 'application/pdf';
    }
    return fileExtension?.toLowerCase() == 'pdf';
  }
}

@HiveType(typeId: 67)
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
      daysUntilExpiry: json['daysUntilExpiry'] as int?,
      status: json['status'] as String,
      statusColor: json['statusColor'] as String,
      isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daysUntilExpiry': daysUntilExpiry,
      'status': status,
      'statusColor': statusColor,
      'isExpiringSoon': isExpiringSoon,
      'isExpired': isExpired,
    };
  }
}

@HiveType(typeId: 68)
class UploadedByInfo extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? employeeCode;

  UploadedByInfo({
    required this.id,
    required this.name,
    this.employeeCode,
  });

  factory UploadedByInfo.fromJson(Map<String, dynamic> json) {
    return UploadedByInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      employeeCode: json['employeeCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employeeCode': employeeCode,
    };
  }
}

/// Asset Document List Response Wrapper
class AssetDocumentListResponse {
  final int totalCount;
  final List<AssetDocumentModel> values;

  AssetDocumentListResponse({
    required this.totalCount,
    required this.values,
  });

  factory AssetDocumentListResponse.fromJson(Map<String, dynamic> json) {
    return AssetDocumentListResponse(
      totalCount: json['totalCount'] as int,
      values: (json['values'] as List)
          .map((item) => AssetDocumentModel.fromJson(item as Map<String, dynamic>))
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
