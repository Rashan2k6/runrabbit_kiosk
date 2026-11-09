import 'options.dart';
import 'product.dart';

class Recommendation {
  const Recommendation({
    required this.product,
    required this.matchedConcerns,
    required this.skinMatch,
    required this.score,
  });

  final Product product;

  /// Selected concerns this product helps with (best first).
  final List<String> matchedConcerns;

  /// True when the product lists the skin type or is for all skin types.
  final bool skinMatch;
  final int score;
}

class RecommendationResult {
  const RecommendationResult({
    required this.recommendations,
    required this.emptySteps,
  });

  final List<Recommendation> recommendations;
  final List<Step> emptySteps;
}

class BrandRoutine {
  const BrandRoutine({
    required this.brand,
    required this.items,
    required this.missingSteps,
    required this.totalScore,
    required this.totalPrice,
  });

  final String brand;
  final List<Recommendation> items;
  final Set<Step> missingSteps;
  final int totalScore;
  final int totalPrice;
}

/// Pure logic, no Flutter imports, so it is easy to unit test.
class RecommendationEngine {
  /// Checks whether a product is a mask, patch, or auxiliary treatment that
  /// should not be recommended in the core skincare routine steps.
  static bool _isExcludedAuxiliaryProduct(Product p, {bool allowMask = false}) {
    if (p.step == Step.mask && !allowMask) return true;
    final lowerName = p.name.toLowerCase();
    final lowerId = p.id.toLowerCase();
    if (lowerName.contains('patch') || lowerId.contains('patch')) return true;
    if (lowerName.contains('nose pack') || lowerId.contains('nose-pack')) {
      return true;
    }
    if (!allowMask && (lowerName.contains('mask') || lowerId.contains('mask'))) {
      return true;
    }
    return false;
  }

  static Recommendation _rate(
    Product p,
    String? skinType,
    Set<String> concerns, {
    bool sensitive = false,
  }) {
    var score = 0;
    final matched = <String>[];
    for (final c in concerns) {
      final w = p.concerns[c] ?? 0;
      if (w > 0) {
        score += w;
        matched.add(c);
      }
    }
    matched.sort((a, b) => p.concerns[b]!.compareTo(p.concerns[a]!));

    int skinTermFor(String type) {
      if (p.skinTypes.contains(type)) return 2;
      if (p.skinTypes.contains('all')) return 1;
      return 0;
    }

    var skinTerm = skinType == null ? 0 : skinTermFor(skinType);
    if (sensitive) {
      final sensTerm = skinTermFor('sensitive');
      if (sensTerm > skinTerm) {
        skinTerm = sensTerm;
      }
    }

    return Recommendation(
      product: p,
      matchedConcerns: matched,
      skinMatch: skinTerm > 0,
      score: score + skinTerm,
    );
  }

  static int _compare(Recommendation a, Recommendation b) {
    final s = b.score - a.score;
    if (s != 0) return s;
    final price = a.product.price - b.product.price;
    if (price != 0) return price;
    return a.product.id.compareTo(b.product.id);
  }

  static RecommendationResult recommend({
    required List<Product> products,
    required String? skinType,
    required Set<String> concerns,
    required Set<Step> steps,
    bool sensitive = false,
  }) {
    final allowMask = steps.contains(Step.mask);
    final rated = products
        .where((p) =>
            p.inStock &&
            !_isExcludedAuxiliaryProduct(p, allowMask: allowMask) &&
            (skinType == null || !p.avoidSkinTypes.contains(skinType)) &&
            (!sensitive || !p.avoidSkinTypes.contains('sensitive')) &&
            steps.contains(p.step))
        .map((p) => _rate(p, skinType, concerns, sensitive: sensitive))
        .toList();

    final picked = <Recommendation>[];
    final emptySteps = <Step>[];
    final limit = steps.length == 1
        ? 3
        : (steps.length >= routineSteps.length)
            ? 1
            : 2;

    for (final step in Step.values.where(steps.contains)) {
      final stepCandidates =
          rated.where((r) => r.product.step == step).toList()..sort(_compare);

      if (stepCandidates.isEmpty) {
        emptySteps.add(step);
      } else {
        picked.addAll(stepCandidates.take(limit));
      }
    }

    return RecommendationResult(
      recommendations: picked,
      emptySteps: emptySteps,
    );
  }

  /// Builds a routine using only products from [brand], following the exact same
  /// scoring, filtering, per-step picking and tie-breaking as [recommend].
  static RecommendationResult recommendForBrand({
    required List<Product> products,
    required String? skinType,
    required Set<String> concerns,
    required Set<Step> steps,
    required String brand,
    bool sensitive = false,
  }) {
    final brandNorm = brand.trim().toLowerCase();
    final brandProducts = products
        .where((p) => p.brand.trim().toLowerCase() == brandNorm)
        .toList();

    return recommend(
      products: brandProducts,
      skinType: skinType,
      concerns: concerns,
      steps: steps,
      sensitive: sensitive,
    );
  }

  static String _nicestBrandSpelling(List<String> variants) {
    if (variants.length == 1) return variants.first;
    for (final v in variants) {
      final hasUpper = v.contains(RegExp(r'[A-Z]'));
      final hasLower = v.contains(RegExp(r'[a-z]'));
      if (hasUpper && hasLower) return v;
    }
    return variants.first;
  }

  /// Recommends single-brand routines for distinct qualifying brands.
  ///
  /// Returns at most 2 [BrandRoutine]s, ranked by totalScore descending.
  /// Tie-breaks: fewer missing steps, then lower totalPrice, then brand name.
  /// If fewer than 1 brand qualifies, returns an empty list.
  static List<BrandRoutine> recommendByBrand({
    required List<Product> products,
    required String? skinType,
    required Set<String> concerns,
    required Set<Step> steps,
    bool sensitive = false,
  }) {
    if (steps.isEmpty) return const [];

    final brandVariants = <String, List<String>>{};
    for (final p in products) {
      if (!p.inStock) continue;
      final trimmed = p.brand.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      brandVariants.putIfAbsent(key, () => []).add(trimmed);
    }

    final qualifying = <BrandRoutine>[];

    for (final entry in brandVariants.entries) {
      final displayBrand = _nicestBrandSpelling(entry.value);
      final result = recommendForBrand(
        products: products,
        skinType: skinType,
        concerns: concerns,
        steps: steps,
        brand: displayBrand,
        sensitive: sensitive,
      );

      final items = result.recommendations;
      final missingSteps = result.emptySteps.toSet();
      final filledStepsCount = steps.length - missingSteps.length;

      final minFilled = steps.length == 1 ? 1 : 2;
      if (filledStepsCount < minFilled) continue;

      final stepCoverageOk = missingSteps.isEmpty ||
          (steps.length >= 4 && missingSteps.length <= 1);
      if (!stepCoverageOk) continue;

      final totalScore = items.fold<int>(0, (sum, r) => sum + r.score);
      final totalPrice = items.fold<int>(0, (sum, r) => sum + r.product.price);

      qualifying.add(BrandRoutine(
        brand: displayBrand,
        items: items,
        missingSteps: missingSteps,
        totalScore: totalScore,
        totalPrice: totalPrice,
      ));
    }

    if (qualifying.isEmpty) return const [];

    qualifying.sort((a, b) {
      final scoreDiff = b.totalScore - a.totalScore;
      if (scoreDiff != 0) return scoreDiff;
      final missingDiff = a.missingSteps.length - b.missingSteps.length;
      if (missingDiff != 0) return missingDiff;
      final priceDiff = a.totalPrice - b.totalPrice;
      if (priceDiff != 0) return priceDiff;
      return a.brand.toLowerCase().compareTo(b.brand.toLowerCase());
    });

    return qualifying.take(2).toList();
  }
}
