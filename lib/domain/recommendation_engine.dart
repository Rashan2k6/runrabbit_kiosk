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
            (skinType == null || !p.avoidSkinTypes.contains(skinType)) &&
            (!sensitive || !p.avoidSkinTypes.contains('sensitive')) &&
            steps.contains(p.step))
        .map((p) => _rate(p, skinType, concerns, sensitive: sensitive))
        .toList();

    final picked = <Recommendation>[];
    final emptySteps = <Step>[];
    final limit = steps.length == 1
        ? 3
        : steps.length == routineSteps.length
            ? 1
            : 2;
    for (final step in routineSteps.where(steps.contains)) {
      final candidates = rated.where((r) => r.product.step == step).toList()
        ..sort(_compare);
      if (candidates.isEmpty) {
        emptySteps.add(step);
      } else {
        picked.addAll(candidates.take(limit));
      }
    }
    return RecommendationResult(
      recommendations: picked,
      emptySteps: emptySteps,
    );
  }
}
