// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentRequestModelAdapter extends TypeAdapter<DocumentRequestModel> {
  @override
  final int typeId = 50;

  @override
  DocumentRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentRequestModel(
      id: fields[0] as int?,
      documentType: fields[1] as String?,
      status: fields[2] as String?,
      statusLabel: fields[3] as String?,
      remarks: fields[4] as String?,
      adminRemarks: fields[5] as String?,
      requestedDate: fields[6] as String?,
      approvedDate: fields[7] as String?,
      generatedDate: fields[8] as String?,
      fileUrl: fields[9] as String?,
      canCancel: fields[10] as bool?,
      canDownload: fields[11] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentRequestModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentType)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.statusLabel)
      ..writeByte(4)
      ..write(obj.remarks)
      ..writeByte(5)
      ..write(obj.adminRemarks)
      ..writeByte(6)
      ..write(obj.requestedDate)
      ..writeByte(7)
      ..write(obj.approvedDate)
      ..writeByte(8)
      ..write(obj.generatedDate)
      ..writeByte(9)
      ..write(obj.fileUrl)
      ..writeByte(10)
      ..write(obj.canCancel)
      ..writeByte(11)
      ..write(obj.canDownload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentRequestStatisticsAdapter
    extends TypeAdapter<DocumentRequestStatistics> {
  @override
  final int typeId = 51;

  @override
  DocumentRequestStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentRequestStatistics(
      total: fields[0] as int?,
      pending: fields[1] as int?,
      approved: fields[2] as int?,
      generated: fields[3] as int?,
      rejected: fields[4] as int?,
      cancelled: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentRequestStatistics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.pending)
      ..writeByte(2)
      ..write(obj.approved)
      ..writeByte(3)
      ..write(obj.generated)
      ..writeByte(4)
      ..write(obj.rejected)
      ..writeByte(5)
      ..write(obj.cancelled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentRequestStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
