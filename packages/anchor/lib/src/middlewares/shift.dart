import 'package:meta/meta.dart';

import '../anchor_points.dart';
import '../placement.dart';
import '../position.dart';
import '../types.dart';

/// Data produced by [ShiftMiddleware] after positioning.
@immutable
class ShiftData {
  /// Creates [ShiftData].
  const ShiftData({required this.shift});

  /// The shift offset applied to prevent overflow.
  ///
  /// For vertical placements (top/bottom), this is the horizontal shift.
  /// For horizontal placements (left/right), this is the vertical shift.
  final Offset shift;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftData &&
          runtimeType == other.runtimeType &&
          shift == other.shift;

  @override
  int get hashCode => shift.hashCode;

  @override
  String toString() => 'ShiftData(shift: $shift)';
}

/// A middleware that adjusts the overlay's alignment along
/// the cross-axis to prevent it from overflowing the viewport.
///
/// For example, a [Placement.top] (which implies center alignment)
/// might be "shifted" to the left or right if it's too close to the
/// edge of the screen.
@immutable
class ShiftMiddleware implements PositioningMiddleware<ShiftData> {
  /// Creates a [ShiftMiddleware].
  const ShiftMiddleware({
    required this.preferredDirection,
  });

  /// The preferred [AxisDirection] to determine which cross-axis to shift.
  /// This is typically derived from the initial [Placement].
  final AxisDirection preferredDirection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftMiddleware &&
          runtimeType == other.runtimeType &&
          preferredDirection == other.preferredDirection;

  @override
  int get hashCode => preferredDirection.hashCode;

  @override
  (PositionState, ShiftData?) run(PositionState state) {
    final config = state.config;
    final originalOffset = state.anchorPoints.offset;

    final anchors = switch (preferredDirection) {
      // Vertical placements (above/below) → shift horizontally (cross-axis)
      AxisDirection.up || AxisDirection.down => switch (config.overlayWidth) {
          final width? => _adjustForOverflow(
              anchors: state.anchorPoints,
              axis: Axis.horizontal,
              overlaySize: width,
              childPosition: config.childPosition,
              childSize: config.childSize,
              viewportSize: config.viewportSize.width,
              padding: config.padding,
            ),
          null => state.anchorPoints,
        },
      // Horizontal placements (left/right) → shift vertically (cross-axis)
      AxisDirection.left || AxisDirection.right => switch (
            config.overlayHeight) {
          final height? => _adjustForOverflow(
              anchors: state.anchorPoints,
              axis: Axis.vertical,
              overlaySize: height,
              childPosition: config.childPosition,
              childSize: config.childSize,
              viewportSize: config.viewportSize.height,
              padding: config.padding,
            ),
          null => state.anchorPoints,
        },
    };

    final newState = state.copyWith(anchorPoints: anchors);
    final appliedShift = anchors.offset - originalOffset;

    return (newState, ShiftData(shift: appliedShift));
  }

  static AnchorPoints _adjustForOverflow({
    required AnchorPoints anchors,
    required Axis axis,
    required double overlaySize,
    required Offset childPosition,
    required Size childSize,
    required double viewportSize,
    required EdgeInsets padding,
  }) {
    final (childAnchorPos, overlayAnchorOffset, overlayOffset) = switch (axis) {
      Axis.horizontal => (
          childPosition.dx +
              (childSize.width / 2) * (1 + anchors.childAnchor.x),
          (overlaySize / 2) * (1 + anchors.overlayAnchor.x),
          anchors.offset.dx,
        ),
      Axis.vertical => (
          childPosition.dy +
              (childSize.height / 2) * (1 + anchors.childAnchor.y),
          (overlaySize / 2) * (1 + anchors.overlayAnchor.y),
          anchors.offset.dy,
        ),
    };

    final overlayStart = childAnchorPos - overlayAnchorOffset + overlayOffset;
    final overlayEnd = overlayStart + overlaySize;

    // Calculate boundaries accounting for padding
    final (boundaryStart, boundaryEnd) = switch (axis) {
      Axis.horizontal => (padding.left, viewportSize - padding.right),
      Axis.vertical => (padding.top, viewportSize - padding.bottom),
    };

    // Calculate overflow amounts (positive means overflowing)
    final overflowStart = boundaryStart - overlayStart;
    final overflowEnd = overlayEnd - boundaryEnd;

    final shift = switch ((overflowStart, overflowEnd)) {
      (_, > 0) => -overflowEnd, // Overflowing end: shift toward start
      (> 0, _) => overflowStart, // Overflowing start: shift toward end
      _ => 0.0, // No overflow
    };

    if (shift == 0) return anchors;

    return anchors.copyWith(
      offset: switch (axis) {
        Axis.horizontal => anchors.offset + Offset(shift, 0),
        Axis.vertical => anchors.offset + Offset(0, shift),
      },
    );
  }
}
