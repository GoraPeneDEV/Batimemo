// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentTypeModelAdapter extends TypeAdapter<DocumentTypeModel> {
  @override
  final int typeId = 4;

  @override
  DocumentTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentTypeModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      code: fields[2] as String?,
      description: fields[3] as String?,
      notes: fields[4] as String?,
      isRequired: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentTypeModel obj) {
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
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.isRequired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
