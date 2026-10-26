import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../domain/product.dart';
import '../presentation/screens/idle_screen.dart';
import '../presentation/screens/option_screens.dart';
import '../presentation/screens/quiz_screens.dart';
import '../presentation/screens/results_screen.dart';
import '../presentation/state/flow_state.dart';
import '../presentation/widgets/adaptive.dart';
import 'brand.dart';
import 'strings.dart';
import 'theme.dart';

class KioskApp extends StatelessWidget {
  KioskApp({
    super.key,
    ProductRepository? repository,
    Duration? idleTimeout,
    Duration? standardWarnAfter,
    Duration? standardWarnFor,
    Duration? resultsWarnAfter,
    Duration? resultsWarnFor,
  })  : repository = repository ?? JsonProductRepository(),
        standardWarnAfter = standardWarnAfter ??
            (idleTimeout != null
                ? idleTimeout * 0.75
                : const Duration(seconds: 45)),
        standardWarnFor = standardWarnFor ??
            (idleTimeout != null
                ? idleTimeout * 0.25
                : const Duration(seconds: 15)),
        resultsWarnAfter = resultsWarnAfter ??
            (idleTimeout != null
                ? idleTimeout * 1.25
                : const Duration(seconds: 75)),
        resultsWarnFor = resultsWarnFor ??
            (idleTimeout != null
                ? idleTimeout * 0.25
                : const Duration(seconds: 15));

  final ProductRepository repository;

  /// Duration before showing the idle warning on standard screens.
  final Duration standardWarnAfter;

  /// How long the idle warning is displayed on standard screens before resetting.
  final Duration standardWarnFor;

  /// Duration before showing the idle warning on the Results screen.
  final Duration resultsWarnAfter;

  /// How long the idle warning is displayed on the Results screen before resetting.
  final Duration resultsWarnFor;

  /// Compatibility getter for legacy callers.
  Duration get idleTimeout => standardWarnAfter + standardWarnFor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RunRabbit Kiosk',
      theme: buildTheme(),
      // Cap the system font scale so a changed device setting cannot break layouts.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: child!,
      ),
      home: KioskHome(
        repository: repository,
        standardWarnAfter: standardWarnAfter,
        standardWarnFor: standardWarnFor,
        resultsWarnAfter: resultsWarnAfter,
        resultsWarnFor: resultsWarnFor,
      ),
    );
  }
}

class KioskHome extends StatefulWidget {
  const KioskHome({
    super.key,
    required this.repository,
    this.standardWarnAfter = const Duration(seconds: 45),
    this.standardWarnFor = const Duration(seconds: 15),
    this.resultsWarnAfter = const Duration(seconds: 75),
    this.resultsWarnFor = const Duration(seconds: 15),
    Duration? idleTimeout,
  }) : _legacyIdleTimeout = idleTimeout;

  final ProductRepository repository;
  final Duration standardWarnAfter;
  final Duration standardWarnFor;
  final Duration resultsWarnAfter;
  final Duration resultsWarnFor;
  final Duration? _legacyIdleTimeout;

  Duration get effectiveStandardWarnAfter =>
      _legacyIdleTimeout != null ? _legacyIdleTimeout * 0.75 : standardWarnAfter;
  Duration get effectiveStandardWarnFor =>
      _legacyIdleTimeout != null ? _legacyIdleTimeout * 0.25 : standardWarnFor;
  Duration get effectiveResultsWarnAfter =>
      _legacyIdleTimeout != null ? _legacyIdleTimeout * 1.25 : resultsWarnAfter;
  Duration get effectiveResultsWarnFor =>
      _legacyIdleTimeout != null ? _legacyIdleTimeout * 0.25 : resultsWarnFor;

  @override
  State<KioskHome> createState() => _KioskHomeState();
}

class _KioskHomeState extends State<KioskHome> {
  final KioskFlow _flow = KioskFlow();
  late final Future<List<Product>> _products = widget.repository.loadAll();

  Timer? _warnTimer;
  Timer? _resetTimer;
  Timer? _countdownTicker;

  bool _showWarning = false;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _flow.addListener(_onFlowChanged);
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _flow.removeListener(_onFlowChanged);
    _flow.dispose();
    super.dispose();
  }

  void _onFlowChanged() {
    if (_flow.stage == Stage.idle) {
      _cancelAllTimers();
      if (_showWarning) {
        setState(() {
          _showWarning = false;
        });
      }
      return;
    }
    // Re-arm when stage changes (e.g., to/from Results screen which has different timing)
    _armCycle();
  }

  void _cancelAllTimers() {
    _warnTimer?.cancel();
    _warnTimer = null;
    _resetTimer?.cancel();
    _resetTimer = null;
    _countdownTicker?.cancel();
    _countdownTicker = null;
  }

  /// Restarts the idle cycle from the beginning.
  void _armCycle() {
    _cancelAllTimers();
    if (_showWarning) {
      setState(() {
        _showWarning = false;
      });
    }

    if (_flow.stage == Stage.idle) return;

    final warnAfter = _flow.stage == Stage.results
        ? widget.effectiveResultsWarnAfter
        : widget.effectiveStandardWarnAfter;

    _warnTimer = Timer(warnAfter, _triggerWarning);
  }

  void _triggerWarning() {
    final warnFor = _flow.stage == Stage.results
        ? widget.effectiveResultsWarnFor
        : widget.effectiveStandardWarnFor;

    final seconds = math.max(1, warnFor.inSeconds);

    setState(() {
      _showWarning = true;
      _secondsRemaining = seconds;
    });

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining -= 1;
        });
      } else {
        timer.cancel();
      }
    });

    _resetTimer = Timer(warnFor, () {
      _cancelAllTimers();
      setState(() {
        _showWarning = false;
      });
      _flow.reset();
    });
  }

  void _dismissWarningAndRestart() {
    _armCycle();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // the Android back button must not leave the app
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          if (!_showWarning) {
            _armCycle();
          }
        },
        child: Scaffold(
          body: ListenableBuilder(
            listenable: _flow,
            builder: (context, _) {
              final s = Strings(_flow.lang);
              return Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<List<Product>>(
                    future: _products,
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              s.t('error'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        );
                      }
                      if (!snap.hasData) return const SizedBox.shrink();
                      switch (_flow.stage) {
                        case Stage.idle:
                          return IdleScreen(flow: _flow, s: s);
                        case Stage.skin:
                          return SkinTypeScreen(flow: _flow, s: s);
                        case Stage.quizQuestion:
                          return QuizQuestionScreen(flow: _flow, s: s);
                        case Stage.quizConcern:
                          return QuizConcernScreen(flow: _flow, s: s);
                        case Stage.quizResult:
                          return QuizResultScreen(flow: _flow, s: s);
                        case Stage.concerns:
                          return ConcernsScreen(flow: _flow, s: s);
                        case Stage.steps:
                          return StepsScreen(flow: _flow, s: s);
                        case Stage.results:
                          return ResultsScreen(
                            flow: _flow,
                            s: s,
                            products: snap.data!,
                          );
                      }
                    },
                  ),
                  if (_showWarning && _flow.stage != Stage.idle)
                    _IdleWarningOverlay(
                      s: s,
                      secondsRemaining: _secondsRemaining,
                      onDismiss: _dismissWarningAndRestart,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _IdleWarningOverlay extends StatelessWidget {
  const _IdleWarningOverlay({
    required this.s,
    required this.secondsRemaining,
    required this.onDismiss,
  });

  final Strings s;
  final int secondsRemaining;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final a = Adaptive.of(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: s.t('idleWarningTitle'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: Container(
          color: const Color(0xB80A0A0C), // Deep, soft obsidian backdrop
          padding: EdgeInsets.symmetric(
            horizontal: a.s(28),
            vertical: a.s(24),
          ),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: a.s(480)),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Brand.surface,
                  borderRadius: BorderRadius.circular(Brand.cardRadius + 6),
                  border: Border.all(
                    color: Brand.outlineLight,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x38000000),
                      blurRadius: 36,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: a.s(32),
                  vertical: a.s(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Badge / Category cue
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: a.s(14),
                        vertical: a.s(5),
                      ),
                      decoration: BoxDecoration(
                        color: Brand.surfaceSubtle,
                        borderRadius: BorderRadius.circular(Brand.pillRadius),
                        border: Border.all(color: Brand.outlineLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            size: a.s(14),
                            color: Brand.accent,
                          ),
                          SizedBox(width: a.s(6)),
                          Text(
                            Brand.name,
                            style: TextStyle(
                              fontSize: a.s(11),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: Brand.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: a.s(20)),

                    // Premium Editorial Countdown Circular Indicator
                    Container(
                      width: a.s(104),
                      height: a.s(104),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Brand.surfaceSubtle,
                        border: Border.all(
                          color: Brand.accent.withValues(alpha: 0.22),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Brand.accent.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$secondsRemaining',
                        style: TextStyle(
                          fontSize: a.s(48),
                          fontWeight: FontWeight.w900,
                          color: Brand.primary,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: a.s(22)),

                    // Heading Title
                    Text(
                      s.t('idleWarningTitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: a.s(25),
                        fontWeight: FontWeight.w800,
                        color: Brand.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: a.s(8)),

                    // Informative description line
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: a.s(12)),
                      child: Text(
                        s.t('idleWarningBody', {'n': '$secondsRemaining'}),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: a.s(14),
                          fontWeight: FontWeight.w500,
                          color: Brand.mutedText,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: a.s(28)),

                    // High-contrast primary touch target
                    SizedBox(
                      width: double.infinity,
                      height: math.max(64.0, a.s(64)),
                      child: Semantics(
                        button: true,
                        label: s.t('idleWarningStay'),
                        child: FilledButton(
                          onPressed: onDismiss,
                          style: FilledButton.styleFrom(
                            backgroundColor: Brand.primary,
                            foregroundColor: Brand.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Brand.cardRadius),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: a.s(20),
                                color: Brand.onPrimary,
                              ),
                              SizedBox(width: a.s(10)),
                              Text(
                                s.t('idleWarningStay'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: a.s(17),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
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
            ),
          ),
        ),
      ),
    );
  }
}


