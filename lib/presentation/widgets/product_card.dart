import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../../domain/product.dart' as domain;
import '../../domain/recommendation_engine.dart';
import 'adaptive.dart';

String formatLkr(int value, {bool from = false, Strings? s}) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  final formatted = out.toString();
  if (s != null) {
    return s.t(from ? 'priceFrom' : 'price', {'price': formatted});
  }
  return from ? 'From Rs. $formatted' : 'Rs. $formatted';
}

/// Product card mirroring the RunRabbit website product cards:
/// - Real product image at the top with neutral fallback placeholder
/// - Uppercase tracked brand name (e.g. BEAUTY OF JOSEON, AXIS-Y, LUMEA)
/// - Bold product title with optimal hierarchy
/// - Promotional price with "From Rs." for multi-variant products
/// - In-store shelf location indicator & size badge (hidden when empty)
/// - Personalized routine reason & skin compatibility badges
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.rec,
    required this.skinType,
    required this.sensitive,
    required this.s,
  });

  final Recommendation rec;
  final String? skinType;
  final bool sensitive;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final p = rec.product;
    final note = p.noteFor(s.lang);
    final baseSkinMatches = skinType != null &&
        (p.skinTypes.contains(skinType) || p.skinTypes.contains('all'));
    final sensitiveMatches = sensitive &&
        (p.skinTypes.contains('sensitive') || p.skinTypes.contains('all'));

    final reason = <String>[
      if (baseSkinMatches) s.t('reasonSkin', {'skin': s.skin(skinType!)}),
      if (sensitiveMatches) s.t('reasonSensitive'),
      if (rec.matchedConcerns.isNotEmpty)
        s.t('reasonHelps', {
          'list': rec.matchedConcerns.take(3).map(s.concern).join(', '),
        }),
    ].join(' ');

    // Simulated original price before in-store promotion (+15%)
    final originalPrice = (p.price * 1.15).round();

    final hasShelf = p.shelf.trim().isNotEmpty;
    final hasSize = p.size.trim().isNotEmpty;
    final shelfText = p.shelf.toLowerCase().contains('shelf')
        ? p.shelf
        : '${s.t('shelf')} ${p.shelf}';

    return Container(
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(Brand.cardRadius),
        border: Border.all(color: Brand.outline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Product Image Hero
          _ProductImageHero(product: p, s: s),

          // 2. Product Details Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: a.s(14),
              vertical: a.s(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand name in uppercase with letter spacing
                Text(
                  p.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: a.s(11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Brand.brandLabel,
                  ),
                ),
                SizedBox(height: a.s(3)),

                // Product title (Standardized 2-line height so all cards align!)
                SizedBox(
                  height: a.s(40),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: a.s(15.5),
                        fontWeight: FontWeight.w800,
                        color: Brand.primary,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: a.s(8)),

                // Price Row (Standardized height)
                SizedBox(
                  height: a.s(26),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatLkr(p.price, from: p.priceFrom, s: s),
                          style: TextStyle(
                            fontSize: a.s(19),
                            fontWeight: FontWeight.w900,
                            color: Brand.saleRed,
                          ),
                        ),
                        SizedBox(width: a.s(6)),
                        Text(
                          formatLkr(originalPrice, s: s),
                          style: TextStyle(
                            fontSize: a.s(12),
                            fontWeight: FontWeight.w500,
                            color: Brand.strikethroughPrice,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: a.s(6)),

                // Shelf & Size Badges Row (Standardized height)
                SizedBox(
                  height: a.s(24),
                  child: (hasShelf || hasSize)
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasShelf) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: a.s(7),
                                    vertical: a.s(3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFDCFCE7),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pin_drop_rounded,
                                        size: a.s(12),
                                        color: const Color(0xFF166534),
                                      ),
                                      SizedBox(width: a.s(3)),
                                      Text(
                                        shelfText,
                                        style: TextStyle(
                                          fontSize: a.s(11),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF166534),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasSize) SizedBox(width: a.s(6)),
                              ],
                              if (hasSize)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: a.s(6),
                                    vertical: a.s(3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Brand.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.size,
                                    style: TextStyle(
                                      fontSize: a.s(11),
                                      fontWeight: FontWeight.w600,
                                      color: Brand.mutedText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: a.s(8)),

                // Benefit statement (Standardized 2-line height so all cards align!)
                SizedBox(
                  height: a.s(34),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      p.benefitFor(s.lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: a.s(12.5),
                        color: Brand.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: a.s(8)),

                // Routine fit explanation (Standardized height container!)
                Container(
                  width: double.infinity,
                  height: a.s(52),
                  padding: EdgeInsets.symmetric(
                    horizontal: a.s(8),
                    vertical: a.s(6),
                  ),
                  decoration: BoxDecoration(
                    color: Brand.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Brand.outlineLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: a.s(14),
                        color: Brand.accent,
                      ),
                      SizedBox(width: a.s(6)),
                      Expanded(
                        child: Text(
                          reason.isNotEmpty ? reason : s.t('reasonRoutine'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: a.s(11.5),
                            color: Brand.mutedText,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Caution / Allergy note
                if (note != null) ...[
                  SizedBox(height: a.s(6)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(a.s(8)),
                    decoration: BoxDecoration(
                      color: Brand.cautionBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Brand.caution.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: a.s(14),
                          color: Brand.caution,
                        ),
                        SizedBox(width: a.s(6)),
                        Expanded(
                          child: Text(
                            note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: a.s(11.5),
                              fontWeight: FontWeight.w500,
                              color: Brand.caution,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Studio Product Image Hero:
/// Shows the product image with BoxFit.contain on a white background, fixed aspect ratio,
/// cacheWidth set from card width (using MediaQuery devicePixelRatio), gaplessPlayback true,
/// and an errorBuilder that displays a neutral placeholder (icon on light background).
class _ProductImageHero extends StatelessWidget {
  const _ProductImageHero({
    required this.product,
    required this.s,
  });

  final domain.Product product;
  final Strings s;

  String _stepNumber() {
    switch (product.step) {
      case domain.Step.cleanser:
        return 'STEP 1';
      case domain.Step.toner:
        return 'STEP 2';
      case domain.Step.serum:
        return 'STEP 3';
      case domain.Step.moisturiser:
        return 'STEP 4';
      case domain.Step.sunscreen:
        return 'STEP 5';
      case domain.Step.mask:
        return 'MASK';
    }
  }

  Color _stepAccent() {
    switch (product.step) {
      case domain.Step.cleanser:
        return const Color(0xFF16A34A);
      case domain.Step.toner:
        return const Color(0xFF0284C7);
      case domain.Step.serum:
        return const Color(0xFFD97706);
      case domain.Step.moisturiser:
        return const Color(0xFFE11D48);
      case domain.Step.sunscreen:
        return const Color(0xFFCA8A04);
      case domain.Step.mask:
        return const Color(0xFF9333EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final accent = _stepAccent();

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Brand.cardRadius - 1),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(a.s(12)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ??
                        MediaQuery.of(context).devicePixelRatio;
                    final cardWidth = constraints.maxWidth.isFinite &&
                            constraints.maxWidth > 0
                        ? constraints.maxWidth
                        : 300.0;
                    final cacheWidth = (cardWidth * dpr).round().clamp(1, 2048);

                    Widget placeholder() => Container(
                          decoration: BoxDecoration(
                            color: Brand.surfaceSubtle,
                            borderRadius:
                                BorderRadius.circular(Brand.radius - 2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.spa_outlined,
                              size: a.s(36),
                              color: Brand.mutedText.withValues(alpha: 0.4),
                            ),
                          ),
                        );

                    if (product.image.isEmpty) {
                      return placeholder();
                    }

                    return Image.asset(
                      product.image,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      cacheWidth: cacheWidth,
                      errorBuilder: (context, error, stackTrace) =>
                          placeholder(),
                    );
                  },
                ),
              ),
            ),

            // Routine Step Pill (Top Left)
            Positioned(
              top: a.s(8),
              left: a.s(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(8),
                  vertical: a.s(3.5),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Brand.pillRadius),
                  border: Border.all(color: Brand.outlineLight),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: a.s(6),
                      height: a.s(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                    SizedBox(width: a.s(5)),
                    Text(
                      '${_stepNumber()} · ${s.step(product.step.name).toUpperCase()}',
                      style: TextStyle(
                        fontSize: a.s(9.5),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Brand.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MATCHED Tag (Top Right)
            Positioned(
              top: a.s(8),
              right: a.s(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(8),
                  vertical: a.s(3),
                ),
                decoration: BoxDecoration(
                  color: Brand.discountBadgeBg,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Brand.discountBadgeBg.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'MATCHED',
                  style: TextStyle(
                    fontSize: a.s(9.5),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
