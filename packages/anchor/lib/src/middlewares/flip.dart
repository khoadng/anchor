import 'package:meta/meta.dart';

import '../position.dart';
import '../types.dart';
import 'virtual.dart';

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
/// if it overflows the viewport in its preferred direction.
///
/// If neither side fits, it chooses the side with more available space
/// among the two.
@immutable
class FlipMiddleware implements PositioningMiddleware<FlipData> {
  /// Creates a [FlipMiddleware].
  const FlipMiddleware();

  @override
  (PositionState, FlipData?) run(PositionState state) {
    final config = state.config;
    final preferredDirection = config.placement.direction;
    final currentAnchors = state.anchorPoints;
    final currentOffset = currentAnchors.offset;
    final virtualData = state.metadata.get<VirtualReferenceData>();

    final preferredFits = _canFitWithOffset(
      config: config,
      direction: preferredDirection,
      offset: currentOffset,
      isVirtual: virtualData != null,
    );

    if (preferredFits) {
      return (
        state,
        FlipData(wasFlipped: false, finalDirection: preferredDirection),
      );
    }

    final opposite = _flipDirection(preferredDirection);
    final spaces = config.spaces;

    final oppositeFits = _canFitWithOffset(
      config: config,
      direction: opposite,
      offset: currentOffset,
      isVirtual: virtualData != null,
    );

    final chosenDirection = switch (oppositeFits) {
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

    // Flip the placement to preserve alignment
    final flippedPlacement = config.placement.flip();

    // When flipping, we need to invert the main axis component of the offset
    // to maintain its semantic meaning (e.g., "50px away from child" should
    // remain "50px away" even after flipping to the opposite side).
    final flippedOffset = _invertOffsetForFlip(
      currentOffset: currentAnchors.offset,
      direction: preferredDirection,
    );

    // For virtual references, we need to recalculate the offset for the new
    // placement since offset calculations are placement-specific.
    // For normal widget anchors, we update the anchor points directly.
    final anchors = switch (virtualData) {
      null => flippedPlacement.toAnchorPoints().copyWith(
            offset: flippedOffset,
          ),
      final virtualData => currentAnchors.copyWith(
          offset: VirtualReferenceMiddleware.calculateOffsetForPlacement(
            virtualRect: virtualData.virtualRect,
            childPosition: config.childPosition,
            placement: flippedPlacement,
            overlayWidth: config.overlayWidth,
            overlayHeight: config.overlayHeight,
          ),
        ),
    };

    final newState = state.copyWith(
      anchorPoints: anchors,
      config: config.copyWith(placement: flippedPlacement),
    );
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

  /// Inverts the main axis component of an offset when flipping.
  ///
  /// This ensures that offsets maintain their semantic meaning after a flip.
  /// For example, a positive mainAxis offset means "away from child", and this
  /// should remain "away from child" even after flipping to the opposite side.
  static Offset _invertOffsetForFlip({
    required Offset currentOffset,
    required AxisDirection direction,
  }) {
    return switch (direction) {
      AxisDirection.up || AxisDirection.down => Offset(
          currentOffset.dx,
          -currentOffset.dy,
        ),
      AxisDirection.left || AxisDirection.right => Offset(
          -currentOffset.dx,
          currentOffset.dy,
        ),
    };
  }

  /// Checks if the overlay can fit in the given direction with the current offset applied.
  bool _canFitWithOffset({
    required PositioningConfig config,
    required AxisDirection direction,
    required Offset offset,
    required bool isVirtual,
  }) {
    final availableSpace = config.spaces.inDirection(direction);

    // For virtual references, the available spaces are already calculated
    // relative to the virtual reference position, and the offset represents
    // an absolute position from the child origin. We should only check if
    // the overlay size fits in the available space.
    //
    // For non-virtual references, the offset is a relative spacing adjustment,
    // so we need to account for it when checking if the overlay fits.
    return switch (direction) {
      AxisDirection.up => switch (config.overlayHeight) {
          final height? => isVirtual
              ? availableSpace >= height
              : availableSpace >= (height + offset.dy.abs()),
          null => true,
        },
      AxisDirection.down => switch (config.overlayHeight) {
          final height? => isVirtual
              ? availableSpace >= height
              : availableSpace >= (height + offset.dy.abs()),
          null => true,
        },
      AxisDirection.left => switch (config.overlayWidth) {
          final width? => isVirtual
              ? availableSpace >= width
              : availableSpace >= (width + offset.dx.abs()),
          null => true,
        },
      AxisDirection.right => switch (config.overlayWidth) {
          final width? => isVirtual
              ? availableSpace >= width
              : availableSpace >= (width + offset.dx.abs()),
          null => true,
        },
    };
  }

  @override
  String toString() => 'Flip()';
}
