import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/brand.dart';

/// A reusable circular badge for icons matching the RunRabbit brand aesthetic.
///
/// - Supports either an [IconData] or an SVG asset path via [svgAsset].
/// - Unselected: Light terracotta tint (Brand.accent at ~8% opacity), icon in Brand.accent.
/// - Selected: Solid terracotta (Brand.accent), icon in Brand.onPrimary (white).
/// - Icon size: ~50% of circle size.
/// - 200ms smooth AnimatedContainer transition when selection toggles.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    this.icon,
    this.svgAsset,
    this.size = 56.0,
    this.selected = false,
  }) : assert(icon != null || svgAsset != null, 'Either icon or svgAsset must be provided');

  final IconData? icon;
  final String? svgAsset;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? Brand.accent
        : Brand.accent.withValues(alpha: 0.08);

    final iconColor = selected
        ? Colors.white
        : Brand.accent;

    final iconDimension = size * 0.50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: svgAsset != null
          ? SvgPicture.asset(
              svgAsset!,
              width: iconDimension,
              height: iconDimension,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            )
          : Icon(
              icon,
              size: iconDimension,
              color: iconColor,
            ),
    );
  }
}
