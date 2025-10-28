import 'package:meta/meta.dart';

import '../placement.dart';
import '../position.dart';
import '../types.dart';
import 'offset.dart';

/// Data produced by [SizeMiddleware] after positioning.
@immutable
class SizeData {
  /// Creates [SizeData].
  const SizeData({
    required this.availableWidth,
    required this.availableHeight,
  });

  /// Maximum available width for the overlay without overflowing.
  final double availableWidth;

  /// Maximum available height for the overlay without overflowing.
  final double availableHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeData &&
          runtimeType == other.runtimeType &&
          availableWidth == other.availableWidth &&
          availableHeight == other.availableHeight;

  @override
  int get hashCode => Object.hash(availableWidth, availableHeight);

  @override
  String toString() =>
      'SizeData(availableWidth: $availableWidth, availableHeight: $availableHeight)';
}

/// A middleware that calculates the maximum available dimensions
/// for the overlay to prevent it from overflowing the viewport.
///
/// This is useful for constraining overlay size dynamically based
/// on available space.
@immutable
class SizeMiddleware implements PositioningMiddleware<SizeData> {
  /// Creates a [SizeMiddleware].
  const SizeMiddleware();

  @override
  (PositionState, SizeData?) run(PositionState state) {
    final config = state.config;
    final placement = config.placement;
    final spaces = config.spaces;

    final availableWidth = _calculateAvailableWidth(
      placement: placement,
      spaces: spaces,
      viewportWidth: config.viewportSize.width,
      padding: config.padding,
    );

    final availableHeight = _calculateAvailableHeight(
      placement: placement,
      spaces: spaces,
      viewportHeight: config.viewportSize.height,
      padding: config.padding,
    );

    final appliedOffset =
        state.metadata.get<OffsetData>()?.appliedOffset ?? Offset.zero;

    return (
      state,
      SizeData(
        availableWidth: availableWidth - appliedOffset.dx.abs(),
        availableHeight: availableHeight - appliedOffset.dy.abs(),
      ),
    );
  }

  static double _calculateAvailableWidth({
    required Placement placement,
    required AvailableSpaces spaces,
    required double viewportWidth,
    required EdgeInsets padding,
  }) {
    final direction = placement.direction;
    final available = switch (direction) {
      AxisDirection.left => spaces.left,
      AxisDirection.right => spaces.right,
      AxisDirection.up ||
      AxisDirection.down =>
        viewportWidth - padding.horizontal,
    };

    // If no space is available in the placement direction, use full viewport width
    return available > 0 ? available : viewportWidth - padding.horizontal;
  }

  /// Calculates available height based on placement and available spaces.
  static double _calculateAvailableHeight({
    required Placement placement,
    required AvailableSpaces spaces,
    required double viewportHeight,
    required EdgeInsets padding,
  }) {
    final direction = placement.direction;
    final available = switch (direction) {
      AxisDirection.up => spaces.above,
      AxisDirection.down => spaces.below,
      AxisDirection.left ||
      AxisDirection.right =>
        viewportHeight - padding.vertical,
    };

    // If no space is available in the placement direction, use full viewport height
    return available > 0 ? available : viewportHeight - padding.vertical;
  }

  @override
  String toString() => 'Size()';
}
