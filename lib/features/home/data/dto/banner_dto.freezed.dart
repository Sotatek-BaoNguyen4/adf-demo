// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BannerDto _$BannerDtoFromJson(Map<String, dynamic> json) {
  return _BannerDto.fromJson(json);
}

/// @nodoc
mixin _$BannerDto {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get imageUrl => throw _privateConstructorUsedError;

  /// Deep-link or web URL navigated to on tap.
  @HiveField(2)
  String get targetUrl => throw _privateConstructorUsedError;
  @HiveField(3)
  String get title => throw _privateConstructorUsedError;

  /// Optional overlay fields — nullable for backward compat.
  @HiveField(4)
  String? get genre => throw _privateConstructorUsedError;
  @HiveField(5)
  double? get rating => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get badgeKind => throw _privateConstructorUsedError;

  /// Serializes this BannerDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BannerDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerDtoCopyWith<BannerDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerDtoCopyWith<$Res> {
  factory $BannerDtoCopyWith(BannerDto value, $Res Function(BannerDto) then) =
      _$BannerDtoCopyWithImpl<$Res, BannerDto>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String imageUrl,
    @HiveField(2) String targetUrl,
    @HiveField(3) String title,
    @HiveField(4) String? genre,
    @HiveField(5) double? rating,
    @HiveField(6) String? badgeKind,
  });
}

/// @nodoc
class _$BannerDtoCopyWithImpl<$Res, $Val extends BannerDto>
    implements $BannerDtoCopyWith<$Res> {
  _$BannerDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BannerDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? targetUrl = null,
    Object? title = null,
    Object? genre = freezed,
    Object? rating = freezed,
    Object? badgeKind = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            targetUrl: null == targetUrl
                ? _value.targetUrl
                : targetUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            genre: freezed == genre
                ? _value.genre
                : genre // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            badgeKind: freezed == badgeKind
                ? _value.badgeKind
                : badgeKind // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BannerDtoImplCopyWith<$Res>
    implements $BannerDtoCopyWith<$Res> {
  factory _$$BannerDtoImplCopyWith(
    _$BannerDtoImpl value,
    $Res Function(_$BannerDtoImpl) then,
  ) = __$$BannerDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String imageUrl,
    @HiveField(2) String targetUrl,
    @HiveField(3) String title,
    @HiveField(4) String? genre,
    @HiveField(5) double? rating,
    @HiveField(6) String? badgeKind,
  });
}

/// @nodoc
class __$$BannerDtoImplCopyWithImpl<$Res>
    extends _$BannerDtoCopyWithImpl<$Res, _$BannerDtoImpl>
    implements _$$BannerDtoImplCopyWith<$Res> {
  __$$BannerDtoImplCopyWithImpl(
    _$BannerDtoImpl _value,
    $Res Function(_$BannerDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BannerDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? targetUrl = null,
    Object? title = null,
    Object? genre = freezed,
    Object? rating = freezed,
    Object? badgeKind = freezed,
  }) {
    return _then(
      _$BannerDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        targetUrl: null == targetUrl
            ? _value.targetUrl
            : targetUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        genre: freezed == genre
            ? _value.genre
            : genre // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        badgeKind: freezed == badgeKind
            ? _value.badgeKind
            : badgeKind // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BannerDtoImpl implements _BannerDto {
  const _$BannerDtoImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.imageUrl,
    @HiveField(2) required this.targetUrl,
    @HiveField(3) required this.title,
    @HiveField(4) this.genre,
    @HiveField(5) this.rating,
    @HiveField(6) this.badgeKind,
  });

  factory _$BannerDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BannerDtoImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String imageUrl;

  /// Deep-link or web URL navigated to on tap.
  @override
  @HiveField(2)
  final String targetUrl;
  @override
  @HiveField(3)
  final String title;

  /// Optional overlay fields — nullable for backward compat.
  @override
  @HiveField(4)
  final String? genre;
  @override
  @HiveField(5)
  final double? rating;
  @override
  @HiveField(6)
  final String? badgeKind;

  @override
  String toString() {
    return 'BannerDto(id: $id, imageUrl: $imageUrl, targetUrl: $targetUrl, title: $title, genre: $genre, rating: $rating, badgeKind: $badgeKind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.targetUrl, targetUrl) ||
                other.targetUrl == targetUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.badgeKind, badgeKind) ||
                other.badgeKind == badgeKind));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    imageUrl,
    targetUrl,
    title,
    genre,
    rating,
    badgeKind,
  );

  /// Create a copy of BannerDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerDtoImplCopyWith<_$BannerDtoImpl> get copyWith =>
      __$$BannerDtoImplCopyWithImpl<_$BannerDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BannerDtoImplToJson(this);
  }
}

abstract class _BannerDto implements BannerDto {
  const factory _BannerDto({
    @HiveField(0) required final String id,
    @HiveField(1) required final String imageUrl,
    @HiveField(2) required final String targetUrl,
    @HiveField(3) required final String title,
    @HiveField(4) final String? genre,
    @HiveField(5) final double? rating,
    @HiveField(6) final String? badgeKind,
  }) = _$BannerDtoImpl;

  factory _BannerDto.fromJson(Map<String, dynamic> json) =
      _$BannerDtoImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get imageUrl;

  /// Deep-link or web URL navigated to on tap.
  @override
  @HiveField(2)
  String get targetUrl;
  @override
  @HiveField(3)
  String get title;

  /// Optional overlay fields — nullable for backward compat.
  @override
  @HiveField(4)
  String? get genre;
  @override
  @HiveField(5)
  double? get rating;
  @override
  @HiveField(6)
  String? get badgeKind;

  /// Create a copy of BannerDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerDtoImplCopyWith<_$BannerDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
