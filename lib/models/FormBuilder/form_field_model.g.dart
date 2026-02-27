// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormFieldModelAdapter extends TypeAdapter<FormFieldModel> {
  @override
  final int typeId = 101;

  @override
  FormFieldModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormFieldModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      label: fields[3] as String?,
      required: fields[4] as bool,
      placeholder: fields[5] as String?,
      options: (fields[6] as List?)?.cast<FormOptionModel>(),
      rows: fields[7] as int?,
      min: fields[8] as double?,
      max: fields[9] as double?,
      step: fields[10] as double?,
      accept: fields[11] as String?,
      maxSize: fields[12] as int?,
      multiple: fields[13] as bool?,
      content: fields[14] as String?,
      level: fields[15] as String?,
      text: fields[16] as String?,
      maxRating: fields[17] as int?,
      pattern: fields[18] as String?,
      minLength: fields[19] as int?,
      maxLength: fields[20] as int?,
      defaultValue: fields[21] as String?,
      helpText: fields[22] as String?,
      conditionalDisplay: (fields[23] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FormFieldModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.required)
      ..writeByte(5)
      ..write(obj.placeholder)
      ..writeByte(6)
      ..write(obj.options)
      ..writeByte(7)
      ..write(obj.rows)
      ..writeByte(8)
      ..write(obj.min)
      ..writeByte(9)
      ..write(obj.max)
      ..writeByte(10)
      ..write(obj.step)
      ..writeByte(11)
      ..write(obj.accept)
      ..writeByte(12)
      ..write(obj.maxSize)
      ..writeByte(13)
      ..write(obj.multiple)
      ..writeByte(14)
      ..write(obj.content)
      ..writeByte(15)
      ..write(obj.level)
      ..writeByte(16)
      ..write(obj.text)
      ..writeByte(17)
      ..write(obj.maxRating)
      ..writeByte(18)
      ..write(obj.pattern)
      ..writeByte(19)
      ..write(obj.minLength)
      ..writeByte(20)
      ..write(obj.maxLength)
      ..writeByte(21)
      ..write(obj.defaultValue)
      ..writeByte(22)
      ..write(obj.helpText)
      ..writeByte(23)
      ..write(obj.conditionalDisplay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormFieldModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
