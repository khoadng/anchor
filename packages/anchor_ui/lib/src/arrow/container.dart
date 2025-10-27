import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'arrows.dart';
import 'border.dart';

/// A container widget that adds an arrow to an anchored overlay.
class AnchorArrowContainer extends StatelessWidget {
  /// Creates an [AnchorArrowContainer].
  const AnchorArrowContainer({
    super.key,
    this.backgroundColor,
    this.borderRadius,
    this.arrowShape,
    this.arrowSize,
    this.border,
    this.boxShadow,
    required this.child,
  });

  /// The content to display inside the overlay.
  final Widget child;

  /// The background color of the overlay.
  final Color? backgroundColor;

  /// The border radius of the overlay's corners.
  final BorderRadius? borderRadius;

  /// The shape of the arrow.
  final ArrowShape? arrowShape;

  /// The size of the arrow
  final Size? arrowSize;

  /// The border style, color, and width.
  final BorderSide? border;

  /// A list of shadows to apply to the overlay container.
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final anchorData = AnchorData.of(context);
    final points = anchorData.points;
    final metadata = anchorData.metadata;
    final effectiveArrowShape = arrowShape ?? const SharpArrow();
    final effectiveArrowSize = arrowSize ?? const Size(20, 10);
    final effectiveBorderRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(8));
    final effectiveBorder = border ?? BorderSide.none;

    final flipData = metadata.get<FlipData>();
    final arrowData = metadata.get<ArrowData>();

    final arrowDirection = switch (flipData?.finalDirection) {
      AxisDirection.up => AxisDirection.down,
      AxisDirection.down => AxisDirection.up,
      AxisDirection.left => AxisDirection.right,
      AxisDirection.right => AxisDirection.left,
      null => switch (points) {
          AnchorPoints(isLeft: true) => AxisDirection.right,
          AnchorPoints(isRight: true) => AxisDirection.left,
          AnchorPoints(isBelow: true) => AxisDirection.up,
          _ => AxisDirection.down,
        },
    };

    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;

    return Container(
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: AnchorShapeBorder(
          arrowShape: effectiveArrowShape,
          arrowDirection: arrowDirection,
          arrowData: arrowData,
          arrowSize: effectiveArrowSize,
          borderRadius: effectiveBorderRadius,
          border: effectiveBorder,
        ),
        shadows: boxShadow,
      ),
      margin: switch (effectiveArrowShape) {
        NoArrow() => EdgeInsets.zero,
        _ => switch (arrowDirection) {
            AxisDirection.up => EdgeInsets.only(top: effectiveArrowSize.height),
            AxisDirection.down =>
              EdgeInsets.only(bottom: effectiveArrowSize.height),
            AxisDirection.left =>
              EdgeInsets.only(left: effectiveArrowSize.height),
            AxisDirection.right =>
              EdgeInsets.only(right: effectiveArrowSize.height),
          },
      },
      child: child,
    );
  }
}
