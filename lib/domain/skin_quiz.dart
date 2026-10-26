class QuizNode {
  const QuizNode({
    required this.id,
    required this.textKey,
    required this.defaultText,
    required this.yesTarget,
    required this.noTarget,
  });

  final String id;
  final String textKey;
  final String defaultText;
  final String yesTarget;
  final String noTarget;
}

class QuizConcernOption {
  const QuizConcernOption({
    required this.id,
    required this.nameKey,
    required this.defaultName,
    required this.symptom1Key,
    required this.defaultSymptom1,
    required this.symptom2Key,
    required this.defaultSymptom2,
  });

  final String id;
  final String nameKey;
  final String defaultName;
  final String symptom1Key;
  final String defaultSymptom1;
  final String symptom2Key;
  final String defaultSymptom2;
}

class SkinQuizResult {
  const SkinQuizResult({
    required this.base,
    required this.concern,
    required this.code,
    required this.label,
  });

  final String base;
  final String concern;
  final String code;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkinQuizResult &&
          runtimeType == other.runtimeType &&
          base == other.base &&
          concern == other.concern &&
          code == other.code &&
          label == other.label;

  @override
  int get hashCode => Object.hash(base, concern, code, label);

  @override
  String toString() =>
      'SkinQuizResult($code: $label, base: $base, concern: $concern)';
}

/// Pure Dart logic for the optional skin type quiz.
class SkinQuiz {
  static const startNodeId = 'Q1';

  static const resultOily = 'RESULT_OILY';
  static const resultCombination = 'RESULT_COMBINATION';
  static const resultDry = 'RESULT_DRY';

  /// Flowchart questions as a const data structure.
  /// Easy to swap wording later once final permissions/source are confirmed.
  static const Map<String, QuizNode> questions = {
    'Q1': QuizNode(
      id: 'Q1',
      textKey: 'quiz.q1',
      defaultText: 'Gets skin trouble after using rich creams',
      yesTarget: 'Q2',
      noTarget: 'Q4',
    ),
    'Q2': QuizNode(
      id: 'Q2',
      textKey: 'quiz.q2',
      defaultText: 'Visibly large pores',
      yesTarget: 'Q3',
      noTarget: 'Q5',
    ),
    'Q3': QuizNode(
      id: 'Q3',
      textKey: 'quiz.q3',
      defaultText: 'Have lots of blackheads and sebum',
      yesTarget: resultOily,
      noTarget: 'Q6',
    ),
    'Q4': QuizNode(
      id: 'Q4',
      textKey: 'quiz.q4',
      defaultText: 'Hair gets greasy quickly',
      yesTarget: 'Q5',
      noTarget: 'Q7',
    ),
    'Q5': QuizNode(
      id: 'Q5',
      textKey: 'quiz.q5',
      defaultText: 'Dry U-zone area (cheeks and chin)',
      yesTarget: 'Q6',
      noTarget: 'Q3',
    ),
    'Q6': QuizNode(
      id: 'Q6',
      textKey: 'quiz.q6',
      defaultText: 'Skin feels tight after cleansing',
      yesTarget: 'Q9',
      noTarget: resultCombination,
    ),
    'Q7': QuizNode(
      id: 'Q7',
      textKey: 'quiz.q7',
      defaultText: 'Oily T-zone area (forehead, nose)',
      yesTarget: 'Q5',
      noTarget: 'Q8',
    ),
    'Q8': QuizNode(
      id: 'Q8',
      textKey: 'quiz.q8',
      defaultText: 'Often gets flaky skin',
      yesTarget: 'Q9',
      noTarget: 'Q6',
    ),
    'Q9': QuizNode(
      id: 'Q9',
      textKey: 'quiz.q9',
      defaultText: 'Skin is usually dry and tight',
      yesTarget: resultDry,
      noTarget: resultCombination,
    ),
  };

  /// Step 2 concern choices.
  static const List<QuizConcernOption> concerns = [
    QuizConcernOption(
      id: 'sensitive',
      nameKey: 'quiz.concern.sensitive',
      defaultName: 'Sensitive',
      symptom1Key: 'quiz.concern.sensitive.s1',
      defaultSymptom1: 'Becomes red and irritated easily',
      symptom2Key: 'quiz.concern.sensitive.s2',
      defaultSymptom2: 'Often gets skin reaction and skin trouble',
    ),
    QuizConcernOption(
      id: 'uneven',
      nameKey: 'quiz.concern.uneven',
      defaultName: 'Uneven',
      symptom1Key: 'quiz.concern.uneven.s1',
      defaultSymptom1: 'Has dark spots and pigmented skin',
      symptom2Key: 'quiz.concern.uneven.s2',
      defaultSymptom2: 'Has dull and uneven tone',
    ),
    QuizConcernOption(
      id: 'wrinkled',
      nameKey: 'quiz.concern.wrinkled',
      defaultName: 'Wrinkled',
      symptom1Key: 'quiz.concern.wrinkled.s1',
      defaultSymptom1: 'Reduced skin elasticity',
      symptom2Key: 'quiz.concern.wrinkled.s2',
      defaultSymptom2: 'Has visible wrinkles and fine lines',
    ),
  ];

  static String start() => startNodeId;

  static String next(String nodeId, bool yes) {
    final node = questions[nodeId];
    if (node == null) throw ArgumentError('Unknown node id: $nodeId');
    return yes ? node.yesTarget : node.noTarget;
  }

  static bool isResult(String target) =>
      target == resultOily ||
      target == resultCombination ||
      target == resultDry;

  static String skinTypeFromResult(String resultId) {
    switch (resultId) {
      case resultOily:
        return 'oily';
      case resultCombination:
        return 'combination';
      case resultDry:
        return 'dry';
      default:
        throw ArgumentError('Unknown result id: $resultId');
    }
  }

  static SkinQuizResult buildResult(String base, String concern) {
    final baseClean = base.trim().toLowerCase();
    final concernClean = concern.trim().toLowerCase();

    final baseCode = switch (baseClean) {
      'dry' => 'D',
      'oily' => 'O',
      'combination' => 'C',
      _ => throw ArgumentError('Invalid base skin type: $base'),
    };

    final concernCode = switch (concernClean) {
      'sensitive' => 'S',
      'uneven' => 'U',
      'wrinkled' => 'W',
      _ => throw ArgumentError('Invalid concern: $concern'),
    };

    final baseLabel = switch (baseClean) {
      'dry' => 'Dry',
      'oily' => 'Oily',
      'combination' => 'Combination',
      _ => base,
    };

    final concernLabel = switch (concernClean) {
      'sensitive' => 'Sensitive',
      'uneven' => 'Uneven',
      'wrinkled' => 'Wrinkled',
      _ => concern,
    };

    return SkinQuizResult(
      base: baseClean,
      concern: concernClean,
      code: '$baseCode$concernCode',
      label: '$baseLabel | $concernLabel',
    );
  }
}
