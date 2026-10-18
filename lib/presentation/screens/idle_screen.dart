import 'package:flutter/material.dart';

import '../../app/brand.dart';
import '../../app/strings.dart';
import '../state/flow_state.dart';
import '../widgets/adaptive.dart';

/// Clean, minimal attract screen for shoppers walking past the kiosk.
/// Any touch on the screen starts the skincare routine consultation.
class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);

    return Scaffold(
      backgroundColor: Brand.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen touch detector to start the flow
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: flow.start,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: a.s(32),
                      vertical: a.s(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Brand.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: a.s(60),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: Brand.primary,
                          ),
                        ),
                        SizedBox(height: a.s(16)),
                        Text(
                          s.t('tagline'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: a.s(26),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            color: Brand.mutedText,
                          ),
                        ),
                        SizedBox(height: a.s(48)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: a.s(44),
                            vertical: a.s(22),
                          ),
                          decoration: BoxDecoration(
                            color: Brand.primary,
                            borderRadius: BorderRadius.circular(Brand.radius),
                            boxShadow: [
                              BoxShadow(
                                color: Brand.primary.withValues(alpha: 0.16),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.t('touchStart'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: a.s(24),
                                  fontWeight: FontWeight.w700,
                                  color: Brand.onPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: a.s(12)),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: a.s(24),
                                color: Brand.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top-right language switcher pill
            Positioned(
              top: a.s(16),
              right: a.s(20),
              child: InkWell(
                onTap: () => flow.setLang(flow.lang == 'en' ? 'si' : 'en'),
                borderRadius: BorderRadius.circular(Brand.pillRadius),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: a.s(14),
                    vertical: a.s(7),
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
                        size: a.s(16),
                        color: Brand.primary,
                      ),
                      SizedBox(width: a.s(6)),
                      Text(
                        s.otherLanguageName,
                        style: TextStyle(
                          fontSize: a.s(13),
                          fontWeight: FontWeight.w700,
                          color: Brand.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
