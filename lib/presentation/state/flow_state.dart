import 'package:flutter/foundation.dart';

import '../../domain/options.dart';
import '../../domain/product.dart';
import '../../domain/skin_quiz.dart';

enum Stage {
  idle,
  skin,
  quizQuestion,
  quizConcern,
  quizResult,
  concerns,
  steps,
  results,
}

/// Everything the customer has chosen. Lives above the screens, so rotating
/// the tablet never loses a choice.
class KioskFlow extends ChangeNotifier {
  Stage stage = Stage.idle;
  String? skinType;
  bool sensitive = false;
  final Set<String> concerns = {};
  final Set<Step> steps = {};
  String lang = 'en';

  // Quiz state
  SkinQuizResult? quizResult;
  String? quizBaseResult;
  String currentQuizNodeId = SkinQuiz.startNodeId;
  final List<String> quizHistory = [];
  final Set<String> _quizConcerns = {};

  void start() => _go(Stage.skin);

  void startQuiz() {
    currentQuizNodeId = SkinQuiz.startNodeId;
    quizHistory.clear();
    _go(Stage.quizQuestion);
  }

  void answerQuizQuestion(bool yes) {
    quizHistory.add(currentQuizNodeId);
    final target = SkinQuiz.next(currentQuizNodeId, yes);
    if (SkinQuiz.isResult(target)) {
      quizBaseResult = SkinQuiz.skinTypeFromResult(target);
      _go(Stage.quizConcern);
    } else {
      currentQuizNodeId = target;
      notifyListeners();
    }
  }

  void pickQuizConcern(String concernId) {
    if (quizBaseResult == null) return;
    quizResult = SkinQuiz.buildResult(quizBaseResult!, concernId);
    _go(Stage.quizResult);
  }

  void applyQuizAndContinue() {
    if (quizResult == null) return;
    skinType = quizResult!.base;
    sensitive = quizResult!.concern == 'sensitive';

    _quizConcerns.clear();
    switch (quizResult!.concern) {
      case 'sensitive':
        _quizConcerns.add('redness');
      case 'uneven':
        _quizConcerns.addAll(['pigmentation', 'dullness']);
      case 'wrinkled':
        _quizConcerns.add('aging');
    }

    for (final c in _quizConcerns) {
      if (concerns.length < maxConcerns || concerns.contains(c)) {
        concerns.add(c);
      }
    }

    _go(Stage.concerns);
  }

  void chooseDifferentSkinType() {
    _clearQuizDerivedState();
    _go(Stage.skin);
  }

  void pickSkin(String id) {
    _clearQuizDerivedState();
    skinType = id;
    _go(Stage.concerns);
  }

  void _clearQuizDerivedState() {
    concerns.removeAll(_quizConcerns);
    _quizConcerns.clear();
    sensitive = false;
    quizResult = null;
    quizBaseResult = null;
    quizHistory.clear();
    currentQuizNodeId = SkinQuiz.startNodeId;
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
      case Stage.quizResult:
        _go(Stage.quizConcern);
      case Stage.quizConcern:
        _go(Stage.quizQuestion);
      case Stage.quizQuestion:
        if (quizHistory.isNotEmpty) {
          currentQuizNodeId = quizHistory.removeLast();
          notifyListeners();
        } else {
          _go(Stage.skin);
        }
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
    sensitive = false;
    quizResult = null;
    quizBaseResult = null;
    _quizConcerns.clear();
    quizHistory.clear();
    currentQuizNodeId = SkinQuiz.startNodeId;
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
