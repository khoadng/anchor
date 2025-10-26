import 'package:anchor/anchor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Contains the geometric information of the anchored overlay.
@immutable
class AnchorGeometry {
  /// Creates an [AnchorGeometry].
  const AnchorGeometry({
    required this.overlayBounds,
    required this.childBounds,
    required this.direction,
    required this.alignment,
  });

  /// Calculates the anchor geometry based on anchor points and positioning info.
  factory AnchorGeometry.fromPoints({
    required AnchorPoints points,
    required Offset offset,
    Offset? childGlobalPosition,
    Size? childSize,
    double? overlayWidth,
    double? overlayHeight,
  }) {
    final direction = points.isAbove
        ? AxisDirection.up
        : points.isBelow
            ? AxisDirection.down
            : points.isLeft
                ? AxisDirection.left
                : AxisDirection.right;

    Rect? overlayBounds;
    if (overlayWidth != null &&
        overlayHeight != null &&
        childGlobalPosition != null &&
        childSize != null) {
      final overlayX = childGlobalPosition.dx +
          (points.childAnchor.x + 1) * childSize.width / 2 +
          offset.dx -
          (points.overlayAnchor.x + 1) * overlayWidth / 2;
      final overlayY = childGlobalPosition.dy +
          (points.childAnchor.y + 1) * childSize.height / 2 +
          offset.dy -
          (points.overlayAnchor.y + 1) * overlayHeight / 2;
      overlayBounds = Rect.fromLTWH(
        overlayX,
        overlayY,
        overlayWidth,
        overlayHeight,
      );
    }

    Rect? childBounds;
    if (childGlobalPosition != null && childSize != null) {
      childBounds = Rect.fromLTWH(
        childGlobalPosition.dx,
        childGlobalPosition.dy,
        childSize.width,
        childSize.height,
      );
    }

    return AnchorGeometry(
      overlayBounds: overlayBounds,
      childBounds: childBounds,
      direction: direction,
      alignment: points.overlayAlignment,
    );
  }

  /// The global bounds of the overlay content.
  final Rect? overlayBounds;

  /// The global bounds of the child widget.
  final Rect? childBounds;

  /// The direction the overlay is facing relative to its child.
  final AxisDirection direction;

  /// The alignment of the overlay on the cross-axis.
  final Alignment alignment;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnchorGeometry &&
        other.overlayBounds == overlayBounds &&
        other.childBounds == childBounds &&
        other.direction == direction &&
        other.alignment == alignment;
  }

  @override
  int get hashCode =>
      Object.hash(overlayBounds, childBounds, direction, alignment);
}
