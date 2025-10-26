import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'arrow/arrows.dart';
import 'arrow/border.dart';

/// Creates an anchor overlay styled as a popover.
class AnchorPopover extends StatelessWidget {
  /// Creates an anchor popover.
  const AnchorPopover({
    super.key,
    this.controller,
    this.spacing,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
    this.triggerMode,
    this.backgroundColor,
    this.borderRadius,
    this.arrowShape,
    this.arrowSize,
    this.placement,
    this.scrollBehavior,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
    this.boxShadow,
    this.border,
    this.onShow,
    this.onHide,
    this.enabled,
    required this.overlayBuilder,
    required this.child,
  });

  /// The widget that the overlay is anchored to.
  final Widget child;

  /// A builder for the content of the overlay.
  final WidgetBuilder overlayBuilder;

  /// {@macro anchor_controller}
  final AnchorController? controller;

  /// {@macro anchor_spacing}
  final double? spacing;

  /// {@macro anchor_offset}
  final Offset? offset;

  /// {@macro anchor_overlay_height}
  final double? overlayHeight;

  /// {@macro anchor_overlay_width}
  final double? overlayWidth;

  /// {@macro anchor_trigger_mode}
  final AnchorTriggerMode? triggerMode;

  /// {@macro anchor_placement}
  final Placement? placement;

  /// {@macro anchor_scroll_behavior}
  final AnchorScrollBehavior? scrollBehavior;

  /// {@macro anchor_transition_duration}
  final Duration? transitionDuration;

  /// {@macro anchor_transition_builder}
  final AnimatedTransitionBuilder? transitionBuilder;

  /// {@macro anchor_backdrop_builder}
  final WidgetBuilder? backdropBuilder;

  /// {@macro anchor_on_show}
  final VoidCallback? onShow;

  /// {@macro anchor_on_hide}
  final VoidCallback? onHide;

  /// The background color of the popover overlay.
  final Color? backgroundColor;

  /// The border radius of the popover overlay.
  final BorderRadius? borderRadius;

  /// The shape of the arrow for the popover overlay.
  final ArrowShape? arrowShape;

  /// The size of the arrow for the popover overlay.
  final Size? arrowSize;

  /// The box shadow(s) for the popover overlay.
  final List<BoxShadow>? boxShadow;

  /// The border for the popover overlay.
  final BorderSide? border;

  /// {@macro anchor_enabled}
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return AnchorMiddlewares(
      middlewares: _buildMiddlewares(),
      child: Anchor(
        key: key,
        controller: controller,
        spacing: spacing,
        offset: offset,
        overlayHeight: overlayHeight,
        overlayWidth: overlayWidth,
        triggerMode: triggerMode,
        placement: placement,
        scrollBehavior: scrollBehavior,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        backdropBuilder: backdropBuilder,
        onShow: onShow,
        onHide: onHide,
        enabled: enabled,
        overlayBuilder: (context) {
          return _AnchorWithArrow(
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            arrowShape: arrowShape,
            arrowSize: arrowSize,
            boxShadow: boxShadow,
            border: border,
            child: overlayBuilder(context),
          );
        },
        child: child,
      ),
    );
  }

  List<PositioningMiddleware> _buildMiddlewares() {
    final effectivePlacement = placement ?? Placement.top;
    final effectiveSpacing = spacing ?? 4;

    return [
      FlipMiddleware(
        preferredDirection: effectivePlacement.direction,
      ),
      ShiftMiddleware(
        preferredDirection: effectivePlacement.direction,
      ),
      OffsetMiddleware(mainAxis: effectiveSpacing),
      ArrowMiddleware(
        arrowSize: arrowSize ?? const Size(20, 10),
      ),
    ];
  }
}

class _AnchorWithArrow extends StatelessWidget {
  const _AnchorWithArrow({
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.arrowShape,
    this.arrowSize,
    this.border,
    this.boxShadow,
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
    final controller = anchorData.controller;
    final points = controller.points;
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
