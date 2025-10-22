import 'dart:ui';

import 'package:meta/meta.dart';

/// Represents a virtual reference point or region for positioning overlays.
@immutable
sealed class VirtualReference {
  const VirtualReference._();

  /// Creates a virtual reference from a single point (typically cursor position).
  const factory VirtualReference.fromPoint(Offset position) = _PointReference;

  /// Creates a virtual reference from a rectangular region.
  const factory VirtualReference.fromRect(Rect rect) = _RectReference;

  /// Returns the bounding rectangle for this virtual reference.
  ///
  /// For point-based references, this returns a zero-size rect at the point.
  /// For rect-based references, this returns the rect itself.
  Rect getBoundingRect();

  /// Returns the position (top-left corner) of this virtual reference.
  Offset get position => getBoundingRect().topLeft;

  /// Returns the size of this virtual reference.
  ///
  /// For point-based references, this returns [Size.zero].
  /// For rect-based references, this returns the rect's size.
  Size get size => getBoundingRect().size;
}

/// A virtual reference based on a single point.
class _PointReference extends VirtualReference {
  const _PointReference(this.point) : super._();

  final Offset point;

  @override
  Rect getBoundingRect() => Rect.fromLTWH(point.dx, point.dy, 0, 0);

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
class _RectReference extends VirtualReference {
  const _RectReference(this.rect) : super._();

  final Rect rect;

  @override
  Rect getBoundingRect() => rect;

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
