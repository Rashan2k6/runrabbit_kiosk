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
    flow.pickBaseSkin('oily');
    flow.continueFromSkin();
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

  group('skin type selection', () {
    test('base skin selection replaces the previous base selection', () {
      final flow = KioskFlow();
      flow.pickBaseSkin('oily');
      flow.pickBaseSkin('dry');

      expect(flow.skinType, 'dry');
      expect(flow.sensitive, isFalse);
    });

    test('sensitive toggles independently and can be selected on its own', () {
      final flow = KioskFlow();
      expect(flow.hasSkinSelection, isFalse);

      flow.toggleSensitive();
      expect(flow.sensitive, isTrue);
      expect(flow.skinType, isNull);
      expect(flow.hasSkinSelection, isTrue);

      flow.pickBaseSkin('oily');
      expect(flow.skinType, 'oily');
      expect(flow.sensitive, isTrue);

      flow.toggleSensitive();
      expect(flow.sensitive, isFalse);
      expect(flow.skinType, 'oily');
    });

    test('reset clears both skin selections', () {
      final flow = KioskFlow()
        ..pickBaseSkin('dry')
        ..toggleSensitive()
        ..reset();

      expect(flow.skinType, isNull);
      expect(flow.sensitive, isFalse);
      expect(flow.hasSkinSelection, isFalse);
    });
  });

  group('KioskFlow quiz flow and state', () {
    test(
        'after quiz completes the stage after Continue is Concerns, never Skin type; '
        'quiz concerns are pre-selected for Sensitive, Uneven and Wrinkled', () {
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
      // Forward path: Continue goes DIRECTLY to Concerns, never Skin type!
      expect(flow1.stage, Stage.concerns);
      expect(flow1.skinType, 'oily');
      expect(flow1.sensitive, isTrue);
      expect(flow1.concerns, {'redness'});
      expect(flow1.quizConcerns, {'redness'});

      // Uneven -> pigmentation, dullness
      final flow2 = KioskFlow()..startQuiz();
      flow2.answerQuizQuestion(false); // Q1 -> Q4
      flow2.answerQuizQuestion(false); // Q4 -> Q7
      flow2.answerQuizQuestion(false); // Q7 -> Q8
      flow2.answerQuizQuestion(true); // Q8 -> Q9
      flow2.answerQuizQuestion(true); // Q9 -> RESULT_DRY
      expect(flow2.quizBaseResult, 'dry');

      flow2.pickQuizConcern('uneven');
      flow2.applyQuizAndContinue();
      expect(flow2.stage, Stage.concerns);
      expect(flow2.skinType, 'dry');
      expect(flow2.sensitive, isFalse);
      expect(flow2.concerns, {'pigmentation', 'dullness'});
      expect(flow2.quizConcerns, {'pigmentation', 'dullness'});

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
      expect(flow3.stage, Stage.concerns);
      expect(flow3.skinType, 'combination');
      expect(flow3.sensitive, isFalse);
      expect(flow3.concerns, {'aging'});
      expect(flow3.quizConcerns, {'aging'});
    });

    test('user edits to concerns survive Back and forward', () {
      final flow = KioskFlow()..startQuiz();
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('sensitive');
      flow.applyQuizAndContinue();

      expect(flow.stage, Stage.concerns);
      expect(flow.concerns, {'redness'});

      // Customer adds acne and removes redness
      flow.toggleConcern('acne');
      flow.toggleConcern('redness');
      expect(flow.concerns, {'acne'});

      // Customer goes to Steps, then Back to Concerns
      flow.toSteps();
      expect(flow.stage, Stage.steps);
      flow.back();
      expect(flow.stage, Stage.concerns);
      expect(flow.concerns, {'acne'});

      // Customer goes Back to quiz result, then Continue forward again
      flow.back();
      expect(flow.stage, Stage.quizResult);
      flow.applyQuizAndContinue();
      expect(flow.stage, Stage.concerns);
      // Pre-selections applied once on quiz completion; customer edits preserved!
      expect(flow.concerns, {'acne'});
    });

    test('re-taking the quiz replaces only unchanged quiz-derived concerns', () {
      // First quiz: sensitive -> redness
      final flow = KioskFlow()..startQuiz();
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('sensitive');
      flow.applyQuizAndContinue();

      expect(flow.stage, Stage.concerns);
      expect(flow.concerns, {'redness'});
      expect(flow.quizConcerns, {'redness'});

      // Customer adds 'acne' (user-chosen)
      flow.toggleConcern('acne');
      expect(flow.concerns, {'redness', 'acne'});

      // Customer navigates back to quiz and re-takes it -> uneven (pigmentation, dullness)
      flow.back(); // -> quizResult
      flow.back(); // -> quizConcern
      flow.pickQuizConcern('uneven');
      flow.applyQuizAndContinue();

      expect(flow.stage, Stage.concerns);
      // 'redness' was unchanged quiz-derived, replaced by 'pigmentation' and 'dullness'.
      // 'acne' chosen by customer remains!
      expect(flow.concerns, {'acne', 'pigmentation', 'dullness'});
      expect(flow.quizConcerns, {'pigmentation', 'dullness'});

      // Re-take again where user has already toggled off 'pigmentation' manually
      flow.toggleConcern('pigmentation');
      expect(flow.concerns, {'acne', 'dullness'});

      flow.back();
      flow.back();
      flow.pickQuizConcern('wrinkled'); // -> aging
      flow.applyQuizAndContinue();

      // Only unchanged quiz-derived concerns (dullness) removed and replaced by aging.
      expect(flow.concerns, {'acne', 'aging'});
      expect(flow.quizConcerns, {'aging'});
    });

    test(
        'choosing a skin card manually clears quiz-derived state while keeping concerns user chose',
        () {
      final flow = KioskFlow()..startQuiz();
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

      // Customer goes to skin type screen via chooseDifferentSkinType
      flow.chooseDifferentSkinType();
      expect(flow.stage, Stage.skin);
      expect(flow.quizResult, isNull);
      expect(flow.sensitive, isFalse);
      expect(flow.quizConcerns, isEmpty);
      // Only 'acne' remains, 'redness' cleared
      expect(flow.concerns, {'acne'});

      // Customer picks dry manually
      flow.pickBaseSkin('dry');
      expect(flow.skinType, 'dry');
      expect(flow.concerns, {'acne'});
      flow.continueFromSkin();
      expect(flow.stage, Stage.concerns);
      // Back from manually-reached concerns goes to skin screen
      flow.back();
      expect(flow.stage, Stage.skin);
    });

    test('manual skin card tap after quiz clears quiz-derived state', () {
      final flow = KioskFlow()..startQuiz();
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('sensitive');
      flow.applyQuizAndContinue();

      flow.toggleConcern('pores');
      expect(flow.concerns, {'redness', 'pores'});

      // If user later taps a skin card manually
      flow.pickBaseSkin('normal');
      expect(flow.quizResult, isNull);
      expect(flow.sensitive, isFalse);
      expect(flow.quizConcerns, isEmpty);
      expect(flow.skinType, 'normal');
      expect(flow.concerns, {'pores'});
      expect(flow.cameFromQuiz, isFalse);
    });

    test('Back sequence listed in specification is followed exactly', () {
      final flow = KioskFlow()..start();
      expect(flow.stage, Stage.skin);

      // First quiz question: Back goes to Skin type screen
      flow.startQuiz();
      expect(flow.stage, Stage.quizQuestion);
      expect(flow.currentQuizNodeId, 'Q1');
      flow.back();
      expect(flow.stage, Stage.skin);

      // Quiz questions navigation
      flow.startQuiz();
      flow.answerQuizQuestion(true); // Q1 -> Q2
      expect(flow.currentQuizNodeId, 'Q2');
      flow.answerQuizQuestion(true); // Q2 -> Q3
      expect(flow.currentQuizNodeId, 'Q3');
      flow.answerQuizQuestion(true); // Q3 -> RESULT_OILY -> quizConcern
      expect(flow.stage, Stage.quizConcern);

      // Quiz concern card: Back goes to the last quiz question
      flow.back();
      expect(flow.stage, Stage.quizQuestion);
      expect(flow.currentQuizNodeId, 'Q3');

      // Forward again to quizConcern
      flow.answerQuizQuestion(true);
      expect(flow.stage, Stage.quizConcern);

      // Pick concern -> quizResult
      flow.pickQuizConcern('sensitive');
      expect(flow.stage, Stage.quizResult);

      // Quiz result screen: Back goes to the quiz concern card
      flow.back();
      expect(flow.stage, Stage.quizConcern);

      // Forward to quizResult then Continue to concerns
      flow.pickQuizConcern('sensitive');
      expect(flow.stage, Stage.quizResult);
      flow.applyQuizAndContinue();
      expect(flow.stage, Stage.concerns);

      // Concerns screen reached from the quiz: Back goes to the quiz result screen
      flow.back();
      expect(flow.stage, Stage.quizResult);

      // Continue to Concerns again
      flow.applyQuizAndContinue();
      expect(flow.stage, Stage.concerns);

      // Advance to steps and results
      flow.toSteps();
      expect(flow.stage, Stage.steps);
      flow.toggleStep(Step.cleanser);
      flow.seeResults();
      expect(flow.stage, Stage.results);
      flow.back();
      expect(flow.stage, Stage.steps);
      flow.back();
      expect(flow.stage, Stage.concerns);

      // Back from quiz-reached concerns goes to quizResult
      flow.back();
      expect(flow.stage, Stage.quizResult);

      // Secondary button: Choose a different skin type
      flow.chooseDifferentSkinType();
      expect(flow.stage, Stage.skin);

      // Concerns screen reached the normal way: Back goes to Skin type screen
      flow.pickBaseSkin('dry');
      flow.continueFromSkin();
      expect(flow.stage, Stage.concerns);
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
      expect(flow.quizConcerns, isEmpty);
      expect(flow.cameFromQuiz, isFalse);
      expect(flow.concerns, isEmpty);
      expect(flow.steps, isEmpty);
      expect(flow.quizHistory, isEmpty);
    });

    test('the 5th concern can be selected, the 6th cannot; deselecting then selecting another works', () {
      final flow = KioskFlow();
      expect(flow.concerns, isEmpty);

      flow.toggleConcern('acne');
      flow.toggleConcern('pores');
      flow.toggleConcern('pigmentation');
      flow.toggleConcern('dullness');
      expect(flow.concerns.length, 4);

      // 5th concern can be selected
      flow.toggleConcern('aging');
      expect(flow.concerns.length, 5);
      expect(flow.concerns.length, maxConcerns);
      expect(flow.concerns, {'acne', 'pores', 'pigmentation', 'dullness', 'aging'});

      // 6th concern cannot be selected
      flow.toggleConcern('redness');
      expect(flow.concerns.length, 5);
      expect(flow.concerns.contains('redness'), isFalse);

      // Deselecting one works
      flow.toggleConcern('pores');
      expect(flow.concerns.length, 4);
      expect(flow.concerns.contains('pores'), isFalse);

      // Now selecting another (e.g. redness) works up to 5
      flow.toggleConcern('redness');
      expect(flow.concerns.length, 5);
      expect(flow.concerns.contains('redness'), isTrue);

      // Reset clears all
      flow.reset();
      expect(flow.concerns, isEmpty);
    });

    test('quiz pre-selection never pushes total concerns above maxConcerns', () {
      final flow = KioskFlow();
      // Pre-fill 4 concerns
      flow.toggleConcern('acne');
      flow.toggleConcern('pores');
      flow.toggleConcern('aging');
      flow.toggleConcern('darkcircles');
      expect(flow.concerns.length, 4);

      // Start quiz and complete with uneven (pigmentation, dullness -> 2 concerns)
      flow.startQuiz();
      flow.answerQuizQuestion(false);
      flow.answerQuizQuestion(false);
      flow.answerQuizQuestion(false);
      flow.answerQuizQuestion(true);
      flow.answerQuizQuestion(true);
      flow.pickQuizConcern('uneven');
      flow.applyQuizAndContinue();

      // Total must not exceed maxConcerns (5)
      expect(flow.concerns.length, lessThanOrEqualTo(maxConcerns));
      expect(flow.concerns.length, 5);
    });
  });
}
