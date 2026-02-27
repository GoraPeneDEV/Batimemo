// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetDocumentModelAdapter extends TypeAdapter<AssetDocumentModel> {
  @override
  final int typeId = 66;

  @override
  AssetDocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetDocumentModel(
      id: fields[0] as int,
      uuid: fields[1] as String,
      assetId: fields[2] as int,
      title: fields[3] as String,
      description: fields[4] as String?,
      documentType: fields[5] as String,
      documentTypeLabel: fields[6] as String,
      fileName: fields[7] as String,
      filePath: fields[8] as String,
      fileUrl: fields[9] as String?,
      fileSize: fields[10] as String,
      fileSizeFormatted: fields[11] as String?,
      mimeType: fields[12] as String?,
      fileExtension: fields[13] as String?,
      documentDate: fields[14] as String?,
      expiryDate: fields[15] as String?,
      hasExpiry: fields[16] as bool,
      expiryInfo: fields[17] as DocumentExpiryInfo?,
      referenceNumber: fields[18] as String?,
      issuedBy: fields[19] as String?,
      notes: fields[20] as String?,
      uploadedBy: fields[21] as UploadedByInfo?,
      canDownload: fields[22] as bool,
      canDelete: fields[23] as bool,
      createdAt: fields[24] as String,
      updatedAt: fields[25] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AssetDocumentModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.assetId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.documentType)
      ..writeByte(6)
      ..write(obj.documentTypeLabel)
      ..writeByte(7)
      ..write(obj.fileName)
      ..writeByte(8)
      ..write(obj.filePath)
      ..writeByte(9)
      ..write(obj.fileUrl)
      ..writeByte(10)
      ..write(obj.fileSize)
      ..writeByte(11)
      ..write(obj.fileSizeFormatted)
      ..writeByte(12)
      ..write(obj.mimeType)
      ..writeByte(13)
      ..write(obj.fileExtension)
      ..writeByte(14)
      ..write(obj.documentDate)
      ..writeByte(15)
      ..write(obj.expiryDate)
      ..writeByte(16)
      ..write(obj.hasExpiry)
      ..writeByte(17)
      ..write(obj.expiryInfo)
      ..writeByte(18)
      ..write(obj.referenceNumber)
      ..writeByte(19)
      ..write(obj.issuedBy)
      ..writeByte(20)
      ..write(obj.notes)
      ..writeByte(21)
      ..write(obj.uploadedBy)
      ..writeByte(22)
      ..write(obj.canDownload)
      ..writeByte(23)
      ..write(obj.canDelete)
      ..writeByte(24)
      ..write(obj.createdAt)
      ..writeByte(25)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetDocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentExpiryInfoAdapter extends TypeAdapter<DocumentExpiryInfo> {
  @override
  final int typeId = 67;

  @override
  DocumentExpiryInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentExpiryInfo(
      daysUntilExpiry: fields[0] as int?,
      status: fields[1] as String,
      statusColor: fields[2] as String,
      isExpiringSoon: fields[3] as bool,
      isExpired: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentExpiryInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.daysUntilExpiry)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.statusColor)
      ..writeByte(3)
      ..write(obj.isExpiringSoon)
      ..writeByte(4)
      ..write(obj.isExpired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentExpiryInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UploadedByInfoAdapter extends TypeAdapter<UploadedByInfo> {
  @override
  final int typeId = 68;

  @override
  UploadedByInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadedByInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      employeeCode: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UploadedByInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.employeeCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadedByInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
