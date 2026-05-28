// Hand-rolled fake HomeRepository for provider unit tests.
// Avoids mocktail complexity — single configurable fake with
// predictable setup/behavior per test.

import 'package:adf_demo/features/home/domain/entities/banner.dart';
import 'package:adf_demo/features/home/domain/entities/movie.dart';
import 'package:adf_demo/features/home/domain/home_repository.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.nowShowing = const [],
    this.comingSoon = const [],
    this.recommended = const [],
    this.trending = const [],
    this.banners = const [],
    this.throwOnNowShowing,
    this.throwOnComingSoon,
    this.throwOnRecommended,
    this.throwOnTrending,
    this.throwOnBanners,
  });

  final List<Movie> nowShowing;
  final List<Movie> comingSoon;
  final List<Movie> recommended;
  final List<Movie> trending;
  final List<Banner> banners;

  final Object? throwOnNowShowing;
  final Object? throwOnComingSoon;
  final Object? throwOnRecommended;
  final Object? throwOnTrending;
  final Object? throwOnBanners;

  int nowShowingCallCount = 0;
  int comingSoonCallCount = 0;
  int recommendedCallCount = 0;
  int trendingCallCount = 0;
  int bannersCallCount = 0;

  @override
  Future<List<Movie>> getNowShowing({bool forceRefresh = false}) async {
    nowShowingCallCount++;
    if (throwOnNowShowing != null) throw throwOnNowShowing!;
    return nowShowing;
  }

  @override
  Future<List<Movie>> getComingSoon({bool forceRefresh = false}) async {
    comingSoonCallCount++;
    if (throwOnComingSoon != null) throw throwOnComingSoon!;
    return comingSoon;
  }

  @override
  Future<List<Movie>> getRecommended({bool forceRefresh = false}) async {
    recommendedCallCount++;
    if (throwOnRecommended != null) throw throwOnRecommended!;
    return recommended;
  }

  @override
  Future<List<Movie>> getTrending({bool forceRefresh = false}) async {
    trendingCallCount++;
    if (throwOnTrending != null) throw throwOnTrending!;
    return trending;
  }

  @override
  Future<List<Banner>> getBanners({bool forceRefresh = false}) async {
    bannersCallCount++;
    if (throwOnBanners != null) throw throwOnBanners!;
    return banners;
  }
}
