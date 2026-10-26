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
      parseProducts(File('assets/data/products.json').readAsStringSync());
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
}
