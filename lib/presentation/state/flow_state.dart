import 'package:flutter/foundation.dart';

import '../../domain/options.dart';
import '../../domain/product.dart';

enum Stage { idle, skin, concerns, steps, results }

/// Everything the customer has chosen. Lives above the screens, so rotating
/// the tablet never loses a choice.
class KioskFlow extends ChangeNotifier {
  Stage stage = Stage.idle;
  String? skinType;
  final Set<String> concerns = {};
  final Set<Step> steps = {};
  String lang = 'en';

  void start() => _go(Stage.skin);

  void pickSkin(String id) {
    skinType = id;
    _go(Stage.concerns);
  }

  void toggleConcern(String id) {
    if (!concerns.remove(id)) {
      if (concerns.length >= maxConcerns) return;
      concerns.add(id);
    }
    notifyListeners();
  }

  void toSteps() => _go(Stage.steps);

  bool get isWholeRoutine =>
      steps.length == routineSteps.length && steps.containsAll(routineSteps);

  void toggleStep(Step step) {
    if (!routineSteps.contains(step)) return;
    if (!steps.remove(step)) steps.add(step);
    notifyListeners();
  }

  void toggleBundle() {
    if (isWholeRoutine) {
      steps.clear();
    } else {
      steps
        ..clear()
        ..addAll(routineSteps);
    }
    notifyListeners();
  }

  void seeResults() => _go(Stage.results);

  void back() {
    switch (stage) {
      case Stage.results:
        _go(Stage.steps);
      case Stage.steps:
        _go(Stage.concerns);
      case Stage.concerns:
        _go(Stage.skin);
      case Stage.skin:
      case Stage.idle:
        reset();
    }
  }

  void setLang(String value) {
    lang = value;
    notifyListeners();
  }

  /// Back to the welcome screen and forget the customer's choices.
  void reset() {
    stage = Stage.idle;
    skinType = null;
    concerns.clear();
    steps.clear();
    lang = 'en';
    notifyListeners();
  }

  void _go(Stage s) {
    stage = s;
    notifyListeners();
  }
}
