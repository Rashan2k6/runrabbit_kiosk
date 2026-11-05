import 'package:flutter/material.dart';

import '../app/brand.dart';

/// The official RunRabbit logo typography:
/// "RUN" in bold/black weight (`w900`) and "RABBIT" in clean regular weight (`w400`).
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    required this.fontSize,
    this.letterSpacing = 3.5,
    this.color = Brand.primary,
    this.textAlign,
  });

  final double fontSize;
  final double letterSpacing;
  final Color color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        children: [
          TextSpan(
            text: 'RUN',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(
            text: 'RABBIT',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}

