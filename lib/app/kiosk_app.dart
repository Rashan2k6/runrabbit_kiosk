import 'dart:async';

import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../domain/product.dart';
import '../presentation/screens/idle_screen.dart';
import '../presentation/screens/option_screens.dart';
import '../presentation/screens/quiz_screens.dart';
import '../presentation/screens/results_screen.dart';
import '../presentation/state/flow_state.dart';
import 'strings.dart';
import 'theme.dart';

class KioskApp extends StatelessWidget {
  KioskApp({
    super.key,
    ProductRepository? repository,
    this.idleTimeout = const Duration(seconds: 60),
  }) : repository = repository ?? JsonProductRepository();

  final ProductRepository repository;

  /// How long without a touch before the kiosk returns to the welcome screen.
  final Duration idleTimeout;

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
      home: KioskHome(repository: repository, idleTimeout: idleTimeout),
    );
  }
}

class KioskHome extends StatefulWidget {
  const KioskHome({
    super.key,
    required this.repository,
    required this.idleTimeout,
  });

  final ProductRepository repository;
  final Duration idleTimeout;

  @override
  State<KioskHome> createState() => _KioskHomeState();
}

class _KioskHomeState extends State<KioskHome> {
  final KioskFlow _flow = KioskFlow();
  late final Future<List<Product>> _products = widget.repository.loadAll();
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _flow.addListener(_armTimer);
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _flow.removeListener(_armTimer);
    _flow.dispose();
    super.dispose();
  }

  /// Restarts the countdown. It only runs while a customer is mid-flow.
  void _armTimer() {
    _idleTimer?.cancel();
    if (_flow.stage == Stage.idle) return;
    _idleTimer = Timer(widget.idleTimeout, _flow.reset);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // the Android back button must not leave the app
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _armTimer(),
        child: Scaffold(
          body: ListenableBuilder(
            listenable: _flow,
            builder: (context, _) {
              final s = Strings(_flow.lang);
              return FutureBuilder<List<Product>>(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
