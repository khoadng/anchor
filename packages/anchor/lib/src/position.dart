import 'package:meta/meta.dart';

import 'anchor_points.dart';
import 'placement.dart';
import 'types.dart';

/// Represents the available space around the child widget in all four directions.
@immutable
class AvailableSpaces {
  /// Creates an [AvailableSpaces] instance.
  const AvailableSpaces({
    required this.above,
    required this.below,
    required this.left,
    required this.right,
  });

  /// Available space above the child widget.
  final double above;

  /// Available space below the child widget.
  final double below;

  /// Available space to the left of the child widget.
  final double left;

  /// Available space to the right of the child widget.
  final double right;

  /// Gets the available space in the given [direction].
  double inDirection(AxisDirection direction) {
    return switch (direction) {
      AxisDirection.up => above,
      AxisDirection.down => below,
      AxisDirection.left => left,
      AxisDirection.right => right,
    };
  }

  /// Returns the direction with more space between two opposite directions.
  ///
  /// For vertical axis (up/down), returns the direction with more space.
  /// For horizontal axis (left/right), returns the direction with more space.
  AxisDirection largerDirection(AxisDirection preferredDirection) {
    return switch (preferredDirection) {
      AxisDirection.up ||
      AxisDirection.down =>
        above >= below ? AxisDirection.up : AxisDirection.down,
      AxisDirection.left ||
      AxisDirection.right =>
        left >= right ? AxisDirection.left : AxisDirection.right,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableSpaces &&
          runtimeType == other.runtimeType &&
          above == other.above &&
          below == other.below &&
          left == other.left &&
          right == other.right;

  @override
  int get hashCode => Object.hash(above, below, left, right);

  @override
  String toString() =>
      'AvailableSpaces(above: $above, below: $below, left: $left, right: $right)';
}

/// Holds all the necessary geometric information about the child (anchor),
/// the overlay and the viewport.
@immutable
class PositioningConfig {
  /// Creates a new positioning configuration.
  const PositioningConfig({
    required this.childPosition,
    required this.childSize,
    required this.viewportSize,
    required this.overlayHeight,
    required this.overlayWidth,
    this.explicitSpaces,
  });

  /// The position of the child (anchor) widget relative to the viewport.
  final Offset childPosition;

  /// The size of the child (anchor) widget.
  final Size childSize;

  /// The size of the available viewport (usually the screen or a scrollable area).
  final Size viewportSize;

  /// The height of the overlay widget.
  ///
  /// This can be `null` if the height is not yet known.
  final double? overlayHeight;

  /// The width of the overlay widget.
  ///
  /// This can be `null` if the width is not yet known.
  final double? overlayWidth;

  /// Explicit spaces to use instead of deriving them from the viewport.
  final AvailableSpaces? explicitSpaces;

  /// Creates a copy of this config with the given fields replaced.
  PositioningConfig copyWith({
    Offset? childPosition,
    Size? childSize,
    Size? viewportSize,
    double? overlayHeight,
    double? overlayWidth,
    AvailableSpaces? explicitSpaces,
  }) {
    return PositioningConfig(
      childPosition: childPosition ?? this.childPosition,
      childSize: childSize ?? this.childSize,
      viewportSize: viewportSize ?? this.viewportSize,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      explicitSpaces: explicitSpaces ?? this.explicitSpaces,
    );
  }

  /// Calculates the available space on all four sides of the child widget.
  ///
  /// If [explicitSpaces] is set, returns those spaces instead of calculating
  /// them from the viewport.
  AvailableSpaces get spaces =>
      explicitSpaces ??
      AvailableSpaces(
        above: childPosition.dy,
        below: viewportSize.height - (childPosition.dy + childSize.height),
        left: childPosition.dx,
        right: viewportSize.width - (childPosition.dx + childSize.width),
      );

  /// Checks if the overlay fits in the given [direction] based on the
  /// available space and the overlay's dimensions.
  bool canFitInDirection(AxisDirection direction) {
    final spaces = this.spaces;
    final availableSpace = spaces.inDirection(direction);

    return switch (direction) {
      AxisDirection.up || AxisDirection.down => switch (overlayHeight) {
          final double height => availableSpace >= height,
          null => true,
        },
      AxisDirection.left || AxisDirection.right => switch (overlayWidth) {
          final double width => availableSpace >= width,
          null => true,
        },
    };
  }
}

/// Represents the state of a positioning calculation as it passes
/// through the [PositioningPipeline].
@immutable
class PositionState {
  /// Creates a new [PositionState].
  const PositionState({
    required this.anchorPoints,
    required this.config,
  });

  /// Creates an initial [PositionState] from a [Placement] and [PositioningConfig].
  factory PositionState.fromPlacement(
    Placement placement,
    PositioningConfig config,
  ) {
    return PositionState(
      anchorPoints: placement.toAnchorPoints(),
      config: config,
    );
  }

  /// The calculated anchor points for both the child and overlay.
  final AnchorPoints anchorPoints;

  /// The positioning configuration containing geometric constraints.
  final PositioningConfig config;

  /// Creates a copy of this state with the given fields replaced.
  PositionState copyWith({
    AnchorPoints? anchorPoints,
    PositioningConfig? config,
  }) {
    return PositionState(
      anchorPoints: anchorPoints ?? this.anchorPoints,
      config: config ?? this.config,
    );
  }
}

/// The interface for a positioning middleware.
///
/// Middleware are functions that run sequentially to compute the final
/// position of the overlay. They can modify the [PositionState] which
/// contains both the anchor points and the positioning configuration.
abstract interface class PositioningMiddleware {
  /// Runs the middleware logic.
  ///
  /// Takes the [state] from the previous middleware (or the initial state)
  /// and returns a new, modified [PositionState]. Middleware can modify
  /// both the anchor points and the config (e.g., for virtual references).
  PositionState run(PositionState state);
}

/// Orchestrates the entire positioning calculation.
class PositioningPipeline {
  /// Creates a positioning pipeline.
  const PositioningPipeline({required this.middlewares});

  /// The list of [PositioningMiddleware] to run, in order.
  final List<PositioningMiddleware> middlewares;

  /// Runs the positioning pipeline.
  PositionState run({
    required Placement placement,
    required PositioningConfig config,
  }) {
    var state = PositionState.fromPlacement(placement, config);

    for (final middleware in middlewares) {
      state = middleware.run(state);
    }

    return state;
  }
}
