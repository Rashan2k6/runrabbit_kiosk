import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../../domain/product.dart' as domain;
import '../../domain/recommendation_engine.dart';
import 'adaptive.dart';

String formatLkr(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return 'Rs. $out';
}

/// Product card mirroring the RunRabbit website product cards:
/// - Distinctive custom K-Beauty cosmetic packaging illustration for each routine step
/// - Uppercase tracked brand name (e.g. BEAUTY OF JOSEON, AXIS-Y, LUMEA)
/// - Bold product title with optimal hierarchy
/// - Sale red promotional price with subtle original price strikethrough
/// - In-store shelf location indicator & size badge
/// - Personalized routine reason & skin compatibility badges
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.rec,
    required this.skinType,
    required this.s,
  });

  final Recommendation rec;
  final String skinType;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final p = rec.product;
    final note = p.noteFor(s.lang);

    final reason = <String>[
      if (rec.skinMatch) s.t('reasonSkin', {'skin': s.skin(skinType)}),
      if (rec.matchedConcerns.isNotEmpty)
        s.t('reasonHelps', {
          'list': rec.matchedConcerns.map(s.concern).join(', '),
        }),
    ].join(' ');

    // Simulated original price before in-store promotion (+15%)
    final originalPrice = (p.price * 1.15).round();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Studio Product Visual Hero with K-Beauty Cosmetic Bottle
          _CosmeticBottleVisual(product: p, s: s),

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
                          formatLkr(p.price),
                          style: TextStyle(
                            fontSize: a.s(19),
                            fontWeight: FontWeight.w900,
                            color: Brand.saleRed,
                          ),
                        ),
                        SizedBox(width: a.s(6)),
                        Text(
                          formatLkr(originalPrice),
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: a.s(7),
                            vertical: a.s(3),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
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
                                p.shelf,
                                style: TextStyle(
                                  fontSize: a.s(11),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: a.s(6)),
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
                  ),
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
                          reason.isNotEmpty ? reason : s.skin(skinType),
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

/// Custom K-Beauty Cosmetic Product Visual Hero:
/// Draws a realistic, recognizable cosmetic container for each skincare step
/// (Pump bottle for Cleanser, Dropper bottle for Serum, Cosmetic cream jar for Moisturiser,
///  Squeeze tube for Sunscreen, Slender bottle for Toner) with studio reflections,
///  routine step pill, and match status.
class _CosmeticBottleVisual extends StatelessWidget {
  const _CosmeticBottleVisual({
    required this.product,
    required this.s,
  });

  final domain.Product product;
  final Strings s;

  Color _stepBg() {
    switch (product.step) {
      case domain.Step.cleanser:
        return const Color(0xFFF0FDF4); // Sage botanical clean
      case domain.Step.toner:
        return const Color(0xFFF0F9FF); // Fresh hydration sky
      case domain.Step.serum:
        return const Color(0xFFFFFBEB); // Warm active amber
      case domain.Step.moisturiser:
        return const Color(0xFFFFF1F2); // Rose peptide barrier
      case domain.Step.sunscreen:
        return const Color(0xFFFEFCE8); // Sunshield bright gold
      case domain.Step.mask:
        return const Color(0xFFFAF5FF); // Relaxing spa lavender
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

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final bg = _stepBg();
    final accent = _stepAccent();

    return Container(
      height: a.s(145),
      margin: EdgeInsets.all(a.s(8)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Brand.radius - 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bg,
            Colors.white.withValues(alpha: 0.6),
            bg.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Studio Pedestal Backdrop
          Positioned(
            top: a.s(14),
            child: Container(
              width: a.s(84),
              height: a.s(84),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Cosmetic Bottle Graphic
          Padding(
            padding: EdgeInsets.only(top: a.s(14)),
            child: _buildBottleIllustration(product.step, a, accent),
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
    );
  }

  Widget _buildBottleIllustration(domain.Step step, Adaptive a, Color accent) {
    switch (step) {
      case domain.Step.cleanser:
        // Foam Cleanser Pump Bottle
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: a.s(16),
                  height: a.s(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: a.s(6),
                  height: a.s(5),
                  color: Colors.transparent,
                ),
              ],
            ),
            Container(
              width: a.s(6),
              height: a.s(6),
              color: const Color(0xFF757575),
            ),
            Container(
              width: a.s(18),
              height: a.s(6),
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Cleanser Bottle Body
            Container(
              width: a.s(44),
              height: a.s(62),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(a.s(8)),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: a.s(18),
                    color: accent,
                  ),
                  SizedBox(height: a.s(4)),
                  Container(
                    width: a.s(24),
                    height: a.s(2),
                    color: accent.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ],
        );

      case domain.Step.serum:
        // Serum Dropper Pipette Bottle
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: a.s(12),
              height: a.s(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(a.s(6))),
              ),
            ),
            Container(
              width: a.s(20),
              height: a.s(7),
              decoration: BoxDecoration(
                color: const Color(0xFFBFA054), // Elegant gold collar
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Glass Ampoule Bottle Body
            Container(
              width: a.s(42),
              height: a.s(60),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(a.s(10)),
                border: Border.all(color: const Color(0xFFFFDCA8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.colorize_rounded,
                    size: a.s(18),
                    color: accent,
                  ),
                  SizedBox(height: a.s(4)),
                  Container(
                    width: a.s(20),
                    height: a.s(2),
                    color: accent.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ],
        );

      case domain.Step.moisturiser:
        // Cosmetic Cream Jar
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: a.s(12)),
            Container(
              width: a.s(56),
              height: a.s(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37), // Metallic brushed lid
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            Container(
              width: a.s(54),
              height: a.s(44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(a.s(12)),
                ),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.spa_outlined,
                  size: a.s(20),
                  color: accent,
                ),
              ),
            ),
          ],
        );

      case domain.Step.sunscreen:
        // Sunscreen Squeeze Tube
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: a.s(42),
              height: a.s(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE047),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Container(
              width: a.s(42),
              height: a.s(56),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFEF08A), Colors.white],
                ),
                borderRadius: BorderRadius.circular(a.s(6)),
                border: Border.all(color: const Color(0xFFFACC15), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: a.s(20),
                  color: accent,
                ),
              ),
            ),
            Container(
              width: a.s(26),
              height: a.s(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      default:
        // Slender Bottle for Toners / Masks
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: a.s(18),
              height: a.s(8),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: a.s(40),
              height: a.s(64),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(a.s(8)),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.waves_rounded,
                  size: a.s(20),
                  color: accent,
                ),
              ),
            ),
          ],
        );
    }
  }
}
