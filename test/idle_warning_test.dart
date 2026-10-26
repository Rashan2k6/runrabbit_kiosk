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

  group('Idle warning and reset behavior', () {
    testWidgets(
        'short durations: warning not visible before warnAfter, appears at warnAfter, '
        'countdown decreases, tapping button hides it and preserves choices, '
        'subsequent idle period triggers warning again, doing nothing resets after warnFor',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // warnAfter = 5s, warnFor = 3s
      await tester.pumpWidget(KioskApp(
        repository: _FakeRepo(),
        standardWarnAfter: const Duration(seconds: 5),
        standardWarnFor: const Duration(seconds: 3),
      ));
      await tester.pumpAndSettle();

      // Start flow
      await tester.tap(find.text(s.t('touchStart')));
      await tester.pumpAndSettle();

      // On skin screen, choose dry
      await tester.tap(find.text(s.skin('dry')));
      await tester.pumpAndSettle();

      // Advance 4s: warning is NOT visible yet
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(s.t('idleWarningTitle')), findsNothing);

      // Advance 1s more (total 5s = warnAfter): warning appears
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(s.t('idleWarningTitle')), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // initial 3 seconds
      expect(find.text(s.t('idleWarningStay')), findsOneWidget);

      // After 1 second, countdown decreases to 2
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);

      // Tap "I'm still here" button
      await tester.tap(find.text(s.t('idleWarningStay')));
      await tester.pumpAndSettle();

      // Warning disappears, choices remain intact (still on skin screen with dry selected)
      expect(find.text(s.t('idleWarningTitle')), findsNothing);
      expect(find.text(s.t('skinTitle')), findsOneWidget);

      // A later full idle period of 5s shows the warning again
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text(s.t('idleWarningTitle')), findsOneWidget);

      // Doing nothing returns to welcome screen after warnFor (3s)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text(s.t('touchStart')), findsOneWidget);
      expect(find.text(s.t('idleWarningTitle')), findsNothing);
    });

    testWidgets('no warning and no reset on the welcome (idle) screen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(KioskApp(
        repository: _FakeRepo(),
        standardWarnAfter: const Duration(seconds: 5),
        standardWarnFor: const Duration(seconds: 3),
      ));
      await tester.pumpAndSettle();

      // Stays on welcome screen even after long time
      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();

      expect(find.text(s.t('touchStart')), findsOneWidget);
      expect(find.text(s.t('idleWarningTitle')), findsNothing);
    });

    testWidgets('Results screen uses its longer timing (resultsWarnAfter and resultsWarnFor)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // standardWarnAfter: 4s, resultsWarnAfter: 8s, resultsWarnFor: 4s
      await tester.pumpWidget(KioskApp(
        repository: _FakeRepo(),
        standardWarnAfter: const Duration(seconds: 4),
        standardWarnFor: const Duration(seconds: 2),
        resultsWarnAfter: const Duration(seconds: 8),
        resultsWarnFor: const Duration(seconds: 4),
      ));
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

      expect(find.text(s.t('resultsTitle')), findsOneWidget);

      // On Results screen, after standard 4s: warning should NOT appear
      await tester.pump(const Duration(seconds: 5));
      expect(find.text(s.t('idleWarningTitle')), findsNothing);

      // After total 8s: warning appears
      await tester.pump(const Duration(seconds: 3));
      expect(find.text(s.t('idleWarningTitle')), findsOneWidget);
      expect(find.text('4'), findsOneWidget); // resultsWarnFor is 4s

      // After 4s of warnFor: resets to welcome screen
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text(s.t('touchStart')), findsOneWidget);
    });

    testWidgets('touching the overlay does not trigger the control underneath',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(KioskApp(
        repository: _FakeRepo(),
        standardWarnAfter: const Duration(seconds: 4),
        standardWarnFor: const Duration(seconds: 4),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(s.t('touchStart')));
      await tester.pumpAndSettle();

      // On skin screen, don't tap Continue yet
      expect(find.text(s.t('skinTitle')), findsOneWidget);

      // Wait for warning
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(find.text(s.t('idleWarningTitle')), findsOneWidget);

      // Tap on the dark scrim area (e.g. top-left corner (20, 20) where language toggle or header sits)
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // Warning is dismissed
      expect(find.text(s.t('idleWarningTitle')), findsNothing);
      // Still on skin screen (not navigated or language switched)
      expect(find.text(s.t('skinTitle')), findsOneWidget);
    });
  });
}
