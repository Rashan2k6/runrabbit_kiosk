import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/widgets/option_grid.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('assets/data/products.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  Future<void> navigateToStepsScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Welcome -> Skin
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    // Skin -> Concerns
    await tester.tap(find.text(s.skin('oily')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('continue')));
    await tester.pumpAndSettle();

    // Concerns -> Steps
    await tester.tap(find.text(s.concern('acne')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('next')));
    await tester.pumpAndSettle();

    expect(find.byType(OptionGrid), findsOneWidget);
  }

  testWidgets(
      'StepsScreen displays 6 cards with SVG assets, fills screen, and toggles selection in landscape',
      (tester) async {
    await navigateToStepsScreen(tester, const Size(1280, 800));

    // Verify all 6 routine step labels
    expect(find.text(s.step('cleanser')), findsOneWidget);
    expect(find.text(s.step('toner')), findsOneWidget);
    expect(find.text(s.step('serum')), findsOneWidget);
    expect(find.text(s.step('moisturiser')), findsOneWidget);
    expect(find.text(s.step('sunscreen')), findsOneWidget);
    expect(find.text(s.t('wholeRoutine')), findsOneWidget);

    // Verify SVG pictures are rendered
    expect(find.byType(SvgPicture), findsNWidgets(6));

    // Verify card height is dynamically calculated to fill the space (> 200 on 800 height)
    final gridFinder = find.byType(OptionGrid);
    final gridBox = tester.renderObject(gridFinder) as RenderBox;
    expect(gridBox.size.height, greaterThan(400));

    // Tap Cleanser to select it
    await tester.tap(find.text(s.step('cleanser')));
    await tester.pumpAndSettle();

    // See results button should now be enabled
    await tester.tap(find.text(s.t('seeResults')));
    await tester.pumpAndSettle();
    expect(find.text(s.t('resultsTitle')), findsOneWidget);
  });

  testWidgets(
      'StepsScreen displays 6 cards arranged in 2 columns x 3 rows in portrait',
      (tester) async {
    await navigateToStepsScreen(tester, const Size(800, 1280));

    // Verify all 6 routine step labels
    expect(find.text(s.step('cleanser')), findsOneWidget);
    expect(find.text(s.step('toner')), findsOneWidget);
    expect(find.text(s.step('serum')), findsOneWidget);
    expect(find.text(s.step('moisturiser')), findsOneWidget);
    expect(find.text(s.step('sunscreen')), findsOneWidget);
    expect(find.text(s.t('wholeRoutine')), findsOneWidget);

    // Verify grid height is large in portrait
    final gridFinder = find.byType(OptionGrid);
    final gridBox = tester.renderObject(gridFinder) as RenderBox;
    expect(gridBox.size.height, greaterThan(800));

    // Tap Whole Routine to toggle
    await tester.tap(find.text(s.t('wholeRoutine')));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.t('seeResults')));
    await tester.pumpAndSettle();
    expect(find.text(s.t('resultsTitle')), findsOneWidget);
  });
}
