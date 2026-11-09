import 'dart:math' as math;

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

    final bestMatchResult = RecommendationEngine.recommend(
      products: products,
      skinType: skin,
      concerns: flow.concerns,
      steps: flow.steps,
      sensitive: flow.sensitive,
    );
    final bestMatchRecs = bestMatchResult.recommendations;

    final brandRoutines = RecommendationEngine.recommendByBrand(
      products: products,
      skinType: skin,
      concerns: flow.concerns,
      steps: flow.steps,
      sensitive: flow.sensitive,
    );

    BrandRoutine? activeBrandRoutine;
    if (flow.selectedBrandTab != null) {
      for (final b in brandRoutines) {
        if (b.brand.toLowerCase() == flow.selectedBrandTab!.toLowerCase()) {
          activeBrandRoutine = b;
          break;
        }
      }
    }

    final currentTotal = activeBrandRoutine != null
        ? activeBrandRoutine.totalPrice
        : bestMatchRecs.fold<int>(0, (sum, r) => sum + r.product.price);

    final currentItemCount = activeBrandRoutine != null
        ? activeBrandRoutine.items.length
        : bestMatchRecs.length;

    final gridChildren = <Widget>[];
    if (activeBrandRoutine != null) {
      for (final step in Step.values.where(flow.steps.contains)) {
        if (activeBrandRoutine.missingSteps.contains(step)) {
          gridChildren.add(_MissingBrandStepCard(step: step, s: s, a: a));
        } else {
          for (final rec in activeBrandRoutine.items
              .where((r) => r.product.step == step)) {
            gridChildren.add(
              ProductCard(
                rec: rec,
                skinType: skin,
                sensitive: flow.sensitive,
                s: s,
              ),
            );
          }
        }
      }
    } else {
      for (final rec in bestMatchRecs) {
        gridChildren.add(
          ProductCard(
            rec: rec,
            skinType: skin,
            sensitive: flow.sensitive,
            s: s,
          ),
        );
      }
    }

    final hasContent = gridChildren.isNotEmpty;

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
                // Brand Tabs (only shown when at least 1 brand routine qualifies)
                if (brandRoutines.isNotEmpty) ...[
                  _BrandTabBar(
                    brandRoutines: brandRoutines,
                    selectedBrand: activeBrandRoutine?.brand,
                    onSelect: flow.selectBrandTab,
                    s: s,
                    a: a,
                  ),
                  SizedBox(height: a.s(16)),
                ],

                // Routine Summary Banner
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
                            activeBrandRoutine != null
                                ? '${activeBrandRoutine.brand} Routine'
                                : '${selectedSkinLabels.join(' + ')} Skin Routine',
                            style: TextStyle(
                              fontSize: a.s(15),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: a.s(8),
                        runSpacing: a.s(6),
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: a.s(12),
                              vertical: a.s(4),
                            ),
                            decoration: BoxDecoration(
                              color: Brand.surfaceSubtle,
                              borderRadius:
                                  BorderRadius.circular(Brand.pillRadius),
                              border: Border.all(color: Brand.outlineLight),
                            ),
                            child: Text(
                              '$currentItemCount products curated',
                              style: TextStyle(
                                fontSize: a.s(13),
                                fontWeight: FontWeight.w600,
                                color: Brand.mutedText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: a.s(12),
                              vertical: a.s(4),
                            ),
                            decoration: BoxDecoration(
                              color: Brand.surfaceSubtle,
                              borderRadius:
                                  BorderRadius.circular(Brand.pillRadius),
                              border: Border.all(color: Brand.outlineLight),
                            ),
                            child: Text(
                              '${s.t('routineTotal')}: ${formatLkr(currentTotal, s: s)}',
                              style: TextStyle(
                                fontSize: a.s(13),
                                fontWeight: FontWeight.w700,
                                color: Brand.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Routine Products Grid or No Results Message
                if (!hasContent)
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
                          softWrap: true,
                          style: TextStyle(
                            fontSize: a.s(20),
                            fontWeight: FontWeight.w700,
                            color: Brand.primary,
                            height: s.lineHeight(1.3),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _RecommendationGrid(
                    a: a,
                    width: box.maxWidth,
                    children: gridChildren,
                  ),
                  if (activeBrandRoutine == null)
                    for (final step in bestMatchResult.emptySteps) ...[
                      SizedBox(height: a.s(16)),
                      _EmptyStepMessage(step: step, s: s, a: a),
                    ],
                  SizedBox(height: a.s(12)),
                  // Routine Total under the products
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(
                      horizontal: a.s(4),
                      vertical: a.s(6),
                    ),
                    child: Text(
                      '${s.t('routineTotal')}: ${formatLkr(currentTotal, s: s)}',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: a.s(16),
                        fontWeight: FontWeight.w800,
                        color: Brand.primary,
                        height: s.lineHeight(),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: a.s(20)),

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

class _BrandTabBar extends StatelessWidget {
  const _BrandTabBar({
    required this.brandRoutines,
    required this.selectedBrand,
    required this.onSelect,
    required this.s,
    required this.a,
  });

  final List<BrandRoutine> brandRoutines;
  final String? selectedBrand;
  final ValueChanged<String?> onSelect;
  final Strings s;
  final Adaptive a;

  @override
  Widget build(BuildContext context) {
    final targetHeight = math.max(56.0, a.s(56));

    Widget buildTab({
      required String? brand,
      required String label,
      required bool isSelected,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Brand.pillRadius),
          onTap: () => onSelect(brand),
          child: Container(
            height: targetHeight,
            constraints: BoxConstraints(minWidth: a.s(110)),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: a.s(20)),
            decoration: BoxDecoration(
              color: isSelected ? Brand.primary : Brand.surface,
              borderRadius: BorderRadius.circular(Brand.pillRadius),
              border: Border.all(
                color: isSelected ? Brand.primary : Brand.outline,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: a.s(15),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Brand.onPrimary : Brand.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.t('brandRoutineHint'),
          style: TextStyle(
            fontSize: a.s(13),
            fontWeight: FontWeight.w600,
            color: Brand.mutedText,
          ),
        ),
        SizedBox(height: a.s(8)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTab(
                brand: null,
                label: s.t('bestMatch'),
                isSelected: selectedBrand == null,
              ),
              for (final b in brandRoutines) ...[
                SizedBox(width: a.s(10)),
                buildTab(
                  brand: b.brand,
                  label: b.brand,
                  isSelected:
                      selectedBrand?.toLowerCase() == b.brand.toLowerCase(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MissingBrandStepCard extends StatelessWidget {
  const _MissingBrandStepCard({
    required this.step,
    required this.s,
    required this.a,
  });

  final Step step;
  final Strings s;
  final Adaptive a;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Brand.surfaceSubtle,
        borderRadius: BorderRadius.circular(Brand.cardRadius),
        border: Border.all(color: Brand.outline, width: 1.2),
      ),
      padding: EdgeInsets.all(a.s(20)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: a.s(10),
                vertical: a.s(4),
              ),
              decoration: BoxDecoration(
                color: Brand.surface,
                borderRadius: BorderRadius.circular(Brand.pillRadius),
                border: Border.all(color: Brand.outlineLight),
              ),
              child: Text(
                s.step(step.name).toUpperCase(),
                style: TextStyle(
                  fontSize: a.s(11),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Brand.mutedText,
                ),
              ),
            ),
            SizedBox(height: a.s(16)),
            Icon(
              Icons.remove_circle_outline_rounded,
              size: a.s(32),
              color: Brand.mutedText,
            ),
            SizedBox(height: a.s(12)),
            Text(
              s.t('notInBrand'),
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: a.s(14),
                fontWeight: FontWeight.w600,
                color: Brand.mutedText,
                height: s.lineHeight(1.3),
              ),
            ),
          ],
        ),
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
    required this.a,
    required this.width,
    required this.children,
  });

  final Adaptive a;
  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = width >= a.s(880)
        ? 4
        : width >= a.s(540)
            ? 2
            : 1;
    final gap = a.s(16);
    final rows = (children.length / columns).ceil();
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
                  if (row * columns + column < children.length)
                    Expanded(child: children[row * columns + column])
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
