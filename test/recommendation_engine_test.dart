import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/options.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/domain/recommendation_engine.dart';

void main() {
  late List<Product> products;

  Product product({
    required String id,
    List<String> skinTypes = const [],
    List<String> avoidSkinTypes = const [],
    int price = 1000,
  }) =>
      Product(
        id: id,
        name: id,
        brand: 'Test',
        step: Step.cleanser,
        price: price,
        size: '100 ml',
        inStock: true,
        skinTypes: skinTypes,
        concerns: const {},
        keyIngredients: const [],
        avoidSkinTypes: avoidSkinTypes,
        note: const {},
        shelf: 'Test shelf',
        benefit: const {'en': 'Test benefit'},
      );

  setUpAll(() {
    products =
        parseProducts(File('assets/data/products.json').readAsStringSync());
  });

  RecommendationResult run(Set<Step> steps,
          {String skin = 'oily',
          Set<String> concerns = const {'acne', 'pores'}}) =>
      RecommendationEngine.recommend(
        products: products,
        skinType: skin,
        concerns: concerns,
        steps: steps,
      );

  test('dummy data loads', () => expect(products.length, 30));

  test('whole routine returns one product per step in routine order', () {
    final recs = run(routineSteps.toSet()).recommendations;
    expect(recs.map((r) => r.product.step), routineSteps);
    expect(recs.map((r) => r.product.id), ['c3', 't2', 's1', 'm1', 'u1']);
  });

  test('one selected step returns up to three products from that step only',
      () {
    final recs = run({Step.serum}).recommendations;
    expect(recs.length, lessThanOrEqualTo(3));
    expect(recs, isNotEmpty);
    expect(recs.every((r) => r.product.step == Step.serum), isTrue);
  });

  test('two to four selected steps return up to two products per step', () {
    final steps = {Step.cleanser, Step.serum, Step.sunscreen};
    final recs = run(steps).recommendations;
    for (final step in steps) {
      expect(recs.where((r) => r.product.step == step).length,
          lessThanOrEqualTo(2));
    }
    expect(recs.every((r) => steps.contains(r.product.step)), isTrue);
  });

  test('sold-out and incompatible products are never shown', () {
    final recs =
        run(routineSteps.toSet(), skin: 'sensitive', concerns: {'aging'})
            .recommendations;
    expect(recs.every((r) => r.product.inStock), isTrue);
    expect(recs.every((r) => !r.product.avoidSkinTypes.contains('sensitive')),
        isTrue);
  });

  test('ties are broken by lower price', () {
    final tied = [
      products.firstWhere((p) => p.id == 'c1'),
      products.firstWhere((p) => p.id == 'c2'),
    ];
    final recs = RecommendationEngine.recommend(
      products: tied,
      skinType: 'notlisted',
      concerns: const {},
      steps: {Step.cleanser},
    ).recommendations;
    expect(
        recs.first.product.price, lessThanOrEqualTo(recs.last.product.price));
  });

  test('a step with no eligible products is reported', () {
    final result = RecommendationEngine.recommend(
      products: products.where((p) => p.step != Step.toner).toList(),
      skinType: 'oily',
      concerns: const {'acne'},
      steps: {Step.toner},
    );
    expect(result.recommendations, isEmpty);
    expect(result.emptySteps, [Step.toner]);
  });

  test(
      'with sensitive=true and skinType oily, products avoiding sensitive are never returned',
      () {
    // Retinol serum s5 has skinTypes: [normal, oily, combination], avoidSkinTypes: [sensitive, dry]
    final nonSensRecs = RecommendationEngine.recommend(
      products: products,
      skinType: 'oily',
      concerns: {'aging'},
      steps: {Step.serum},
      sensitive: false,
    ).recommendations;
    expect(nonSensRecs.any((r) => r.product.id == 's5'), isTrue);

    final sensRecs = RecommendationEngine.recommend(
      products: products,
      skinType: 'oily',
      concerns: {'aging'},
      steps: {Step.serum},
      sensitive: true,
    ).recommendations;
    expect(sensRecs.any((r) => r.product.id == 's5'), isFalse);
    expect(
        sensRecs.every((r) => !r.product.avoidSkinTypes.contains('sensitive')),
        isTrue);
  });

  test(
      'a product listing sensitive in skinType gets higher skin term when sensitive=true',
      () {
    // Milk cleanser c2 has skinTypes: [dry, sensitive], avoidSkinTypes: []
    // When skinType is oily, base term is 0. With sensitive=true, sensitive term is 2.
    final recNotSens = RecommendationEngine.recommend(
      products: products.where((p) => p.id == 'c2').toList(),
      skinType: 'oily',
      concerns: const {},
      steps: {Step.cleanser},
      sensitive: false,
    ).recommendations.first;
    expect(recNotSens.score, 0);
    expect(recNotSens.skinMatch, isFalse);

    final recSens = RecommendationEngine.recommend(
      products: products.where((p) => p.id == 'c2').toList(),
      skinType: 'oily',
      concerns: const {},
      steps: {Step.cleanser},
      sensitive: true,
    ).recommendations.first;
    expect(recSens.score, 2);
    expect(recSens.skinMatch, isTrue);
  });

  test(
      'sensitive-only selection filters sensitive avoidances and scores sensitive matches',
      () {
    final result = RecommendationEngine.recommend(
      products: [
        product(id: 'sensitive-match', skinTypes: const ['sensitive']),
        product(id: 'avoid-sensitive', avoidSkinTypes: const ['sensitive']),
      ],
      skinType: null,
      sensitive: true,
      concerns: const {},
      steps: {Step.cleanser},
    );

    expect(
        result.recommendations.map((r) => r.product.id), ['sensitive-match']);
    expect(result.recommendations.single.score, 2);
  });

  test(
      'combined base and sensitive selection filters products avoided by either',
      () {
    final result = RecommendationEngine.recommend(
      products: [
        product(id: 'avoid-oily', avoidSkinTypes: const ['oily']),
        product(id: 'avoid-sensitive', avoidSkinTypes: const ['sensitive']),
        product(id: 'safe', skinTypes: const ['oily']),
      ],
      skinType: 'oily',
      sensitive: true,
      concerns: const {},
      steps: {Step.cleanser},
    );

    expect(result.recommendations.map((r) => r.product.id), ['safe']);
  });

  test('a non-sensitive dry selection keeps prior base-type behaviour', () {
    final result = RecommendationEngine.recommend(
      products: [
        product(id: 'dry-match', skinTypes: const ['dry']),
        product(id: 'sensitive-avoid', avoidSkinTypes: const ['sensitive']),
      ],
      skinType: 'dry',
      sensitive: false,
      concerns: const {},
      steps: {Step.cleanser},
    );

    expect(result.recommendations.map((r) => r.product.id),
        ['dry-match', 'sensitive-avoid']);
    expect(result.recommendations.first.score, 2);
  });

  test(
      'a product matching base and sensitive skin receives one skin score term',
      () {
    final result = RecommendationEngine.recommend(
      products: [
        product(id: 'both', skinTypes: const ['dry', 'sensitive'])
      ],
      skinType: 'dry',
      sensitive: true,
      concerns: const {},
      steps: {Step.cleanser},
    );

    expect(result.recommendations.single.score, 2);
  });

  test('5 concerns selected returns valid results respecting sold-out, avoid rules, tie-break and step limits', () {
    final fiveConcerns = {'acne', 'pores', 'pigmentation', 'aging', 'redness'};
    final result = run(routineSteps.toSet(), skin: 'oily', concerns: fiveConcerns);

    expect(result.recommendations, isNotEmpty);
    expect(result.recommendations.map((r) => r.product.step), routineSteps);

    for (final rec in result.recommendations) {
      // In-stock rule respected
      expect(rec.product.inStock, isTrue);
      // Incompatible avoidSkinTypes respected
      expect(rec.product.avoidSkinTypes.contains('oily'), isFalse);
      // Matched concerns are a subset of selected concerns
      for (final mc in rec.matchedConcerns) {
        expect(fiveConcerns.contains(mc), isTrue);
      }
    }

    // Step rules unchanged: 1 step test with 5 concerns returns at most 3 products
    final singleStepResult = run({Step.serum}, skin: 'dry', concerns: fiveConcerns);
    expect(singleStepResult.recommendations.length, lessThanOrEqualTo(3));

    // Multi-step (2-4 steps) returns up to 2 per step
    final multiStep = {Step.cleanser, Step.moisturiser};
    final multiStepResult = run(multiStep, skin: 'combination', concerns: fiveConcerns);
    for (final step in multiStep) {
      expect(
        multiStepResult.recommendations.where((r) => r.product.step == step).length,
        lessThanOrEqualTo(2),
      );
    }
  });
}
