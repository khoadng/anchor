import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';

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

  /// Calculates the arrow direction and alignment based on anchor points.
  ///
  /// If [userArrowDirection] is provided, it will be used and [userArrowAlignment]
  /// defaults to center if not provided.
  ///
  /// If [userArrowDirection] is null, the direction is automatically determined
  /// from the [points], and alignment is calculated based on the cross-axis
  /// position unless [userArrowAlignment] is provided.
  ///
  /// When [userArrowAlignment] is provided, the value represents the position
  /// along the child element's edge (0.0 = start, 0.5 = center, 1.0 = end).
  /// The arrow will automatically adjust to point to the same relative position
  /// on the child, regardless of which side the overlay appears on due to
  /// screen constraints.
  factory ArrowInfo.fromPoints({
    required AnchorPoints points,
    AxisDirection? userArrowDirection,
    double? userArrowAlignment,
  }) {
    if (userArrowDirection != null) {
      return ArrowInfo(
        direction: userArrowDirection,
        alignment: userArrowAlignment ?? kArrowAlignmentCenter,
      );
    }

    final direction = switch (points) {
      AnchorPoints(isLeft: true) => AxisDirection.right,
      AnchorPoints(isRight: true) => AxisDirection.left,
      AnchorPoints(isBelow: true) => AxisDirection.up,
      _ => AxisDirection.down, // isAbove
    };

    final alignment = switch (userArrowAlignment) {
      final double value when !points.isCrossAxisFlipped => value,
      final double value => 1.0 - value,
      null => _calculateAutoAlignment(points: points, direction: direction),
    };

    return ArrowInfo(
      direction: direction,
      alignment: alignment,
    );
  }

  /// The direction the arrow points.
  final AxisDirection direction;

  /// The position of the arrow along the overlay's edge (0.0 to 1.0).
  final double alignment;

  /// Calculates automatic arrow alignment based on cross-axis positioning.
  static double _calculateAutoAlignment({
    required AnchorPoints points,
    required AxisDirection direction,
  }) {
    final crossAxisValue = switch (direction) {
      AxisDirection.left || AxisDirection.right => points.overlayAnchor.y,
      AxisDirection.up || AxisDirection.down => points.overlayAnchor.x,
    };

    return switch (crossAxisValue) {
      <= -0.5 => kArrowAlignmentStart,
      >= 0.5 => kArrowAlignmentEnd,
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
