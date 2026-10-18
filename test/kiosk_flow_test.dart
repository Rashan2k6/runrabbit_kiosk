import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/product.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('assets/data/products.json').readAsStringSync());
}

void main() {
  const s = Strings('en');

  // Phone-ish, small tablet, 10" tablet, 13" tablet, each in both orientations.
  const sizes = <Size>[
    Size(480, 800),
    Size(800, 480),
    Size(600, 960),
    Size(960, 600),
    Size(800, 1280),
    Size(1280, 800),
    Size(1600, 2560),
    Size(2560, 1600),
  ];

  for (final size in sizes) {
    testWidgets('full flow works at ${size.width}x${size.height}',
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

      await tester.tap(find.text(s.concern('acne')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('next')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(s.t('wholeRoutine')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.t('seeResults')));
      await tester.pumpAndSettle();

      expect(find.text(s.t('resultsTitle')), findsOneWidget);
      expect(tester.takeException(), isNull); // no layout overflow
    });
  }

  testWidgets('returns to the welcome screen after the idle timeout',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KioskApp(
      repository: _FakeRepo(),
      idleTimeout: const Duration(seconds: 5),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.t('touchStart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.skin('dry')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text(s.t('touchStart')), findsOneWidget);
  });
}
