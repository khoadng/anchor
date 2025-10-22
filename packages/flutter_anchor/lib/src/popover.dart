import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';

import 'arrow/arrow_info.dart';
import 'arrow/rendering/arrows.dart';
import 'arrow/rendering/border.dart';
import 'core/anchor.dart';
import 'core/controller.dart';
import 'core/data.dart';
import 'core/trigger.dart';

const _defaultArrowSpacing = 8;

/// Creates an anchor overlay styled as a popover.
class AnchorPopover extends StatelessWidget {
  /// Creates an anchor popover.
  const AnchorPopover({
    super.key,
    required this.child,
    required this.overlayBuilder,
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
    this.arrowAlignment,
    this.placement,
    this.enableFlip,
    this.enableShift,
    this.scrollBehavior,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
    this.boxShadow,
    this.border,
    this.onShow,
    this.onHide,
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

  /// {@macro anchor_enable_flip}
  final bool? enableFlip;

  /// {@macro anchor_enable_shift}
  final bool? enableShift;

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

  /// The alignment of the arrow for the popover overlay.
  final double? arrowAlignment;

  /// The box shadow(s) for the popover overlay.
  final List<BoxShadow>? boxShadow;

  /// The border for the popover overlay.
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    return Anchor(
      key: key,
      controller: controller,
      spacing: spacing,
      offset: offset,
      overlayHeight: overlayHeight,
      overlayWidth: overlayWidth,
      triggerMode: triggerMode,
      placement: placement,
      enableFlip: enableFlip,
      enableShift: enableShift,
      scrollBehavior: scrollBehavior,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      backdropBuilder: backdropBuilder,
      onShow: onShow,
      onHide: onHide,
      overlayBuilder: (context) {
        return Builder(
          builder: (context) {
            return _AnchorWithArrow(
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              arrowShape: arrowShape,
              arrowSize: arrowSize,
              arrowAlignment: arrowAlignment,
              boxShadow: boxShadow,
              border: border,

              /// Maybe later allow overriding arrow direction
              // ignore: avoid_redundant_argument_values
              arrowDirection: null,
              child: overlayBuilder(context),
            );
          },
        );
      },
      child: child,
    );
  }
}

class _AnchorWithArrow extends StatelessWidget {
  const _AnchorWithArrow({
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.arrowShape,
    this.arrowDirection,
    this.arrowAlignment,
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

  /// Overrides the automatic arrow direction.
  final AxisDirection? arrowDirection;

  /// The position of the arrow along the overlay's edge (0.0 to 1.0).
  final double? arrowAlignment;

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
    final offset = points.offset;

    final effectiveArrowShape = arrowShape ?? const SharpArrow();
    final effectiveArrowSize = arrowSize ?? const Size(20, 10);
    final effectiveBorderRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(8));
    final effectiveBorder = border ?? BorderSide.none;

    final arrowInfo = ArrowInfo.fromPoints(
      points: points,
      userArrowDirection: arrowDirection,
      userArrowAlignment: arrowAlignment,
    );

    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;

    // Don't add margin for NoArrow shape
    final hasArrow = effectiveArrowShape is! NoArrow;

    // Calculate margin accounting for offset to prevent double spacing
    double calculateMargin(AxisDirection direction) {
      if (!hasArrow) return 0;

      final offsetInDirection = switch (direction) {
        AxisDirection.up => offset.dy.abs(),
        AxisDirection.down => offset.dy.abs(),
        AxisDirection.left => offset.dx.abs(),
        AxisDirection.right => offset.dx.abs(),
      };

      // Margin = arrow height - offset component + some offset
      return (effectiveArrowSize.height - offsetInDirection)
              .clamp(0.0, double.infinity) +
          _defaultArrowSpacing;
    }

    return Container(
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: AnchorShapeBorder(
          arrowShape: effectiveArrowShape,
          arrowDirection: arrowInfo.direction,
          arrowAlignment: arrowInfo.alignment,
          arrowSize: effectiveArrowSize,
          borderRadius: effectiveBorderRadius,
          border: effectiveBorder,
        ),
        shadows: boxShadow,
      ),
      margin: hasArrow
          ? EdgeInsets.only(
              top: arrowInfo.direction == AxisDirection.up
                  ? calculateMargin(AxisDirection.up)
                  : 0,
              bottom: arrowInfo.direction == AxisDirection.down
                  ? calculateMargin(AxisDirection.down)
                  : 0,
              left: arrowInfo.direction == AxisDirection.left
                  ? calculateMargin(AxisDirection.left)
                  : 0,
              right: arrowInfo.direction == AxisDirection.right
                  ? calculateMargin(AxisDirection.right)
                  : 0,
            )
          : EdgeInsets.zero,
      child: child,
    );
  }
}
