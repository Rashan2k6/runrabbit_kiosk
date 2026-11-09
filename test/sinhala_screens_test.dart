import 'dart:io';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/brand.dart';
import 'package:runrabbit_kiosk/app/kiosk_app.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/app/theme.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/screens/idle_screen.dart';
import 'package:runrabbit_kiosk/presentation/screens/option_screens.dart';
import 'package:runrabbit_kiosk/presentation/screens/quiz_screens.dart';
import 'package:runrabbit_kiosk/presentation/screens/results_screen.dart';
import 'package:runrabbit_kiosk/presentation/state/flow_state.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> loadAll() async =>
      parseProducts(File('test/fixtures/products_dummy.json').readAsStringSync());
}

void main() {
  group('Sinhala string keys and fallbacks', () {
    test('every English key has a Sinhala entry or a documented fallback', () {
      final missingKeys = <String>[];

      for (final key in Strings.en.keys) {
        final hasSinhala =
            Strings.si.containsKey(key) && Strings.si[key]!.trim().isNotEmpty;
        final hasDocumentedFallback = Strings.documentedFallbacks.contains(key);

        if (!hasSinhala && !hasDocumentedFallback) {
          missingKeys.add(key);
        }
      }

      expect(
        missingKeys,
        isEmpty,
        reason:
            'These keys have neither a Sinhala translation nor a documented fallback: $missingKeys',
      );
    });

    test('documented fallbacks return valid English text when not translated', () {
      const s = Strings('si');
      for (final key in Strings.documentedFallbacks) {
        if (!Strings.si.containsKey(key)) {
          expect(s.t(key), equals(Strings.en[key]),
              reason: '$key should fall back to English text');
        }
      }
    });

    test('parameterized placeholders match between English and Sinhala', () {
      final paramRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

      for (final entry in Strings.en.entries) {
        final key = entry.key;
        final enText = entry.value;
        final siText = Strings.si[key];

        if (siText == null) continue;

        final enParams =
            paramRegex.allMatches(enText).map((m) => m.group(1)!).toSet();
        final siParams =
            paramRegex.allMatches(siText).map((m) => m.group(1)!).toSet();

        expect(
          siParams,
          equals(enParams),
          reason: 'Key "$key" parameter placeholder mismatch: en=$enParams vs si=$siParams',
        );
      }
    });
  });

  group('Sinhala font and typography theme', () {
    test('Noto Sinhala font and line height are applied only for Sinhala', () {
      final siTheme = buildTheme('si');
      final siBtnStyle = siTheme.filledButtonTheme.style?.textStyle?.resolve({});
      expect(siBtnStyle?.fontFamily, equals('NotoSansSinhala'));
      expect(siBtnStyle?.height, closeTo(1.45, 0.01));
      expect(siTheme.textTheme.bodyLarge?.fontFamily, equals('NotoSansSinhala'));
      expect(siTheme.textTheme.bodyLarge?.height, closeTo(1.45, 0.01));
      expect(siTheme.textTheme.titleLarge?.fontFamily, equals('NotoSansSinhala'));
      expect(siTheme.textTheme.titleLarge?.height, closeTo(1.45, 0.01));

      final enTheme = buildTheme('en');
      final enBtnStyle = enTheme.filledButtonTheme.style?.textStyle?.resolve({});
      expect(enBtnStyle?.fontFamily, isNull);
      expect(enBtnStyle?.height, isNull);
      expect(enTheme.textTheme.bodyLarge?.height, isNull);
      expect(enTheme.textTheme.titleLarge?.height, isNull);
    });
  });

  const targetSizes = <Size>[
    Size(480, 800),
    Size(800, 480),
    Size(800, 1280),
    Size(1280, 800),
  ];

  late List<Product> products;

  setUpAll(() async {
    products = await _FakeRepo().loadAll();
  });

  Widget buildScreenWrapper(Widget child, {String lang = 'si'}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(lang),
      builder: (context, c) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: c!,
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }

  for (final size in targetSizes) {
    group('Sinhala screens at ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('IdleScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(IdleScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('SkinTypeScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.start();
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(SkinTypeScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('QuizQuestionScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.startQuiz();
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(QuizQuestionScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('QuizConcernScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.stage = Stage.quizConcern;
        flow.quizBaseResult = 'combination';
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(QuizConcernScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('QuizResultScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.stage = Stage.quizResult;
        flow.skinType = 'combination';
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(QuizResultScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('ConcernsScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.stage = Stage.concerns;
        flow.skinType = 'combination';
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(ConcernsScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('StepsScreen does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.stage = Stage.steps;
        flow.skinType = 'combination';
        flow.concerns.add('acne');
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(StepsScreen(flow: flow, s: s)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('ResultsScreen (best match & brand routine) does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final flow = KioskFlow(initialLang: 'si');
        flow.stage = Stage.results;
        flow.skinType = 'combination';
        flow.concerns.add('acne');
        flow.steps.addAll([Step.cleanser, Step.toner, Step.moisturiser, Step.sunscreen]);
        const s = Strings('si');
        await tester.pumpWidget(buildScreenWrapper(ResultsScreen(
          flow: flow,
          s: s,
          products: products,
        )));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Tap a brand tab if available
        final brandTabFinder = find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(Brand.pillRadius));
        if (brandTabFinder.evaluate().isNotEmpty) {
          await tester.tap(brandTabFinder.first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('Idle warning overlay does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        const s = Strings('si');
        await tester.pumpWidget(KioskApp(
          repository: _FakeRepo(),
          initialLang: 'si',
          standardWarnAfter: const Duration(seconds: 1),
          standardWarnFor: const Duration(seconds: 10),
        ));
        await tester.pumpAndSettle();

        // Start flow to skin screen
        await tester.tap(find.text(s.t('touchStart')));
        await tester.pumpAndSettle();

        // Advance 1s to trigger idle warning overlay
        await tester.pump(const Duration(seconds: 1));

        expect(find.text(s.t('idleWarningTitle')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Full flow end-to-end in KioskApp does not overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        const s = Strings('si');
        final app = KioskApp(
          repository: _FakeRepo(),
          initialLang: 'si',
        );

        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        // 1. Idle -> Skin
        await tester.tap(find.text(s.t('touchStart')));
        await tester.pumpAndSettle();

        // 2. Skin -> Concerns
        await tester.tap(find.text(s.skin('oily')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(s.t('continue')));
        await tester.pumpAndSettle();

        // 3. Concerns -> Steps
        await tester.tap(find.text(s.concern('acne')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(s.t('next')));
        await tester.pumpAndSettle();

        // 4. Steps -> Results
        await tester.tap(find.text(s.t('wholeRoutine')), warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.tap(find.text(s.t('seeResults')), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  }
}
