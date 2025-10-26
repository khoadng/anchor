import 'dart:ui';

import 'package:meta/meta.dart';

import '../anchor_points.dart';
import '../position.dart';
import '../types.dart';

/// Data produced by [ArrowMiddleware] after positioning.
///
/// Contains the precise coordinates for positioning an arrow element
/// to point at the center of the reference element.
@immutable
class ArrowData {
  /// Creates [ArrowData].
  const ArrowData({
    required this.x,
    required this.y,
    required this.centerOffset,
  });

  /// The x-coordinate offset for the arrow (used for top/bottom placements).
  ///
  /// This value represents the distance from the left edge of the overlay
  /// to where the arrow should be positioned.
  final double? x;

  /// The y-coordinate offset for the arrow (used for left/right placements).
  ///
  /// This value represents the distance from the top edge of the overlay
  /// to where the arrow should be positioned.
  final double? y;

  /// How far the arrow is from being perfectly centered on the reference element.
  ///
  /// A value of 0 means the arrow is perfectly centered.
  /// A non-zero value indicates the arrow had to shift to stay within bounds.
  final double centerOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowData &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          centerOffset == other.centerOffset;

  @override
  int get hashCode => Object.hash(x, y, centerOffset);

  @override
  String toString() => 'ArrowData(x: $x, y: $y, centerOffset: $centerOffset)';
}

/// A middleware that calculates the position of an arrow element.
///
/// This middleware computes precise coordinates for an arrow (triangle/caret)
/// so it appears to point at the center of the reference element.
@immutable
class ArrowMiddleware implements PositioningMiddleware<ArrowData> {
  /// Creates an [ArrowMiddleware].
  ///
  /// [arrowSize] is the size (width and height) of the arrow element.
  /// [padding] is the minimum distance the arrow should maintain from
  /// the edges of the overlay.
  const ArrowMiddleware({
    required this.arrowSize,
    this.padding = 0.0,
  });

  /// The size of the arrow element (both width and height).
  final Size arrowSize;

  /// The minimum padding from the overlay edges.
  final double padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowMiddleware &&
          runtimeType == other.runtimeType &&
          arrowSize == other.arrowSize &&
          padding == other.padding;

  @override
  int get hashCode => Object.hash(arrowSize, padding);

  @override
  String toString() =>
      'ArrowMiddleware(arrowSize: $arrowSize, padding: $padding)';

  @override
  (PositionState, ArrowData?) run(PositionState state) {
    final points = state.anchorPoints;
    final config = state.config;

    final isVertical = points.isAbove || points.isBelow;
    final isHorizontal = points.isLeft || points.isRight;

    final overlayWidth = config.overlayWidth;
    final overlayHeight = config.overlayHeight;
    final childSize = config.childSize;
    final childPosition = config.childPosition;

    // Can't calculate arrow position without overlay dimensions
    if (overlayWidth == null || overlayHeight == null) {
      return (state, null);
    }

    final overlayPosition = _calculateOverlayPosition(
      childPosition: childPosition,
      childSize: childSize,
      overlaySize: Size(overlayWidth, overlayHeight),
      anchorPoints: points,
    );

    if (isVertical) {
      // For top/bottom placements, calculate x position
      // Arrow should point at center of child, relative to overlay
      final childCenterX = childPosition.dx + childSize.width / 2;
      final relativeToOverlay = childCenterX - overlayPosition.dx;

      final arrowX = _calculateArrowPosition(
        idealPosition: relativeToOverlay,
        overlaySize: overlayWidth,
        arrowSize: arrowSize.width,
        padding: padding,
      );

      return (
        state,
        ArrowData(
          x: arrowX.position,
          y: null,
          centerOffset: arrowX.centerOffset,
        ),
      );
    } else if (isHorizontal) {
      // For left/right placements, calculate y position
      // Arrow should point at center of child, relative to overlay
      final childCenterY = childPosition.dy + childSize.height / 2;
      final relativeToOverlay = childCenterY - overlayPosition.dy;

      final arrowY = _calculateArrowPosition(
        idealPosition: relativeToOverlay,
        overlaySize: overlayHeight,
        arrowSize: arrowSize.height,
        padding: padding,
      );

      return (
        state,
        ArrowData(
          x: null,
          y: arrowY.position,
          centerOffset: arrowY.centerOffset,
        ),
      );
    }

    return (state, null);
  }

  Offset _calculateOverlayPosition({
    required Offset childPosition,
    required Size childSize,
    required Size overlaySize,
    required AnchorPoints anchorPoints,
  }) {
    final childAnchorOffset = Offset(
      childSize.width * (anchorPoints.childAnchor.x + 1) / 2,
      childSize.height * (anchorPoints.childAnchor.y + 1) / 2,
    );

    final overlayAnchorOffset = Offset(
      overlaySize.width * (anchorPoints.overlayAnchor.x + 1) / 2,
      overlaySize.height * (anchorPoints.overlayAnchor.y + 1) / 2,
    );

    final anchorPoint = childPosition + childAnchorOffset;
    return anchorPoint - overlayAnchorOffset + anchorPoints.offset;
  }

  _ArrowCalculation _calculateArrowPosition({
    required double idealPosition,
    required double overlaySize,
    required double arrowSize,
    required double padding,
  }) {
    final idealArrowStart = idealPosition - arrowSize / 2;

    final minPosition = padding;
    final maxPosition = overlaySize - arrowSize - padding;

    final clampedPosition = idealArrowStart.clamp(minPosition, maxPosition);

    final arrowActualCenter = clampedPosition + arrowSize / 2;
    final centerOffset = arrowActualCenter - idealPosition;

    return _ArrowCalculation(
      position: clampedPosition,
      centerOffset: centerOffset,
    );
  }
}

/// Internal class to hold arrow calculation results.
class _ArrowCalculation {
  const _ArrowCalculation({
    required this.position,
    required this.centerOffset,
  });

  final double position;
  final double centerOffset;
}
