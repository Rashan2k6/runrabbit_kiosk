import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../../domain/skin_quiz.dart';
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: a.s(640)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: a.s(12),
                          vertical: a.s(4),
                        ),
                        decoration: BoxDecoration(
                          color: Brand.surfaceSubtle,
                          borderRadius: BorderRadius.circular(Brand.pillRadius),
                          border: Border.all(color: Brand.outlineLight),
                        ),
                        child: Text(
                          s.t('quizProgress', {'n': '$questionNumber'}),
                          style: TextStyle(
                            fontSize: a.s(12),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: Brand.mutedText,
                          ),
                        ),
                      ),
                      SizedBox(height: a.s(16)),
                      Text(
                        questionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: a.s(22),
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          letterSpacing: -0.3,
                          color: Brand.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: a.s(16)),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: math.max(64.0, a.s(64)),
                        child: OutlinedButton(
                          onPressed: () => flow.answerQuizQuestion(false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Brand.surface,
                            side: const BorderSide(
                              color: Brand.outline,
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Brand.cardRadius),
                            ),
                          ),
                          child: Text(
                            s.t('no'),
                            style: TextStyle(
                              fontSize: a.s(18),
                              fontWeight: FontWeight.w800,
                              color: Brand.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: a.s(14)),
                    Expanded(
                      child: SizedBox(
                        height: math.max(64.0, a.s(64)),
                        child: FilledButton(
                          onPressed: () => flow.answerQuizQuestion(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Brand.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Brand.cardRadius),
                            ),
                          ),
                          child: Text(
                            s.t('yes'),
                            style: TextStyle(
                              fontSize: a.s(18),
                              fontWeight: FontWeight.w800,
                              color: Brand.onPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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

  IconData _concernIcon(String id) {
    switch (id) {
      case 'sensitive':
        return Icons.health_and_safety_outlined;
      case 'uneven':
        return Icons.tonality_rounded;
      case 'wrinkled':
        return Icons.waves_rounded;
      default:
        return Icons.spa_outlined;
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
                        Container(
                          width: a.s(44),
                          height: a.s(44),
                          decoration: BoxDecoration(
                            color: Brand.surfaceSubtle,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Brand.outlineLight,
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            _concernIcon(concern.id),
                            color: Brand.primary,
                            size: a.s(22),
                          ),
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
