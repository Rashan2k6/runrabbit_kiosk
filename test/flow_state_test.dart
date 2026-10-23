import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/domain/options.dart';
import 'package:runrabbit_kiosk/domain/product.dart';
import 'package:runrabbit_kiosk/presentation/state/flow_state.dart';

void main() {
  test('bundle selects all steps and clears when tapped again', () {
    final flow = KioskFlow();
    flow.toggleBundle();
    expect(flow.isWholeRoutine, isTrue);
    expect(flow.steps, routineSteps.toSet());
    flow.toggleBundle();
    expect(flow.steps, isEmpty);
  });

  test('deselecting one step clears bundle and selecting five restores it', () {
    final flow = KioskFlow()..toggleBundle();
    flow.toggleStep(Step.serum);
    expect(flow.isWholeRoutine, isFalse);
    for (final step in routineSteps) {
      if (!flow.steps.contains(step)) flow.toggleStep(step);
    }
    expect(flow.isWholeRoutine, isTrue);
  });

  test('steps are required, back navigates in order, and reset clears them',
      () {
    final flow = KioskFlow();
    flow.start();
    flow.pickSkin('oily');
    flow.toggleConcern('acne');
    flow.toSteps();
    expect(flow.steps, isEmpty);
    flow.toggleStep(Step.cleanser);
    flow.seeResults();
    flow.back();
    expect(flow.stage, Stage.steps);
    flow.back();
    expect(flow.stage, Stage.concerns);
    flow.back();
    expect(flow.stage, Stage.skin);
    flow.reset();
    expect(flow.steps, isEmpty);
  });

  group('KioskFlow quiz flow and state', () {
    test('quiz base result sets skinType and concerns according to choice', () {
      // Sensitive -> redness
      final flow1 = KioskFlow()..startQuiz();
      flow1.answerQuizQuestion(true); // Q1 -> Q2
      flow1.answerQuizQuestion(true); // Q2 -> Q3
      flow1.answerQuizQuestion(true); // Q3 -> RESULT_OILY
      expect(flow1.stage, Stage.quizConcern);
      expect(flow1.quizBaseResult, 'oily');

      flow1.pickQuizConcern('sensitive');
      expect(flow1.stage, Stage.quizResult);
      expect(flow1.quizResult?.code, 'OS');

      flow1.applyQuizAndContinue();
      expect(flow1.stage, Stage.concerns);
      expect(flow1.skinType, 'oily');
      expect(flow1.sensitive, isTrue);
      expect(flow1.concerns, {'redness'});

      // Uneven -> pigmentation, dullness
      final flow2 = KioskFlow()..startQuiz();
      flow2.answerQuizQuestion(false); // Q1 -> Q4
      flow2.answerQuizQuestion(false); // Q4 -> Q7
      flow2.answerQuizQuestion(false); // Q7 -> Q8
      flow2.answerQuizQuestion(true);  // Q8 -> Q9
      flow2.answerQuizQuestion(true);  // Q9 -> RESULT_DRY
      expect(flow2.quizBaseResult, 'dry');

      flow2.pickQuizConcern('uneven');
      flow2.applyQuizAndContinue();
      expect(flow2.skinType, 'dry');
      expect(flow2.sensitive, isFalse);
      expect(flow2.concerns, {'pigmentation', 'dullness'});

      // Wrinkled -> aging
      final flow3 = KioskFlow()..startQuiz();
      flow3.answerQuizQuestion(false); // Q1 -> Q4
      flow3.answerQuizQuestion(false); // Q4 -> Q7
      flow3.answerQuizQuestion(false); // Q7 -> Q8
      flow3.answerQuizQuestion(false); // Q8 -> Q6
      flow3.answerQuizQuestion(false); // Q6 -> RESULT_COMBINATION
      expect(flow3.quizBaseResult, 'combination');

      flow3.pickQuizConcern('wrinkled');
      flow3.applyQuizAndContinue();
      expect(flow3.skinType, 'combination');
      expect(flow3.sensitive, isFalse);
      expect(flow3.concerns, {'aging'});
    });

    test('picking a skin type card manually after the quiz clears quiz-derived state without removing customer choices', () {
      final flow = KioskFlow()..startQuiz();
      // Answer to oily
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('sensitive');
      flow.applyQuizAndContinue();

      expect(flow.skinType, 'oily');
      expect(flow.sensitive, isTrue);
      expect(flow.concerns, {'redness'});

      // Customer adds another concern
      flow.toggleConcern('acne');
      expect(flow.concerns, {'redness', 'acne'});

      // Customer goes back to skin type screen and picks dry manually
      flow.back();
      expect(flow.stage, Stage.skin);

      flow.pickSkin('dry');
      expect(flow.stage, Stage.concerns);
      expect(flow.skinType, 'dry');
      expect(flow.sensitive, isFalse);
      expect(flow.quizResult, isNull);
      // 'redness' from quiz was removed, but 'acne' chosen by customer remains!
      expect(flow.concerns, {'acne'});
    });

    test('back navigation through quiz questions follows history stack', () {
      final flow = KioskFlow()..start();
      expect(flow.stage, Stage.skin);

      flow.startQuiz();
      expect(flow.stage, Stage.quizQuestion);
      expect(flow.currentQuizNodeId, 'Q1');

      // Back from Q1 returns to skin type screen
      flow.back();
      expect(flow.stage, Stage.skin);

      // Start quiz again and advance
      flow.startQuiz();
      flow.answerQuizQuestion(true); // Q1 -> Q2
      expect(flow.currentQuizNodeId, 'Q2');
      flow.answerQuizQuestion(false); // Q2 -> Q5
      expect(flow.currentQuizNodeId, 'Q5');

      // Back returns to Q2
      flow.back();
      expect(flow.stage, Stage.quizQuestion);
      expect(flow.currentQuizNodeId, 'Q2');

      // Back returns to Q1
      flow.back();
      expect(flow.stage, Stage.quizQuestion);
      expect(flow.currentQuizNodeId, 'Q1');

      // Back returns to skin screen
      flow.back();
      expect(flow.stage, Stage.skin);
    });

    test('reset() clears everything including quiz state and sensitive', () {
      final flow = KioskFlow()..startQuiz();
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('sensitive');
      flow.applyQuizAndContinue();
      expect(flow.sensitive, isTrue);
      expect(flow.concerns, isNotEmpty);

      flow.reset();
      expect(flow.stage, Stage.idle);
      expect(flow.skinType, isNull);
      expect(flow.sensitive, isFalse);
      expect(flow.quizResult, isNull);
      expect(flow.quizBaseResult, isNull);
      expect(flow.concerns, isEmpty);
      expect(flow.steps, isEmpty);
      expect(flow.quizHistory, isEmpty);
    });
  });
}
