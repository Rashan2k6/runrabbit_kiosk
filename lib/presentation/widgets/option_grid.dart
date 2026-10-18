import 'package:flutter/material.dart';

import '../../app/brand.dart';
import 'adaptive.dart';

class OptionItem {
  const OptionItem({
    required this.id,
    required this.label,
    this.emoji,
    this.icon,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? emoji;
  final IconData? icon;
  final String? subtitle;
}

/// A scrollable grid of interactive cards aligned with RunRabbit's website aesthetic:
/// - Circular icon / avatar representations inspired by the store's concern visual categories
/// - Bold, high-contrast active state matching the website's dark pill buttons
/// - Responsive grid layout that scales across phone, compact tablet, and large display kiosks
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
    final a = Adaptive.of(context);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: a.s(380),
        mainAxisExtent: a.s(104),
        crossAxisSpacing: a.s(16),
        mainAxisSpacing: a.s(16),
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return _OptionCard(
          item: item,
          selected: selected.contains(item.id),
          onTap: () => onTap(item.id),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final OptionItem item;
  final bool selected;
  final VoidCallback onTap;

  Color _avatarBg() {
    if (selected) return Colors.white.withValues(alpha: 0.18);
    // Subtle pastels evoking cosmetic and skin-health illustrations
    switch (item.id) {
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
      case 'dry':
        return const Color(0xFFE7F5FF);
      case 'redness':
      case 'sensitive':
        return const Color(0xFFFFF0F6);
      case 'oily':
        return const Color(0xFFFFF8E6);
      case 'combination':
        return const Color(0xFFF8F9FA);
      case 'cleanser':
        return const Color(0xFFF0FDF4);
      case 'toner':
        return const Color(0xFFF0F9FF);
      case 'serum':
        return const Color(0xFFFFF7ED);
      case 'moisturiser':
        return const Color(0xFFFFF1F2);
      case 'sunscreen':
        return const Color(0xFFFEFCE8);
      case 'wholeRoutine':
        return const Color(0xFFF5F3FF);
      default:
        return Brand.surfaceSubtle;
    }
  }

  Color _iconColor() {
    if (selected) return Colors.white;
    switch (item.id) {
      case 'cleanser':
        return const Color(0xFF16A34A);
      case 'toner':
        return const Color(0xFF0284C7);
      case 'serum':
        return const Color(0xFFD97706);
      case 'moisturiser':
        return const Color(0xFFE11D48);
      case 'sunscreen':
        return const Color(0xFFCA8A04);
      case 'wholeRoutine':
        return const Color(0xFF7C3AED);
      default:
        return Brand.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final bg = selected ? Brand.primary : Brand.surface;
    final fg = selected ? Brand.onPrimary : Brand.primary;
    final subColor =
        selected ? Colors.white.withValues(alpha: 0.75) : Brand.mutedText;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Brand.cardRadius),
          border: Border.all(
            color: selected ? Brand.primary : Brand.outline,
            width: selected ? 2.0 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Brand.primary.withValues(alpha: 0.20)
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
                horizontal: a.s(18),
                vertical: a.s(14),
              ),
              child: Row(
                children: [
                  // Circular visual that keeps routine and concern cards equally scannable.
                  if (item.emoji != null || item.icon != null) ...[
                    Container(
                      width: a.s(52),
                      height: a.s(52),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _avatarBg(),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.25)
                              : Brand.outlineLight,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: item.icon != null
                          ? Icon(
                              item.icon,
                              size: a.s(27),
                              color: _iconColor(),
                            )
                          : Text(
                              item.emoji!,
                              style: TextStyle(fontSize: a.s(26)),
                            ),
                    ),
                    SizedBox(width: a.s(16)),
                  ],

                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: a.s(18),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: fg,
                            height: 1.2,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          SizedBox(height: a.s(3)),
                          Text(
                            item.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: a.s(13),
                              fontWeight: FontWeight.w500,
                              color: subColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: a.s(12)),

                  // Selection Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: a.s(26),
                    height: a.s(26),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: selected ? Colors.white : Brand.outline,
                        width: 2.0,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: a.s(18),
                            color: Brand.primary,
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
