import 'package:hive/hive.dart';

part 'document_category_model.g.dart';

@HiveType(typeId: 56)
class DocumentCategoryModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? code;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final bool requiresExpiryDate;

  @HiveField(5)
  final bool requiresVerification;

  DocumentCategoryModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.requiresExpiryDate,
    required this.requiresVerification,
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      requiresExpiryDate: json['requires_expiry_date'] ?? false,
      requiresVerification: json['requires_verification'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'requires_expiry_date': requiresExpiryDate,
      'requires_verification': requiresVerification,
    };
  }
}
