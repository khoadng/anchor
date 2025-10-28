import 'dart:ui';

import 'package:meta/meta.dart';

import '../position.dart';

/// Data produced by [OffsetMiddleware] after positioning.
@immutable
class OffsetData {
  /// Creates [OffsetData].
  const OffsetData({
    required this.mainAxisOffset,
    required this.crossAxisOffset,
    required this.appliedOffset,
  });

  /// The main axis offset value that was requested.
  final double mainAxisOffset;

  /// The cross axis offset value that was requested.
  final double crossAxisOffset;

  /// The actual offset that was applied to the overlay.
  final Offset appliedOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffsetData &&
          runtimeType == other.runtimeType &&
          mainAxisOffset == other.mainAxisOffset &&
          crossAxisOffset == other.crossAxisOffset &&
          appliedOffset == other.appliedOffset;

  @override
  int get hashCode =>
      Object.hash(mainAxisOffset, crossAxisOffset, appliedOffset);

  @override
  String toString() =>
      'OffsetData(mainAxis: $mainAxisOffset, crossAxis: $crossAxisOffset, applied: $appliedOffset)';
}

/// A function that computes an offset value based on the current positioning state.
typedef OffsetValueCallback = double Function(PositionState state);

/// Represents an offset value that can be either a static double or a callback.
@immutable
class OffsetValue {
  /// Creates an [OffsetValue] from a static double value.
  const OffsetValue.value(double value)
      : _value = value,
        _callback = null;

  /// Creates an [OffsetValue] that computes the offset based on the current state.
  const OffsetValue.compute(OffsetValueCallback callback)
      : _value = null,
        _callback = callback;

  final double? _value;
  final OffsetValueCallback? _callback;

  /// Resolves the offset value based on the current state.
  double resolve(PositionState state) {
    if (_callback != null) {
      return _callback(state);
    }
    return _value ?? 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffsetValue &&
          runtimeType == other.runtimeType &&
          _value == other._value &&
          _callback == other._callback;

  @override
  int get hashCode => Object.hash(_value, _callback);

  @override
  String toString() {
    if (_callback != null) {
      return 'Value(compute)';
    }

    return 'Value($_value)';
  }
}

/// A middleware that applies a positional offset to the overlay.
@immutable
class OffsetMiddleware implements PositioningMiddleware<OffsetData> {
  /// Creates an [OffsetMiddleware].
  ///
  /// The [mainAxis] and [crossAxis] parameters can be either static values
  /// or computed dynamically using [OffsetValue.compute].
  const OffsetMiddleware({
    this.mainAxis = const OffsetValue.value(0),
    this.crossAxis = const OffsetValue.value(0),
  });

  /// The offset along the main axis (e.g., vertical for `top`/`bottom`).
  /// A positive value moves the overlay *away* from the child.
  final OffsetValue mainAxis;

  /// The offset along the cross axis (e.g., horizontal for `top`/`bottom`).
  /// A positive value typically moves the overlay to the right (for `top`/`bottom`)
  /// or down (for `left`/`right`).
  final OffsetValue crossAxis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffsetMiddleware &&
          runtimeType == other.runtimeType &&
          mainAxis == other.mainAxis &&
          crossAxis == other.crossAxis;

  @override
  int get hashCode => Object.hash(mainAxis, crossAxis);

  @override
  String toString() => 'Offset(mainAxis: $mainAxis, crossAxis: $crossAxis)';

  @override
  (PositionState, OffsetData?) run(PositionState state) {
    final points = state.anchorPoints;
    final resolvedMainAxis = mainAxis.resolve(state);
    final resolvedCrossAxis = crossAxis.resolve(state);

    final newOffset = switch (points) {
      _ when points.isAbove => Offset(resolvedCrossAxis, -resolvedMainAxis),
      _ when points.isBelow => Offset(resolvedCrossAxis, resolvedMainAxis),
      _ when points.isLeft => Offset(-resolvedMainAxis, resolvedCrossAxis),
      _ when points.isRight => Offset(resolvedMainAxis, resolvedCrossAxis),
      _ => Offset.zero,
    };

    final updatedPoints = points.copyWith(
      offset: points.offset + newOffset,
    );

    final newState = state.copyWith(anchorPoints: updatedPoints);

    return (
      newState,
      OffsetData(
        mainAxisOffset: resolvedMainAxis,
        crossAxisOffset: resolvedCrossAxis,
        appliedOffset: newOffset,
      ),
    );
  }
}
