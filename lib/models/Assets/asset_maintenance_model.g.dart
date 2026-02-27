// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_maintenance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetMaintenanceModelAdapter extends TypeAdapter<AssetMaintenanceModel> {
  @override
  final int typeId = 35;

  @override
  AssetMaintenanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetMaintenanceModel(
      id: fields[0] as int,
      maintenanceType: fields[1] as String,
      performedAt: fields[2] as String?,
      details: fields[3] as String,
      cost: fields[4] as double?,
      provider: fields[5] as String?,
      nextDueDate: fields[6] as String?,
      completedBy: fields[7] as CompletedByModel?,
    );
  }

  @override
  void write(BinaryWriter writer, AssetMaintenanceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.maintenanceType)
      ..writeByte(2)
      ..write(obj.performedAt)
      ..writeByte(3)
      ..write(obj.details)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.provider)
      ..writeByte(6)
      ..write(obj.nextDueDate)
      ..writeByte(7)
      ..write(obj.completedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetMaintenanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletedByModelAdapter extends TypeAdapter<CompletedByModel> {
  @override
  final int typeId = 36;

  @override
  CompletedByModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedByModel(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedByModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedByModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
