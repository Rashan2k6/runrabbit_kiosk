import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/options.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/widgets/concern_cards.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('assets/data/products.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  testWidgets(
      'ConcernsScreen displays eight cards matching skin type aesthetic',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Start flow to reach SkinTypeScreen
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    // Pick a skin type to reach ConcernsScreen (tap no longer auto-advances)
    await tester.tap(find.text(s.skin('oily')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('continue')));
    await tester.pumpAndSettle();

    expect(find.byType(ConcernCards), findsOneWidget);

    // Verify all 8 skin concerns are present in the scrollable view
    for (final concern in concernOptions) {
      await tester.scrollUntilVisible(
        find.text(s.concern(concern.id)),
        60.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(s.concern(concern.id)), findsOneWidget);
    }

    // Scroll back to the top
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await tester.pumpAndSettle();

    // Next button should be disabled when 0 concerns are chosen
    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, s.t('next')),
    );
    expect(nextButton.onPressed, isNull);

    // Tap 1st concern (acne)
    await tester.tap(find.text(s.concern('acne')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 of $maxConcerns chosen'), findsOneWidget);

    // Tap 2nd concern (pores)
    await tester.tap(find.text(s.concern('pores')));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 of $maxConcerns chosen'), findsOneWidget);

    // Tap 3rd concern (pigmentation)
    await tester.tap(find.text(s.concern('pigmentation')));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 of $maxConcerns chosen'), findsOneWidget);

    // Tap 4th concern (dullness)
    await tester.tap(find.text(s.concern('dullness')));
    await tester.pumpAndSettle();
    expect(find.textContaining('4 of $maxConcerns chosen'), findsOneWidget);

    // Tap 5th concern (aging)
    await tester.scrollUntilVisible(
      find.text(s.concern('aging')),
      60.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(s.concern('aging')));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 of $maxConcerns chosen'), findsOneWidget);

    // Tapping a 6th concern (redness) should be ignored because max is 5
    await tester.scrollUntilVisible(
      find.text(s.concern('redness')),
      60.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(s.concern('redness')));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 of $maxConcerns chosen'), findsOneWidget);

    // Deselect pores (scroll back to top)
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.concern('pores')));
    await tester.pumpAndSettle();
    expect(find.textContaining('4 of $maxConcerns chosen'), findsOneWidget);

    // Next button should now be enabled
    final enabledNext = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, s.t('next')),
    );
    expect(enabledNext.onPressed, isNotNull);

    // Tap Next to reach routine steps.
    await tester.tap(find.text(s.t('next')));
    await tester.pumpAndSettle();

    expect(find.text(s.t('stepsTitle')), findsOneWidget);
  });
}
