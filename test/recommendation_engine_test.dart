import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/data/product_repository.dart';
import 'package:runrabbit_kiosk/domain/options.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/domain/recommendation_engine.dart';

void main() {
  late List<Product> products;

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

  test('with sensitive=true and skinType oily, products avoiding sensitive are never returned', () {
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
    expect(sensRecs.every((r) => !r.product.avoidSkinTypes.contains('sensitive')), isTrue);
  });

  test('a product listing sensitive in skinType gets higher skin term when sensitive=true', () {
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
}
