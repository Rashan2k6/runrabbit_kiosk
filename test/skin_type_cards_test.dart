import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/options.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/widgets/skin_type_cards.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('test/fixtures/products_dummy.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  testWidgets(
      'SkinTypeScreen displays five horizontal cards with round pictures and labels',
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

    // Verify all 5 skin types are present
    for (final skin in skinTypes) {
      expect(find.text(s.skin(skin.id)), findsOneWidget);
    }

    // Verify all 5 skin type subtitles are present in English
    expect(find.text('Prone to shine throughout the day'), findsOneWidget);
    expect(find.text('Feels tight, rough or flaky'), findsOneWidget);
    expect(find.text('Oily T-zone, normal cheeks'), findsOneWidget);
    expect(find.text(s.t('skinSensitiveHint')), findsOneWidget);
    expect(find.text('Balanced moisture and comfort'), findsOneWidget);

    // Verify circular cropped images exist
    expect(find.byType(ClipOval), findsNWidgets(5));

    // Tap one of the cards (e.g. combination) – no longer auto-advances
    await tester.tap(find.text(s.skin('combination')));
    await tester.pumpAndSettle();

    // Still on skin screen; must tap Continue to advance
    expect(find.text(s.t('skinTitle')), findsOneWidget);
    await tester.tap(find.text(s.t('continue')));
    await tester.pumpAndSettle();

    // Now on concerns screen
    expect(find.text(s.t('concernsTitle')), findsOneWidget);
  });

  testWidgets(
      'all five skin type cards have equal heights, aligned avatars, and aligned radio buttons in Sinhala',
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

    // Get the rects of the 5 cards
    final cardsFinder = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byType(InkWell),
    );
    expect(cardsFinder, findsNWidgets(6)); // 5 skin cards + 1 quiz helper card

    final cardRects = <Rect>[];
    for (var i = 0; i < 5; i++) {
      cardRects.add(tester.getRect(cardsFinder.at(i)));
    }

    // Verify all 5 cards have the exact same height and aligned top & bottom edges
    final expectedHeight = cardRects.first.height;
    final expectedTop = cardRects.first.top;
    final expectedBottom = cardRects.first.bottom;

    for (var i = 1; i < cardRects.length; i++) {
      expect(cardRects[i].height, closeTo(expectedHeight, 0.5),
          reason: 'Card $i height should match card 0');
      expect(cardRects[i].top, closeTo(expectedTop, 0.5),
          reason: 'Card $i top edge should align with card 0');
      expect(cardRects[i].bottom, closeTo(expectedBottom, 0.5),
          reason: 'Card $i bottom edge should align with card 0');
    }

    // Verify avatars are horizontally aligned along the same vertical position
    final avatarsFinder = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byType(ClipOval),
    );
    expect(avatarsFinder, findsNWidgets(5));
    final avatarFirstTop = tester.getRect(avatarsFinder.first).top;
    for (var i = 1; i < 5; i++) {
      expect(tester.getRect(avatarsFinder.at(i)).top, closeTo(avatarFirstTop, 0.5),
          reason: 'Avatar $i should align horizontally with avatar 0');
    }

    // Verify radio indicators are aligned along the same bottom line
    final radioFinders = find.descendant(
      of: find.byType(SkinTypeCards),
      matching: find.byWidgetPredicate((widget) {
        if (widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle) {
          // Radios have circle shape and check icon or null child
          return widget.child is Icon || widget.child == null;
        }
        return false;
      }),
    );
    expect(radioFinders, findsNWidgets(5));
    final radioFirstBottom = tester.getRect(radioFinders.first).bottom;
    for (var i = 1; i < 5; i++) {
      expect(tester.getRect(radioFinders.at(i)).bottom, closeTo(radioFirstBottom, 0.5),
          reason: 'Radio indicator $i should align horizontally with radio 0');
    }

    // Verify all 5 subtitles are present in Sinhala
    expect(find.text('දවස පුරා තෙල් ගතියක් ඇති වේ'), findsOneWidget);
    expect(find.text('තද බවක්, රළු බවක් හෝ පොතු ගැලවීමක් දැනේ'), findsOneWidget);
    expect(find.text('T-කලාපය තෙල් සහිතයි, කම්මුල් සාමාන්‍යයි'), findsOneWidget);
    expect(find.text(si.t('skinSensitiveHint')), findsOneWidget);
    expect(find.text('සමබර තෙතමනය සහ සුවපහසුව'), findsOneWidget);
  });
}
