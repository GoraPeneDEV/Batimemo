import 'package:hive/hive.dart';

part 'asset_maintenance_model.g.dart';

@HiveType(typeId: 35)
class AssetMaintenanceModel {
  @HiveField(0)
  int id;

  @HiveField(1)
  String maintenanceType;

  @HiveField(2)
  String? performedAt;

  @HiveField(3)
  String details;

  @HiveField(4)
  double? cost;

  @HiveField(5)
  String? provider;

  @HiveField(6)
  String? nextDueDate;

  @HiveField(7)
  CompletedByModel? completedBy;

  AssetMaintenanceModel({
    required this.id,
    required this.maintenanceType,
    this.performedAt,
    required this.details,
    this.cost,
    this.provider,
    this.nextDueDate,
    this.completedBy,
  });

  factory AssetMaintenanceModel.fromJson(Map<String, dynamic> json) {
    return AssetMaintenanceModel(
      id: json['id'],
      maintenanceType: json['maintenanceType'] ?? '',
      performedAt: json['performedAt'],
      details: json['details'] ?? '',
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) : null,
      provider: json['provider'],
      nextDueDate: json['nextDueDate'],
      completedBy: json['completedBy'] != null
          ? CompletedByModel.fromJson(json['completedBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenanceType': maintenanceType,
      'performedAt': performedAt,
      'details': details,
      'cost': cost,
      'provider': provider,
      'nextDueDate': nextDueDate,
      'completedBy': completedBy?.toJson(),
    };
  }

  String get maintenanceTypeLabel {
    switch (maintenanceType.toLowerCase()) {
      case 'repair':
        return 'Repair';
      case 'upgrade':
        return 'Upgrade';
      case 'cleaning':
        return 'Cleaning';
      case 'calibration':
        return 'Calibration';
      case 'scheduled_maintenance':
        return 'Scheduled Maintenance';
      case 'inspection':
        return 'Inspection';
      case 'other':
        return 'Other';
      default:
        return maintenanceType;
    }
  }
}

@HiveType(typeId: 36)
class CompletedByModel {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  CompletedByModel({
    required this.id,
    required this.name,
  });

  factory CompletedByModel.fromJson(Map<String, dynamic> json) {
    return CompletedByModel(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Response model for maintenance history list
class MaintenanceHistoryResponse {
  final int totalCount;
  final List<AssetMaintenanceModel> values;

  MaintenanceHistoryResponse({
    required this.totalCount,
    required this.values,
  });

  factory MaintenanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistoryResponse(
      totalCount: json['totalCount'] ?? 0,
      values: (json['values'] as List<dynamic>?)
              ?.map((item) => AssetMaintenanceModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'values': values.map((v) => v.toJson()).toList(),
    };
  }
}
