// Widget tests for BannerOverlayContent.
//
// Verifies that badge, title, genre, rating, and CTA buttons all render
// from a fixture Banner. Callback firing is also verified.

import 'package:flutter_test/flutter_test.dart';

import 'package:adf_demo/features/home/domain/entities/banner.dart' as domain;
import 'package:adf_demo/features/home/presentation/widgets/banner_overlay_content.dart';

import '../../../_helpers/widget_test_harness.dart';

const _bannerFixture = domain.Banner(
  id: 'b1',
  imageUrl: 'https://example.com/img.jpg',
  targetUrl: 'https://example.com',
  title: 'Galactic Storm',
  genre: 'Sci-Fi',
  rating: 8.4,
  badgeKind: domain.BadgeKind.nowShowing,
);

void main() {
  testWidgets('renders NOW SHOWING badge', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('NOW SHOWING'), findsOneWidget);
  });

  testWidgets('renders title text', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('Galactic Storm'), findsOneWidget);
  });

  testWidgets('renders genre and rating', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('Sci-Fi'), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
  });

  testWidgets('renders Book Tickets and Trailer CTA buttons', (tester) async {
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('Book Tickets'), findsOneWidget);
    expect(find.text('Trailer'), findsOneWidget);
  });

  testWidgets('onBook fires when Book Tickets tapped', (tester) async {
    var fired = false;
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () => fired = true,
        onTrailer: () {},
      ),
    );
    await tester.tap(find.text('Book Tickets'));
    expect(fired, isTrue);
  });

  testWidgets('onTrailer fires when Trailer tapped', (tester) async {
    var fired = false;
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: _bannerFixture,
        onBook: () {},
        onTrailer: () => fired = true,
      ),
    );
    await tester.tap(find.text('Trailer'));
    expect(fired, isTrue);
  });

  testWidgets('COMING SOON badge renders for comingSoon kind', (tester) async {
    const comingSoonBanner = domain.Banner(
      id: 'b2',
      imageUrl: 'https://example.com/img2.jpg',
      targetUrl: 'https://example.com',
      title: 'Future Horizons',
      badgeKind: domain.BadgeKind.comingSoon,
    );
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: comingSoonBanner,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('COMING SOON'), findsOneWidget);
  });

  testWidgets('no badge pill when badgeKind is null', (tester) async {
    const noBadgeBanner = domain.Banner(
      id: 'b3',
      imageUrl: 'https://example.com/img3.jpg',
      targetUrl: 'https://example.com',
      title: 'No Badge Movie',
    );
    await pumpInProviderScope(
      tester,
      BannerOverlayContent(
        banner: noBadgeBanner,
        onBook: () {},
        onTrailer: () {},
      ),
    );
    expect(find.text('NOW SHOWING'), findsNothing);
    expect(find.text('COMING SOON'), findsNothing);
  });
}
