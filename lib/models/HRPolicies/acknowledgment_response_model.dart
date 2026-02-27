class AcknowledgmentResponseModel {
  final String message;
  final String acknowledgedDate;

  AcknowledgmentResponseModel({
    required this.message,
    required this.acknowledgedDate,
  });

  factory AcknowledgmentResponseModel.fromJson(Map<String, dynamic> json) {
    return AcknowledgmentResponseModel(
      message: json['message'] as String,
      acknowledgedDate: json['acknowledged_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'acknowledged_date': acknowledgedDate,
    };
  }
}
