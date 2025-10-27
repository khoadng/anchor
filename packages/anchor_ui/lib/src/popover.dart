import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'arrow/arrows.dart';
import 'arrow/container.dart';

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
    this.viewPadding,
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

  /// {@macro anchor_view_padding}
  final EdgeInsets? viewPadding;

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
        viewPadding: viewPadding,
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
          return AnchorArrowContainer(
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
    final effectiveSpacing = spacing ?? 4;

    return [
      OffsetMiddleware(mainAxis: OffsetValue.value(effectiveSpacing)),
      const FlipMiddleware(),
      const ShiftMiddleware(),
      ArrowMiddleware(
        arrowSize: arrowSize ?? const Size(20, 10),
      ),
    ];
  }
}
