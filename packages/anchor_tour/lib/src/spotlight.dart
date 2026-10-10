import 'package:flutter/material.dart';

enum AnchorTourSpotlightShape {
  none,
  roundedRect,
  circle,
  custom,
}

typedef AnchorTourSpotlightPathBuilder = Path Function(
  Rect target,
  Size viewport,
);

@immutable
class AnchorTourSpotlight {
  const AnchorTourSpotlight({
    this.shape = AnchorTourSpotlightShape.roundedRect,
    this.color = const Color(0x99000000),
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.pathBuilder,
  }) : assert(
          shape != AnchorTourSpotlightShape.custom || pathBuilder != null,
          'A custom spotlight needs a pathBuilder.',
        );

  const AnchorTourSpotlight.none()
      : shape = AnchorTourSpotlightShape.none,
        color = const Color(0x00000000),
        padding = EdgeInsets.zero,
        borderRadius = BorderRadius.zero,
        pathBuilder = null;

  final AnchorTourSpotlightShape shape;
  final Color color;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final AnchorTourSpotlightPathBuilder? pathBuilder;

  static const defaults = AnchorTourSpotlight();
}

class AnchorTourSpotlightBackdrop extends StatelessWidget {
  const AnchorTourSpotlightBackdrop({
    super.key,
    required this.targetRect,
    this.spotlight = AnchorTourSpotlight.defaults,
    this.onTap,
  });

  final Rect? targetRect;
  final AnchorTourSpotlight spotlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (spotlight.shape == AnchorTourSpotlightShape.none) {
      return const SizedBox.expand();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.expand(
        child: _SpotlightPaintBox(
          targetGlobalRect: targetRect,
          spotlight: spotlight,
        ),
      ),
    );
  }
}

class _SpotlightPaintBox extends LeafRenderObjectWidget {
  const _SpotlightPaintBox({
    required this.targetGlobalRect,
    required this.spotlight,
  });

  final Rect? targetGlobalRect;
  final AnchorTourSpotlight spotlight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSpotlightPaintBox(
      targetGlobalRect: targetGlobalRect,
      spotlight: spotlight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSpotlightPaintBox renderObject,
  ) {
    renderObject
      ..targetGlobalRect = targetGlobalRect
      ..spotlight = spotlight;
  }
}

class _RenderSpotlightPaintBox extends RenderBox {
  _RenderSpotlightPaintBox({
    required Rect? targetGlobalRect,
    required AnchorTourSpotlight spotlight,
  })  : _targetGlobalRect = targetGlobalRect,
        _spotlight = spotlight;

  Rect? _targetGlobalRect;
  AnchorTourSpotlight _spotlight;

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  Rect? get targetGlobalRect => _targetGlobalRect;
  set targetGlobalRect(Rect? value) {
    if (_targetGlobalRect == value) return;
    _targetGlobalRect = value;
    markNeedsPaint();
  }

  AnchorTourSpotlight get spotlight => _spotlight;
  set spotlight(AnchorTourSpotlight value) {
    if (_spotlight == value) return;
    _spotlight = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _paintSpotlight(canvas, size, _targetLocalRect, spotlight);
    canvas.restore();
  }

  Rect? get _targetLocalRect => switch (targetGlobalRect) {
        final target? => globalRectToLocal(target),
        null => null,
      };

  void _paintSpotlight(
    Canvas canvas,
    Size size,
    Rect? targetRect,
    AnchorTourSpotlight spotlight,
  ) {
    final viewport = Offset.zero & size;
    final target = targetRect;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = spotlight.color;

    if (target == null || target.isEmpty) {
      canvas.drawRect(viewport, paint);
      return;
    }

    final paddedTarget = Rect.fromLTRB(
      target.left - spotlight.padding.left,
      target.top - spotlight.padding.top,
      target.right + spotlight.padding.right,
      target.bottom + spotlight.padding.bottom,
    );

    final hole = switch (spotlight.shape) {
      AnchorTourSpotlightShape.none => Path(),
      AnchorTourSpotlightShape.roundedRect => Path()
        ..addRRect(spotlight.borderRadius.toRRect(paddedTarget)),
      AnchorTourSpotlightShape.circle => Path()
        ..addOval(Rect.fromCircle(
          center: paddedTarget.center,
          radius: paddedTarget.longestSide / 2,
        )),
      AnchorTourSpotlightShape.custom =>
        spotlight.pathBuilder!(paddedTarget, size),
    };

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(viewport)
      ..addPath(hole, Offset.zero);

    canvas.drawPath(path, paint);
  }
}

/// Maps rects from global coordinates into a render box.
extension GlobalRectToLocal on RenderBox {
  /// The bounds of [globalRect] in this box's coordinates.
  Rect globalRectToLocal(Rect globalRect) =>
      MatrixUtils.inverseTransformRect(getTransformTo(null), globalRect);
}
