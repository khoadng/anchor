import 'dart:ui';

import 'package:meta/meta.dart';

import '../position.dart';

/// A middleware that applies a positional offset to the overlay.
@immutable
class OffsetMiddleware implements PositioningMiddleware {
  /// Creates an [OffsetMiddleware].
  const OffsetMiddleware({
    this.mainAxis = 0.0,
    this.crossAxis = 0.0,
  });

  /// The offset along the main axis (e.g., vertical for `top`/`bottom`).
  /// A positive value moves the overlay *away* from the child.
  final double mainAxis;

  /// The offset along the cross axis (e.g., horizontal for `top`/`bottom`).
  /// A positive value typically moves the overlay to the right (for `top`/`bottom`)
  /// or down (for `left`/`right`).
  final double crossAxis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffsetMiddleware &&
          runtimeType == other.runtimeType &&
          mainAxis == other.mainAxis &&
          crossAxis == other.crossAxis;

  @override
  int get hashCode => Object.hash(mainAxis, crossAxis);

  @override
  String toString() =>
      'OffsetMiddleware(mainAxis: $mainAxis, crossAxis: $crossAxis)';

  @override
  PositionState run(PositionState state) {
    final points = state.anchorPoints;

    final newOffset = switch (points) {
      _ when points.isAbove => Offset(crossAxis, -mainAxis),
      _ when points.isBelow => Offset(crossAxis, mainAxis),
      _ when points.isLeft => Offset(-mainAxis, crossAxis),
      _ when points.isRight => Offset(mainAxis, crossAxis),
      _ => Offset.zero,
    };

    final updatedPoints = points.copyWith(
      offset: points.offset + newOffset,
    );

    return state.copyWith(anchorPoints: updatedPoints);
  }
}
