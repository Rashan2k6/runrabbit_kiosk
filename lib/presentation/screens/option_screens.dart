import 'package:flutter/material.dart' hide Step;

import '../../app/strings.dart';
import '../../domain/options.dart';
import '../../domain/product.dart';
import '../state/flow_state.dart';
import '../widgets/concern_cards.dart';
import '../widgets/option_grid.dart';
import '../widgets/screen_frame.dart';
import '../widgets/skin_type_cards.dart';

class SkinTypeScreen extends StatelessWidget {
  const SkinTypeScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  String? _skinSubtitle(String id) {
    if (flow.lang == 'si') return null;
    switch (id) {
      case 'oily':
        return 'Prone to shine throughout the day';
      case 'dry':
        return 'Feels tight, rough or flaky';
      case 'combination':
        return 'Oily T-zone, normal cheeks';
      case 'sensitive':
        return 'Easily irritated or reactive';
      case 'normal':
        return 'Balanced moisture and comfort';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('skinTitle'),
      subtitle: s.t('skinHelp'),
      child: SkinTypeCards(
        items: [
          for (final o in skinTypes)
            OptionItem(
              id: o.id,
              label: s.skin(o.id),
              emoji: o.emoji,
              subtitle: _skinSubtitle(o.id),
            ),
        ],
        selected: flow.skinType,
        onTap: flow.pickSkin,
      ),
    );
  }
}

class ConcernsScreen extends StatelessWidget {
  const ConcernsScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  String? _concernSubtitle(String id) {
    if (flow.lang == 'si') return null;
    switch (id) {
      case 'acne':
        return 'Blemishes & active spots';
      case 'pores':
        return 'Congestion & texture';
      case 'pigmentation':
        return 'Sun spots & dark marks';
      case 'dullness':
        return 'Uneven tone & lack of glow';
      case 'aging':
        return 'Elasticity & fine lines';
      case 'darkcircles':
        return 'Under-eye discoloration';
      case 'dryness':
        return 'Dehydration & moisture barrier';
      case 'redness':
        return 'Flushing & skin barrier calm';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = flow.concerns.length;
    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('concernsTitle'),
      subtitle: '${s.t('concernsHelp')}  ${s.t('counter', {'n': '$count'})}',
      primary: FilledButton(
        onPressed: count == 0 ? null : flow.toSteps,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.t('next')),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
      child: ConcernCards(
        items: [
          for (final o in concernOptions)
            OptionItem(
              id: o.id,
              label: s.concern(o.id),
              emoji: o.emoji,
              subtitle: _concernSubtitle(o.id),
            ),
        ],
        selected: flow.concerns,
        onTap: flow.toggleConcern,
      ),
    );
  }
}

class StepsScreen extends StatelessWidget {
  const StepsScreen({super.key, required this.flow, required this.s});

  final KioskFlow flow;
  final Strings s;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      flow: flow,
      s: s,
      title: s.t('stepsTitle'),
      subtitle: s.t('stepsHelp'),
      primary: FilledButton(
        onPressed: flow.steps.isEmpty ? null : flow.seeResults,
        child: Text(s.t('seeResults')),
      ),
      child: OptionGrid(
        items: [
          for (final step in routineSteps)
            OptionItem(
              id: step.name,
              label: s.step(step.name),
              icon: _stepIcon(step),
            ),
          OptionItem(
            id: 'wholeRoutine',
            label: s.t('wholeRoutine'),
            icon: Icons.auto_awesome_rounded,
          ),
        ],
        selected: {
          for (final step in flow.steps) step.name,
          if (flow.isWholeRoutine) 'wholeRoutine',
        },
        onTap: (id) => id == 'wholeRoutine'
            ? flow.toggleBundle()
            : flow.toggleStep(Step.values.byName(id)),
      ),
    );
  }

  IconData _stepIcon(Step step) {
    switch (step) {
      case Step.cleanser:
        return Icons.water_drop_outlined;
      case Step.toner:
        return Icons.water_rounded;
      case Step.serum:
        return Icons.colorize_rounded;
      case Step.moisturiser:
        return Icons.spa_outlined;
      case Step.sunscreen:
        return Icons.wb_sunny_outlined;
      case Step.mask:
        return Icons.masks_rounded;
    }
  }
}
