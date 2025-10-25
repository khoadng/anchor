import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';

import '../core/geometry.dart';

/// Constant for aligning the arrow to the start of the overlay edge.
const kArrowAlignmentStart = 0.1;

/// Constant for aligning the arrow to the center of the overlay edge.
const kArrowAlignmentCenter = 0.5;

/// Constant for aligning the arrow to the end of the overlay edge.
const kArrowAlignmentEnd = 0.9;

/// Contains calculated information about the arrow's direction and alignment
/// for an anchored overlay.
@immutable
class ArrowInfo {
  /// Creates arrow information with the given direction and alignment.
  const ArrowInfo({
    required this.direction,
    required this.alignment,
  });

  /// Calculates the arrow direction and alignment based on anchor points and geometry.
  factory ArrowInfo.fromPoints({
    required AnchorPoints points,
    PositionMetadata? metadata,
    AnchorGeometry? geometry,
  }) {
    // Determine arrow direction
    final flipData = metadata?.get<FlipData>();
    final direction = switch (flipData?.finalDirection) {
      // If we have flip data, use the opposite direction
      AxisDirection.up => AxisDirection.down,
      AxisDirection.down => AxisDirection.up,
      AxisDirection.left => AxisDirection.right,
      AxisDirection.right => AxisDirection.left,
      null => switch (points) {
          AnchorPoints(isLeft: true) => AxisDirection.right,
          AnchorPoints(isRight: true) => AxisDirection.left,
          AnchorPoints(isBelow: true) => AxisDirection.up,
          _ => AxisDirection.down,
        },
    };

    return ArrowInfo(
      direction: direction,
      alignment: _calculateAutoAlignment(
        points: points,
        direction: direction,
        geometry: geometry,
      ),
    );
  }

  /// The direction the arrow points.
  final AxisDirection direction;

  /// The position of the arrow along the overlay's edge (0.0 to 1.0).
  final double alignment;

  /// Calculates automatic arrow alignment based on child position.
  ///
  /// Falls back to using anchor points if geometry is not available.
  static double _calculateAutoAlignment({
    required AnchorPoints points,
    required AxisDirection direction,
    AnchorGeometry? geometry,
  }) {
    final childBounds = geometry?.childBounds;
    final overlayBounds = geometry?.overlayBounds;
    if (childBounds != null && overlayBounds != null) {
      final childCenter = childBounds.center;

      final relativePosition = switch (direction) {
        AxisDirection.up ||
        AxisDirection.down =>
          (childCenter.dx - overlayBounds.left) / overlayBounds.width,
        AxisDirection.left ||
        AxisDirection.right =>
          (childCenter.dy - overlayBounds.top) / overlayBounds.height,
      };

      final clamped = relativePosition.clamp(0.0, 1.0);
      return switch (clamped) {
        < 0.3 => kArrowAlignmentStart,
        > 0.7 => kArrowAlignmentEnd,
        _ => kArrowAlignmentCenter,
      };
    }

    // Fallback: use anchor points cross-axis value
    final crossAxisValue = switch (direction) {
      AxisDirection.left || AxisDirection.right => points.overlayAnchor.y,
      AxisDirection.up || AxisDirection.down => points.overlayAnchor.x,
    };

    return switch (crossAxisValue) {
      < -0.3 => kArrowAlignmentStart,
      > 0.3 => kArrowAlignmentEnd,
      _ => kArrowAlignmentCenter,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowInfo &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          alignment == other.alignment;

  @override
  int get hashCode => Object.hash(direction, alignment);

  @override
  String toString() =>
      'ArrowInfo(direction: $direction, alignment: $alignment)';
}
