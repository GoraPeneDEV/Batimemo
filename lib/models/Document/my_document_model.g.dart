// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyDocumentModelAdapter extends TypeAdapter<MyDocumentModel> {
  @override
  final int typeId = 52;

  @override
  MyDocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyDocumentModel(
      id: fields[0] as int,
      category: fields[1] as String,
      title: fields[2] as String,
      number: fields[3] as String?,
      issueDate: fields[4] as String?,
      expiryDate: fields[5] as String?,
      issuingAuthority: fields[6] as String?,
      issuingCountry: fields[7] as String?,
      issuingPlace: fields[8] as String?,
      verificationStatus: fields[9] as String,
      verificationNotes: fields[10] as String?,
      verifiedBy: fields[11] as String?,
      verifiedDate: fields[12] as String?,
      expiryInfo: fields[13] as DocumentExpiryInfo?,
      notes: fields[14] as String?,
      fileSize: fields[15] as String?,
      canDownload: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MyDocumentModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.number)
      ..writeByte(4)
      ..write(obj.issueDate)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.issuingAuthority)
      ..writeByte(7)
      ..write(obj.issuingCountry)
      ..writeByte(8)
      ..write(obj.issuingPlace)
      ..writeByte(9)
      ..write(obj.verificationStatus)
      ..writeByte(10)
      ..write(obj.verificationNotes)
      ..writeByte(11)
      ..write(obj.verifiedBy)
      ..writeByte(12)
      ..write(obj.verifiedDate)
      ..writeByte(13)
      ..write(obj.expiryInfo)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.fileSize)
      ..writeByte(16)
      ..write(obj.canDownload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyDocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentExpiryInfoAdapter extends TypeAdapter<DocumentExpiryInfo> {
  @override
  final int typeId = 53;

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

class MyDocumentStatisticsAdapter extends TypeAdapter<MyDocumentStatistics> {
  @override
  final int typeId = 54;

  @override
  MyDocumentStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyDocumentStatistics(
      total: fields[0] as int,
      pending: fields[1] as int,
      verified: fields[2] as int,
      rejected: fields[3] as int,
      expired: fields[4] as int,
      expiringSoon: fields[5] as int,
      valid: fields[6] as int,
      noExpiry: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MyDocumentStatistics obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.pending)
      ..writeByte(2)
      ..write(obj.verified)
      ..writeByte(3)
      ..write(obj.rejected)
      ..writeByte(4)
      ..write(obj.expired)
      ..writeByte(5)
      ..write(obj.expiringSoon)
      ..writeByte(6)
      ..write(obj.valid)
      ..writeByte(7)
      ..write(obj.noExpiry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyDocumentStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
