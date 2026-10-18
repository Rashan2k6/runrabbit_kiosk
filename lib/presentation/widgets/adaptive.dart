import 'package:flutter/widgets.dart';

/// One scale factor derived from the screen's shorter side, so a 7" and a 13"
/// tablet both look right in either orientation. 600dp is the baseline.
class Adaptive {
  const Adaptive._(this.scale, this.width);

  final double scale;
  final double width;

  factory Adaptive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Adaptive._((size.shortestSide / 600).clamp(0.9, 1.6), size.width);
  }

  /// Scales a design value (padding, font size, tile size).
  double s(double v) => v * scale;
}
