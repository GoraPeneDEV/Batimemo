// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetAssignmentModelAdapter extends TypeAdapter<AssetAssignmentModel> {
  @override
  final int typeId = 63;

  @override
  AssetAssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetAssignmentModel(
      id: fields[0] as int,
      assetId: fields[1] as int,
      assetName: fields[2] as String,
      assetTag: fields[3] as String,
      category: fields[4] as String,
      manufacturer: fields[5] as String?,
      model: fields[6] as String?,
      serialNumber: fields[7] as String?,
      image: fields[8] as String?,
      assignedAt: fields[9] as String,
      returnedAt: fields[10] as String?,
      isActive: fields[11] as bool,
      assignmentNotes: fields[12] as String?,
      returnNotes: fields[13] as String?,
      conditionAtAssignment: fields[14] as String?,
      conditionAtReturn: fields[15] as String?,
      assignedBy: fields[16] as AssignedByInfo?,
      returnedTo: fields[17] as ReturnedToInfo?,
      createdAt: fields[18] as String,
      updatedAt: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AssetAssignmentModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assetId)
      ..writeByte(2)
      ..write(obj.assetName)
      ..writeByte(3)
      ..write(obj.assetTag)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.manufacturer)
      ..writeByte(6)
      ..write(obj.model)
      ..writeByte(7)
      ..write(obj.serialNumber)
      ..writeByte(8)
      ..write(obj.image)
      ..writeByte(9)
      ..write(obj.assignedAt)
      ..writeByte(10)
      ..write(obj.returnedAt)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.assignmentNotes)
      ..writeByte(13)
      ..write(obj.returnNotes)
      ..writeByte(14)
      ..write(obj.conditionAtAssignment)
      ..writeByte(15)
      ..write(obj.conditionAtReturn)
      ..writeByte(16)
      ..write(obj.assignedBy)
      ..writeByte(17)
      ..write(obj.returnedTo)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetAssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssignedByInfoAdapter extends TypeAdapter<AssignedByInfo> {
  @override
  final int typeId = 64;

  @override
  AssignedByInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignedByInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      designation: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignedByInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.designation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedByInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReturnedToInfoAdapter extends TypeAdapter<ReturnedToInfo> {
  @override
  final int typeId = 65;

  @override
  ReturnedToInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReturnedToInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      designation: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReturnedToInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.designation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReturnedToInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
