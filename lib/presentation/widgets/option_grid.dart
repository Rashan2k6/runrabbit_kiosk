import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/brand.dart';

class OptionItem {
  const OptionItem({
    required this.id,
    required this.label,
    this.emoji,
    this.icon,
    this.svgAsset,
    this.color,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? emoji;
  final IconData? icon;
  final String? svgAsset;
  final Color? color;
  final String? subtitle;
}

/// A responsive grid of interactive routine cards that fills the available vertical space.
/// - 3 columns x 2 rows in landscape / wide screens
/// - 2 columns x 3 rows in portrait / narrow screens (< 700 width)
/// - Proportional card scaling (icon circle, icon, label, radio button)
class OptionGrid extends StatelessWidget {
  const OptionGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.selected = const {},
  });

  final List<OptionItem> items;
  final Set<String> selected;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;

        // Landscape or wide screens: 3 columns x 2 rows.
        // Portrait or narrow screens (width < 700): 2 columns x 3 rows.
        final isPortrait = totalWidth < 700 || totalHeight > totalWidth;
        final cols = isPortrait ? 2 : 3;
        final rows = isPortrait ? 3 : 2;

        final spacing = totalWidth > 1100 ? 20.0 : 16.0;
        final availableHeight = totalHeight - (rows - 1) * spacing;
        final naturalCardHeight = availableHeight / rows;

        // Only allow scrolling if content is too tall on very small screens
        const minCardHeight = 92.0;
        final shouldScroll = naturalCardHeight < minCardHeight;
        final cardHeight = shouldScroll ? minCardHeight : naturalCardHeight;

        // Scale card contents proportionally to card height
        final circleDiameter = (cardHeight * 0.40).clamp(64.0, 120.0);
        final iconSize = circleDiameter * 0.60;
        final labelFontSize = (cardHeight * 0.12).clamp(22.0, 34.0);
        final radioSize = (cardHeight * 0.16).clamp(32.0, 40.0);

        Widget buildRow(int r) {
          return SizedBox(
            height: cardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int c = 0; c < cols; c++) ...[
                  if (c > 0) SizedBox(width: spacing),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final index = r * cols + c;
                        if (index >= items.length) {
                          return const SizedBox.shrink();
                        }
                        final item = items[index];
                        return _OptionCard(
                          item: item,
                          selected: selected.contains(item.id),
                          onTap: () => onTap(item.id),
                          cardHeight: cardHeight,
                          circleDiameter: circleDiameter,
                          iconSize: iconSize,
                          labelFontSize: labelFontSize,
                          radioSize: radioSize,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int r = 0; r < rows; r++) ...[
              if (r > 0) SizedBox(height: spacing),
              buildRow(r),
            ],
          ],
        );

        if (shouldScroll) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: content,
          );
        }

        return content;
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.cardHeight,
    required this.circleDiameter,
    required this.iconSize,
    required this.labelFontSize,
    required this.radioSize,
  });

  final OptionItem item;
  final bool selected;
  final VoidCallback onTap;
  final double cardHeight;
  final double circleDiameter;
  final double iconSize;
  final double labelFontSize;
  final double radioSize;

  Color _resolveColor() {
    if (item.color != null) return item.color!;
    switch (item.id) {
      case 'cleanser':
        return const Color(0xFF3F8F7B);
      case 'toner':
        return const Color(0xFF4C7FA8);
      case 'serum':
        return const Color(0xFFC4872A);
      case 'moisturiser':
        return const Color(0xFFC8566B);
      case 'sunscreen':
        return const Color(0xFFD8582B);
      case 'wholeRoutine':
        return const Color(0xFF141414);
      default:
        return Brand.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = _resolveColor();

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: selected ? itemColor : Brand.outline,
            width: selected ? 2.4 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? itemColor.withValues(alpha: 0.16)
                  : const Color(0x08000000),
              blurRadius: selected ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24.0),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (cardHeight * 0.08).clamp(14.0, 24.0),
                vertical: (cardHeight * 0.06).clamp(8.0, 18.0),
              ),
              child: Row(
                children: [
                  // Icon circle:
                  // Unselected: circle filled with item colour at 12% opacity; icon in full item colour.
                  // Selected: circle filled solid with item colour; icon in white.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? itemColor
                          : itemColor.withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: item.svgAsset != null
                        ? SvgPicture.asset(
                            item.svgAsset!,
                            width: iconSize,
                            height: iconSize,
                            colorFilter: ColorFilter.mode(
                              selected ? Colors.white : itemColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : (item.icon != null
                            ? Icon(
                                item.icon,
                                size: iconSize,
                                color: selected ? Colors.white : itemColor,
                              )
                            : (item.emoji != null
                                ? Text(
                                    item.emoji!,
                                    style: TextStyle(
                                      fontSize: iconSize,
                                    ),
                                  )
                                : const SizedBox.shrink())),
                  ),

                  SizedBox(width: (cardHeight * 0.06).clamp(12.0, 20.0)),

                  // Labels
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: Brand.primary,
                            height: 1.15,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (labelFontSize * 0.65).clamp(12.0, 16.0),
                              fontWeight: FontWeight.w500,
                              color: Brand.mutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: (cardHeight * 0.04).clamp(10.0, 16.0)),

                  // Radio circle indicator:
                  // Selected: item colour (solid fill with white dot)
                  // Unselected: light grey (#E5E5E5) border
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: radioSize,
                    height: radioSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? itemColor : Colors.transparent,
                      border: Border.all(
                        color: selected ? itemColor : const Color(0xFFE5E5E5),
                        width: 2.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: selected
                        ? Container(
                            width: radioSize * 0.38,
                            height: radioSize * 0.38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

