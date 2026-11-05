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

/// Pure logic, no Flutter imports, so it is easy to unit test.
class RecommendationEngine {
  /// Checks whether a product is a mask, patch, or auxiliary treatment that
  /// should not be recommended in the core skincare routine steps.
  static bool _isExcludedAuxiliaryProduct(Product p) {
    if (p.step == Step.mask) return true;
    final lowerName = p.name.toLowerCase();
    final lowerId = p.id.toLowerCase();
    if (lowerName.contains('patch') || lowerId.contains('patch')) return true;
    if (lowerName.contains('mask') || lowerId.contains('mask')) return true;
    if (lowerName.contains('nose pack') || lowerId.contains('nose-pack')) {
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
    final rated = products
        .where((p) =>
            p.inStock &&
            !_isExcludedAuxiliaryProduct(p) &&
            (skinType == null || !p.avoidSkinTypes.contains(skinType)) &&
            (!sensitive || !p.avoidSkinTypes.contains('sensitive')) &&
            steps.contains(p.step))
        .map((p) => _rate(p, skinType, concerns, sensitive: sensitive))
        .toList();

    // When recommending multi-step routines, harmonize around the best-fitting brand:
    // 1. Brand with the highest coverage of requested routine steps
    // 2. Highest total score across covered steps
    // 3. Lower total price as tie-breaker
    String? preferredBrand;
    if (steps.length > 1 && rated.isNotEmpty) {
      final byBrand = <String, List<Recommendation>>{};
      for (final r in rated) {
        byBrand.putIfAbsent(r.product.brand, () => []).add(r);
      }

      String? bestBrand;
      var bestCoverage = -1;
      var bestScore = -1;
      var bestPrice = double.infinity;

      for (final entry in byBrand.entries) {
        final brand = entry.key;
        final brandRecs = entry.value;

        final coveredSteps = <Step>{};
        var scoreSum = 0;
        var priceSum = 0;

        for (final step in routineSteps.where(steps.contains)) {
          final stepCandidates =
              brandRecs.where((r) => r.product.step == step).toList()
                ..sort(_compare);
          if (stepCandidates.isNotEmpty) {
            coveredSteps.add(step);
            scoreSum += stepCandidates.first.score;
            priceSum += stepCandidates.first.product.price;
          }
        }

        final coverage = coveredSteps.length;
        if (coverage > bestCoverage ||
            (coverage == bestCoverage && scoreSum > bestScore) ||
            (coverage == bestCoverage &&
                scoreSum == bestScore &&
                priceSum < bestPrice)) {
          bestBrand = brand;
          bestCoverage = coverage;
          bestScore = scoreSum;
          bestPrice = priceSum.toDouble();
        }
      }
      preferredBrand = bestBrand;
    }

    final picked = <Recommendation>[];
    final emptySteps = <Step>[];
    final limit = steps.length == 1
        ? 3
        : steps.length == routineSteps.length
            ? 1
            : 2;

    for (final step in routineSteps.where(steps.contains)) {
      final stepCandidates =
          rated.where((r) => r.product.step == step).toList()..sort(_compare);

      if (stepCandidates.isEmpty) {
        emptySteps.add(step);
      } else {
        if (preferredBrand != null) {
          final brandCandidates = stepCandidates
              .where((r) => r.product.brand == preferredBrand)
              .toList();

          if (brandCandidates.isNotEmpty) {
            picked.addAll(brandCandidates.take(limit));
          } else {
            // Fallback to top candidates if preferred brand doesn't offer this step
            picked.addAll(stepCandidates.take(limit));
          }
        } else {
          picked.addAll(stepCandidates.take(limit));
        }
      }
    }

    return RecommendationResult(
      recommendations: picked,
      emptySteps: emptySteps,
    );
  }
}
