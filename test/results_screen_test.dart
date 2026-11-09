import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/widgets/product_card.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('test/fixtures/products_dummy.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  testWidgets(
      'ResultsScreen displays curated routine products neatly with packaging and shelf info',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Start flow
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    // Pick skin type (oily) – card tap no longer auto-advances
    await tester.tap(find.text(s.skin('oily')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('continue')));
    await tester.pumpAndSettle();

    // Pick concern (acne)
    await tester.tap(find.text(s.concern('acne')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('next')));
    await tester.pumpAndSettle();

    // Pick a whole routine.
    await tester.tap(find.text(s.t('wholeRoutine')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('seeResults')));
    await tester.pumpAndSettle();

    // Verify Results screen is displayed
    expect(find.text(s.t('resultsTitle')), findsOneWidget);

    // Verify product cards exist
    expect(find.byType(ProductCard), findsWidgets);

    // Verify that at least 3 routine steps are recommended
    final cards =
        tester.widgetList<ProductCard>(find.byType(ProductCard)).toList();
    expect(cards.length, greaterThanOrEqualTo(3));

    // Verify that matched tag, step, and prices are rendered, while shelf is not shown
    expect(find.text('MATCHED'), findsWidgets);
    expect(find.textContaining('STEP 1'), findsOneWidget);
    expect(find.textContaining('Shelf'), findsWidgets);

    // Each responsive product card should render with a usable size.
    final cardRenderObjects =
        tester.renderObjectList<RenderBox>(find.byType(ProductCard)).toList();
    expect(cardRenderObjects.length, greaterThanOrEqualTo(3));
    for (final box in cardRenderObjects) {
      expect(box.size.width, greaterThan(0));
      expect(box.size.height, greaterThan(0));
    }

    // Routine products share rows on a wide kiosk instead of consuming one
    // full-width section per routine step.
    final cardPositions =
        cardRenderObjects.map((box) => box.localToGlobal(Offset.zero)).toList();
    expect(cardPositions[0].dy, closeTo(cardPositions[1].dy, 0.1));
    expect(cardPositions[1].dy, closeTo(cardPositions[2].dy, 0.1));
  });

  for (final size in const [
    Size(480, 800),
    Size(800, 480),
    Size(600, 960),
    Size(960, 600),
    Size(800, 1280),
    Size(1280, 800),
    Size(1600, 2560),
    Size(2560, 1600),
  ]) {
    testWidgets(
        'results screen shows tabs, tapping a brand tab changes products and total with no overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(s.t('touchStart')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.skin('oily')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.concern('acne')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('next')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('wholeRoutine')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('seeResults')));
      await tester.pumpAndSettle();

      // Results title should be displayed
      expect(find.text(s.t('resultsTitle')), findsOneWidget);

      // Best match tab should be visible
      expect(find.text(s.t('bestMatch')), findsOneWidget);

      // Check for presence of routine total
      expect(find.textContaining(s.t('routineTotal')), findsWidgets);

      // Get initial Best Match products
      final initialCards =
          tester.widgetList<ProductCard>(find.byType(ProductCard)).toList();
      final initialProductIds =
          initialCards.map((c) => c.rec.product.id).toList();

      // Find brand tabs (e.g. Lumea, Kiri, Verdant)
      final brandTabFinder = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data == 'Lumea' ||
              widget.data == 'Kiri' ||
              widget.data == 'Verdant'));

      if (brandTabFinder.evaluate().isNotEmpty) {
        final firstBrandText = tester.widget<Text>(brandTabFinder.first);
        final brandName = firstBrandText.data!;

        // Tap the brand tab
        await tester.tap(find.text(brandName));
        await tester.pumpAndSettle();

        // Products should now all belong to this brand
        final brandCards =
            tester.widgetList<ProductCard>(find.byType(ProductCard)).toList();
        expect(brandCards, isNotEmpty);
        expect(
          brandCards.every((c) =>
              c.rec.product.brand.toLowerCase() == brandName.toLowerCase()),
          isTrue,
        );

        // Tap back to Best match
        await tester.tap(find.text(s.t('bestMatch')));
        await tester.pumpAndSettle();

        final restoredCards =
            tester.widgetList<ProductCard>(find.byType(ProductCard)).toList();
        final restoredProductIds =
            restoredCards.map((c) => c.rec.product.id).toList();
        expect(restoredProductIds, equals(initialProductIds));
      }

      // No overflow or exception thrown
      expect(tester.takeException(), isNull);
    });
  }
}
