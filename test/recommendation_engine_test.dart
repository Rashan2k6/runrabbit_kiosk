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
}
