// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieDto _$MovieDtoFromJson(Map<String, dynamic> json) {
  return _MovieDto.fromJson(json);
}

/// @nodoc
mixin _$MovieDto {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(2)
  String get posterUrl => throw _privateConstructorUsedError;

  /// Rating (0-10). Present in now-showing + recommended; absent in coming-soon.
  @HiveField(3)
  double? get rating => throw _privateConstructorUsedError;

  /// ISO-8601 date. Present in now-showing only.
  @HiveField(4)
  String? get releaseDate => throw _privateConstructorUsedError;

  /// ISO-8601 date. Present in coming-soon only.
  @HiveField(5)
  String? get expectedReleaseDate => throw _privateConstructorUsedError;

  /// 0-100 match score. Present in recommended only.
  @HiveField(6)
  int? get matchPercentage => throw _privateConstructorUsedError;

  /// 1-based weekly trending rank. Present in trending only.
  @HiveField(7)
  int? get rank => throw _privateConstructorUsedError;

  /// Formatted view count string (e.g. "2.4M"). Present in trending only.
  @HiveField(8)
  String? get views => throw _privateConstructorUsedError;

  /// Serializes this MovieDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieDtoCopyWith<MovieDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieDtoCopyWith<$Res> {
  factory $MovieDtoCopyWith(MovieDto value, $Res Function(MovieDto) then) =
      _$MovieDtoCopyWithImpl<$Res, MovieDto>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String title,
    @HiveField(2) String posterUrl,
    @HiveField(3) double? rating,
    @HiveField(4) String? releaseDate,
    @HiveField(5) String? expectedReleaseDate,
    @HiveField(6) int? matchPercentage,
    @HiveField(7) int? rank,
    @HiveField(8) String? views,
  });
}

/// @nodoc
class _$MovieDtoCopyWithImpl<$Res, $Val extends MovieDto>
    implements $MovieDtoCopyWith<$Res> {
  _$MovieDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? posterUrl = null,
    Object? rating = freezed,
    Object? releaseDate = freezed,
    Object? expectedReleaseDate = freezed,
    Object? matchPercentage = freezed,
    Object? rank = freezed,
    Object? views = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            posterUrl: null == posterUrl
                ? _value.posterUrl
                : posterUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            releaseDate: freezed == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            expectedReleaseDate: freezed == expectedReleaseDate
                ? _value.expectedReleaseDate
                : expectedReleaseDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            matchPercentage: freezed == matchPercentage
                ? _value.matchPercentage
                : matchPercentage // ignore: cast_nullable_to_non_nullable
                      as int?,
            rank: freezed == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int?,
            views: freezed == views
                ? _value.views
                : views // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieDtoImplCopyWith<$Res>
    implements $MovieDtoCopyWith<$Res> {
  factory _$$MovieDtoImplCopyWith(
    _$MovieDtoImpl value,
    $Res Function(_$MovieDtoImpl) then,
  ) = __$$MovieDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String title,
    @HiveField(2) String posterUrl,
    @HiveField(3) double? rating,
    @HiveField(4) String? releaseDate,
    @HiveField(5) String? expectedReleaseDate,
    @HiveField(6) int? matchPercentage,
    @HiveField(7) int? rank,
    @HiveField(8) String? views,
  });
}

/// @nodoc
class __$$MovieDtoImplCopyWithImpl<$Res>
    extends _$MovieDtoCopyWithImpl<$Res, _$MovieDtoImpl>
    implements _$$MovieDtoImplCopyWith<$Res> {
  __$$MovieDtoImplCopyWithImpl(
    _$MovieDtoImpl _value,
    $Res Function(_$MovieDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? posterUrl = null,
    Object? rating = freezed,
    Object? releaseDate = freezed,
    Object? expectedReleaseDate = freezed,
    Object? matchPercentage = freezed,
    Object? rank = freezed,
    Object? views = freezed,
  }) {
    return _then(
      _$MovieDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        posterUrl: null == posterUrl
            ? _value.posterUrl
            : posterUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        releaseDate: freezed == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        expectedReleaseDate: freezed == expectedReleaseDate
            ? _value.expectedReleaseDate
            : expectedReleaseDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        matchPercentage: freezed == matchPercentage
            ? _value.matchPercentage
            : matchPercentage // ignore: cast_nullable_to_non_nullable
                  as int?,
        rank: freezed == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int?,
        views: freezed == views
            ? _value.views
            : views // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieDtoImpl implements _MovieDto {
  const _$MovieDtoImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.title,
    @HiveField(2) required this.posterUrl,
    @HiveField(3) this.rating,
    @HiveField(4) this.releaseDate,
    @HiveField(5) this.expectedReleaseDate,
    @HiveField(6) this.matchPercentage,
    @HiveField(7) this.rank,
    @HiveField(8) this.views,
  });

  factory _$MovieDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieDtoImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String posterUrl;

  /// Rating (0-10). Present in now-showing + recommended; absent in coming-soon.
  @override
  @HiveField(3)
  final double? rating;

  /// ISO-8601 date. Present in now-showing only.
  @override
  @HiveField(4)
  final String? releaseDate;

  /// ISO-8601 date. Present in coming-soon only.
  @override
  @HiveField(5)
  final String? expectedReleaseDate;

  /// 0-100 match score. Present in recommended only.
  @override
  @HiveField(6)
  final int? matchPercentage;

  /// 1-based weekly trending rank. Present in trending only.
  @override
  @HiveField(7)
  final int? rank;

  /// Formatted view count string (e.g. "2.4M"). Present in trending only.
  @override
  @HiveField(8)
  final String? views;

  @override
  String toString() {
    return 'MovieDto(id: $id, title: $title, posterUrl: $posterUrl, rating: $rating, releaseDate: $releaseDate, expectedReleaseDate: $expectedReleaseDate, matchPercentage: $matchPercentage, rank: $rank, views: $views)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.expectedReleaseDate, expectedReleaseDate) ||
                other.expectedReleaseDate == expectedReleaseDate) &&
            (identical(other.matchPercentage, matchPercentage) ||
                other.matchPercentage == matchPercentage) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.views, views) || other.views == views));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    posterUrl,
    rating,
    releaseDate,
    expectedReleaseDate,
    matchPercentage,
    rank,
    views,
  );

  /// Create a copy of MovieDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieDtoImplCopyWith<_$MovieDtoImpl> get copyWith =>
      __$$MovieDtoImplCopyWithImpl<_$MovieDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieDtoImplToJson(this);
  }
}

abstract class _MovieDto implements MovieDto {
  const factory _MovieDto({
    @HiveField(0) required final String id,
    @HiveField(1) required final String title,
    @HiveField(2) required final String posterUrl,
    @HiveField(3) final double? rating,
    @HiveField(4) final String? releaseDate,
    @HiveField(5) final String? expectedReleaseDate,
    @HiveField(6) final int? matchPercentage,
    @HiveField(7) final int? rank,
    @HiveField(8) final String? views,
  }) = _$MovieDtoImpl;

  factory _MovieDto.fromJson(Map<String, dynamic> json) =
      _$MovieDtoImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(2)
  String get posterUrl;

  /// Rating (0-10). Present in now-showing + recommended; absent in coming-soon.
  @override
  @HiveField(3)
  double? get rating;

  /// ISO-8601 date. Present in now-showing only.
  @override
  @HiveField(4)
  String? get releaseDate;

  /// ISO-8601 date. Present in coming-soon only.
  @override
  @HiveField(5)
  String? get expectedReleaseDate;

  /// 0-100 match score. Present in recommended only.
  @override
  @HiveField(6)
  int? get matchPercentage;

  /// 1-based weekly trending rank. Present in trending only.
  @override
  @HiveField(7)
  int? get rank;

  /// Formatted view count string (e.g. "2.4M"). Present in trending only.
  @override
  @HiveField(8)
  String? get views;

  /// Create a copy of MovieDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieDtoImplCopyWith<_$MovieDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
