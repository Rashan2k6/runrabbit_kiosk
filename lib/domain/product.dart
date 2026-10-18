/// Routine steps, in the order they are shown to the customer.
enum Step { cleanser, toner, serum, moisturiser, sunscreen, mask }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.step,
    required this.price,
    required this.size,
    required this.inStock,
    required this.skinTypes,
    required this.concerns,
    required this.keyIngredients,
    required this.avoidSkinTypes,
    required this.note,
    required this.shelf,
    required this.benefit,
  });

  final String id;
  final String name;
  final String brand;
  final Step step;

  /// Price in LKR.
  final int price;
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

  String benefitFor(String lang) => benefit[lang] ?? benefit['en'] ?? '';
  String? noteFor(String lang) {
    final text = note[lang] ?? note['en'];
    return (text == null || text.isEmpty) ? null : text;
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    Map<String, String> strings(Object? v) => v == null
        ? const {}
        : (v as Map).map((k, val) => MapEntry(k as String, val as String));
    return Product(
      id: j['id'] as String,
      name: j['name'] as String,
      brand: j['brand'] as String,
      step: Step.values.byName(j['step'] as String),
      price: (j['price'] as num).toInt(),
      size: j['size'] as String,
      inStock: j['inStock'] as bool,
      skinTypes: List<String>.from(j['skinTypes'] as List),
      concerns: (j['concerns'] as Map)
          .map((k, v) => MapEntry(k as String, (v as num).toInt())),
      keyIngredients: List<String>.from(j['keyIngredients'] as List),
      avoidSkinTypes: List<String>.from(j['avoidSkinTypes'] as List),
      note: strings(j['note']),
      shelf: j['shelf'] as String,
      benefit: strings(j['benefit']),
    );
  }
}
