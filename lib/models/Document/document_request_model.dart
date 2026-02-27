import 'package:hive/hive.dart';

part 'document_request_model.g.dart';

@HiveType(typeId: 50)
class DocumentRequestModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? documentType;

  @HiveField(2)
  String? status;

  @HiveField(3)
  String? statusLabel;

  @HiveField(4)
  String? remarks;

  @HiveField(5)
  String? adminRemarks;

  @HiveField(6)
  String? requestedDate;

  @HiveField(7)
  String? approvedDate;

  @HiveField(8)
  String? generatedDate;

  @HiveField(9)
  String? fileUrl;

  @HiveField(10)
  bool? canCancel;

  @HiveField(11)
  bool? canDownload;

  DocumentRequestModel({
    this.id,
    this.documentType,
    this.status,
    this.statusLabel,
    this.remarks,
    this.adminRemarks,
    this.requestedDate,
    this.approvedDate,
    this.generatedDate,
    this.fileUrl,
    this.canCancel,
    this.canDownload,
  });

  DocumentRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Handle nested document_type object
    if (json['document_type'] is Map) {
      documentType = json['document_type']['name'];
    } else {
      documentType = json['document_type'];
    }
    status = json['status'];
    statusLabel = json['status_label'];
    remarks = json['remarks'];
    adminRemarks = json['admin_remarks'];
    requestedDate = json['created_at'];
    approvedDate = json['action_taken_at'];
    generatedDate = json['action_taken_at'];
    fileUrl = json['generated_file_url'];
    // Determine canCancel based on status
    canCancel = json['status'] == 'pending';
    // Can download if status is generated and file exists
    canDownload = json['status'] == 'generated' && json['generated_file_url'] != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_type': documentType,
      'status': status,
      'status_label': statusLabel,
      'remarks': remarks,
      'admin_remarks': adminRemarks,
      'requested_date': requestedDate,
      'approved_date': approvedDate,
      'generated_date': generatedDate,
      'file_url': fileUrl,
      'can_cancel': canCancel,
      'can_download': canDownload,
    };
  }
}

@HiveType(typeId: 51)
class DocumentRequestStatistics extends HiveObject {
  @HiveField(0)
  int? total;

  @HiveField(1)
  int? pending;

  @HiveField(2)
  int? approved;

  @HiveField(3)
  int? generated;

  @HiveField(4)
  int? rejected;

  @HiveField(5)
  int? cancelled;

  DocumentRequestStatistics({
    this.total,
    this.pending,
    this.approved,
    this.generated,
    this.rejected,
    this.cancelled,
  });

  DocumentRequestStatistics.fromJson(Map<String, dynamic> json) {
    total = json['total'] ?? 0;
    pending = json['pending'] ?? 0;
    approved = json['approved'] ?? 0;
    generated = json['generated'] ?? 0;
    rejected = json['rejected'] ?? 0;
    cancelled = json['cancelled'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'generated': generated,
      'rejected': rejected,
      'cancelled': cancelled,
    };
  }
}

// Response class for old API compatibility
class DocumentRequestResponse {
  final int totalCount;
  final List<DocumentRequestModel> values;

  DocumentRequestResponse({
    required this.totalCount,
    required this.values,
  });

  factory DocumentRequestResponse.fromJson(Map<String, dynamic> json) =>
      DocumentRequestResponse(
        totalCount: json['totalCount'] ?? 0,
        values: (json['values'] as List? ?? [])
            .map((item) => DocumentRequestModel.fromJson(item))
            .toList(),
      );
}
