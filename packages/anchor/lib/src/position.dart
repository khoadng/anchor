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
    required this.placement,
    this.explicitSpaces,
    this.padding = EdgeInsets.zero,
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

  /// Padding to apply to the viewport boundaries.
  ///
  /// This reduces the available space on all sides, effectively creating
  /// an inset viewport for positioning calculations.
  final EdgeInsets padding;

  /// The desired placement of the overlay relative to the child.
  final Placement placement;

  /// Creates a copy of this config with the given fields replaced.
  PositioningConfig copyWith({
    Offset? childPosition,
    Size? childSize,
    Size? viewportSize,
    double? overlayHeight,
    double? overlayWidth,
    AvailableSpaces? explicitSpaces,
    EdgeInsets? padding,
    Placement? placement,
  }) {
    return PositioningConfig(
      childPosition: childPosition ?? this.childPosition,
      childSize: childSize ?? this.childSize,
      viewportSize: viewportSize ?? this.viewportSize,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      explicitSpaces: explicitSpaces ?? this.explicitSpaces,
      padding: padding ?? this.padding,
      placement: placement ?? this.placement,
    );
  }

  /// Calculates the available space on all four sides of the child widget.
  ///
  /// If [explicitSpaces] is set, returns those spaces instead of calculating
  /// them from the viewport. The calculated spaces account for viewport padding,
  /// ensuring the overlay stays within the padded boundaries.
  AvailableSpaces get spaces {
    if (explicitSpaces case final spaces?) return spaces;

    final rawAbove = childPosition.dy - padding.top;
    final rawBelow = viewportSize.height -
        padding.bottom -
        (childPosition.dy + childSize.height);
    final rawLeft = childPosition.dx - padding.left;
    final rawRight = viewportSize.width -
        padding.right -
        (childPosition.dx + childSize.width);

    return AvailableSpaces(
      above: rawAbove < 0 ? 0 : rawAbove,
      below: rawBelow < 0 ? 0 : rawBelow,
      left: rawLeft < 0 ? 0 : rawLeft,
      right: rawRight < 0 ? 0 : rawRight,
    );
  }

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
    this.metadata = const PositionMetadata(),
  });

  /// Creates an initial [PositionState] from a [Placement] and [PositioningConfig].
  factory PositionState.fromConfig(
    PositioningConfig config,
  ) {
    return PositionState(
      anchorPoints: config.placement.toAnchorPoints(),
      config: config,
    );
  }

  /// The calculated anchor points for both the child and overlay.
  final AnchorPoints anchorPoints;

  /// The positioning configuration containing geometric constraints.
  final PositioningConfig config;

  /// Metadata produced by middleware during positioning.
  final PositionMetadata metadata;

  /// Creates a copy of this state with the given fields replaced.
  PositionState copyWith({
    AnchorPoints? anchorPoints,
    PositioningConfig? config,
    PositionMetadata? metadata,
  }) {
    return PositionState(
      anchorPoints: anchorPoints ?? this.anchorPoints,
      config: config ?? this.config,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Holds metadata produced by middleware during positioning.
///
/// This allows middleware to expose additional information (like whether
/// a flip occurred, shift amounts, arrow positions, etc.) without cluttering
/// the core [PositionState].
@immutable
class PositionMetadata {
  /// Creates a [PositionMetadata] with the given data map.
  const PositionMetadata([this._data = const {}]);

  final Map<Type, Object?> _data;

  /// Gets middleware data by type.
  ///
  /// Returns `null` if no data of type [T] was produced by any middleware.
  ///
  /// Example:
  /// ```dart
  /// final flipData = metadata.get<FlipData>();
  /// if (flipData?.wasFlipped == true) {
  ///   // Handle flipped case
  /// }
  /// ```
  T? get<T>() => _data[T] as T?;

  /// Creates a new [PositionMetadata] with additional data.
  PositionMetadata withData<T>(T value) {
    return PositionMetadata({..._data, value.runtimeType: value});
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionMetadata &&
          runtimeType == other.runtimeType &&
          _mapsEqual(_data, other._data);

  @override
  int get hashCode => Object.hashAll(_data.entries);

  static bool _mapsEqual(Map<Type, Object?> a, Map<Type, Object?> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

/// The result of running the positioning pipeline.
///
/// Contains both the final positioning state and metadata produced by
/// middleware during the positioning calculation.
@immutable
class PositionResult {
  /// Creates a [PositionResult].
  const PositionResult({
    required this.state,
    required this.metadata,
  });

  /// The final position state after all middleware have run.
  final PositionState state;

  /// Metadata produced by middleware during positioning.
  final PositionMetadata metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionResult &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          metadata == other.metadata;

  @override
  int get hashCode => Object.hash(state, metadata);
}

/// The interface for a positioning middleware.
///
/// Middleware are functions that run sequentially to compute the final
/// position of the overlay. They can modify the [PositionState] and
/// optionally produce metadata of type [T].
///
/// The generic type [T] declares what kind of data this middleware produces.
/// Use `void` if the middleware doesn't produce any metadata.
///
/// Example:
/// ```dart
/// class FlipMiddleware implements PositioningMiddleware<FlipData> {
///   @override
///   (PositionState, FlipData?) run(PositionState state) {
///     // ... flip logic
///     return (newState, FlipData(wasFlipped: true));
///   }
/// }
/// ```
abstract interface class PositioningMiddleware<T> {
  /// Runs the middleware logic.
  ///
  /// Takes the [state] from the previous middleware (or the initial state)
  /// and returns a tuple of:
  /// - The new [PositionState] (potentially modified)
  /// - Optional metadata of type [T] (or `null` if no data to report)
  ///
  /// Middleware can modify both the anchor points and the config
  /// (e.g., for virtual references).
  (PositionState, T?) run(PositionState state);
}

/// Orchestrates the entire positioning calculation.
class PositioningPipeline {
  /// Creates a positioning pipeline.
  const PositioningPipeline({required this.middlewares});

  /// The list of [PositioningMiddleware] to run, in order.
  final List<PositioningMiddleware> middlewares;

  /// Runs the positioning pipeline.
  ///
  /// Returns a [PositionResult] containing both the final position state
  /// and metadata produced by all middleware.
  PositionResult run({
    required PositioningConfig config,
  }) {
    var state = PositionState.fromConfig(config);

    for (final middleware in middlewares) {
      final (newState, data) = middleware.run(state);

      if (data != null) {
        state = newState.copyWith(
          metadata: newState.metadata.withData(data),
        );
      } else {
        state = newState;
      }
    }

    return PositionResult(
      state: state,
      metadata: state.metadata,
    );
  }
}
