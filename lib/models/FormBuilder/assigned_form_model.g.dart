// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignedFormModelAdapter extends TypeAdapter<AssignedFormModel> {
  @override
  final int typeId = 102;

  @override
  AssignedFormModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignedFormModel(
      assignmentId: fields[0] as int,
      formId: fields[1] as int,
      formName: fields[2] as String,
      formDescription: fields[3] as String?,
      formFields: (fields[4] as List).cast<FormFieldModel>(),
      status: fields[5] as String,
      dueDate: fields[6] as DateTime?,
      submittedDate: fields[7] as DateTime?,
      isOverdue: fields[8] as bool,
      assignedOn: fields[9] as DateTime,
      assignedBy: fields[10] as String?,
      assignedByName: fields[11] as String?,
      remarks: fields[12] as String?,
      priority: fields[13] as int?,
      submissionData: (fields[14] as Map?)?.cast<String, dynamic>(),
      attachmentUrls: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AssignedFormModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.assignmentId)
      ..writeByte(1)
      ..write(obj.formId)
      ..writeByte(2)
      ..write(obj.formName)
      ..writeByte(3)
      ..write(obj.formDescription)
      ..writeByte(4)
      ..write(obj.formFields)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.submittedDate)
      ..writeByte(8)
      ..write(obj.isOverdue)
      ..writeByte(9)
      ..write(obj.assignedOn)
      ..writeByte(10)
      ..write(obj.assignedBy)
      ..writeByte(11)
      ..write(obj.assignedByName)
      ..writeByte(12)
      ..write(obj.remarks)
      ..writeByte(13)
      ..write(obj.priority)
      ..writeByte(14)
      ..write(obj.submissionData)
      ..writeByte(15)
      ..write(obj.attachmentUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedFormModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
