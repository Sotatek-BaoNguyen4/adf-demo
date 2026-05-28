// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Movie {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get posterUrl => throw _privateConstructorUsedError;

  /// IMDb-style rating (0-10). Null for coming-soon entries.
  double? get rating => throw _privateConstructorUsedError;

  /// ISO-8601 date string (yyyy-MM-dd). Present in now-showing.
  String? get releaseDate => throw _privateConstructorUsedError;

  /// ISO-8601 date string (yyyy-MM-dd). Present in coming-soon.
  String? get expectedReleaseDate => throw _privateConstructorUsedError;

  /// 0-100 match percentage. Present in recommended.
  int? get matchPercentage => throw _privateConstructorUsedError;

  /// 1-based weekly trending rank. Present in trending.
  int? get rank => throw _privateConstructorUsedError;

  /// Formatted view count string (e.g. "2.4M"). Present in trending.
  String? get views => throw _privateConstructorUsedError;

  /// Create a copy of Movie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieCopyWith<Movie> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieCopyWith<$Res> {
  factory $MovieCopyWith(Movie value, $Res Function(Movie) then) =
      _$MovieCopyWithImpl<$Res, Movie>;
  @useResult
  $Res call({
    String id,
    String title,
    String posterUrl,
    double? rating,
    String? releaseDate,
    String? expectedReleaseDate,
    int? matchPercentage,
    int? rank,
    String? views,
  });
}

/// @nodoc
class _$MovieCopyWithImpl<$Res, $Val extends Movie>
    implements $MovieCopyWith<$Res> {
  _$MovieCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Movie
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
abstract class _$$MovieImplCopyWith<$Res> implements $MovieCopyWith<$Res> {
  factory _$$MovieImplCopyWith(
    _$MovieImpl value,
    $Res Function(_$MovieImpl) then,
  ) = __$$MovieImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String posterUrl,
    double? rating,
    String? releaseDate,
    String? expectedReleaseDate,
    int? matchPercentage,
    int? rank,
    String? views,
  });
}

/// @nodoc
class __$$MovieImplCopyWithImpl<$Res>
    extends _$MovieCopyWithImpl<$Res, _$MovieImpl>
    implements _$$MovieImplCopyWith<$Res> {
  __$$MovieImplCopyWithImpl(
    _$MovieImpl _value,
    $Res Function(_$MovieImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Movie
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
      _$MovieImpl(
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

class _$MovieImpl implements _Movie {
  const _$MovieImpl({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.rating,
    this.releaseDate,
    this.expectedReleaseDate,
    this.matchPercentage,
    this.rank,
    this.views,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String posterUrl;

  /// IMDb-style rating (0-10). Null for coming-soon entries.
  @override
  final double? rating;

  /// ISO-8601 date string (yyyy-MM-dd). Present in now-showing.
  @override
  final String? releaseDate;

  /// ISO-8601 date string (yyyy-MM-dd). Present in coming-soon.
  @override
  final String? expectedReleaseDate;

  /// 0-100 match percentage. Present in recommended.
  @override
  final int? matchPercentage;

  /// 1-based weekly trending rank. Present in trending.
  @override
  final int? rank;

  /// Formatted view count string (e.g. "2.4M"). Present in trending.
  @override
  final String? views;

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, posterUrl: $posterUrl, rating: $rating, releaseDate: $releaseDate, expectedReleaseDate: $expectedReleaseDate, matchPercentage: $matchPercentage, rank: $rank, views: $views)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieImpl &&
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

  /// Create a copy of Movie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieImplCopyWith<_$MovieImpl> get copyWith =>
      __$$MovieImplCopyWithImpl<_$MovieImpl>(this, _$identity);
}

abstract class _Movie implements Movie {
  const factory _Movie({
    required final String id,
    required final String title,
    required final String posterUrl,
    final double? rating,
    final String? releaseDate,
    final String? expectedReleaseDate,
    final int? matchPercentage,
    final int? rank,
    final String? views,
  }) = _$MovieImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get posterUrl;

  /// IMDb-style rating (0-10). Null for coming-soon entries.
  @override
  double? get rating;

  /// ISO-8601 date string (yyyy-MM-dd). Present in now-showing.
  @override
  String? get releaseDate;

  /// ISO-8601 date string (yyyy-MM-dd). Present in coming-soon.
  @override
  String? get expectedReleaseDate;

  /// 0-100 match percentage. Present in recommended.
  @override
  int? get matchPercentage;

  /// 1-based weekly trending rank. Present in trending.
  @override
  int? get rank;

  /// Formatted view count string (e.g. "2.4M"). Present in trending.
  @override
  String? get views;

  /// Create a copy of Movie
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieImplCopyWith<_$MovieImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
