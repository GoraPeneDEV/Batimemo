class AttendanceHistory {
  final int id;
  final String date;
  final String dayName;
  final String? checkInTime;
  final String? checkOutTime;

  // Multiple Check-In Support
  final bool isMultipleCheckIn;
  final List<CheckInOutPair> checkInOutPairs;
  final int totalCheckIns;
  final int totalCheckOuts;

  // Hours Calculation
  final double totalHours;
  final String workingHours;
  final double workingHoursDecimal;
  final double breakHours;
  final String breakHoursFormatted;

  // Overtime & Late Tracking
  final double overtime;
  final double lateHours;
  final int lateMinutes;
  final int earlyCheckoutMinutes;

  // Shift Information
  final Shift? shift;

  // Status & Reasons
  final String status;
  final String statusLabel;
  final String? lateReason;
  final String? earlyCheckoutReason;
  final bool isHoliday;
  final bool isWeekend;
  final bool isHalfDay;

  // Break Details
  final List<BreakInfo> breaks;

  // Activity Counters
  final int visitsCount;
  final int ordersCount;
  final int formsCount;

  // Regularization Status
  final bool hasRegularization;
  final String? regularizationStatus;

  // Location Data
  final Location? checkInLocation;
  final Location? checkOutLocation;
  final double distanceTravelled;

  AttendanceHistory({
    required this.id,
    required this.date,
    required this.dayName,
    this.checkInTime,
    this.checkOutTime,
    required this.isMultipleCheckIn,
    required this.checkInOutPairs,
    required this.totalCheckIns,
    required this.totalCheckOuts,
    required this.totalHours,
    required this.workingHours,
    required this.workingHoursDecimal,
    required this.breakHours,
    required this.breakHoursFormatted,
    required this.overtime,
    required this.lateHours,
    required this.lateMinutes,
    required this.earlyCheckoutMinutes,
    this.shift,
    required this.status,
    required this.statusLabel,
    this.lateReason,
    this.earlyCheckoutReason,
    required this.isHoliday,
    required this.isWeekend,
    required this.isHalfDay,
    required this.breaks,
    required this.visitsCount,
    required this.ordersCount,
    required this.formsCount,
    required this.hasRegularization,
    this.regularizationStatus,
    this.checkInLocation,
    this.checkOutLocation,
    required this.distanceTravelled,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      dayName: json['dayName'] ?? '',
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      isMultipleCheckIn: json['isMultipleCheckIn'] ?? false,
      checkInOutPairs: (json['checkInOutPairs'] as List?)
              ?.map((e) => CheckInOutPair.fromJson(e))
              .toList() ??
          [],
      totalCheckIns: json['totalCheckIns'] ?? 0,
      totalCheckOuts: json['totalCheckOuts'] ?? 0,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      workingHours: json['workingHours'] ?? '0h 0m',
      workingHoursDecimal:
          (json['workingHoursDecimal'] as num?)?.toDouble() ?? 0.0,
      breakHours: (json['breakHours'] as num?)?.toDouble() ?? 0.0,
      breakHoursFormatted: json['breakHoursFormatted'] ?? '0h 0m',
      overtime: _parseNumeric(json['overtime']),
      lateHours: _parseNumeric(json['lateHours']),
      lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
      earlyCheckoutMinutes: (json['earlyCheckoutMinutes'] as num?)?.toInt() ?? 0,
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? '',
      lateReason: json['lateReason'],
      earlyCheckoutReason: json['earlyCheckoutReason'],
      isHoliday: json['isHoliday'] ?? false,
      isWeekend: json['isWeekend'] ?? false,
      isHalfDay: json['isHalfDay'] ?? false,
      breaks: (json['breaks'] as List?)
              ?.map((e) => BreakInfo.fromJson(e))
              .toList() ??
          [],
      visitsCount: json['visitsCount'] ?? 0,
      ordersCount: json['ordersCount'] ?? 0,
      formsCount: json['formsCount'] ?? 0,
      hasRegularization: json['hasRegularization'] ?? false,
      regularizationStatus: json['regularizationStatus'],
      checkInLocation: json['checkInLocation'] != null
          ? Location.fromJson(json['checkInLocation'])
          : null,
      checkOutLocation: json['checkOutLocation'] != null
          ? Location.fromJson(json['checkOutLocation'])
          : null,
      distanceTravelled: (json['distanceTravelled'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'dayName': dayName,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'isMultipleCheckIn': isMultipleCheckIn,
      'checkInOutPairs': checkInOutPairs.map((e) => e.toJson()).toList(),
      'totalCheckIns': totalCheckIns,
      'totalCheckOuts': totalCheckOuts,
      'totalHours': totalHours,
      'workingHours': workingHours,
      'workingHoursDecimal': workingHoursDecimal,
      'breakHours': breakHours,
      'breakHoursFormatted': breakHoursFormatted,
      'overtime': overtime,
      'lateHours': lateHours,
      'lateMinutes': lateMinutes,
      'earlyCheckoutMinutes': earlyCheckoutMinutes,
      'shift': shift?.toJson(),
      'status': status,
      'statusLabel': statusLabel,
      'lateReason': lateReason,
      'earlyCheckoutReason': earlyCheckoutReason,
      'isHoliday': isHoliday,
      'isWeekend': isWeekend,
      'isHalfDay': isHalfDay,
      'breaks': breaks.map((e) => e.toJson()).toList(),
      'visitsCount': visitsCount,
      'ordersCount': ordersCount,
      'formsCount': formsCount,
      'hasRegularization': hasRegularization,
      'regularizationStatus': regularizationStatus,
      'checkInLocation': checkInLocation?.toJson(),
      'checkOutLocation': checkOutLocation?.toJson(),
      'distanceTravelled': distanceTravelled,
    };
  }

  /// Helper method to parse numeric values that might come as strings
  static double _parseNumeric(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class CheckInOutPair {
  final String? checkIn;
  final String? checkOut;
  final Location? checkInLocation;
  final Location? checkOutLocation;

  CheckInOutPair({
    this.checkIn,
    this.checkOut,
    this.checkInLocation,
    this.checkOutLocation,
  });

  factory CheckInOutPair.fromJson(Map<String, dynamic> json) {
    return CheckInOutPair(
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      checkInLocation: json['checkInLocation'] != null
          ? Location.fromJson(json['checkInLocation'])
          : null,
      checkOutLocation: json['checkOutLocation'] != null
          ? Location.fromJson(json['checkOutLocation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'checkInLocation': checkInLocation?.toJson(),
      'checkOutLocation': checkOutLocation?.toJson(),
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class BreakInfo {
  final int id;
  final String type;
  final String startTime;
  final String? endTime;
  final double duration; // Duration in minutes (can be decimal)
  final String status;

  BreakInfo({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.status,
  });

  factory BreakInfo.fromJson(Map<String, dynamic> json) {
    return BreakInfo(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'],
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'status': status,
    };
  }
}

class Shift {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int workingHours;

  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.workingHours,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      workingHours: json['workingHours'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'workingHours': workingHours,
    };
  }
}

class AttendanceHistoryResponse {
  final int totalCount;
  final bool isMultipleCheckInEnabled;
  final List<AttendanceHistory> values;

  AttendanceHistoryResponse({
    required this.totalCount,
    required this.isMultipleCheckInEnabled,
    required this.values,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponse(
      totalCount: json['totalCount'] ?? 0,
      isMultipleCheckInEnabled: json['isMultipleCheckInEnabled'] ?? false,
      values: (json['values'] as List?)
              ?.map((e) => AttendanceHistory.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'isMultipleCheckInEnabled': isMultipleCheckInEnabled,
      'values': values.map((e) => e.toJson()).toList(),
    };
  }
}
