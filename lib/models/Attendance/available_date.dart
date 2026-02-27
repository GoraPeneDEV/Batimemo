/// Model for available dates for regularization
class AvailableDate {
  final String date;
  final bool hasAttendance;
  final bool hasCheckIn;
  final bool hasCheckOut;
  final bool hasRegularizationRequest;
  final String? regularizationStatus;

  AvailableDate({
    required this.date,
    required this.hasAttendance,
    required this.hasCheckIn,
    required this.hasCheckOut,
    required this.hasRegularizationRequest,
    this.regularizationStatus,
  });

  factory AvailableDate.fromJson(Map<String, dynamic> json) {
    return AvailableDate(
      date: json['date'] ?? '',
      hasAttendance: json['hasAttendance'] ?? false,
      hasCheckIn: json['hasCheckIn'] ?? false,
      hasCheckOut: json['hasCheckOut'] ?? false,
      hasRegularizationRequest: json['hasRegularizationRequest'] ?? false,
      regularizationStatus: json['regularizationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'hasAttendance': hasAttendance,
      'hasCheckIn': hasCheckIn,
      'hasCheckOut': hasCheckOut,
      'hasRegularizationRequest': hasRegularizationRequest,
      'regularizationStatus': regularizationStatus,
    };
  }

  /// Check if date can be regularized
  bool get canRegularize => !hasRegularizationRequest || regularizationStatus == 'rejected';

  /// Get status display text
  String get statusText {
    if (!hasAttendance) return 'No Attendance';
    if (!hasCheckIn) return 'Missing Check-in';
    if (!hasCheckOut) return 'Missing Check-out';
    return 'Complete';
  }
}

/// Container for available dates response
class AvailableDatesResponse {
  final String startDate;
  final String endDate;
  final List<AvailableDate> dates;

  AvailableDatesResponse({
    required this.startDate,
    required this.endDate,
    required this.dates,
  });

  factory AvailableDatesResponse.fromJson(Map<String, dynamic> json) {
    return AvailableDatesResponse(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      dates: (json['dates'] as List? ?? [])
          .map((item) => AvailableDate.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'dates': dates.map((date) => date.toJson()).toList(),
    };
  }
}
