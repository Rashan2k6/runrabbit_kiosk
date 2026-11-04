import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../../domain/skin_quiz.dart';
import '../../widgets/app_icon_badge.dart';
import '../state/flow_state.dart';
import '../widgets/adaptive.dart';
import '../widgets/screen_frame.dart';

class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final questionNumber = flow.quizHistory.length + 1;
    final node = SkinQuiz.questions[flow.currentQuizNodeId] ??
        SkinQuiz.questions[SkinQuiz.startNodeId]!;
    final questionText = s.t(node.textKey);

    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('quizTitle'),
      subtitle: s.t('quizSubtitle'),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final spacing = (availableHeight * 0.035).clamp(20.0, 28.0);

              Widget buildCard() {
                return LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final cardHeight = cardConstraints.maxHeight;
                    final questionFontSize =
                        (cardHeight * 0.105).clamp(34.0, 46.0);
                    final pillGap = (cardHeight * 0.035).clamp(12.0, 18.0);
                    final iconGap = (cardHeight * 0.045).clamp(14.0, 22.0);

                    return Container(
                      decoration: BoxDecoration(
                        color: Brand.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: const Color(0xFFEAEAEE), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 24,
                            offset: Offset(0, 6),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: a.s(36).clamp(24.0, 60.0),
                            vertical: 16.0,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: math.max(
                                    280.0, cardConstraints.maxWidth - 64.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // White "QUESTION N" pill matching reference image
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          a.s(18).clamp(14.0, 22.0),
                                      vertical: a.s(7).clamp(6.0, 9.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          Brand.pillRadius),
                                      border: Border.all(
                                        color: const Color(0xFFE2E2E8),
                                        width: 1.2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x05000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      s
                                          .t('quizProgress',
                                              {'n': '$questionNumber'})
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize:
                                            a.s(13).clamp(12.0, 15.0),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.8,
                                        color: const Color(0xFF6E6E73),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pillGap),
                                  // Dark circle with white question mark & warm glow
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2E),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Brand.accent
                                              .withValues(alpha: 0.32),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                        const BoxShadow(
                                          color: Color(0x18000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.question_mark_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: iconGap),
                                  // Bold question text
                                  Text(
                                    questionText,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: questionFontSize,
                                      fontWeight: FontWeight.w800,
                                      height: 1.24,
                                      letterSpacing: -0.6,
                                      color: const Color(0xFF141414),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              Widget buildButtons() {
                return LayoutBuilder(
                  builder: (context, buttonConstraints) {
                    final buttonHeight = buttonConstraints.maxHeight;
                    final buttonFontSize =
                        (buttonHeight * 0.22).clamp(26.0, 30.0);
                    final minButtonHeight = math.min(96.0, buttonHeight);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _QuizAnswerButton(
                            label: s.t('no'),
                            backgroundColor: Brand.surface,
                            foregroundColor: Brand.primary,
                            borderColor: const Color(0xFFE2E2E8),
                            fontSize: buttonFontSize,
                            minHeight: minButtonHeight,
                            onTap: () => flow.answerQuizQuestion(false),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _QuizAnswerButton(
                            label: s.t('yes'),
                            backgroundColor: Brand.primary,
                            foregroundColor: Brand.onPrimary,
                            fontSize: buttonFontSize,
                            minHeight: minButtonHeight,
                            onTap: () => flow.answerQuizQuestion(true),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              final helperLine = Text(
                s.t('quizHelper'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: a.s(16.5).clamp(16.0, 18.0),
                  fontWeight: FontWeight.w500,
                  color: Brand.mutedText,
                  height: 1.3,
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 50,
                    child: buildCard(),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    flex: 25,
                    child: buildButtons(),
                  ),
                  SizedBox(height: spacing),
                  helperLine,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizAnswerButton extends StatefulWidget {
  const _QuizAnswerButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.fontSize,
    required this.minHeight,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double fontSize;
  final double minHeight;
  final VoidCallback onTap;

  @override
  State<_QuizAnswerButton> createState() => _QuizAnswerButtonState();
}

class _QuizAnswerButtonState extends State<_QuizAnswerButton> {
  bool _isPressed = false;

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _onTap,
        child: Semantics(
          button: true,
          label: widget.label,
          child: Container(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1.5)
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: widget.foregroundColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizConcernScreen extends StatelessWidget {
  const QuizConcernScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);

    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('quizConcernTitle'),
      subtitle: s.t('quizConcernSubtitle'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= a.s(540);
          final gap = a.s(16);

          final cardWidgets = [
            for (final concern in SkinQuiz.concerns)
              _ConcernOptionCard(
                concern: concern,
                s: s,
                a: a,
                onTap: () => flow.pickQuizConcern(concern.id),
              ),
          ];

          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: a.s(1100)),
                child: isWide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < cardWidgets.length; i++) ...[
                              if (i > 0) SizedBox(width: gap),
                              Expanded(child: cardWidgets[i]),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < cardWidgets.length; i++) ...[
                            if (i > 0) SizedBox(height: gap),
                            cardWidgets[i],
                          ],
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConcernOptionCard extends StatelessWidget {
  const _ConcernOptionCard({
    required this.concern,
    required this.s,
    required this.a,
    required this.onTap,
  });

  final QuizConcernOption concern;
  final Strings s;
  final Adaptive a;
  final VoidCallback onTap;

  String _concernSvg(String id) {
    switch (id) {
      case 'sensitive':
        return 'assets/icons/shield_check.svg';
      case 'uneven':
        return 'assets/icons/scales.svg';
      case 'wrinkled':
        return 'assets/icons/wave_sine.svg';
      default:
        return 'assets/icons/sparkle.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = s.t(concern.nameKey);
    final s1 = s.t(concern.symptom1Key);
    final s2 = s.t(concern.symptom2Key);

    return Semantics(
      button: true,
      label: '$label, $s1, $s2',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Brand.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: Brand.surface,
              borderRadius: BorderRadius.circular(Brand.cardRadius),
              border: Border.all(color: Brand.outline, width: 1.6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: a.s(210)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(22),
                  vertical: a.s(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppIconBadge(
                          svgAsset: _concernSvg(concern.id),
                          size: a.s(44),
                          selected: false,
                        ),
                        SizedBox(width: a.s(14)),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: a.s(21),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: a.s(22)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SymptomRow(text: s1, a: a),
                        SizedBox(height: a.s(12)),
                        _SymptomRow(text: s2, a: a),
                      ],
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

class _SymptomRow extends StatelessWidget {
  const _SymptomRow({required this.text, required this.a});

  final String text;
  final Adaptive a;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: a.s(3)),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: a.s(16),
            color: Brand.accent,
          ),
        ),
        SizedBox(width: a.s(10)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: a.s(15),
              fontWeight: FontWeight.w600,
              color: Brand.primary.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final result = flow.quizResult;
    final code = result?.code ?? '';
    final label = result?.label ?? '';

    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('quizResultTitle'),
      subtitle: null,
      primary: FilledButton(
        onPressed: flow.applyQuizAndContinue,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: a.s(26),
            vertical: a.s(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.t('continue'),
              style: TextStyle(
                fontSize: a.s(16),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: a.s(8)),
            Icon(Icons.arrow_forward_rounded, size: a.s(18)),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: a.s(560)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Result Card
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: a.s(24),
                    vertical: a.s(24),
                  ),
                  decoration: BoxDecoration(
                    color: Brand.surface,
                    borderRadius: BorderRadius.circular(Brand.cardRadius),
                    border: Border.all(color: Brand.outline, width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 14,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large 2-Letter Code Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: a.s(20),
                          vertical: a.s(8),
                        ),
                        decoration: BoxDecoration(
                          color: Brand.surfaceSelected,
                          borderRadius: BorderRadius.circular(Brand.pillRadius),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            fontSize: a.s(32),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: Brand.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: a.s(14)),

                      // Full Label in large text (e.g. Dry | Sensitive)
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: a.s(24),
                          fontWeight: FontWeight.w800,
                          color: Brand.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: a.s(12)),

                      // One short sentence: suggestion disclaimer
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: a.s(14),
                          vertical: a.s(8),
                        ),
                        decoration: BoxDecoration(
                          color: Brand.surfaceSubtle,
                          borderRadius: BorderRadius.circular(Brand.radius),
                          border: Border.all(color: Brand.outlineLight),
                        ),
                        child: Text(
                          s.t('quizResultDisclaimer'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: a.s(13),
                            fontWeight: FontWeight.w500,
                            color: Brand.mutedText,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: a.s(16)),

                // Secondary Button: Choose a different skin type
                Center(
                  child: OutlinedButton(
                    onPressed: flow.chooseDifferentSkinType,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Brand.outline, width: 1.4),
                      padding: EdgeInsets.symmetric(
                        horizontal: a.s(20),
                        vertical: a.s(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Brand.pillRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: a.s(18),
                          color: Brand.primary,
                        ),
                        SizedBox(width: a.s(8)),
                        Text(
                          s.t('chooseDifferentSkin'),
                          style: TextStyle(
                            fontSize: a.s(14),
                            fontWeight: FontWeight.w700,
                            color: Brand.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
