/// Attendance log model for regularization requests
class AttendanceLog {
  final String type; // 'check_in' or 'check_out'
  final String time;
  final String? latitude;
  final String? longitude;

  AttendanceLog({
    required this.type,
    required this.time,
    this.latitude,
    this.longitude,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      type: json['type'] ?? '',
      time: json['time'] ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isCheckIn => type == 'check_in';
  bool get isCheckOut => type == 'check_out';
}
