// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieDtoAdapter extends TypeAdapter<MovieDto> {
  @override
  final typeId = 3;

  @override
  MovieDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieDto(
      id: fields[0] as String,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      rating: (fields[3] as num?)?.toDouble(),
      releaseDate: fields[4] as String?,
      expectedReleaseDate: fields[5] as String?,
      matchPercentage: (fields[6] as num?)?.toInt(),
      rank: (fields[7] as num?)?.toInt(),
      views: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieDto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterUrl)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.expectedReleaseDate)
      ..writeByte(6)
      ..write(obj.matchPercentage)
      ..writeByte(7)
      ..write(obj.rank)
      ..writeByte(8)
      ..write(obj.views);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieDtoImpl _$$MovieDtoImplFromJson(Map<String, dynamic> json) =>
    _$MovieDtoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      releaseDate: json['releaseDate'] as String?,
      expectedReleaseDate: json['expectedReleaseDate'] as String?,
      matchPercentage: (json['matchPercentage'] as num?)?.toInt(),
      rank: (json['rank'] as num?)?.toInt(),
      views: json['views'] as String?,
    );

Map<String, dynamic> _$$MovieDtoImplToJson(_$MovieDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'posterUrl': instance.posterUrl,
      'rating': instance.rating,
      'releaseDate': instance.releaseDate,
      'expectedReleaseDate': instance.expectedReleaseDate,
      'matchPercentage': instance.matchPercentage,
      'rank': instance.rank,
      'views': instance.views,
    };
