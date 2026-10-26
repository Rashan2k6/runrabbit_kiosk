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
      parseProducts(File('assets/data/products.json').readAsStringSync());
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

    // Verify that shelf location, matched tag, and prices are rendered
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
}
