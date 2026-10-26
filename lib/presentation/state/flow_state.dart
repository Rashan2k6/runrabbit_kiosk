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
  final Set<String> quizConcerns = {};
  bool cameFromQuiz = false;

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
    final newResult = SkinQuiz.buildResult(quizBaseResult!, concernId);
    if (quizResult != newResult) {
      quizResult = newResult;
      _quizApplied = false;
    }
    _go(Stage.quizResult);
  }

  bool _quizApplied = false;

  void applyQuizAndContinue() {
    if (quizResult == null) return;
    skinType = quizResult!.base;
    sensitive = quizResult!.concern == 'sensitive';
    cameFromQuiz = true;

    if (!_quizApplied) {
      final newQuizConcerns = <String>{};
      switch (quizResult!.concern) {
        case 'sensitive':
          newQuizConcerns.add('redness');
        case 'uneven':
          newQuizConcerns.addAll(['pigmentation', 'dullness']);
        case 'wrinkled':
          newQuizConcerns.add('aging');
      }

      for (final oldQuizConcern in quizConcerns) {
        if (!newQuizConcerns.contains(oldQuizConcern)) {
          concerns.remove(oldQuizConcern);
        }
      }

      quizConcerns
        ..clear()
        ..addAll(newQuizConcerns);

      for (final c in quizConcerns) {
        if (concerns.length < maxConcerns || concerns.contains(c)) {
          concerns.add(c);
        }
      }

      _quizApplied = true;
    }

    _go(Stage.concerns);
  }

  void chooseDifferentSkinType() {
    _clearQuizDerivedState();
    sensitive = false;
    _go(Stage.skin);
  }

  /// Selects one base skin type without advancing to the next screen.
  void pickBaseSkin(String id) {
    if (quizResult != null) {
      _clearQuizDerivedState();
      sensitive = false;
    }
    skinType = id;
    notifyListeners();
  }

  /// Changes the independent sensitive-skin selection without affecting the
  /// selected base skin type.
  void toggleSensitive() {
    if (quizResult != null) {
      _clearQuizDerivedState();
    }
    sensitive = !sensitive;
    notifyListeners();
  }

  bool get hasSkinSelection => skinType != null || sensitive;

  void continueFromSkin() {
    if (hasSkinSelection) {
      cameFromQuiz = false;
      _go(Stage.concerns);
    }
  }

  void _clearQuizDerivedState() {
    concerns.removeAll(quizConcerns);
    quizConcerns.clear();
    quizResult = null;
    quizBaseResult = null;
    quizHistory.clear();
    currentQuizNodeId = SkinQuiz.startNodeId;
    cameFromQuiz = false;
    _quizApplied = false;
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
        if (cameFromQuiz) {
          _go(Stage.quizResult);
        } else {
          _go(Stage.skin);
        }
      case Stage.quizResult:
        _go(Stage.quizConcern);
      case Stage.quizConcern:
        if (quizHistory.isNotEmpty) {
          currentQuizNodeId = quizHistory.removeLast();
          _go(Stage.quizQuestion);
        } else {
          _go(Stage.skin);
        }
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
    quizConcerns.clear();
    quizHistory.clear();
    currentQuizNodeId = SkinQuiz.startNodeId;
    cameFromQuiz = false;
    _quizApplied = false;
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
