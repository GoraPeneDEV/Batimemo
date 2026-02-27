/// Simple CompOff detail model for use in LeaveRequest
/// This avoids circular dependency with CompensatoryOff model
class CompOffDetail {
  final int id;
  final num compOffDays;
  final String reason;
  final String? requestedDate;
  final String expiryDate;
  final String status;

  CompOffDetail({
    required this.id,
    required this.compOffDays,
    required this.reason,
    this.requestedDate,
    required this.expiryDate,
    required this.status,
  });

  factory CompOffDetail.fromJson(Map<String, dynamic> json) {
    return CompOffDetail(
      id: json['id'],
      compOffDays: _parseNum(json['compOffDays']),
      reason: json['reason'] ?? '',
      requestedDate: json['requestedDate'],
      expiryDate: json['expiryDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compOffDays': compOffDays,
      'reason': reason,
      'requestedDate': requestedDate,
      'expiryDate': expiryDate,
      'status': status,
    };
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
