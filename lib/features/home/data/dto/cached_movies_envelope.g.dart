// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_movies_envelope.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedMoviesEnvelopeAdapter extends TypeAdapter<CachedMoviesEnvelope> {
  @override
  final typeId = 1;

  @override
  CachedMoviesEnvelope read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMoviesEnvelope(
      payload: (fields[0] as List).cast<MovieDto>(),
      savedAtEpochMs: (fields[1] as num).toInt(),
      schemaVersion: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedMoviesEnvelope obj) {
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
      other is CachedMoviesEnvelopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
