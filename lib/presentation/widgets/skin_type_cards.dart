import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../widgets/app_icon_badge.dart';
import 'adaptive.dart';
import 'option_grid.dart';

/// Five horizontal skin type selection cards matching RunRabbit's website aesthetic:
/// - Arranged horizontally in the same line across the screen
/// - Circular-cropped illustrated portrait avatar in the top part of each card
/// - Skin type title, descriptive cue, and selection badge below the picture
/// - Responsive scaling for kiosk tablets and phones
class SkinTypeCards extends StatelessWidget {
  const SkinTypeCards({
    super.key,
    required this.items,
    required this.selectedBase,
    required this.sensitive,
    required this.onTap,
    this.onStartQuiz,
    this.quizTitle,
    this.quizSubtitle,
  });

  final List<OptionItem> items;
  final String? selectedBase;
  final bool sensitive;
  final void Function(String id) onTap;
  final VoidCallback? onStartQuiz;
  final String? quizTitle;
  final String? quizSubtitle;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final gap = a.s(12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardCount = items.length; // 5 cards
        final singleCardWidth =
            (availableWidth - ((cardCount - 1) * gap)) / cardCount;

        // If cards can fit comfortably on one line (>= 95dp per card), display side-by-side
        final fitsInSingleLine = singleCardWidth >= a.s(95);

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (fitsInSingleLine)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        Expanded(
                          child: _SkinTypeCard(
                            item: items[i],
                            selected: items[i].id == 'sensitive'
                                ? sensitive
                                : selectedBase == items[i].id,
                            onTap: () => onTap(items[i].id),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) SizedBox(width: gap),
                          SizedBox(
                            width: a.s(136),
                            child: _SkinTypeCard(
                              item: items[i],
                              selected: items[i].id == 'sensitive'
                                  ? sensitive
                                  : selectedBase == items[i].id,
                              onTap: () => onTap(items[i].id),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (onStartQuiz != null) ...[
                  SizedBox(height: gap),
                  _QuizHelperCard(
                    title: quizTitle ?? 'Not sure? Find your skin type',
                    subtitle: quizSubtitle ?? 'Take a quick test',
                    onTap: onStartQuiz!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuizHelperCard extends StatelessWidget {
  const _QuizHelperCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Brand.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: Brand.surface,
              borderRadius: BorderRadius.circular(Brand.cardRadius),
              border: Border.all(
                color: Brand.accent.withValues(alpha: 0.35),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Brand.accent.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: a.s(56)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(18),
                  vertical: a.s(12),
                ),
                child: Row(
                  children: [
                    AppIconBadge(
                      svgAsset: 'assets/icons/sparkle.svg',
                      size: a.s(36),
                      selected: false,
                    ),
                    SizedBox(width: a.s(14)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: a.s(15),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: a.s(2)),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: a.s(12),
                              fontWeight: FontWeight.w600,
                              color: Brand.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Brand.accent,
                      size: a.s(20),
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

class _SkinTypeCard extends StatelessWidget {
  const _SkinTypeCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final OptionItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final borderColor = selected ? Brand.primary : Brand.outline;
    final borderWidth = selected ? 2.4 : 1.2;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
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
                horizontal: a.s(8),
                vertical: a.s(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Picture of the skin type cropped round in the top part of the card
                  Container(
                    width: a.s(74),
                    height: a.s(74),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Brand.primary : Brand.outlineLight,
                        width: selected ? 2.2 : 1.4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Transform.scale(
                        scale: 1.28,
                        child: Image.asset(
                          'assets/images/skin_types/${item.id}.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Brand.surfaceSubtle,
                            alignment: Alignment.center,
                            child: Text(
                              item.emoji ?? '✨',
                              style: TextStyle(fontSize: a.s(30)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: a.s(12)),

                  // Text below that: Title
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: a.s(16),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Brand.primary,
                    ),
                  ),

                  if (item.subtitle != null) ...[
                    SizedBox(height: a.s(4)),
                    Text(
                      item.subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: a.s(11),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: Brand.mutedText,
                      ),
                    ),
                  ],

                  SizedBox(height: a.s(10)),

                  // Selection Radio Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: a.s(22),
                    height: a.s(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Brand.accent : Colors.transparent,
                      border: Border.all(
                        color: selected ? Brand.accent : Brand.outline,
                        width: 1.8,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: a.s(15),
                            color: Colors.white,
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
