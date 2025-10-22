import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// An abstract class for defining the shape of an overlay's arrow.
///
/// Implement this class to create custom arrow shapes.
abstract class ArrowShape {
  /// Creates an arrow shape.
  const ArrowShape();

  /// Adds the drawing commands for the arrow to the given [Path].
  ///
  /// - [path]: The [Path] object to which the arrow's geometry is added.
  /// - [baseStart]: The starting point of the arrow's base on the overlay's edge.
  /// - [baseEnd]: The ending point of the arrow's base on the overlay's edge.
  /// - [direction]: The direction the arrow should point.
  /// - [arrowHeight]: The length of the arrow from its base to its tip.
  void buildArrowPath({
    required Path path,
    required Offset baseStart,
    required Offset baseEnd,
    required AxisDirection direction,
    required double arrowHeight,
  });
}

/// An [ArrowShape] that draws a simple, triangular arrow.
class SharpArrow extends ArrowShape {
  /// Creates a sharp, triangular arrow shape.
  const SharpArrow();

  @override
  void buildArrowPath({
    required Path path,
    required Offset baseStart,
    required Offset baseEnd,
    required AxisDirection direction,
    required double arrowHeight,
  }) {
    final tipPosition = switch (direction) {
      AxisDirection.up => Offset(
          (baseStart.dx + baseEnd.dx) / 2,
          baseStart.dy - arrowHeight,
        ),
      AxisDirection.down => Offset(
          (baseStart.dx + baseEnd.dx) / 2,
          baseStart.dy + arrowHeight,
        ),
      AxisDirection.left => Offset(
          baseStart.dx - arrowHeight,
          (baseStart.dy + baseEnd.dy) / 2,
        ),
      AxisDirection.right => Offset(
          baseStart.dx + arrowHeight,
          (baseStart.dy + baseEnd.dy) / 2,
        ),
    };

    path.lineTo(tipPosition.dx, tipPosition.dy);
    path.lineTo(baseEnd.dx, baseEnd.dy);
  }
}

/// An [ArrowShape] that renders no arrow at all.
///
/// Use this when you want the styled overlay container without an arrow,
/// such as for tooltips or simple overlays.
class NoArrow extends ArrowShape {
  /// Creates a no-arrow shape.
  const NoArrow();

  @override
  void buildArrowPath({
    required Path path,
    required Offset baseStart,
    required Offset baseEnd,
    required AxisDirection direction,
    required double arrowHeight,
  }) {
    path.lineTo(baseEnd.dx, baseEnd.dy);
  }
}

/// An [ArrowShape] that draws a smooth, curved arrow using cubic Bezier curves.
@immutable
class RoundedArrow extends ArrowShape {
  /// Creates a smooth, rounded arrow shape.
  const RoundedArrow({this.spread = 0.4, this.liftOff = 0.25});

  /// Controls the flatness of the arrow's peak.
  ///
  /// A value of `0.0` results in a pointed peak, while `1.0` results in a
  /// very flat, wide peak.
  final double spread;

  /// Controls how quickly the curve lifts off from the overlay's edge.
  ///
  /// A smaller value creates a steeper curve.
  final double liftOff;

  @override
  void buildArrowPath({
    required Path path,
    required Offset baseStart,
    required Offset baseEnd,
    required AxisDirection direction,
    required double arrowHeight,
  }) {
    final Offset tip;
    final Offset c1;
    final Offset c2;
    final Offset c3;
    final Offset c4; // Control points for two cubic curves

    switch (direction) {
      case AxisDirection.up:
      case AxisDirection.down:
        final arrowWidth = baseEnd.dx - baseStart.dx;
        final vSign = direction == AxisDirection.up ? -1.0 : 1.0;
        tip = Offset(
          (baseStart.dx + baseEnd.dx) / 2,
          baseStart.dy + arrowHeight * vSign,
        );

        c1 = Offset(baseStart.dx + arrowWidth * liftOff, baseStart.dy);
        c2 = Offset(tip.dx - (arrowWidth / 2) * spread, tip.dy);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, tip.dx, tip.dy);

        c3 = Offset(tip.dx + (arrowWidth / 2) * spread, tip.dy);
        c4 = Offset(baseEnd.dx - arrowWidth * liftOff, baseEnd.dy);
        path.cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, baseEnd.dx, baseEnd.dy);

      case AxisDirection.left:
      case AxisDirection.right:
        final arrowWidth =
            baseEnd.dy - baseStart.dy; // "width" is on the y-axis
        final hSign = direction == AxisDirection.left ? -1.0 : 1.0;
        tip = Offset(
          baseStart.dx + arrowHeight * hSign,
          (baseStart.dy + baseEnd.dy) / 2,
        );

        c1 = Offset(baseStart.dx, baseStart.dy + arrowWidth * liftOff);
        c2 = Offset(tip.dx, tip.dy - (arrowWidth / 2) * spread);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, tip.dx, tip.dy);

        c3 = Offset(tip.dx, tip.dy + (arrowWidth / 2) * spread);
        c4 = Offset(baseEnd.dx, baseEnd.dy - arrowWidth * liftOff);
        path.cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, baseEnd.dx, baseEnd.dy);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundedArrow &&
          runtimeType == other.runtimeType &&
          spread == other.spread &&
          liftOff == other.liftOff;

  @override
  int get hashCode => Object.hash(runtimeType, spread, liftOff);
}
