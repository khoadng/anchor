import 'dart:ui';

import 'package:anchor/anchor.dart';

const viewportSize = Size(800, 600);

VirtualReference cursorAtCenter([Offset? offset]) {
  final center = viewportSize.center(Offset.zero);

  return VirtualReference.fromPoint(
    offset != null ? center + offset : center,
  );
}

VirtualReference cursorNearRightEdge([Offset? offset]) {
  final rightEdge = Offset(viewportSize.width, viewportSize.height / 2);

  return VirtualReference.fromPoint(
    offset != null ? rightEdge + offset : rightEdge,
  );
}

/// Returns child position at the top-left corner of the viewport.
/// The child is positioned so its top-left corner touches the viewport's top-left corner.
Offset childAtTopLeft(Size childSize, [Offset? offset]) {
  final position = Offset(childSize.width / 2, childSize.height / 2);
  return offset != null ? position + offset : position;
}

/// Returns child position at the top-right corner of the viewport.
/// The child is positioned so its top-right corner touches the viewport's top-right corner.
Offset childAtTopRight(Size childSize, [Offset? offset]) {
  final position = Offset(
    viewportSize.width - childSize.width / 2,
    childSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the bottom-left corner of the viewport.
/// The child is positioned so its bottom-left corner touches the viewport's bottom-left corner.
Offset childAtBottomLeft(Size childSize, [Offset? offset]) {
  final position = Offset(
    childSize.width / 2,
    viewportSize.height - childSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the bottom-right corner of the viewport.
/// The child is positioned so its bottom-right corner touches the viewport's bottom-right corner.
Offset childAtBottomRight(Size childSize, [Offset? offset]) {
  final position = Offset(
    viewportSize.width - childSize.width / 2,
    viewportSize.height - childSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the center of the viewport.
Offset childAtCenter(Size childSize, [Offset? offset]) {
  final position = viewportSize.center(Offset.zero);
  return offset != null ? position + offset : position;
}

/// Returns child position at the top edge (horizontally centered).
Offset childAtTopEdge(Size childSize, [Offset? offset]) {
  final position = Offset(
    viewportSize.width / 2,
    childSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the bottom edge (horizontally centered).
Offset childAtBottomEdge(Size childSize, [Offset? offset]) {
  final position = Offset(
    viewportSize.width / 2,
    viewportSize.height - childSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the left edge (vertically centered).
Offset childAtLeftEdge(Size childSize, [Offset? offset]) {
  final position = Offset(
    childSize.width / 2,
    viewportSize.height / 2,
  );
  return offset != null ? position + offset : position;
}

/// Returns child position at the right edge (vertically centered).
Offset childAtRightEdge(Size childSize, [Offset? offset]) {
  final position = Offset(
    viewportSize.width - childSize.width / 2,
    viewportSize.height / 2,
  );
  return offset != null ? position + offset : position;
}
