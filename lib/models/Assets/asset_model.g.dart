// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetModelAdapter extends TypeAdapter<AssetModel> {
  @override
  final int typeId = 60;

  @override
  AssetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetModel(
      id: fields[0] as int,
      uuid: fields[1] as String,
      name: fields[2] as String,
      assetTag: fields[3] as String,
      qrCode: fields[4] as String?,
      category: fields[5] as AssetCategoryInfo,
      barcode: fields[6] as String?,
      manufacturer: fields[7] as String?,
      model: fields[8] as String?,
      serialNumber: fields[9] as String?,
      status: fields[10] as String,
      statusLabel: fields[11] as String,
      condition: fields[12] as String,
      conditionLabel: fields[13] as String,
      location: fields[14] as String?,
      department: fields[15] as AssetCategoryInfo?,
      assignedTo: fields[16] as AssignedToInfo?,
      assignedAt: fields[17] as String?,
      purchasePrice: fields[18] as double?,
      purchaseCost: fields[29] as double?,
      supplier: fields[30] as String?,
      insurancePolicyNumber: fields[31] as String?,
      insuranceExpiryDate: fields[32] as String?,
      currentValue: fields[19] as double?,
      purchaseDate: fields[20] as String?,
      warrantyExpiry: fields[21] as String?,
      isUnderWarranty: fields[22] as bool,
      image: fields[23] as String?,
      description: fields[24] as String?,
      notes: fields[25] as String?,
      specifications: fields[26] as String?,
      isActive: fields[27] as bool,
      createdAt: fields[28] as String?,
      updatedAt: fields[33] as String?,
      documents: (fields[34] as List?)?.cast<AssetDocumentModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AssetModel obj) {
    writer
      ..writeByte(35)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.assetTag)
      ..writeByte(4)
      ..write(obj.qrCode)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.barcode)
      ..writeByte(7)
      ..write(obj.manufacturer)
      ..writeByte(8)
      ..write(obj.model)
      ..writeByte(9)
      ..write(obj.serialNumber)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.statusLabel)
      ..writeByte(12)
      ..write(obj.condition)
      ..writeByte(13)
      ..write(obj.conditionLabel)
      ..writeByte(14)
      ..write(obj.location)
      ..writeByte(15)
      ..write(obj.department)
      ..writeByte(16)
      ..write(obj.assignedTo)
      ..writeByte(17)
      ..write(obj.assignedAt)
      ..writeByte(18)
      ..write(obj.purchasePrice)
      ..writeByte(29)
      ..write(obj.purchaseCost)
      ..writeByte(30)
      ..write(obj.supplier)
      ..writeByte(31)
      ..write(obj.insurancePolicyNumber)
      ..writeByte(32)
      ..write(obj.insuranceExpiryDate)
      ..writeByte(19)
      ..write(obj.currentValue)
      ..writeByte(20)
      ..write(obj.purchaseDate)
      ..writeByte(21)
      ..write(obj.warrantyExpiry)
      ..writeByte(22)
      ..write(obj.isUnderWarranty)
      ..writeByte(23)
      ..write(obj.image)
      ..writeByte(24)
      ..write(obj.description)
      ..writeByte(25)
      ..write(obj.notes)
      ..writeByte(26)
      ..write(obj.specifications)
      ..writeByte(27)
      ..write(obj.isActive)
      ..writeByte(28)
      ..write(obj.createdAt)
      ..writeByte(33)
      ..write(obj.updatedAt)
      ..writeByte(34)
      ..write(obj.documents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssetCategoryInfoAdapter extends TypeAdapter<AssetCategoryInfo> {
  @override
  final int typeId = 61;

  @override
  AssetCategoryInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetCategoryInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      code: fields[2] as String?,
      description: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AssetCategoryInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetCategoryInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssignedToInfoAdapter extends TypeAdapter<AssignedToInfo> {
  @override
  final int typeId = 62;

  @override
  AssignedToInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignedToInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      employeeCode: fields[2] as String?,
      department: fields[3] as String?,
      designation: fields[4] as String?,
      email: fields[5] as String?,
      phone: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignedToInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.employeeCode)
      ..writeByte(3)
      ..write(obj.department)
      ..writeByte(4)
      ..write(obj.designation)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedToInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
