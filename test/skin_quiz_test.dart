import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/domain/skin_quiz.dart';

void main() {
  group('SkinQuiz flowchart state machine', () {
    test('exhaustively walks every path from Q1: all end in a result within 9 questions without loops', () {
      void explorePath(String currentId, List<String> history) {
        expect(history.length, lessThan(9),
            reason: 'Path exceeded 9 questions without terminating: $history');
        expect(history.contains(currentId), isFalse,
            reason: 'Loop detected! Node $currentId repeats in path: $history');

        final newHistory = [...history, currentId];

        for (final answer in [true, false]) {
          final target = SkinQuiz.next(currentId, answer);
          if (SkinQuiz.isResult(target)) {
            expect(
              target,
              isIn([
                SkinQuiz.resultOily,
                SkinQuiz.resultCombination,
                SkinQuiz.resultDry,
              ]),
            );
          } else {
            explorePath(target, newHistory);
          }
        }
      }

      explorePath(SkinQuiz.start(), []);
    });

    test('asserts every node Q1..Q9 is reachable from Q1', () {
      final reachable = <String>{};

      void visit(String currentId) {
        reachable.add(currentId);
        for (final answer in [true, false]) {
          final target = SkinQuiz.next(currentId, answer);
          if (!SkinQuiz.isResult(target) && !reachable.contains(target)) {
            visit(target);
          }
        }
      }

      visit(SkinQuiz.start());

      expect(reachable, {
        'Q1',
        'Q2',
        'Q3',
        'Q4',
        'Q5',
        'Q6',
        'Q7',
        'Q8',
        'Q9',
      });
    });

    test('asserts specified flowchart paths', () {
      // 1. Q1 yes, Q2 yes, Q3 yes -> oily
      var current = SkinQuiz.start(); // Q1
      current = SkinQuiz.next(current, true); // Q2
      expect(current, 'Q2');
      current = SkinQuiz.next(current, true); // Q3
      expect(current, 'Q3');
      final oilyTarget = SkinQuiz.next(current, true);
      expect(oilyTarget, SkinQuiz.resultOily);
      expect(SkinQuiz.skinTypeFromResult(oilyTarget), 'oily');

      // 2. Q1 no, Q4 no, Q7 no, Q8 no, Q6 no -> combination
      current = SkinQuiz.start(); // Q1
      current = SkinQuiz.next(current, false); // Q4
      expect(current, 'Q4');
      current = SkinQuiz.next(current, false); // Q7
      expect(current, 'Q7');
      current = SkinQuiz.next(current, false); // Q8
      expect(current, 'Q8');
      current = SkinQuiz.next(current, false); // Q6
      expect(current, 'Q6');
      final combTarget = SkinQuiz.next(current, false);
      expect(combTarget, SkinQuiz.resultCombination);
      expect(SkinQuiz.skinTypeFromResult(combTarget), 'combination');

      // 3. Q1 no, Q4 no, Q7 no, Q8 yes, Q9 yes -> dry
      current = SkinQuiz.start(); // Q1
      current = SkinQuiz.next(current, false); // Q4
      expect(current, 'Q4');
      current = SkinQuiz.next(current, false); // Q7
      expect(current, 'Q7');
      current = SkinQuiz.next(current, false); // Q8
      expect(current, 'Q8');
      current = SkinQuiz.next(current, true); // Q9
      expect(current, 'Q9');
      final dryTarget = SkinQuiz.next(current, true);
      expect(dryTarget, SkinQuiz.resultDry);
      expect(SkinQuiz.skinTypeFromResult(dryTarget), 'dry');
    });

    test('asserts the 9 base+concern combinations produce DS, DU, DW, OS, OU, OW, CS, CU, CW with labels', () {
      final expected = <(String, String), (String, String)>{
        ('dry', 'sensitive'): ('DS', 'Dry | Sensitive'),
        ('dry', 'uneven'): ('DU', 'Dry | Uneven'),
        ('dry', 'wrinkled'): ('DW', 'Dry | Wrinkled'),
        ('oily', 'sensitive'): ('OS', 'Oily | Sensitive'),
        ('oily', 'uneven'): ('OU', 'Oily | Uneven'),
        ('oily', 'wrinkled'): ('OW', 'Oily | Wrinkled'),
        ('combination', 'sensitive'): ('CS', 'Combination | Sensitive'),
        ('combination', 'uneven'): ('CU', 'Combination | Uneven'),
        ('combination', 'wrinkled'): ('CW', 'Combination | Wrinkled'),
      };

      for (final entry in expected.entries) {
        final base = entry.key.$1;
        final concern = entry.key.$2;
        final expectedCode = entry.value.$1;
        final expectedLabel = entry.value.$2;

        final result = SkinQuiz.buildResult(base, concern);
        expect(result.code, expectedCode);
        expect(result.label, expectedLabel);
        expect(result.base, base);
        expect(result.concern, concern);
      }
    });
  });
}
