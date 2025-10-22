import 'package:meta/meta.dart';

import 'types.dart';

/// A set of anchor points defining how an overlay is positioned
@immutable
class AnchorPoints {
  /// Creates a set of overlay anchor points.
  const AnchorPoints({
    required this.childAnchor,
    required this.overlayAnchor,
    Alignment? overlayAlignment,
    this.isCrossAxisFlipped = false,
    this.offset = Offset.zero,
  }) : overlayAlignment = overlayAlignment ?? overlayAnchor;

  /// Creates anchor points based on a raw direction.
  factory AnchorPoints.raw(AxisDirection direction) {
    return switch (direction) {
      AxisDirection.up => const AnchorPoints(
          childAnchor: Alignment.topCenter,
          overlayAnchor: Alignment.bottomCenter,
        ),
      AxisDirection.down => const AnchorPoints(
          childAnchor: Alignment.bottomCenter,
          overlayAnchor: Alignment.topCenter,
        ),
      AxisDirection.left => const AnchorPoints(
          childAnchor: Alignment.centerLeft,
          overlayAnchor: Alignment.centerRight,
        ),
      AxisDirection.right => const AnchorPoints(
          childAnchor: Alignment.centerRight,
          overlayAnchor: Alignment.centerLeft,
        ),
    };
  }

  /// Creates a copy of this AnchorPoints with the given fields replaced
  /// by new values.
  AnchorPoints copyWith({
    Alignment? childAnchor,
    Alignment? overlayAnchor,
    Alignment? overlayAlignment,
    bool? isCrossAxisFlipped,
    Offset? offset,
  }) {
    return AnchorPoints(
      childAnchor: childAnchor ?? this.childAnchor,
      overlayAnchor: overlayAnchor ?? this.overlayAnchor,
      overlayAlignment: overlayAlignment ?? this.overlayAlignment,
      isCrossAxisFlipped: isCrossAxisFlipped ?? this.isCrossAxisFlipped,
      offset: offset ?? this.offset,
    );
  }

  /// The alignment point on the overlay's target (the child widget).
  final Alignment childAnchor;

  /// The alignment point on the overlay itself (the follower widget).
  final Alignment overlayAnchor;

  /// The alignment of the overlay content within its bounding box, used to
  /// handle overflow.
  final Alignment overlayAlignment;

  /// Whether the cross-axis alignment was flipped from its preferred direction
  /// to prevent overflow.
  final bool isCrossAxisFlipped;

  /// The pixel offset to apply to the overlay position.
  final Offset offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnchorPoints &&
        other.childAnchor == childAnchor &&
        other.overlayAnchor == overlayAnchor &&
        other.overlayAlignment == overlayAlignment &&
        other.isCrossAxisFlipped == isCrossAxisFlipped &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        childAnchor,
        overlayAnchor,
        overlayAlignment,
        isCrossAxisFlipped,
        offset,
      );

  @override
  String toString() =>
      'AnchorPoints(childAnchor: $childAnchor, overlayAnchor: $overlayAnchor, overlayAlignment: $overlayAlignment)';

  /// Whether the overlay is positioned above the target.
  bool get isAbove => overlayAnchor.y > childAnchor.y;

  /// Whether the overlay is positioned below the target.
  bool get isBelow => overlayAnchor.y < childAnchor.y;

  /// Whether the overlay is positioned to the left of the target.
  bool get isLeft => overlayAnchor.x > childAnchor.x;

  /// Whether the overlay is positioned to the right of the target.
  bool get isRight => overlayAnchor.x < childAnchor.x;
}
