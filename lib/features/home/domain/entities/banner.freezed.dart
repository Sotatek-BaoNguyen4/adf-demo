// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Banner {
  String get id => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  /// Deep-link or web URL to navigate to when tapped.
  String get targetUrl => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Optional overlay fields (FSD §4 banners endpoint).
  String? get genre => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  BadgeKind? get badgeKind => throw _privateConstructorUsedError;

  /// Create a copy of Banner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerCopyWith<Banner> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerCopyWith<$Res> {
  factory $BannerCopyWith(Banner value, $Res Function(Banner) then) =
      _$BannerCopyWithImpl<$Res, Banner>;
  @useResult
  $Res call({
    String id,
    String imageUrl,
    String targetUrl,
    String title,
    String? genre,
    double? rating,
    BadgeKind? badgeKind,
  });
}

/// @nodoc
class _$BannerCopyWithImpl<$Res, $Val extends Banner>
    implements $BannerCopyWith<$Res> {
  _$BannerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Banner
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
                      as BadgeKind?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BannerImplCopyWith<$Res> implements $BannerCopyWith<$Res> {
  factory _$$BannerImplCopyWith(
    _$BannerImpl value,
    $Res Function(_$BannerImpl) then,
  ) = __$$BannerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String imageUrl,
    String targetUrl,
    String title,
    String? genre,
    double? rating,
    BadgeKind? badgeKind,
  });
}

/// @nodoc
class __$$BannerImplCopyWithImpl<$Res>
    extends _$BannerCopyWithImpl<$Res, _$BannerImpl>
    implements _$$BannerImplCopyWith<$Res> {
  __$$BannerImplCopyWithImpl(
    _$BannerImpl _value,
    $Res Function(_$BannerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Banner
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
      _$BannerImpl(
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
                  as BadgeKind?,
      ),
    );
  }
}

/// @nodoc

class _$BannerImpl implements _Banner {
  const _$BannerImpl({
    required this.id,
    required this.imageUrl,
    required this.targetUrl,
    required this.title,
    this.genre,
    this.rating,
    this.badgeKind,
  });

  @override
  final String id;
  @override
  final String imageUrl;

  /// Deep-link or web URL to navigate to when tapped.
  @override
  final String targetUrl;
  @override
  final String title;

  /// Optional overlay fields (FSD §4 banners endpoint).
  @override
  final String? genre;
  @override
  final double? rating;
  @override
  final BadgeKind? badgeKind;

  @override
  String toString() {
    return 'Banner(id: $id, imageUrl: $imageUrl, targetUrl: $targetUrl, title: $title, genre: $genre, rating: $rating, badgeKind: $badgeKind)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerImpl &&
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

  /// Create a copy of Banner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerImplCopyWith<_$BannerImpl> get copyWith =>
      __$$BannerImplCopyWithImpl<_$BannerImpl>(this, _$identity);
}

abstract class _Banner implements Banner {
  const factory _Banner({
    required final String id,
    required final String imageUrl,
    required final String targetUrl,
    required final String title,
    final String? genre,
    final double? rating,
    final BadgeKind? badgeKind,
  }) = _$BannerImpl;

  @override
  String get id;
  @override
  String get imageUrl;

  /// Deep-link or web URL to navigate to when tapped.
  @override
  String get targetUrl;
  @override
  String get title;

  /// Optional overlay fields (FSD §4 banners endpoint).
  @override
  String? get genre;
  @override
  double? get rating;
  @override
  BadgeKind? get badgeKind;

  /// Create a copy of Banner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerImplCopyWith<_$BannerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
