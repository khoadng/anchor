import 'package:flutter/rendering.dart';

import 'arrows.dart';

/// A [ShapeBorder] that draws a customizable speech bubble-like shape with
/// an arrow.
class AnchorShapeBorder extends ShapeBorder {
  /// Creates a shape for an overlay with an arrow.
  const AnchorShapeBorder({
    this.arrowShape = const SharpArrow(),
    required this.arrowDirection,
    this.arrowAlignment,
    this.arrowSize = const Size(20, 10),
    this.borderRadius = BorderRadius.zero,
    this.border = BorderSide.none,
  });

  /// The shape of the arrow (e.g., sharp or rounded).
  final ArrowShape arrowShape;

  /// The direction the arrow points.
  final AxisDirection arrowDirection;

  /// The position of the arrow along the overlay edge, from 0.0 (start) to
  /// 1.0 (end).
  final double? arrowAlignment;

  /// The size of the arrow
  final Size arrowSize;

  /// The border radius for the main body of the overlay.
  final BorderRadius borderRadius;

  /// The border style, color, and width.
  final BorderSide border;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final rrect = borderRadius.toRRect(rect);
    return _buildArrowPath(rect, rrect);
  }

  Path _buildArrowPath(Rect rect, RRect rrect) {
    final path = Path();

    // Calculate arrow position based on alignment (0.0 to 1.0)
    late final Offset arrowBaseStart;
    late final Offset arrowBaseEnd;
    final arrowAlignment = this.arrowAlignment ?? 0.5;
    final arrowWidth = arrowSize.width;
    final arrowHeight = arrowSize.height;

    switch (arrowDirection) {
      case AxisDirection.up:
        final usableWidth = rect.width - rrect.tlRadiusX - rrect.trRadiusX;
        final centerX =
            rect.left + rrect.tlRadiusX + (usableWidth * arrowAlignment);
        arrowBaseStart = Offset(centerX - arrowWidth / 2, rect.top);
        arrowBaseEnd = Offset(centerX + arrowWidth / 2, rect.top);
      case AxisDirection.down:
        final usableWidth = rect.width - rrect.blRadiusX - rrect.brRadiusX;
        final centerX =
            rect.left + rrect.blRadiusX + (usableWidth * arrowAlignment);
        arrowBaseStart = Offset(centerX - arrowWidth / 2, rect.bottom);
        arrowBaseEnd = Offset(centerX + arrowWidth / 2, rect.bottom);
      case AxisDirection.left:
        final usableHeight = rect.height - rrect.tlRadiusY - rrect.blRadiusY;
        final centerY =
            rect.top + rrect.tlRadiusY + (usableHeight * arrowAlignment);
        arrowBaseStart = Offset(rect.left, centerY - arrowWidth / 2);
        arrowBaseEnd = Offset(rect.left, centerY + arrowWidth / 2);
      case AxisDirection.right:
        final usableHeight = rect.height - rrect.trRadiusY - rrect.brRadiusY;
        final centerY =
            rect.top + rrect.trRadiusY + (usableHeight * arrowAlignment);
        arrowBaseStart = Offset(rect.right, centerY - arrowWidth / 2);
        arrowBaseEnd = Offset(rect.right, centerY + arrowWidth / 2);
    }

    // Start from top-left, draw clockwise
    path.moveTo(rrect.left, rrect.top + rrect.tlRadiusY);

    // Top-left corner
    if (rrect.tlRadius != Radius.zero) {
      path.arcToPoint(
        Offset(rrect.left + rrect.tlRadiusX, rrect.top),
        radius: rrect.tlRadius,
      );
    }

    // Top edge
    if (arrowDirection == AxisDirection.up) {
      path.lineTo(arrowBaseStart.dx, arrowBaseStart.dy);
      arrowShape.buildArrowPath(
        path: path,
        baseStart: arrowBaseStart,
        baseEnd: arrowBaseEnd,
        direction: arrowDirection,
        arrowHeight: arrowHeight,
      );
    }
    path.lineTo(rrect.right - rrect.trRadiusX, rrect.top);

    // Top-right corner
    if (rrect.trRadius != Radius.zero) {
      path.arcToPoint(
        Offset(rrect.right, rrect.top + rrect.trRadiusY),
        radius: rrect.trRadius,
      );
    }

    // Right edge
    if (arrowDirection == AxisDirection.right) {
      path.lineTo(arrowBaseStart.dx, arrowBaseStart.dy);
      arrowShape.buildArrowPath(
        path: path,
        baseStart: arrowBaseStart,
        baseEnd: arrowBaseEnd,
        direction: arrowDirection,
        arrowHeight: arrowHeight,
      );
    }
    path.lineTo(rrect.right, rrect.bottom - rrect.brRadiusY);

    // Bottom-right corner
    if (rrect.brRadius != Radius.zero) {
      path.arcToPoint(
        Offset(rrect.right - rrect.brRadiusX, rrect.bottom),
        radius: rrect.brRadius,
      );
    }

    // Bottom edge
    if (arrowDirection == AxisDirection.down) {
      path.lineTo(arrowBaseEnd.dx, arrowBaseEnd.dy);
      arrowShape.buildArrowPath(
        path: path,
        baseStart: arrowBaseEnd,
        baseEnd: arrowBaseStart,
        direction: arrowDirection,
        arrowHeight: arrowHeight,
      );
    }
    path.lineTo(rrect.left + rrect.blRadiusX, rrect.bottom);

    // Bottom-left corner
    if (rrect.blRadius != Radius.zero) {
      path.arcToPoint(
        Offset(rrect.left, rrect.bottom - rrect.blRadiusY),
        radius: rrect.blRadius,
      );
    }

    // Left edge
    if (arrowDirection == AxisDirection.left) {
      path.lineTo(arrowBaseEnd.dx, arrowBaseEnd.dy);
      arrowShape.buildArrowPath(
        path: path,
        baseStart: arrowBaseEnd,
        baseEnd: arrowBaseStart,
        direction: arrowDirection,
        arrowHeight: arrowHeight,
      );
    }
    path.lineTo(rrect.left, rrect.top + rrect.tlRadiusY);

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (border.style != BorderStyle.none && border.width > 0) {
      final paint = Paint()
        ..color = border.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.width;

      canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return AnchorShapeBorder(
      arrowShape: arrowShape,
      arrowDirection: arrowDirection,
      arrowAlignment: arrowAlignment,
      arrowSize: arrowSize * t,
      borderRadius: borderRadius * t,
      border: border.scale(t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnchorShapeBorder &&
          runtimeType == other.runtimeType &&
          arrowShape == other.arrowShape &&
          arrowDirection == other.arrowDirection &&
          arrowAlignment == other.arrowAlignment &&
          arrowSize == other.arrowSize &&
          borderRadius == other.borderRadius &&
          border == other.border;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        arrowShape,
        arrowDirection,
        arrowAlignment,
        arrowSize,
        borderRadius,
        border,
      );
}
