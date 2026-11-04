import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/widgets/product_card.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a product with all the new keys', () {
      final json = {
        'id': 'real-prod-1',
        'name': 'Centellian24 Madeca Pack Cleanser',
        'brand': 'Centellian24',
        'step': 'cleanser',
        'price': 6790,
        'priceFrom': true,
        'size': '120ml',
        'inStock': true,
        'skinTypes': ['combination', 'oily'],
        'avoidSkinTypes': <String>[],
        'concerns': {'acne': 3, 'pores': 2},
        'keyIngredients': ['Centella', 'Salicylic Acid'],
        'note': {'en': 'Test caution'},
        'shelf': 'Shelf C1',
        'benefit': {'en': 'Clears pores gently'},
        'howTo': {'en': '1. Lather on wet face. 2. Rinse.'},
        'ingredients': 'Water, Glycerin, Centella Asiatica Extract',
        'image': 'assets/images/products/real-prod-1.webp',
      };

      final p = Product.fromJson(json);

      expect(p.id, 'real-prod-1');
      expect(p.name, 'Centellian24 Madeca Pack Cleanser');
      expect(p.brand, 'Centellian24');
      expect(p.step, Step.cleanser);
      expect(p.price, 6790);
      expect(p.priceFrom, isTrue);
      expect(p.size, '120ml');
      expect(p.inStock, isTrue);
      expect(p.skinTypes, ['combination', 'oily']);
      expect(p.avoidSkinTypes, isEmpty);
      expect(p.concerns, {'acne': 3, 'pores': 2});
      expect(p.keyIngredients, ['Centella', 'Salicylic Acid']);
      expect(p.shelf, 'Shelf C1');
      expect(p.benefitFor('en'), 'Clears pores gently');
      expect(p.benefitFor('si'), 'Clears pores gently'); // fallback
      expect(p.howToFor('en'), '1. Lather on wet face. 2. Rinse.');
      expect(p.howToFor('si'), '1. Lather on wet face. 2. Rinse.'); // fallback
      expect(p.noteFor('en'), 'Test caution');
      expect(p.ingredients, 'Water, Glycerin, Centella Asiatica Extract');
      expect(p.image, 'assets/images/products/real-prod-1.webp');
    });

    test('parses an old-style product without new keys with safe defaults', () {
      final json = {
        'id': 'c1',
        'name': 'Gentle Foam Cleanser',
        'brand': 'Lumea',
        'step': 'cleanser',
        'price': 2800,
        'size': '150 ml',
        'inStock': true,
        'skinTypes': ['oily', 'normal'],
        'concerns': {'acne': 1},
        'keyIngredients': ['Amino acids'],
        'avoidSkinTypes': <String>[],
        'note': <String, dynamic>{},
        'shelf': 'Shelf A1',
        'benefit': {'en': 'Lifts oil cleanly.'},
      };

      final p = Product.fromJson(json);

      expect(p.id, 'c1');
      expect(p.price, 2800);
      expect(p.priceFrom, isFalse);
      expect(p.howTo, isEmpty);
      expect(p.howToFor('en'), '');
      expect(p.ingredients, '');
      expect(p.image, '');
      expect(p.shelf, 'Shelf A1');
      expect(p.size, '150 ml');
    });

    test('empty shelf and size are allowed and tolerate missing fields', () {
      final json = {
        'id': 'minimal',
        'name': 'Minimal Product',
        'brand': 'Brand',
        'step': 'serum',
        'price': 4500,
        'size': '',
        'inStock': true,
        'skinTypes': ['all'],
        'concerns': <String, dynamic>{},
        'keyIngredients': <String>[],
        'avoidSkinTypes': <String>[],
        'shelf': '',
      };

      final p = Product.fromJson(json);

      expect(p.shelf, '');
      expect(p.size, '');
      expect(p.priceFrom, isFalse);
      expect(p.ingredients, '');
      expect(p.image, '');
    });
  });

  group('formatLkr format helper', () {
    test('formats "Rs. 5,990" and "From Rs. 5,990"', () {
      expect(formatLkr(5990), 'Rs. 5,990');
      expect(formatLkr(5990, from: true), 'From Rs. 5,990');
      expect(formatLkr(5990, s: const Strings('en')), 'Rs. 5,990');
      expect(formatLkr(5990, from: true, s: const Strings('en')),
          'From Rs. 5,990');
    });

    test('formats Sinhala price when localized strings are provided', () {
      expect(formatLkr(5990, from: true, s: const Strings('si')),
          'රු. 5,990 සිට');
    });
  });
}

