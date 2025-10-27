import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'arrow/arrows.dart';
import 'arrow/container.dart';

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
    this.placement,
    this.transitionDuration,
    this.transitionBuilder,
    this.showDuration,
    this.onShow,
    this.onHide,
    this.enabled,
    required this.content,
    required this.child,
  });

  /// Creates an anchor tooltip with an arrow.
  static Widget arrow({
    Key? key,
    AnchorController? controller,
    double? spacing,
    Offset? offset,
    EdgeInsets? viewPadding,
    AnchorTriggerMode? triggerMode,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Size? arrowSize,
    ArrowShape? arrowShape,
    Placement? placement,
    Duration? transitionDuration,
    AnimatedTransitionBuilder? transitionBuilder,
    List<BoxShadow>? boxShadow,
    BorderSide? border,
    Duration? showDuration,
    VoidCallback? onShow,
    VoidCallback? onHide,
    bool? enabled,
    required Widget content,
    required Widget child,
  }) {
    return AnchorConfig(
      enableOverlayHover: false,
      child: Anchor(
        key: key,
        controller: controller,
        spacing: spacing,
        offset: offset,
        viewPadding: viewPadding,
        triggerMode: triggerMode,
        placement: placement,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        onShow: onShow,
        onHide: onHide,
        enabled: enabled,
        overlayBuilder: (context) => _TooltipAutoDismiss(
          showDuration: showDuration,
          child: AnchorArrowContainer(
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            arrowShape: arrowShape,
            arrowSize: arrowSize,
            border: border,
            boxShadow: boxShadow,
            child: content,
          ),
        ),
        child: child,
      ),
    );
  }

  /// The widget that the overlay is anchored to.
  final Widget child;

  /// The tooltip content to display.
  final Widget content;

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

  /// {@macro anchor_placement}
  final Placement? placement;

  /// {@macro anchor_transition_duration}
  final Duration? transitionDuration;

  /// {@macro anchor_transition_builder}
  final AnimatedTransitionBuilder? transitionBuilder;

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
    return AnchorConfig(
      enableOverlayHover: false,
      child: Anchor(
        viewPadding: viewPadding,
        overlayBuilder: (context) => _TooltipAutoDismiss(
          showDuration: showDuration,
          child: content,
        ),
        controller: controller,
        spacing: spacing,
        offset: offset,
        triggerMode: triggerMode ?? const AnchorTriggerMode.hover(),
        placement: placement,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
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
