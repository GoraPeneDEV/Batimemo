import 'package:hive/hive.dart';
import 'package:open_core_hr/utils/date_parser.dart';
import 'asset_document_model.dart';

part 'asset_model.g.dart';

/// Asset Status Enum
enum AssetStatus {
  available,
  assigned,
  inRepair,
  damaged,
  lost,
  disposed,
  archived;

  /// Get status label for display
  String get label {
    switch (this) {
      case AssetStatus.available:
        return 'Available';
      case AssetStatus.assigned:
        return 'Assigned';
      case AssetStatus.inRepair:
        return 'In Repair';
      case AssetStatus.damaged:
        return 'Damaged';
      case AssetStatus.lost:
        return 'Lost';
      case AssetStatus.disposed:
        return 'Disposed';
      case AssetStatus.archived:
        return 'Archived';
    }
  }

  /// Get status from string value (API response)
  static AssetStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return AssetStatus.available;
      case 'assigned':
        return AssetStatus.assigned;
      case 'in_repair':
        return AssetStatus.inRepair;
      case 'damaged':
        return AssetStatus.damaged;
      case 'lost':
        return AssetStatus.lost;
      case 'disposed':
        return AssetStatus.disposed;
      case 'archived':
        return AssetStatus.archived;
      default:
        return AssetStatus.available;
    }
  }

  /// Convert to API value
  String toApiValue() {
    switch (this) {
      case AssetStatus.inRepair:
        return 'in_repair';
      default:
        return name;
    }
  }
}

/// Asset Condition Enum
enum AssetCondition {
  newCondition,
  good,
  fair,
  poor,
  broken;

  /// Get condition label for display
  String get label {
    switch (this) {
      case AssetCondition.newCondition:
        return 'New';
      case AssetCondition.good:
        return 'Good';
      case AssetCondition.fair:
        return 'Fair';
      case AssetCondition.poor:
        return 'Poor';
      case AssetCondition.broken:
        return 'Broken';
    }
  }

  /// Get condition from string value (API response)
  static AssetCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return AssetCondition.newCondition;
      case 'good':
        return AssetCondition.good;
      case 'fair':
        return AssetCondition.fair;
      case 'poor':
        return AssetCondition.poor;
      case 'broken':
        return AssetCondition.broken;
      default:
        return AssetCondition.good;
    }
  }

  /// Convert to API value
  String toApiValue() {
    switch (this) {
      case AssetCondition.newCondition:
        return 'new';
      default:
        return name;
    }
  }
}

@HiveType(typeId: 60)
class AssetModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String uuid;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String assetTag;

  @HiveField(4)
  final String? qrCode;

  @HiveField(5)
  final AssetCategoryInfo category;

  @HiveField(6)
  final String? barcode;

  @HiveField(7)
  final String? manufacturer;

  @HiveField(8)
  final String? model;

  @HiveField(9)
  final String? serialNumber;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final String statusLabel;

  @HiveField(12)
  final String condition;

  @HiveField(13)
  final String conditionLabel;

  @HiveField(14)
  final String? location;

  @HiveField(15)
  final AssetCategoryInfo? department;

  @HiveField(16)
  final AssignedToInfo? assignedTo;

  @HiveField(17)
  final String? assignedAt;

  @HiveField(18)
  final double? purchasePrice;

  @HiveField(29)
  final double? purchaseCost;

  @HiveField(30)
  final String? supplier;

  @HiveField(31)
  final String? insurancePolicyNumber;

  @HiveField(32)
  final String? insuranceExpiryDate;

  @HiveField(19)
  final double? currentValue;

  @HiveField(20)
  final String? purchaseDate;

  @HiveField(21)
  final String? warrantyExpiry;

  @HiveField(22)
  final bool isUnderWarranty;

  @HiveField(23)
  final String? image;

  @HiveField(24)
  final String? description;

  @HiveField(25)
  final String? notes;

  @HiveField(26)
  final String? specifications;

  @HiveField(27)
  final bool isActive;

  @HiveField(28)
  final String? createdAt;

  @HiveField(33)
  final String? updatedAt;

  @HiveField(34)
  final List<AssetDocumentModel>? documents;

  AssetModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.assetTag,
    this.qrCode,
    required this.category,
    this.barcode,
    this.manufacturer,
    this.model,
    this.serialNumber,
    required this.status,
    required this.statusLabel,
    required this.condition,
    required this.conditionLabel,
    this.location,
    this.department,
    this.assignedTo,
    this.assignedAt,
    this.purchasePrice,
    this.purchaseCost,
    this.supplier,
    this.insurancePolicyNumber,
    this.insuranceExpiryDate,
    this.currentValue,
    this.purchaseDate,
    this.warrantyExpiry,
    required this.isUnderWarranty,
    this.image,
    this.description,
    this.notes,
    this.specifications,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.documents,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    // Handle category - can be either a String or Map
    AssetCategoryInfo category;
    if (json['category'] is String) {
      category = AssetCategoryInfo(
        id: 0,
        name: json['category'] as String,
      );
    } else {
      category = AssetCategoryInfo.fromJson(json['category'] as Map<String, dynamic>);
    }

    // Handle department - can be either a String, Map, or null
    AssetCategoryInfo? department;
    if (json['department'] != null) {
      if (json['department'] is String) {
        department = AssetCategoryInfo(
          id: 0,
          name: json['department'] as String,
        );
      } else if (json['department'] is Map<String, dynamic>) {
        department = AssetCategoryInfo.fromJson(json['department'] as Map<String, dynamic>);
      }
    }

    return AssetModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      assetTag: json['assetTag'] as String,
      qrCode: json['qrCode'] as String?,
      category: category,
      barcode: json['barcode'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String,
      condition: json['condition'] as String,
      conditionLabel: json['conditionLabel'] as String,
      location: json['location'] as String?,
      department: department,
      assignedTo: json['assignedTo'] != null
          ? AssignedToInfo.fromJson(json['assignedTo'] as Map<String, dynamic>)
          : null,
      assignedAt: json['assignedAt'] as String?,
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      purchaseCost: json['purchaseCost'] != null
          ? (json['purchaseCost'] as num).toDouble()
          : null,
      supplier: json['supplier'] as String?,
      insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
      insuranceExpiryDate: json['insuranceExpiryDate'] as String?,
      currentValue: json['currentValue'] != null
          ? (json['currentValue'] as num).toDouble()
          : null,
      purchaseDate: json['purchaseDate'] as String?,
      warrantyExpiry: json['warrantyExpiry'] as String?,
      isUnderWarranty: json['isUnderWarranty'] as bool? ?? false,
      image: json['image'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      specifications: json['specifications'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      documents: json['documents'] != null
          ? (json['documents'] as List<dynamic>)
              .map((doc) => AssetDocumentModel.fromJson(doc as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'assetTag': assetTag,
      'qrCode': qrCode,
      'category': category.toJson(),
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'status': status,
      'statusLabel': statusLabel,
      'condition': condition,
      'conditionLabel': conditionLabel,
      'location': location,
      'department': department,
      'assignedTo': assignedTo?.toJson(),
      'assignedAt': assignedAt,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'purchaseDate': purchaseDate,
      'warrantyExpiry': warrantyExpiry,
      'isUnderWarranty': isUnderWarranty,
      'image': image,
      'description': description,
      'notes': notes,
      'specifications': specifications,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'documents': documents?.map((doc) => doc.toJson()).toList(),
    };
  }

  /// Get AssetStatus enum from status string
  AssetStatus get statusEnum => AssetStatus.fromString(status);

  /// Get AssetCondition enum from condition string
  AssetCondition get conditionEnum => AssetCondition.fromString(condition);

  /// Check if asset is assigned
  bool get isAssigned => assignedTo != null && status == 'assigned';

  /// Get warranty days remaining
  int? get warrantyDaysRemaining {
    if (warrantyExpiry == null) return null;
    try {
      final expiryDate = DateParser.parseApiDate(warrantyExpiry!);
      final now = DateTime.now();
      return expiryDate.difference(now).inDays;
    } catch (e) {
      return null;
    }
  }

  /// Check if warranty is expiring soon (within 30 days)
  bool get isWarrantyExpiringSoon {
    final daysRemaining = warrantyDaysRemaining;
    return daysRemaining != null && daysRemaining > 0 && daysRemaining <= 30;
  }
}

@HiveType(typeId: 61)
class AssetCategoryInfo extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? code;

  @HiveField(3)
  final String? description;

  AssetCategoryInfo({
    required this.id,
    required this.name,
    this.code,
    this.description,
  });

  factory AssetCategoryInfo.fromJson(Map<String, dynamic> json) {
    return AssetCategoryInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
    };
  }
}

@HiveType(typeId: 62)
class AssignedToInfo extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? employeeCode;

  @HiveField(3)
  final String? department;

  @HiveField(4)
  final String? designation;

  @HiveField(5)
  final String? email;

  @HiveField(6)
  final String? phone;

  AssignedToInfo({
    required this.id,
    required this.name,
    this.employeeCode,
    this.department,
    this.designation,
    this.email,
    this.phone,
  });

  factory AssignedToInfo.fromJson(Map<String, dynamic> json) {
    return AssignedToInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      employeeCode: json['employeeCode'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employeeCode': employeeCode,
      'department': department,
      'designation': designation,
      'email': email,
      'phone': phone,
    };
  }
}

/// Asset List Response Wrapper
class AssetListResponse {
  final int totalCount;
  final List<AssetModel> values;

  AssetListResponse({
    required this.totalCount,
    required this.values,
  });

  factory AssetListResponse.fromJson(Map<String, dynamic> json) {
    return AssetListResponse(
      totalCount: json['totalCount'] as int,
      values: (json['values'] as List)
          .map((item) => AssetModel.fromJson(item as Map<String, dynamic>))
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
