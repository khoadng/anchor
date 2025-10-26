import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'arrow/arrows.dart';
import 'popover.dart';

/// Creates an anchor overlay styled as a tooltip.
class AnchorTooltip extends StatelessWidget {
  /// Creates an anchor tooltip.
  const AnchorTooltip({
    super.key,
    this.controller,
    this.spacing,
    this.offset,
    this.viewPadding,
    this.triggerMode,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.arrowSize,
    this.arrowAlignment,
    this.arrowShape,
    this.placement,
    this.scrollBehavior,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
    this.boxShadow,
    this.border,
    this.showDuration,
    this.onShow,
    this.onHide,
    this.enabled,
    required this.message,
    required this.child,
  });

  /// The widget that the overlay is anchored to.
  final Widget child;

  /// The tooltip message to display.
  final Widget message;

  /// {@macro anchor_controller}
  final AnchorController? controller;

  /// {@macro anchor_spacing}
  final double? spacing;

  /// {@macro anchor_offset}
  final Offset? offset;

  /// {@macro anchor_view_padding}
  final EdgeInsets? viewPadding;

  /// {@macro anchor_trigger_mode}
  final AnchorTriggerMode? triggerMode;

  /// The background color of the tooltip overlay.
  final Color? backgroundColor;

  /// The padding inside the tooltip overlay.
  final EdgeInsets? padding;

  /// The border radius of the tooltip overlay.
  final BorderRadius? borderRadius;

  /// The size of the arrow for the tooltip overlay.
  final Size? arrowSize;

  /// The alignment of the arrow for the tooltip overlay.
  final double? arrowAlignment;

  /// The shape of the arrow for the tooltip overlay.
  final ArrowShape? arrowShape;

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

  /// The box shadow(s) for the tooltip overlay.
  final List<BoxShadow>? boxShadow;

  /// The border for the tooltip overlay.
  final BorderSide? border;

  /// Duration to show the tooltip before auto-dismissing.
  final Duration? showDuration;

  /// {@macro anchor_on_show}
  final VoidCallback? onShow;

  /// {@macro anchor_on_hide}
  final VoidCallback? onHide;

  /// {@macro anchor_enabled}
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    return AnchorConfig(
      enableOverlayHover: false,
      child: AnchorPopover(
        viewPadding: viewPadding,
        overlayBuilder: (context) => _TooltipAutoDismiss(
          showDuration: showDuration,
          child: Padding(
            padding: effectivePadding,
            child: message,
          ),
        ),
        controller: controller,
        spacing: spacing,
        offset: offset,
        triggerMode: triggerMode ?? const AnchorTriggerMode.hover(),
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        arrowSize: arrowSize,
        arrowShape: arrowShape,
        placement: placement,
        scrollBehavior: scrollBehavior,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        backdropBuilder: backdropBuilder,
        boxShadow: boxShadow,
        border: border,
        onShow: onShow,
        onHide: onHide,
        enabled: enabled,
        child: child,
      ),
    );
  }
}

class _TooltipAutoDismiss extends StatefulWidget {
  const _TooltipAutoDismiss({
    required this.child,
    required this.showDuration,
  });

  final Widget child;
  final Duration? showDuration;

  @override
  State<_TooltipAutoDismiss> createState() => _TooltipAutoDismissState();
}

class _TooltipAutoDismissState extends State<_TooltipAutoDismiss> {
  AnchorController? _controller;
  Timer? _dismissTimer;

  bool get _isShowing => _controller?.isShowing ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AnchorData.maybeOf(context)?.controller;
    if (_controller == controller) return;

    _controller?.removeListener(_handleControllerChanged);
    _controller = controller;
    _controller?.addListener(_handleControllerChanged);

    if (_controller?.isShowing ?? false) {
      _startTimer();
    } else {
      _cancelTimer();
    }
  }

  @override
  void didUpdateWidget(covariant _TooltipAutoDismiss oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDuration != widget.showDuration && _isShowing) {
      _startTimer();
    }
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    if (_isShowing) {
      _startTimer();
    } else {
      _cancelTimer();
    }
  }

  void _startTimer() {
    _cancelTimer();
    final showDuration = widget.showDuration;
    if (showDuration == null || showDuration <= Duration.zero) return;
    _dismissTimer = Timer(showDuration, () {
      _controller?.hide();
    });
  }

  void _cancelTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
