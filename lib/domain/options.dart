import 'product.dart';

/// The choices the customer sees. Ids are used in products.json.
class Option {
  const Option(this.id, this.emoji);
  final String id;
  final String emoji;
}

const skinTypes = <Option>[
  Option('oily', '✨'),
  Option('dry', '🌵'),
  Option('combination', '🌗'),
  Option('sensitive', '🌸'),
  Option('normal', '🙂'),
];

const concernOptions = <Option>[
  Option('acne', '🔴'),
  Option('pores', '🔍'),
  Option('pigmentation', '🟤'),
  Option('dullness', '☁️'),
  Option('aging', '⏳'),
  Option('darkcircles', '🌙'),
  Option('dryness', '💧'),
  Option('redness', '🌹'),
];

const maxConcerns = 3;

/// The five steps customers can choose. `mask` remains in [Step] because it
/// exists in the catalogue, but it is not part of the kiosk routine flow.
const routineSteps = <Step>[
  Step.cleanser,
  Step.toner,
  Step.serum,
  Step.moisturiser,
  Step.sunscreen,
];
