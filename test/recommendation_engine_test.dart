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
        parseProducts(File('test/fixtures/products_dummy.json').readAsStringSync());
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

  test('excludes pimple patches, nose packs, and face masks from routine suggestions', () {
    final testProds = [
      product(id: 'regular-serum', price: 2000),
      const Product(
        id: 'patch-1',
        name: 'Spot Care Pimple Patch',
        brand: 'TestBrand',
        step: Step.serum,
        price: 800,
        size: '24 patches',
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 3},
        keyIngredients: ['Hydrocolloid'],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'mask-1',
        name: 'Hydrating Face Mask Sheet',
        brand: 'TestBrand',
        step: Step.toner,
        price: 500,
        size: '1 sheet',
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 3},
        keyIngredients: ['Ceramides'],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'nose-pack-1',
        name: 'Pore Nose Pack',
        brand: 'TestBrand',
        step: Step.cleanser,
        price: 600,
        size: '1 pack',
        inStock: true,
        skinTypes: ['all'],
        concerns: {'pores': 3},
        keyIngredients: ['Charcoal'],
        avoidSkinTypes: [],
      ),
    ];

    final result = RecommendationEngine.recommend(
      products: testProds,
      skinType: 'oily',
      concerns: {'acne', 'pores'},
      steps: {Step.cleanser, Step.toner, Step.serum},
    );

    expect(result.recommendations.any((r) => r.product.id == 'patch-1'), isFalse);
    expect(result.recommendations.any((r) => r.product.id == 'mask-1'), isFalse);
    expect(result.recommendations.any((r) => r.product.id == 'nose-pack-1'), isFalse);
  });

  test('a brand tab list never contains a brand that cannot fill the required steps (LAPCOS with a cleanser step selected is excluded)', () {
    final prods = [
      // LAPCOS has only mask
      const Product(
        id: 'lapcos-mask',
        name: 'LAPCOS Pearl Mask',
        brand: 'LAPCOS',
        step: Step.mask,
        price: 900,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'dullness': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      // Brand X has cleanser and toner
      const Product(
        id: 'bx-cleanse',
        name: 'BX Cleanser',
        brand: 'Brand X',
        step: Step.cleanser,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'bx-toner',
        name: 'BX Toner',
        brand: 'Brand X',
        step: Step.toner,
        price: 2500,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
    ];

    // When cleanser and toner are selected, LAPCOS cannot fill the steps and must be excluded
    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: prods,
      skinType: 'oily',
      concerns: {'acne'},
      steps: {Step.cleanser, Step.toner},
    );

    expect(brandRoutines.any((b) => b.brand.toLowerCase() == 'lapcos'), isFalse);
    expect(brandRoutines.any((b) => b.brand == 'Brand X'), isTrue);
  });

  test('a brand routine contains only products of that brand', () {
    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: products,
      skinType: 'oily',
      concerns: {'acne', 'pores'},
      steps: routineSteps.toSet(),
    );

    for (final routine in brandRoutines) {
      expect(
        routine.items.every((item) =>
            item.product.brand.toLowerCase() == routine.brand.toLowerCase()),
        isTrue,
      );
    }
  });

  test('no more than 2 brand routines are returned, ranked by totalScore', () {
    final prods = [
      for (final b in ['Brand1', 'Brand2', 'Brand3', 'Brand4']) ...[
        Product(
          id: '$b-c',
          name: '$b Cleanser',
          brand: b,
          step: Step.cleanser,
          price: 1500,
          inStock: true,
          skinTypes: ['all'],
          concerns: {'acne': b == 'Brand1' ? 3 : (b == 'Brand2' ? 2 : 1)},
          keyIngredients: const [],
          avoidSkinTypes: const [],
        ),
        Product(
          id: '$b-t',
          name: '$b Toner',
          brand: b,
          step: Step.toner,
          price: 1500,
          inStock: true,
          skinTypes: ['all'],
          concerns: {'acne': b == 'Brand1' ? 3 : (b == 'Brand2' ? 2 : 1)},
          keyIngredients: const [],
          avoidSkinTypes: const [],
        ),
      ],
    ];

    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: prods,
      skinType: 'oily',
      concerns: {'acne'},
      steps: {Step.cleanser, Step.toner},
    );

    expect(brandRoutines.length, lessThanOrEqualTo(2));
    expect(brandRoutines.length, 2);
    expect(brandRoutines.first.totalScore,
        greaterThanOrEqualTo(brandRoutines.last.totalScore));
    expect(brandRoutines[0].brand, 'Brand1');
    expect(brandRoutines[1].brand, 'Brand2');
  });

  test(
      'sold-out and avoid-skin-type products are never in a brand routine (test with sensitive = true)',
      () {
    final prods = [
      // Sold out product
      const Product(
        id: 's-out',
        name: 'Brand Z Out of Stock Cleanser',
        brand: 'Brand Z',
        step: Step.cleanser,
        price: 2000,
        inStock: false,
        skinTypes: ['all'],
        concerns: {'acne': 3},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      // In stock but avoids sensitive
      const Product(
        id: 's-avoid',
        name: 'Brand Z Harsh Cleanser',
        brand: 'Brand Z',
        step: Step.cleanser,
        price: 1800,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 3},
        keyIngredients: [],
        avoidSkinTypes: ['sensitive'],
      ),
      // Gentle cleanser
      const Product(
        id: 's-gentle',
        name: 'Brand Z Gentle Cleanser',
        brand: 'Brand Z',
        step: Step.cleanser,
        price: 2200,
        inStock: true,
        skinTypes: ['sensitive'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 's-toner',
        name: 'Brand Z Gentle Toner',
        brand: 'Brand Z',
        step: Step.toner,
        price: 2500,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
    ];

    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: prods,
      skinType: 'oily',
      concerns: {'acne'},
      steps: {Step.cleanser, Step.toner},
      sensitive: true,
    );

    expect(brandRoutines, isNotEmpty);
    final zRoutine = brandRoutines.firstWhere((b) => b.brand == 'Brand Z');
    expect(zRoutine.items.any((i) => !i.product.inStock), isFalse);
    expect(
        zRoutine.items
            .any((i) => i.product.avoidSkinTypes.contains('sensitive')),
        isFalse);
    expect(zRoutine.items.any((i) => i.product.id == 's-gentle'), isTrue);
  });

  test(
      'a missing step appears in missingSteps and no foreign-brand product is added',
      () {
    final prods = [
      // Brand Y has 4 of 5 routine steps (missing sunscreen)
      const Product(
        id: 'y-c',
        name: 'Brand Y Cleanser',
        brand: 'Brand Y',
        step: Step.cleanser,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'y-t',
        name: 'Brand Y Toner',
        brand: 'Brand Y',
        step: Step.toner,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'y-s',
        name: 'Brand Y Serum',
        brand: 'Brand Y',
        step: Step.serum,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      const Product(
        id: 'y-m',
        name: 'Brand Y Moisturiser',
        brand: 'Brand Y',
        step: Step.moisturiser,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
      // Foreign brand with sunscreen
      const Product(
        id: 'other-sun',
        name: 'Other Brand Sunscreen',
        brand: 'Other Brand',
        step: Step.sunscreen,
        price: 2000,
        inStock: true,
        skinTypes: ['all'],
        concerns: {'acne': 2},
        keyIngredients: [],
        avoidSkinTypes: [],
      ),
    ];

    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: prods,
      skinType: 'oily',
      concerns: {'acne'},
      steps: routineSteps.toSet(),
    );

    final yRoutine = brandRoutines.firstWhere((b) => b.brand == 'Brand Y');
    expect(yRoutine.missingSteps, contains(Step.sunscreen));
    expect(yRoutine.items.any((i) => i.product.step == Step.sunscreen), isFalse);
    expect(yRoutine.items.every((i) => i.product.brand == 'Brand Y'), isTrue);
  });
}
