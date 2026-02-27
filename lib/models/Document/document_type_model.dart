import 'package:hive/hive.dart';

part 'document_type_model.g.dart';

@HiveType(typeId: 4)
class DocumentTypeModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? code;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool? isRequired;

  DocumentTypeModel({
    this.id,
    this.name,
    this.code,
    this.description,
    this.notes,
    this.isRequired,
  });

  DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
    notes = json['notes'];
    isRequired = json['is_required'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'notes': notes,
      'is_required': isRequired,
    };
  }
}
