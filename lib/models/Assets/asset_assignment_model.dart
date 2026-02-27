import 'package:hive/hive.dart';
import 'package:open_core_hr/utils/date_parser.dart';

part 'asset_assignment_model.g.dart';

@HiveType(typeId: 63)
class AssetAssignmentModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int assetId;

  @HiveField(2)
  final String assetName;

  @HiveField(3)
  final String assetTag;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? manufacturer;

  @HiveField(6)
  final String? model;

  @HiveField(7)
  final String? serialNumber;

  @HiveField(8)
  final String? image;

  @HiveField(9)
  final String assignedAt;

  @HiveField(10)
  final String? returnedAt;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final String? assignmentNotes;

  @HiveField(13)
  final String? returnNotes;

  @HiveField(14)
  final String? conditionAtAssignment;

  @HiveField(15)
  final String? conditionAtReturn;

  @HiveField(16)
  final AssignedByInfo? assignedBy;

  @HiveField(17)
  final ReturnedToInfo? returnedTo;

  @HiveField(18)
  final String createdAt;

  @HiveField(19)
  final String updatedAt;

  AssetAssignmentModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetTag,
    required this.category,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.image,
    required this.assignedAt,
    this.returnedAt,
    required this.isActive,
    this.assignmentNotes,
    this.returnNotes,
    this.conditionAtAssignment,
    this.conditionAtReturn,
    this.assignedBy,
    this.returnedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetAssignmentModel.fromJson(Map<String, dynamic> json) {
    // Handle category as string or object
    String categoryName = '';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        categoryName = json['category']['name'] ?? '';
      } else if (json['category'] is String) {
        categoryName = json['category'];
      }
    }

    return AssetAssignmentModel(
      id: json['id'] as int,
      assetId: json['assetId'] as int,
      assetName: json['assetName'] as String,
      assetTag: json['assetTag'] as String,
      category: categoryName,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      image: json['image'] as String?,
      assignedAt: json['assignedAt'] as String,
      returnedAt: json['returnedAt'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      assignmentNotes: json['assignmentNotes'] as String?,
      returnNotes: json['returnNotes'] as String?,
      conditionAtAssignment: json['conditionAtAssignment'] as String?,
      conditionAtReturn: json['conditionAtReturn'] as String?,
      assignedBy: json['assignedBy'] != null
          ? AssignedByInfo.fromJson(json['assignedBy'] as Map<String, dynamic>)
          : null,
      returnedTo: json['returnedTo'] != null
          ? ReturnedToInfo.fromJson(json['returnedTo'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'assetTag': assetTag,
      'category': category,
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'image': image,
      'assignedAt': assignedAt,
      'returnedAt': returnedAt,
      'isActive': isActive,
      'assignmentNotes': assignmentNotes,
      'returnNotes': returnNotes,
      'conditionAtAssignment': conditionAtAssignment,
      'conditionAtReturn': conditionAtReturn,
      'assignedBy': assignedBy?.toJson(),
      'returnedTo': returnedTo?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get assignment duration in days
  int get durationInDays {
    try {
      final assignedDate = DateParser.parseDate(assignedAt);
      final endDate = returnedAt != null
          ? DateParser.parseDate(returnedAt!)
          : DateTime.now();
      return endDate.difference(assignedDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get formatted assignment duration
  String get formattedDuration {
    final days = durationInDays;
    if (days < 30) {
      return '$days days';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (days / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  /// Check if assignment is currently active
  bool get isCurrentlyAssigned => isActive && returnedAt == null;
}

@HiveType(typeId: 64)
class AssignedByInfo extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? designation;

  AssignedByInfo({
    required this.id,
    required this.name,
    this.designation,
  });

  factory AssignedByInfo.fromJson(Map<String, dynamic> json) {
    return AssignedByInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      designation: json['designation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
    };
  }
}

@HiveType(typeId: 65)
class ReturnedToInfo extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? designation;

  ReturnedToInfo({
    required this.id,
    required this.name,
    this.designation,
  });

  factory ReturnedToInfo.fromJson(Map<String, dynamic> json) {
    return ReturnedToInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      designation: json['designation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
    };
  }
}

/// Assignment History Response Wrapper
class AssignmentHistoryResponse {
  final int totalCount;
  final List<AssetAssignmentModel> values;

  AssignmentHistoryResponse({
    required this.totalCount,
    required this.values,
  });

  factory AssignmentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentHistoryResponse(
      totalCount: json['totalCount'] as int,
      values: (json['values'] as List)
          .map((item) => AssetAssignmentModel.fromJson(item as Map<String, dynamic>))
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
