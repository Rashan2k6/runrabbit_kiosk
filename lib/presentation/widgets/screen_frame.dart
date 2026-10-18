import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../state/flow_state.dart';
import 'adaptive.dart';

/// Shared layout matching the RunRabbit website:
/// - Distinctive uppercase brand header with tracking
/// - Flow progression indicator (Skin -> Concerns -> Steps -> Routine)
/// - Modern language toggle pill
/// - Editorial title and subtitle
/// - Generous touch targets for Back, Start Over, and Primary actions
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.flow,
    required this.s,
    required this.title,
    this.subtitle,
    required this.child,
    this.primary,
  });

  final KioskFlow flow;
  final Strings s;
  final String title;
  final String? subtitle;
  final Widget child;

  /// The one main action of the screen (optional).
  final Widget? primary;

  int _currentStep() {
    switch (flow.stage) {
      case Stage.idle:
        return 0;
      case Stage.skin:
        return 1;
      case Stage.concerns:
        return 2;
      case Stage.steps:
        return 3;
      case Stage.results:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);
    final step = _currentStep();

    return Scaffold(
      backgroundColor: Brand.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: a.s(28),
            vertical: a.s(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Brand Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Brand.name,
                        style: TextStyle(
                          fontSize: a.s(22),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.5,
                          color: Brand.primary,
                        ),
                      ),
                      Text(
                        Brand.tagline,
                        style: TextStyle(
                          fontSize: a.s(10),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Brand.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Progress Step Pills
                  if (step > 0 && step <= 4) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: a.s(12),
                        vertical: a.s(6),
                      ),
                      decoration: BoxDecoration(
                        color: Brand.surfaceSubtle,
                        borderRadius: BorderRadius.circular(Brand.pillRadius),
                        border: Border.all(color: Brand.outlineLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 1; i <= 4; i++) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: i == step ? a.s(22) : a.s(8),
                              height: a.s(8),
                              decoration: BoxDecoration(
                                color: i == step
                                    ? Brand.primary
                                    : i < step
                                        ? Brand.mutedText.withValues(alpha: 0.5)
                                        : Brand.outline,
                                borderRadius:
                                    BorderRadius.circular(Brand.pillRadius),
                              ),
                            ),
                            if (i < 4) SizedBox(width: a.s(6)),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: a.s(16)),
                  ],

                  // Language Switcher
                  InkWell(
                    onTap: () => flow.setLang(flow.lang == 'en' ? 'si' : 'en'),
                    borderRadius: BorderRadius.circular(Brand.pillRadius),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: a.s(16),
                        vertical: a.s(8),
                      ),
                      decoration: BoxDecoration(
                        color: Brand.surface,
                        borderRadius: BorderRadius.circular(Brand.pillRadius),
                        border: Border.all(color: Brand.outline, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: a.s(18),
                            color: Brand.primary,
                          ),
                          SizedBox(width: a.s(6)),
                          Text(
                            s.otherLanguageName,
                            style: TextStyle(
                              fontSize: a.s(15),
                              fontWeight: FontWeight.w700,
                              color: Brand.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: a.s(20)),

              // Title Section
              Text(
                title,
                style: TextStyle(
                  fontSize: a.s(32),
                  fontWeight: FontWeight.w800,
                  color: Brand.primary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: a.s(6)),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: a.s(17),
                    color: Brand.mutedText,
                    height: 1.3,
                  ),
                ),
              ],

              SizedBox(height: a.s(20)),

              // Main Content
              Expanded(child: child),

              SizedBox(height: a.s(14)),

              // Bottom Actions Bar
              Container(
                padding: EdgeInsets.only(top: a.s(14)),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Brand.outlineLight, width: 1.2),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: a.s(16),
                  runSpacing: a.s(12),
                  children: [
                    Wrap(
                      spacing: a.s(12),
                      runSpacing: a.s(12),
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: flow.back,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Brand.outline,
                              width: 1.4,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: a.s(20),
                              vertical: a.s(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: a.s(18),
                                color: Brand.primary,
                              ),
                              SizedBox(width: a.s(6)),
                              Text(s.t('back')),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: flow.reset,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: a.s(16),
                              vertical: a.s(14),
                            ),
                          ),
                          child: Text(s.t('startOver')),
                        ),
                      ],
                    ),
                    if (primary != null) primary!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
