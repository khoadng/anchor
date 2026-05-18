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
      child: CustomPaint(
        painter: _SpotlightPainter(
          targetRect: targetRect,
          spotlight: spotlight,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.spotlight,
  });

  final Rect? targetRect;
  final AnchorTourSpotlight spotlight;

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.spotlight != spotlight;
  }
}
