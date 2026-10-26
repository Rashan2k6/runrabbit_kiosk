import 'package:flutter/material.dart' hide Step;

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../../domain/product.dart';
import '../../domain/recommendation_engine.dart';
import '../state/flow_state.dart';
import '../widgets/adaptive.dart';
import '../widgets/product_card.dart';
import '../widgets/screen_frame.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.flow,
    required this.s,
    required this.products,
  });

  final KioskFlow flow;
  final Strings s;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final skin = flow.skinType;
    final selectedSkinLabels = [
      if (skin != null) s.skin(skin),
      if (flow.sensitive) s.skin('sensitive'),
    ];
    final result = RecommendationEngine.recommend(
      products: products,
      skinType: skin,
      concerns: flow.concerns,
      steps: flow.steps,
      sensitive: flow.sensitive,
    );
    final recs = result.recommendations;

    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('resultsTitle'),
      subtitle: s.t('resultsHelp'),
      child: LayoutBuilder(
        builder: (context, box) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Routine Summary Bar (Website Banner style)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: a.s(16),
                    vertical: a.s(12),
                  ),
                  margin: EdgeInsets.only(bottom: a.s(20)),
                  decoration: BoxDecoration(
                    color: Brand.surface,
                    borderRadius: BorderRadius.circular(Brand.radius),
                    border: Border.all(color: Brand.outline, width: 1.2),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: a.s(12),
                    runSpacing: a.s(8),
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Brand.accent,
                            size: a.s(20),
                          ),
                          SizedBox(width: a.s(8)),
                          Text(
                            '${selectedSkinLabels.join(' + ')} Skin Routine',
                            style: TextStyle(
                              fontSize: a.s(15),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: a.s(12),
                          vertical: a.s(4),
                        ),
                        decoration: BoxDecoration(
                          color: Brand.surfaceSubtle,
                          borderRadius: BorderRadius.circular(Brand.pillRadius),
                          border: Border.all(color: Brand.outlineLight),
                        ),
                        child: Text(
                          '${recs.length} products curated',
                          style: TextStyle(
                            fontSize: a.s(13),
                            fontWeight: FontWeight.w600,
                            color: Brand.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Keep all recommendations in one responsive grid. Grouping each
                // routine step separately left most of every row empty because a
                // routine normally contains one product per step.
                if (recs.isEmpty)
                  Container(
                    padding: EdgeInsets.all(a.s(32)),
                    decoration: BoxDecoration(
                      color: Brand.surface,
                      borderRadius: BorderRadius.circular(Brand.cardRadius),
                      border: Border.all(color: Brand.outline),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: a.s(48),
                          color: Brand.mutedText,
                        ),
                        SizedBox(height: a.s(16)),
                        Text(
                          s.t('noResults'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: a.s(20),
                            fontWeight: FontWeight.w700,
                            color: Brand.primary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _RecommendationGrid(
                    recommendations: recs,
                    skinType: skin,
                    sensitive: flow.sensitive,
                    s: s,
                    a: a,
                    width: box.maxWidth,
                  ),
                  for (final step in result.emptySteps) ...[
                    SizedBox(height: a.s(16)),
                    _EmptyStepMessage(step: step, s: s, a: a),
                  ],
                ],

                SizedBox(height: a.s(24)),

                // Patch Test & Advisor Banner
                Container(
                  padding: EdgeInsets.all(a.s(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(Brand.radius),
                    border: Border.all(color: Brand.outline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: a.s(22),
                        color: Brand.mutedText,
                      ),
                      SizedBox(width: a.s(12)),
                      Expanded(
                        child: Text(
                          s.t('patchTest'),
                          style: TextStyle(
                            fontSize: a.s(14),
                            color: Brand.mutedText,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: a.s(16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyStepMessage extends StatelessWidget {
  const _EmptyStepMessage(
      {required this.step, required this.s, required this.a});

  final Step step;
  final Strings s;
  final Adaptive a;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(a.s(16)),
        decoration: BoxDecoration(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(Brand.radius),
          border: Border.all(color: Brand.outline),
        ),
        child: Text(
          s.t('noSuitableStep', {'step': s.step(step.name)}),
          style: TextStyle(fontSize: a.s(15), color: Brand.mutedText),
        ),
      );
}

class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid({
    required this.recommendations,
    required this.skinType,
    required this.sensitive,
    required this.s,
    required this.a,
    required this.width,
  });

  final List<Recommendation> recommendations;
  final String? skinType;
  final bool sensitive;
  final Strings s;
  final Adaptive a;
  final double width;

  @override
  Widget build(BuildContext context) {
    final columns = width >= a.s(880)
        ? 4
        : width >= a.s(540)
            ? 2
            : 1;
    final gap = a.s(16);
    final rows = (recommendations.length / columns).ceil();
    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) SizedBox(width: gap),
                  if (row * columns + column < recommendations.length)
                    Expanded(
                      child: ProductCard(
                        rec: recommendations[row * columns + column],
                        skinType: skinType,
                        sensitive: sensitive,
                        s: s,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
