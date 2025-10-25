import 'package:meta/meta.dart';

import '../anchor_points.dart';
import '../placement.dart';
import '../position.dart';
import '../types.dart';

/// Data produced by [FlipMiddleware] after positioning.
@immutable
class FlipData {
  /// Creates [FlipData].
  const FlipData({
    required this.wasFlipped,
    required this.finalDirection,
  });

  /// Whether the overlay was flipped from the preferred direction.
  final bool wasFlipped;

  /// The final direction chosen for the overlay.
  final AxisDirection finalDirection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlipData &&
          runtimeType == other.runtimeType &&
          wasFlipped == other.wasFlipped &&
          finalDirection == other.finalDirection;

  @override
  int get hashCode => Object.hash(wasFlipped, finalDirection);

  @override
  String toString() =>
      'FlipData(wasFlipped: $wasFlipped, finalDirection: $finalDirection)';
}

/// A middleware that flips the overlay to the opposite side
/// if it overflows the viewport in its [preferredDirection].
///
/// For example, if [preferredDirection] is [AxisDirection.up] but the
/// overlay doesn't fit, it will try [AxisDirection.down].
///
/// If neither side fits, it chooses the side with more available space
/// among the two.
@immutable
class FlipMiddleware implements PositioningMiddleware<FlipData> {
  /// Creates a [FlipMiddleware].
  const FlipMiddleware({
    required this.preferredDirection,
  });

  /// The initial [AxisDirection] to try and fit the overlay in.
  /// This is typically derived from the initial [Placement].
  final AxisDirection preferredDirection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlipMiddleware &&
          runtimeType == other.runtimeType &&
          preferredDirection == other.preferredDirection;

  @override
  int get hashCode => preferredDirection.hashCode;

  @override
  (PositionState, FlipData?) run(PositionState state) {
    final config = state.config;

    // If the preferred direction fits, nothing to do.
    if (config.canFitInDirection(preferredDirection)) {
      return (
        state,
        FlipData(wasFlipped: false, finalDirection: preferredDirection),
      );
    }

    final currentAnchors = state.anchorPoints;
    final isConstraints = config.explicitSpaces != null;
    final opposite = _flipDirection(preferredDirection);
    final spaces = config.spaces;

    // Determine which direction to use
    final chosenDirection = switch (config.canFitInDirection(opposite)) {
      // If opposite fits, use it
      true => opposite,

      // If neither fits, pick the direction with more space
      false => spaces.largerDirection(preferredDirection),
    };

    // If we're staying with the preferred direction, no change needed
    if (chosenDirection == preferredDirection) {
      return (
        state,
        FlipData(wasFlipped: false, finalDirection: preferredDirection),
      );
    }

    // Create new anchor points for the chosen direction
    final rawAnchors = AnchorPoints.raw(chosenDirection);
    final anchors = rawAnchors.copyWith(
      childAnchor:
          isConstraints ? currentAnchors.childAnchor : rawAnchors.childAnchor,
      offset: currentAnchors.offset,
    );

    final newState = state.copyWith(anchorPoints: anchors);
    return (
      newState,
      FlipData(wasFlipped: true, finalDirection: chosenDirection),
    );
  }

  /// Returns the opposite [AxisDirection] on the same axis.
  static AxisDirection _flipDirection(AxisDirection direction) {
    return switch (direction) {
      AxisDirection.up => AxisDirection.down,
      AxisDirection.down => AxisDirection.up,
      AxisDirection.left => AxisDirection.right,
      AxisDirection.right => AxisDirection.left,
    };
  }
}
