import 'dart:ui';

import 'package:meta/meta.dart';

import 'position.dart';

/// A function that computes a virtual reference based on the current positioning state.
typedef VirtualReferenceCallback = Rect Function(PositionState state);

/// Represents a virtual reference point or region for positioning overlays.
sealed class VirtualReference {
  const VirtualReference._();

  /// Creates a virtual reference from a single point (typically cursor position).
  const factory VirtualReference.fromPoint(Offset position) = _PointReference;

  /// Creates a virtual reference from a rectangular region.
  const factory VirtualReference.fromRect(Rect rect) = _RectReference;

  /// Creates a virtual reference that computes its position based on the current state.
  const factory VirtualReference.compute(VirtualReferenceCallback callback) =
      _ComputedReference;

  /// Returns the bounding rectangle for this virtual reference.
  ///
  /// For point-based references, this returns a zero-size rect at the point.
  /// For rect-based references, this returns the rect itself.
  /// For computed references, this requires a [PositionState] parameter.
  Rect getBoundingRect([PositionState? state]);

  /// Returns the position (top-left corner) of this virtual reference.
  Offset position([PositionState? state]) => getBoundingRect(state).topLeft;

  /// Returns the size of this virtual reference.
  ///
  /// For point-based references, this returns [Size.zero].
  /// For rect-based references, this returns the rect's size.
  Size size([PositionState? state]) => getBoundingRect(state).size;
}

/// A virtual reference based on a single point.
@immutable
class _PointReference extends VirtualReference {
  const _PointReference(this.point) : super._();

  final Offset point;

  @override
  Rect getBoundingRect([PositionState? state]) =>
      Rect.fromLTWH(point.dx, point.dy, 0, 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _PointReference && other.point == point;
  }

  @override
  int get hashCode => point.hashCode;

  @override
  String toString() => 'VirtualReference.fromPoint($point)';
}

/// A virtual reference based on a rectangular region.
@immutable
class _RectReference extends VirtualReference {
  const _RectReference(this.rect) : super._();

  final Rect rect;

  @override
  Rect getBoundingRect([PositionState? state]) => rect;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _RectReference && other.rect == rect;
  }

  @override
  int get hashCode => rect.hashCode;

  @override
  String toString() => 'VirtualReference.fromRect($rect)';
}

/// A virtual reference that computes its position dynamically.
@immutable
class _ComputedReference extends VirtualReference {
  const _ComputedReference(this.callback) : super._();

  final VirtualReferenceCallback callback;

  @override
  Rect getBoundingRect([PositionState? state]) {
    assert(
      state != null,
      'State is required for computed virtual references. Call getBoundingRect(state).',
    );
    return callback(state!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ComputedReference && other.callback == callback;
  }

  @override
  int get hashCode => callback.hashCode;

  @override
  String toString() => 'VirtualReference.compute(...)';
}
