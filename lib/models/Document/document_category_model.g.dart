// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentCategoryModelAdapter extends TypeAdapter<DocumentCategoryModel> {
  @override
  final int typeId = 56;

  @override
  DocumentCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentCategoryModel(
      id: fields[0] as int,
      name: fields[1] as String,
      code: fields[2] as String?,
      description: fields[3] as String?,
      requiresExpiryDate: fields[4] as bool,
      requiresVerification: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentCategoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.requiresExpiryDate)
      ..writeByte(5)
      ..write(obj.requiresVerification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
