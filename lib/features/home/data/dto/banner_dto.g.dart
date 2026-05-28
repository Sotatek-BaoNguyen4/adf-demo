// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BannerDtoAdapter extends TypeAdapter<BannerDto> {
  @override
  final typeId = 4;

  @override
  BannerDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BannerDto(
      id: fields[0] as String,
      imageUrl: fields[1] as String,
      targetUrl: fields[2] as String,
      title: fields[3] as String,
      genre: fields[4] as String?,
      rating: (fields[5] as num?)?.toDouble(),
      badgeKind: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BannerDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.targetUrl)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.genre)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.badgeKind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BannerDtoImpl _$$BannerDtoImplFromJson(Map<String, dynamic> json) =>
    _$BannerDtoImpl(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      targetUrl: json['targetUrl'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      badgeKind: json['badgeKind'] as String?,
    );

Map<String, dynamic> _$$BannerDtoImplToJson(_$BannerDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'targetUrl': instance.targetUrl,
      'title': instance.title,
      'genre': instance.genre,
      'rating': instance.rating,
      'badgeKind': instance.badgeKind,
    };
