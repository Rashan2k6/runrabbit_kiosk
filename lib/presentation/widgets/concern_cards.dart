import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../domain/options.dart';
import 'adaptive.dart';
import 'option_grid.dart';

/// Eight skin concern selection cards matching RunRabbit's website aesthetic:
/// - Horizontal item arrangement inside each card:
///   1. First: Large, prominent circular portrait image zoomed in on the skin concern
///   2. Second: Concern title and descriptive subtitle
///   3. Third: Selection indicator with check mark
/// - Neat 2-column or 1-column responsive layout managing space carefully
/// - Clean card surface, border highlight, and soft shadow matching SkinTypeCards
class ConcernCards extends StatelessWidget {
  const ConcernCards({
    super.key,
    required this.items,
    required this.selected,
    required this.onTap,
    this.maxSelections = maxConcerns,
  });

  final List<OptionItem> items;
  final Set<String> selected;
  final void Function(String id) onTap;
  final int maxSelections;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final isMaxedOut = selected.length >= maxSelections;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Use 2 columns on wide/tablet screens (4 cards per column = 8 total),
        // and 1 column on narrow/phone screens with smooth bouncing scroll.
        final isTwoColumn = availableWidth >= a.s(580);
        final crossAxisCount = isTwoColumn ? 2 : 1;
        final rowCount = (items.length / crossAxisCount).ceil();

        final hGap = a.s(14);
        final vGap = a.s(10);

        final cardWidth =
            (availableWidth - ((crossAxisCount - 1) * hGap)) / crossAxisCount;

        // Height tuned to give the large concern avatar plenty of space
        // while fitting gracefully in the viewport on tablets.
        final minCardHeight = a.s(96);
        final maxCardHeight = a.s(128);
        final idealCardHeight =
            (availableHeight - ((rowCount - 1) * vGap)) / rowCount;

        final cardHeight = idealCardHeight.clamp(minCardHeight, maxCardHeight);
        final childAspectRatio = cardWidth / cardHeight;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: hGap,
            mainAxisSpacing: vGap,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            final isSelected = selected.contains(item.id);
            final isDimmed = !isSelected && isMaxedOut;

            return _ConcernCard(
              item: item,
              selected: isSelected,
              dimmed: isDimmed,
              cardHeight: cardHeight,
              onTap: () => onTap(item.id),
            );
          },
        );
      },
    );
  }
}

class _ConcernCard extends StatelessWidget {
  const _ConcernCard({
    required this.item,
    required this.selected,
    required this.dimmed,
    required this.cardHeight,
    required this.onTap,
  });

  final OptionItem item;
  final bool selected;
  final bool dimmed;
  final double cardHeight;
  final VoidCallback onTap;

  Color _avatarBg(String id) {
    switch (id) {
      case 'acne':
        return const Color(0xFFFFECEB);
      case 'pores':
        return const Color(0xFFF1F3F5);
      case 'pigmentation':
        return const Color(0xFFFFF4E6);
      case 'dullness':
        return const Color(0xFFFFF9DB);
      case 'aging':
        return const Color(0xFFF3F0FF);
      case 'darkcircles':
        return const Color(0xFFEBFBEE);
      case 'dryness':
        return const Color(0xFFE7F5FF);
      case 'redness':
        return const Color(0xFFFFF0F6);
      default:
        return Brand.surfaceSubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final borderColor = selected ? Brand.primary : Brand.outline;
    final borderWidth = selected ? 2.4 : 1.2;

    // Substantially larger avatar (68-84dp) so facial and skin details are prominent
    final avatarSize = (cardHeight * 0.72).clamp(a.s(68), a.s(84));

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.55 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Brand.surface,
            borderRadius: BorderRadius.circular(Brand.cardRadius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? Brand.primary.withValues(alpha: 0.16)
                    : const Color(0x08000000),
                blurRadius: selected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Brand.cardRadius),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(14),
                  vertical: a.s(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Large, clear image defining the concern
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _avatarBg(item.id),
                        border: Border.all(
                          color: selected ? Brand.primary : Brand.outlineLight,
                          width: selected ? 2.4 : 1.6,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          // Zoom by 1.28 to eliminate outer cream margins and fill circle with face
                          scale: 1.28,
                          child: Image.asset(
                            'assets/images/concerns/${item.id}.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: _avatarBg(item.id),
                              alignment: Alignment.center,
                              child: Text(
                                item.emoji ?? '✨',
                                style: TextStyle(
                                  fontSize: avatarSize * 0.44,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: a.s(14)),

                    // 2. The texts: Title and Subtitle
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
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
                                fontSize: a.s(16),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                height: 1.18,
                                color: Brand.primary,
                              ),
                            ),
                            if (item.subtitle != null) ...[
                              SizedBox(height: a.s(3)),
                              Text(
                                item.subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: a.s(12),
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                  color: Brand.mutedText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: a.s(12)),

                    // 3. The check mark
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: a.s(26),
                      height: a.s(26),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Brand.primary : Colors.transparent,
                        border: Border.all(
                          color: selected ? Brand.primary : Brand.outline,
                          width: 1.8,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check_rounded,
                              size: a.s(17),
                              color: Brand.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
