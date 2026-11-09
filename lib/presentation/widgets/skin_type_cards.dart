import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../widgets/app_icon_badge.dart';
import 'adaptive.dart';
import 'option_grid.dart';

/// Skin type selection for RunRabbit kiosk:
/// - 4 base skin types (Oily, Dry, Combination, Normal) in 1 row (landscape) or 2x2 (portrait)
///   with circular-cropped illustrated avatar and radio selection indicator.
/// - Separate full-width toggle card for Sensitive skin below the base cards, with an icon,
///   description, hint badge, and a switch on the right.
/// - Quiz helper card below.
class SkinTypeCards extends StatelessWidget {
  const SkinTypeCards({
    super.key,
    required this.items,
    required this.selectedBase,
    required this.sensitive,
    this.onTap,
    this.onPickBase,
    this.onToggleSensitive,
    this.sensitiveTitle,
    this.sensitiveDesc,
    this.sensitiveHint,
    this.onStartQuiz,
    this.quizTitle,
    this.quizSubtitle,
  });

  final List<OptionItem> items;
  final String? selectedBase;
  final bool sensitive;
  final void Function(String id)? onTap;
  final void Function(String id)? onPickBase;
  final VoidCallback? onToggleSensitive;
  final String? sensitiveTitle;
  final String? sensitiveDesc;
  final String? sensitiveHint;
  final VoidCallback? onStartQuiz;
  final String? quizTitle;
  final String? quizSubtitle;

  void _handlePickBase(String id) {
    if (onPickBase != null) {
      onPickBase!(id);
    } else if (onTap != null) {
      onTap!(id);
    }
  }

  void _handleToggleSensitive() {
    if (onToggleSensitive != null) {
      onToggleSensitive!();
    } else if (onTap != null) {
      onTap!('sensitive');
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final gap = a.s(12);

    // Keep only the 4 base skin types for the pick-one grid
    final baseCards = items.where((i) => i.id != 'sensitive').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.orientationOf(context);
        final isLandscape = orientation == Orientation.landscape ||
            constraints.maxWidth > constraints.maxHeight;
        final isShortLandscape = isLandscape && constraints.maxHeight < 330;
        final cardGap = isShortLandscape ? a.s(6) : gap;

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Base Skin Types: 1 row in landscape, 2x2 in portrait
                if (isLandscape)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < baseCards.length; i++) ...[
                          if (i > 0) SizedBox(width: cardGap),
                          Expanded(
                            child: _SkinTypeCard(
                              item: baseCards[i],
                              selected: selectedBase == baseCards[i].id,
                              onTap: () => _handlePickBase(baseCards[i].id),
                              compact: isShortLandscape,
                              avatarSize: isShortLandscape ? a.s(44) : null,
                              verticalPadding: isShortLandscape ? a.s(6) : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var r = 0; r < baseCards.length; r += 2) ...[
                        if (r > 0) SizedBox(height: gap),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _SkinTypeCard(
                                  item: baseCards[r],
                                  selected: selectedBase == baseCards[r].id,
                                  onTap: () => _handlePickBase(baseCards[r].id),
                                  compact: true,
                                ),
                              ),
                              SizedBox(width: gap),
                              if (r + 1 < baseCards.length)
                                Expanded(
                                  child: _SkinTypeCard(
                                    item: baseCards[r + 1],
                                    selected: selectedBase ==
                                        baseCards[r + 1].id,
                                    onTap: () => _handlePickBase(
                                        baseCards[r + 1].id),
                                    compact: true,
                                  ),
                                )
                              else
                                const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                SizedBox(height: cardGap),

                // Separate full-width Sensitive toggle card
                _SensitiveToggleCard(
                  selected: sensitive,
                  onToggle: _handleToggleSensitive,
                  title: sensitiveTitle ?? 'Sensitive',
                  description: sensitiveDesc ??
                      'Redness, stinging or itching easily',
                  hint: sensitiveHint ??
                      'Choose this as well as a skin type',
                  compact: isShortLandscape,
                ),

                if (onStartQuiz != null) ...[
                  SizedBox(height: cardGap),
                  _QuizHelperCard(
                    title: quizTitle ?? 'Not sure? Find your skin type',
                    subtitle: quizSubtitle ?? 'Take a quick test',
                    onTap: onStartQuiz!,
                    compact: isShortLandscape,
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

class _SensitiveToggleCard extends StatelessWidget {
  const _SensitiveToggleCard({
    required this.selected,
    required this.onToggle,
    required this.title,
    required this.description,
    required this.hint,
    this.compact = false,
  });

  final bool selected;
  final VoidCallback onToggle;
  final String title;
  final String description;
  final String hint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final isSi = Theme.of(context).textTheme.bodyLarge?.fontFamily ==
            Brand.sinhalaFontFamily ||
        DefaultTextStyle.of(context).style.fontFamily ==
            Brand.sinhalaFontFamily;

    final borderColor = selected
        ? Brand.accent
        : Brand.accent.withValues(alpha: 0.28);
    final bgColor = selected
        ? Brand.accent.withValues(alpha: 0.09)
        : Brand.accent.withValues(alpha: 0.035);

    return Semantics(
      button: true,
      toggled: selected,
      label: '$title, $description. $hint',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(Brand.cardRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(Brand.cardRadius),
              border: Border.all(
                color: borderColor,
                width: selected ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? Brand.accent.withValues(alpha: 0.12)
                      : const Color(0x06000000),
                  blurRadius: selected ? 10 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? a.s(12) : a.s(16),
                vertical: compact ? a.s(6) : a.s(12),
              ),
              child: Row(
                children: [
                  AppIconBadge(
                    icon: Icons.spa_rounded,
                    size: compact ? a.s(28) : a.s(40),
                    selected: selected,
                  ),
                  SizedBox(width: compact ? a.s(10) : a.s(14)),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: a.s(8),
                          runSpacing: a.s(4),
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: compact ? a.s(14) : a.s(16),
                                fontWeight: FontWeight.w800,
                                color: Brand.primary,
                                letterSpacing: -0.2,
                                height: isSi ? Brand.sinhalaLineHeight : null,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? a.s(6) : a.s(8),
                                vertical: compact ? a.s(1.5) : a.s(2),
                              ),
                              decoration: BoxDecoration(
                                color: Brand.accent.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(Brand.pillRadius),
                              ),
                              child: Text(
                                hint,
                                style: TextStyle(
                                  fontSize: compact ? a.s(10) : a.s(11),
                                  fontWeight: FontWeight.w700,
                                  color: Brand.accent,
                                  height: isSi ? Brand.sinhalaLineHeight : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: a.s(3)),
                        Text(
                          description,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: compact ? a.s(11) : a.s(12),
                            fontWeight: FontWeight.w500,
                            color: Brand.mutedText,
                            height: isSi ? Brand.sinhalaLineHeight : 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: a.s(10)),
                  compact
                      ? Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: selected,
                            onChanged: (_) => onToggle(),
                            activeTrackColor: Brand.accent,
                            activeThumbColor: Colors.white,
                          ),
                        )
                      : Switch.adaptive(
                          value: selected,
                          onChanged: (_) => onToggle(),
                          activeTrackColor: Brand.accent,
                          activeThumbColor: Colors.white,
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

class _QuizHelperCard extends StatelessWidget {
  const _QuizHelperCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool compact;

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
              constraints:
                  BoxConstraints(minHeight: compact ? a.s(40) : a.s(56)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? a.s(12) : a.s(18),
                  vertical: compact ? a.s(6) : a.s(12),
                ),
                child: Row(
                  children: [
                    AppIconBadge(
                      svgAsset: 'assets/icons/sparkle.svg',
                      size: compact ? a.s(26) : a.s(36),
                      selected: false,
                    ),
                    SizedBox(width: compact ? a.s(10) : a.s(14)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: compact ? a.s(13) : a.s(15),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: a.s(2)),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: compact ? a.s(11) : a.s(12),
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
                      size: compact ? a.s(16) : a.s(20),
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
    this.compact = false,
    this.avatarSize,
    this.verticalPadding,
  });

  final OptionItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;
  final double? avatarSize;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final isSi = Theme.of(context).textTheme.bodyLarge?.fontFamily ==
            Brand.sinhalaFontFamily ||
        DefaultTextStyle.of(context).style.fontFamily ==
            Brand.sinhalaFontFamily;
    final borderColor = selected ? Brand.primary : Brand.outline;
    final borderWidth = selected ? 2.4 : 1.2;
    final avatarDimension = avatarSize ?? (compact ? a.s(58) : a.s(68));

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
                vertical: verticalPadding ?? (compact ? a.s(10) : a.s(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Picture of the skin type cropped round in the top part of the card
                  Container(
                    width: avatarDimension,
                    height: avatarDimension,
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
                              style:
                                  TextStyle(fontSize: avatarDimension * 0.44),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: compact ? a.s(6) : a.s(10)),

                  // Text below that: Title
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: isSi ? 2 : 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? a.s(14) : a.s(16),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Brand.primary,
                      height: isSi ? Brand.sinhalaLineHeight : null,
                    ),
                  ),

                  if (item.subtitle != null) ...[
                    SizedBox(height: a.s(2)),
                    Text(
                      item.subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? a.s(10) : a.s(11),
                        fontWeight: FontWeight.w500,
                        height: isSi ? Brand.sinhalaLineHeight : 1.25,
                        color: Brand.mutedText,
                      ),
                    ),
                  ],

                  const Spacer(),
                  SizedBox(height: a.s(4)),

                  // Selection Radio Indicator (radio circle for the pick-one base cards)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: compact ? a.s(18) : a.s(22),
                    height: compact ? a.s(18) : a.s(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Brand.accent : Colors.transparent,
                      border: Border.all(
                        color: selected ? Brand.accent : Brand.outline,
                        width: compact ? 1.5 : 1.8,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: compact ? a.s(12) : a.s(15),
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
