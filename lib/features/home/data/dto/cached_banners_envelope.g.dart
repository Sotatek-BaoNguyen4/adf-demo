// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_banners_envelope.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedBannersEnvelopeAdapter extends TypeAdapter<CachedBannersEnvelope> {
  @override
  final typeId = 2;

  @override
  CachedBannersEnvelope read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedBannersEnvelope(
      payload: (fields[0] as List).cast<BannerDto>(),
      savedAtEpochMs: (fields[1] as num).toInt(),
      schemaVersion: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedBannersEnvelope obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.savedAtEpochMs)
      ..writeByte(2)
      ..write(obj.schemaVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedBannersEnvelopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
