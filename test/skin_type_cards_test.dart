import 'dart:io';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/screens/results_screen.dart';
import 'package:runrabbit_kiosk/presentation/widgets/skin_type_cards.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('test/fixtures/products_dummy.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  testWidgets(
      'SkinTypeScreen displays four base cards with round pictures and radio badges, and separate sensitive toggle card',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Start flow to reach SkinTypeScreen
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    expect(find.byType(SkinTypeCards), findsOneWidget);

    // Verify the 4 base skin types are present
    expect(find.text(s.skin('oily')), findsOneWidget);
    expect(find.text(s.skin('dry')), findsOneWidget);
    expect(find.text(s.skin('combination')), findsOneWidget);
    expect(find.text(s.skin('normal')), findsOneWidget);

    // Verify all 4 base skin type subtitles are present in English
    expect(find.text('Prone to shine throughout the day'), findsOneWidget);
    expect(find.text('Feels tight, rough or flaky'), findsOneWidget);
    expect(find.text('Oily T-zone, normal cheeks'), findsOneWidget);
    expect(find.text('Balanced moisture and comfort'), findsOneWidget);

    // Verify 4 circular cropped illustrated avatars exist for the base types
    expect(find.byType(ClipOval), findsNWidgets(4));

    // Verify the separate Sensitive toggle card exists with title, desc, hint, and switch
    expect(find.text(s.t('skinSensitiveTitle')), findsOneWidget);
    expect(find.text(s.t('skinSensitiveDesc')), findsOneWidget);
    expect(find.text(s.t('skinSensitiveHint')), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    // Tap combination card to pick base
    await tester.tap(find.text(s.skin('combination')));
    await tester.pumpAndSettle();

    // Tap Continue to advance to concerns
    expect(find.text(s.t('skinTitle')), findsOneWidget);
    await tester.tap(find.text(s.t('continue')));
    await tester.pumpAndSettle();

    expect(find.text(s.t('concernsTitle')), findsOneWidget);
  });

  testWidgets(
      'four base cards have equal heights, aligned avatars, and aligned radio buttons in landscape',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Switch to Sinhala
    await tester.tap(find.text('සිංහල'));
    await tester.pumpAndSettle();

    // Start flow
    const si = Strings('si');
    await tester.tap(find.text(si.t('touchStart')));
    await tester.pumpAndSettle();

    expect(find.byType(SkinTypeCards), findsOneWidget);

    // Verify 4 base avatars
    final avatarsFinder = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byType(ClipOval),
    );
    expect(avatarsFinder, findsNWidgets(4));

    final avatarFirstTop = tester.getRect(avatarsFinder.first).top;
    for (var i = 1; i < 4; i++) {
      expect(tester.getRect(avatarsFinder.at(i)).top, closeTo(avatarFirstTop, 0.5),
          reason: 'Avatar $i should align horizontally with avatar 0');
    }

    // Verify 4 radio indicators on the 4 base cards
    final radioFinders = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byWidgetPredicate((widget) {
        if (widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle) {
          final box = widget.decoration as BoxDecoration;
          // Radios have a border; AppIconBadge does not have a border
          return box.border != null;
        }
        return false;
      }),
    );
    expect(radioFinders, findsNWidgets(4));

    final radioFirstBottom = tester.getRect(radioFinders.first).bottom;
    for (var i = 1; i < 4; i++) {
      expect(tester.getRect(radioFinders.at(i)).bottom, closeTo(radioFirstBottom, 0.5),
          reason: 'Radio indicator $i should align horizontally with radio 0');
    }

    // Verify Sensitive toggle card in Sinhala
    expect(find.text(si.t('skinSensitiveTitle')), findsOneWidget);
    expect(find.text(si.t('skinSensitiveDesc')), findsOneWidget);
    expect(find.text(si.t('skinSensitiveHint')), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets(
      'four base cards arrange 2x2 in portrait with equal heights per row',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    expect(find.byType(SkinTypeCards), findsOneWidget);

    // 4 base avatars in 2x2 layout
    final avatars = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byType(ClipOval),
    );
    expect(avatars, findsNWidgets(4));

    // Card 0 and Card 1 are on Row 1 (same top offset)
    final r0Top = tester.getRect(avatars.at(0)).top;
    final r1Top = tester.getRect(avatars.at(1)).top;
    expect(r0Top, closeTo(r1Top, 0.5));

    // Card 2 and Card 3 are on Row 2 (same top offset, below Row 1)
    final r2Top = tester.getRect(avatars.at(2)).top;
    final r3Top = tester.getRect(avatars.at(3)).top;
    expect(r2Top, closeTo(r3Top, 0.5));
    expect(r2Top, greaterThan(r0Top));
  });

  testWidgets(
      'Sensitive alone does not enable continue, and Sensitive on + a base type passes both to engine',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(repository: _FakeRepo()));
    await tester.pumpAndSettle();

    // Start flow
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();

    // Find the Continue button
    final continueButton = find.widgetWithText(FilledButton, s.t('continue'));
    expect(continueButton, findsOneWidget);

    // Initially with no base type selected, Continue is disabled
    FilledButton btn = tester.widget<FilledButton>(continueButton);
    expect(btn.onPressed, isNull, reason: 'Continue should be disabled before any selection');

    // Tap the Sensitive toggle card (switching Sensitive ON alone)
    final sensitiveCard = find.text(s.t('skinSensitiveTitle'));
    expect(sensitiveCard, findsOneWidget);
    await tester.tap(sensitiveCard);
    await tester.pumpAndSettle();

    // Verify switch is ON
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    final switchWidget = tester.widget<Switch>(switchFinder);
    expect(switchWidget.value, isTrue);

    // Continue button MUST STILL BE DISABLED (Sensitive alone does not enable continue!)
    btn = tester.widget<FilledButton>(continueButton);
    expect(btn.onPressed, isNull,
        reason: 'Sensitive toggle alone must never enable continue without a base skin type');

    // Now pick a base skin type (e.g. combination)
    await tester.tap(find.text(s.skin('combination')));
    await tester.pumpAndSettle();

    // Continue button MUST NOW BE ENABLED!
    btn = tester.widget<FilledButton>(continueButton);
    expect(btn.onPressed, isNotNull,
        reason: 'Picking a base skin type should enable the continue button');

    // Tap Continue to advance to Concerns
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text(s.t('concernsTitle')), findsOneWidget);

    // Pick a concern (e.g. acne)
    await tester.tap(find.text(s.concern('acne')));
    await tester.pumpAndSettle();

    // Advance to Steps
    await tester.tap(find.text(s.t('next')));
    await tester.pumpAndSettle();
    expect(find.text(s.t('stepsTitle')), findsOneWidget);

    // Pick whole routine and advance to Results
    await tester.tap(find.text(s.t('wholeRoutine')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('seeResults')));
    await tester.pumpAndSettle();

    // Verify we arrived at ResultsScreen
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.text(s.t('resultsTitle')), findsOneWidget);
  });
}
