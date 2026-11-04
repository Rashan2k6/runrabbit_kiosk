import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/domain/recommendation_engine.dart';
import 'package:runrabbit_kiosk/presentation/widgets/product_card.dart';

void main() {
  const s = Strings('en');

  Widget buildCard({
    required Product product,
    String? skinType = 'oily',
    bool sensitive = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: ProductCard(
              rec: Recommendation(
                product: product,
                matchedConcerns: const ['acne'],
                skinMatch: true,
                score: 10,
              ),
              skinType: skinType,
              sensitive: sensitive,
              s: s,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows image slot without crashing when asset file is missing',
      (tester) async {
    const product = Product(
      id: 'missing-asset-prod',
      name: 'Centella Ampoule',
      brand: 'Skin1004',
      step: Step.serum,
      price: 5990,
      size: '50ml',
      inStock: true,
      skinTypes: ['all'],
      concerns: {'acne': 1},
      keyIngredients: ['Centella'],
      avoidSkinTypes: [],
      image: 'assets/images/products/does_not_exist_404.webp',
    );

    await tester.pumpWidget(buildCard(product: product));
    await tester.pump();

    // No exception thrown
    expect(tester.takeException(), isNull);
    // Neutral placeholder icon should be visible
    expect(find.byIcon(Icons.spa_outlined), findsOneWidget);
  });

  testWidgets('hides shelf and size when empty', (tester) async {
    const product = Product(
      id: 'empty-shelf-size-prod',
      name: 'Clean Routine Cleanser',
      brand: 'Axis-Y',
      step: Step.cleanser,
      price: 4500,
      size: '',
      shelf: '',
      inStock: true,
      skinTypes: ['oily'],
      concerns: {'acne': 1},
      keyIngredients: ['Tea Tree'],
      avoidSkinTypes: [],
    );

    await tester.pumpWidget(buildCard(product: product));
    await tester.pumpAndSettle();

    // Shelf pin icon and text should not be present
    expect(find.byIcon(Icons.pin_drop_rounded), findsNothing);
    expect(find.textContaining('Shelf'), findsNothing);
    expect(find.textContaining('Find it at'), findsNothing);
  });

  testWidgets('shows shelf and size when non-empty', (tester) async {
    const product = Product(
      id: 'with-shelf-size-prod',
      name: 'Moisture Barrier Cream',
      brand: 'Purito',
      step: Step.moisturiser,
      price: 7200,
      size: '80ml',
      shelf: 'Shelf B2',
      inStock: true,
      skinTypes: ['dry'],
      concerns: {'dryness': 2},
      keyIngredients: ['Ceramides'],
      avoidSkinTypes: [],
    );

    await tester.pumpWidget(buildCard(product: product));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.pin_drop_rounded), findsOneWidget);
    expect(find.text('Shelf B2'), findsOneWidget);
    expect(find.text('80ml'), findsOneWidget);
  });

  testWidgets('shows "From Rs." when priceFrom is true', (tester) async {
    const multiVariantProd = Product(
      id: 'multi-size-prod',
      name: 'A-Clear Soothing Serum',
      brand: 'Neogen',
      step: Step.serum,
      price: 5990,
      priceFrom: true,
      size: '30ml / 50ml',
      inStock: true,
      skinTypes: ['all'],
      concerns: {'acne': 1},
      keyIngredients: ['Centella'],
      avoidSkinTypes: [],
    );

    await tester.pumpWidget(buildCard(product: multiVariantProd));
    await tester.pumpAndSettle();

    expect(find.text('From Rs. 5,990'), findsOneWidget);
  });

  testWidgets('shows standard "Rs." when priceFrom is false', (tester) async {
    const singlePriceProd = Product(
      id: 'single-price-prod',
      name: 'A-Clear Soothing Serum',
      brand: 'Neogen',
      step: Step.serum,
      price: 5990,
      priceFrom: false,
      size: '50ml',
      inStock: true,
      skinTypes: ['all'],
      concerns: {'acne': 1},
      keyIngredients: ['Centella'],
      avoidSkinTypes: [],
    );

    await tester.pumpWidget(buildCard(product: singlePriceProd));
    await tester.pumpAndSettle();

    expect(find.text('Rs. 5,990'), findsOneWidget);
  });
}
