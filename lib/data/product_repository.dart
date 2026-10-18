import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/product.dart';

/// The only way screens and logic get products. To use Shopify later, add a
/// second implementation of this interface; nothing else needs to change.
abstract class ProductRepository {
  Future<List<Product>> loadAll();
}

class JsonProductRepository implements ProductRepository {
  JsonProductRepository({
    this.assetPath = 'assets/data/products.json',
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle _bundle;

  @override
  Future<List<Product>> loadAll() async {
    final raw = await _bundle.loadString(assetPath);
    return parseProducts(raw);
  }
}

List<Product> parseProducts(String raw) {
  final data = jsonDecode(raw) as Map<String, dynamic>;
  return (data['products'] as List)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();
}
