import 'anchor_points.dart';
import 'types.dart';

/// Represents where the overlay should be positioned relative to the child.
enum Placement {
  /// Position above the child, centered horizontally
  top,

  /// Position above the child, aligned to the left
  topStart,

  /// Position above the child, aligned to the right
  topEnd,

  /// Position below the child, centered horizontally
  bottom,

  /// Position below the child, aligned to the left
  bottomStart,

  /// Position below the child, aligned to the right
  bottomEnd,

  /// Position to the left of the child, centered vertically
  left,

  /// Position to the left of the child, aligned to the top
  leftStart,

  /// Position to the left of the child, aligned to the bottom
  leftEnd,

  /// Position to the right of the child, centered vertically
  right,

  /// Position to the right of the child, aligned to the top
  rightStart,

  /// Position to the right of the child, aligned to the bottom
  rightEnd;

  /// Returns the main-axis direction for this placement.
  AxisDirection get direction {
    return switch (this) {
      Placement.top ||
      Placement.topStart ||
      Placement.topEnd =>
        AxisDirection.up,
      Placement.bottom ||
      Placement.bottomStart ||
      Placement.bottomEnd =>
        AxisDirection.down,
      Placement.left ||
      Placement.leftStart ||
      Placement.leftEnd =>
        AxisDirection.left,
      Placement.right ||
      Placement.rightStart ||
      Placement.rightEnd =>
        AxisDirection.right,
    };
  }

  /// Returns true if this placement is on the vertical axis (top/bottom).
  bool get isVertical =>
      direction == AxisDirection.up || direction == AxisDirection.down;

  /// Returns true if this placement is on the horizontal axis (left/right).
  bool get isHorizontal =>
      direction == AxisDirection.left || direction == AxisDirection.right;

  /// Returns the initial anchor points for this placement.
  AnchorPoints toAnchorPoints() {
    return switch (this) {
      // Top placements
      Placement.top => const AnchorPoints(
          childAnchor: Alignment.topCenter,
          overlayAnchor: Alignment.bottomCenter,
        ),
      Placement.topStart => const AnchorPoints(
          childAnchor: Alignment.topLeft,
          overlayAnchor: Alignment.bottomLeft,
        ),
      Placement.topEnd => const AnchorPoints(
          childAnchor: Alignment.topRight,
          overlayAnchor: Alignment.bottomRight,
        ),

      // Bottom placements
      Placement.bottom => const AnchorPoints(
          childAnchor: Alignment.bottomCenter,
          overlayAnchor: Alignment.topCenter,
        ),
      Placement.bottomStart => const AnchorPoints(
          childAnchor: Alignment.bottomLeft,
          overlayAnchor: Alignment.topLeft,
        ),
      Placement.bottomEnd => const AnchorPoints(
          childAnchor: Alignment.bottomRight,
          overlayAnchor: Alignment.topRight,
        ),

      // Left placements
      Placement.left => const AnchorPoints(
          childAnchor: Alignment.centerLeft,
          overlayAnchor: Alignment.centerRight,
        ),
      Placement.leftStart => const AnchorPoints(
          childAnchor: Alignment.topLeft,
          overlayAnchor: Alignment.topRight,
        ),
      Placement.leftEnd => const AnchorPoints(
          childAnchor: Alignment.bottomLeft,
          overlayAnchor: Alignment.bottomRight,
        ),

      // Right placements
      Placement.right => const AnchorPoints(
          childAnchor: Alignment.centerRight,
          overlayAnchor: Alignment.centerLeft,
        ),
      Placement.rightStart => const AnchorPoints(
          childAnchor: Alignment.topRight,
          overlayAnchor: Alignment.topLeft,
        ),
      Placement.rightEnd => const AnchorPoints(
          childAnchor: Alignment.bottomRight,
          overlayAnchor: Alignment.bottomLeft,
        ),
    };
  }
}
