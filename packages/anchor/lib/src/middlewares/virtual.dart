import 'package:meta/meta.dart';

import '../anchor_points.dart';
import '../placement.dart';
import '../position.dart';
import '../types.dart';
import '../virtual_reference.dart';

/// Data produced by [VirtualReferenceMiddleware] after positioning.
@immutable
class VirtualReferenceData {
  /// Creates [VirtualReferenceData].
  const VirtualReferenceData({
    required this.virtualPosition,
    required this.virtualSize,
    required this.appliedOffset,
    required this.virtualRect,
  });

  /// The position of the virtual reference point.
  final Offset virtualPosition;

  /// The size of the virtual reference (0x0 for point references).
  final Size virtualSize;

  /// The offset that was applied to move from the original child position
  /// to the virtual reference position.
  final Offset appliedOffset;

  /// The bounding rectangle of the virtual reference.
  final Rect virtualRect;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualReferenceData &&
          runtimeType == other.runtimeType &&
          virtualPosition == other.virtualPosition &&
          virtualSize == other.virtualSize &&
          appliedOffset == other.appliedOffset &&
          virtualRect == other.virtualRect;

  @override
  int get hashCode =>
      Object.hash(virtualPosition, virtualSize, appliedOffset, virtualRect);

  @override
  String toString() =>
      'VirtualReferenceData(position: $virtualPosition, size: $virtualSize, offset: $appliedOffset, rect: $virtualRect)';
}

/// A middleware that positions the overlay at an absolute
/// position using a [VirtualReference].
///
/// This is useful for context menus, tooltips at cursor position, or any
/// overlay that should appear at an arbitrary location rather than anchored
/// to a physical widget.
@immutable
class VirtualReferenceMiddleware
    implements PositioningMiddleware<VirtualReferenceData> {
  /// Creates a [VirtualReferenceMiddleware].
  const VirtualReferenceMiddleware(this.reference);

  /// The virtual reference point or region to position the overlay at.
  final VirtualReference reference;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualReferenceMiddleware &&
          runtimeType == other.runtimeType &&
          reference == other.reference;

  @override
  int get hashCode => reference.hashCode;

  @override
  String toString() => 'Virtual($reference)';

  @override
  (PositionState, VirtualReferenceData?) run(PositionState state) {
    final rect = reference.getBoundingRect(state);
    final config = state.config;

    // Calculate the offset needed to move from the original child's position
    // to the virtual reference's position
    final virtualOffset =
        VirtualReferenceMiddleware.calculateOffsetForPlacement(
      virtualRect: rect,
      childPosition: config.childPosition,
      placement: config.placement,
      overlayWidth: config.overlayWidth,
      overlayHeight: config.overlayHeight,
    );

    // Calculate available spaces from the virtual reference position,
    // accounting for viewport padding. This is for subsequent middleware
    // (flip, shift) to use for bounds checking.
    final rawAbove = rect.top - config.padding.top;
    final rawBelow = config.viewportSize.height -
        config.padding.bottom -
        (rect.top + rect.height);
    final rawLeft = rect.left - config.padding.left;
    final rawRight = config.viewportSize.width -
        config.padding.right -
        (rect.left + rect.width);

    final virtualConfig = config.copyWith(
      explicitSpaces: AvailableSpaces(
        above: rawAbove < 0 ? 0 : rawAbove,
        below: rawBelow < 0 ? 0 : rawBelow,
        left: rawLeft < 0 ? 0 : rawLeft,
        right: rawRight < 0 ? 0 : rawRight,
      ),
    );

    // Set anchor points to topLeft for both child and overlay, and apply
    // the offset to move the overlay to the virtual position.
    // Subsequent middlewares can modify the anchor points (e.g., flip to bottom)
    final updatedPoints = AnchorPoints(
      childAnchor: Alignment.topLeft,
      overlayAnchor: Alignment.topLeft,
      overlayAlignment: Alignment.topLeft,
      offset: virtualOffset,
    );

    final newState = state.copyWith(
      config: virtualConfig,
      anchorPoints: updatedPoints,
    );

    return (
      newState,
      VirtualReferenceData(
        virtualPosition: Offset(rect.left, rect.top),
        virtualSize: Size(rect.width, rect.height),
        appliedOffset: virtualOffset,
        virtualRect: rect,
      ),
    );
  }

  /// Calculates the offset for positioning the overlay relative to a virtual
  /// reference rectangle based on the given placement.
  static Offset calculateOffsetForPlacement({
    required Rect virtualRect,
    required Offset childPosition,
    required Placement placement,
    required double? overlayWidth,
    required double? overlayHeight,
  }) {
    final baseOffset = Offset(
      virtualRect.left - childPosition.dx,
      virtualRect.top - childPosition.dy,
    );

    return switch ((overlayWidth, overlayHeight)) {
      (final width?, final height?) => switch (placement) {
          Placement.top => Offset(
              baseOffset.dx + virtualRect.width / 2 - width / 2,
              baseOffset.dy - height,
            ),
          Placement.topStart => Offset(
              baseOffset.dx,
              baseOffset.dy - height,
            ),
          Placement.topEnd => Offset(
              baseOffset.dx + virtualRect.width - width,
              baseOffset.dy - height,
            ),
          Placement.bottom => Offset(
              baseOffset.dx + virtualRect.width / 2 - width / 2,
              baseOffset.dy + virtualRect.height,
            ),
          Placement.bottomStart => Offset(
              baseOffset.dx,
              baseOffset.dy + virtualRect.height,
            ),
          Placement.bottomEnd => Offset(
              baseOffset.dx + virtualRect.width - width,
              baseOffset.dy + virtualRect.height,
            ),
          Placement.left => Offset(
              baseOffset.dx - width,
              baseOffset.dy + virtualRect.height / 2 - height / 2,
            ),
          Placement.leftStart => Offset(
              baseOffset.dx - width,
              baseOffset.dy,
            ),
          Placement.leftEnd => Offset(
              baseOffset.dx - width,
              baseOffset.dy + virtualRect.height - height,
            ),
          Placement.right => Offset(
              baseOffset.dx + virtualRect.width,
              baseOffset.dy + virtualRect.height / 2 - height / 2,
            ),
          Placement.rightStart => Offset(
              baseOffset.dx + virtualRect.width,
              baseOffset.dy,
            ),
          Placement.rightEnd => Offset(
              baseOffset.dx + virtualRect.width,
              baseOffset.dy + virtualRect.height - height,
            ),
        },
      _ => baseOffset,
    };
  }
}
