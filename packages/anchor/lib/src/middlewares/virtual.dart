import 'package:meta/meta.dart';

import '../anchor_points.dart';
import '../position.dart';
import '../types.dart';
import '../virtual_reference.dart';

/// A middleware that positions the overlay at an absolute
/// position using a [VirtualReference].
///
/// This is useful for context menus, tooltips at cursor position, or any
/// overlay that should appear at an arbitrary location rather than anchored
/// to a physical widget.
@immutable
class VirtualReferenceMiddleware implements PositioningMiddleware {
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
  String toString() => 'VirtualReferenceMiddleware($reference)';

  @override
  PositionState run(PositionState state) {
    final rect = reference.getBoundingRect();
    final config = state.config;

    // Calculate the offset needed to move from the original child's position
    // to the virtual reference's position
    final virtualOffset = Offset(
      rect.left - config.childPosition.dx,
      rect.top - config.childPosition.dy,
    );

    final virtualConfig = config.copyWith(
      // Calculate available spaces from the virtual reference position
      // This is for subsequent middleware (flip, shift) to use for
      // bounds checking.
      explicitSpaces: AvailableSpaces(
        above: rect.top,
        below: config.viewportSize.height - (rect.top + rect.height),
        left: rect.left,
        right: config.viewportSize.width - (rect.left + rect.width),
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

    return state.copyWith(
      config: virtualConfig,
      anchorPoints: updatedPoints,
    );
  }
}
