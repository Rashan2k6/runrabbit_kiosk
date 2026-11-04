/// Routine steps, in the order they are shown to the customer.
enum Step { cleanser, toner, serum, moisturiser, sunscreen, mask }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.step,
    required this.price,
    this.priceFrom = false,
    this.size = '',
    required this.inStock,
    required this.skinTypes,
    required this.concerns,
    required this.keyIngredients,
    required this.avoidSkinTypes,
    this.note = const {},
    this.shelf = '',
    this.benefit = const {},
    this.howTo = const {},
    this.ingredients = '',
    this.image = '',
  });

  final String id;
  final String name;
  final String brand;
  final Step step;

  /// Price in LKR.
  final int price;

  /// True when the product has several sizes/prices and price is lowest.
  final bool priceFrom;
  final String size;
  final bool inStock;

  /// Skin type ids this product suits. May contain `all`.
  final List<String> skinTypes;

  /// Concern id -> how strongly it helps (1 to 3).
  final Map<String, int> concerns;
  final List<String> keyIngredients;

  /// Skin types that should NOT be shown this product.
  final List<String> avoidSkinTypes;

  /// Caution text by language code (`en`, `si`). Empty when none.
  final Map<String, String> note;
  final String shelf;

  /// One line benefit by language code.
  final Map<String, String> benefit;

  /// How to use instructions by language code (`en`, `si`).
  final Map<String, String> howTo;

  /// Full ingredients list.
  final String ingredients;

  /// Asset path for product image.
  final String image;

  String benefitFor(String lang) => benefit[lang] ?? benefit['en'] ?? '';
  String howToFor(String lang) => howTo[lang] ?? howTo['en'] ?? '';
  String? noteFor(String lang) {
    final text = note[lang] ?? note['en'];
    return (text == null || text.isEmpty) ? null : text;
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    Map<String, String> strings(Object? v) => v == null
        ? const {}
        : (v as Map).map((k, val) => MapEntry(k.toString(), val.toString()));

    return Product(
      id: (j['id'] as String?) ?? '',
      name: (j['name'] as String?) ?? '',
      brand: (j['brand'] as String?) ?? '',
      step: j['step'] is String
          ? Step.values.firstWhere(
              (s) => s.name == j['step'],
              orElse: () => Step.cleanser,
            )
          : Step.cleanser,
      price: (j['price'] as num?)?.toInt() ?? 0,
      priceFrom: (j['priceFrom'] as bool?) ?? false,
      size: (j['size'] as String?) ?? '',
      inStock: (j['inStock'] as bool?) ?? true,
      skinTypes: (j['skinTypes'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      concerns: j['concerns'] == null
          ? const {}
          : (j['concerns'] as Map).map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            ),
      keyIngredients: (j['keyIngredients'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      avoidSkinTypes: (j['avoidSkinTypes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      note: strings(j['note']),
      shelf: (j['shelf'] as String?) ?? '',
      benefit: strings(j['benefit']),
      howTo: strings(j['howTo']),
      ingredients: (j['ingredients'] as String?) ?? '',
      image: (j['image'] as String?) ?? '',
    );
  }
}
