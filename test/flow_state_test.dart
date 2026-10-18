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
}
