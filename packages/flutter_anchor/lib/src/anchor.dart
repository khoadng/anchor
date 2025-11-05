import 'dart:async';
import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'controller.dart';
import 'data.dart';
import 'raw_anchor.dart';
import 'trigger.dart';

const _defaultDebounceDuration = Duration(milliseconds: 50);
const _defaultTriggerMode = TapTriggerMode();
const _defaultWaitDuration = Duration.zero;
const _defaultConsumeOutsideTap = false;
const _defaultDismissOnTapOutside = true;
const _defaultTransitionDuration = Duration(milliseconds: 100);

/// A widget that displays a pop-up overlay relative to its child.
class Anchor extends StatefulWidget {
  /// Creates an anchor widget.
  const Anchor({
    super.key,
    this.controller,
    this.spacing,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
    this.viewPadding,
    this.triggerMode,
    this.placement,
    this.middlewares,
    this.scrollBehavior,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
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

  /// {@template anchor_trigger_mode}
  /// How the overlay is triggered and its mode-specific configuration.
  /// {@endtemplate}
  final AnchorTriggerMode? triggerMode;

  /// {@macro anchor_placement}
  final Placement? placement;

  /// {@template anchor_middlewares}
  /// Custom positioning middlewares to apply to the overlay.
  ///
  /// If not provided, defaults to:
  /// - [OffsetMiddleware] with spacing from the anchor
  /// - [FlipMiddleware] to flip when needed
  /// - [ShiftMiddleware] to shift along the cross-axis
  /// {@endtemplate}
  final List<PositioningMiddleware>? middlewares;

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

  /// {@template anchor_enabled}
  /// Whether this widget is enabled.
  ///
  /// When disabled, the widget will not trigger the overlay and will not
  /// consume or intercept any events.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool? enabled;

  @override
  State<Anchor> createState() => _AnchorState();
}

class _AnchorState extends State<Anchor> with SingleTickerProviderStateMixin {
  final _tapRegionGroupId = Object();

  final _isChildHovered = ValueNotifier<bool>(false);
  final _isOverlayHovered = ValueNotifier<bool>(false);
  final _isOverlayFocused = ValueNotifier<bool>(false);

  Timer? _showTimer;
  Timer? _hideTimer;

  AnchorController? _internalController;
  FocusNode? _internalFocusNode;
  late final AnimationController _animationController;

  AnchorController get _controller =>
      widget.controller ?? (_internalController ??= AnchorController());

  FocusNode? get _focusNode => switch (_effectiveTriggerMode) {
        FocusTriggerMode(:final focusNode?) => focusNode,
        FocusTriggerMode() => _internalFocusNode ??=
            FocusNode(debugLabel: 'AnchorInternalFocusNode'),
        _ => null,
      };

  AnchorTriggerMode get _effectiveTriggerMode =>
      widget.triggerMode ?? _defaultTriggerMode;

  Duration get _effectiveWaitDuration => switch (_effectiveTriggerMode) {
        HoverTriggerMode(:final waitDuration?) => waitDuration,
        _ => _defaultWaitDuration,
      };

  Duration get _effectiveDebounceDuration => switch (_effectiveTriggerMode) {
        HoverTriggerMode(:final debounceDuration?) => debounceDuration,
        _ => _defaultDebounceDuration,
      };

  bool get _effectiveConsumeOutsideTap => switch (_effectiveTriggerMode) {
        TapTriggerMode(:final consumeOutsideTap?) => consumeOutsideTap,
        SecondaryTapTriggerMode(:final consumeOutsideTap?) => consumeOutsideTap,
        LongPressTriggerMode(:final consumeOutsideTap?) => consumeOutsideTap,
        _ => _defaultConsumeOutsideTap,
      };

  bool get _effectiveDismissOnTapOutside => switch (_effectiveTriggerMode) {
        FocusTriggerMode(:final dismissOnTapOutside?) => dismissOnTapOutside,
        _ => _defaultDismissOnTapOutside,
      };

  Duration get _effectiveTransitionDuration =>
      widget.transitionDuration ?? _defaultTransitionDuration;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _effectiveTransitionDuration,
    );
    _isChildHovered.addListener(_handleHoverChange);
    _isOverlayHovered.addListener(_handleHoverChange);
    _focusNode?.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(Anchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transitionDuration != widget.transitionDuration) {
      _animationController.duration = _effectiveTransitionDuration;
    }
    if (oldWidget.triggerMode != widget.triggerMode) {
      _handleTriggerModeChange(oldWidget.triggerMode);
    }
  }

  void _handleTriggerModeChange(AnchorTriggerMode? oldTriggerMode) {
    final oldFocusNode =
        oldTriggerMode is FocusTriggerMode ? oldTriggerMode.focusNode : null;
    final newFocusNode = _focusNode;

    if (oldFocusNode != newFocusNode) {
      oldFocusNode?.removeListener(_handleFocusChange);
      newFocusNode?.addListener(_handleFocusChange);
    }

    _showTimer?.cancel();
    _hideTimer?.cancel();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isChildHovered.removeListener(_handleHoverChange);
    _isOverlayHovered.removeListener(_handleHoverChange);
    _focusNode?.removeListener(_handleFocusChange);
    _isChildHovered.dispose();
    _isOverlayHovered.dispose();
    _isOverlayFocused.dispose();
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    _showTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showOverlay() {
    _controller.show();
  }

  void _hideOverlay() {
    _controller.hide();
  }

  void _tryShow() {
    if (_controller.isShowing || (_showTimer?.isActive ?? false)) return;
    _showTimer = Timer(_effectiveWaitDuration, _showOverlay);
  }

  void _handleHoverChange() {
    if (_effectiveTriggerMode is! HoverTriggerMode) return;

    _hideTimer?.cancel();
    if (!_isChildHovered.value && !_isOverlayHovered.value) {
      _hideTimer = Timer(_effectiveDebounceDuration, _hideOverlay);
    }
  }

  void _handleFocusChange() {
    final focusNode = _focusNode;
    if (focusNode == null) return;

    _hideTimer?.cancel();
    _showTimer?.cancel();

    final hasChildFocus = focusNode.hasFocus;
    final hasOverlayFocus = _isOverlayFocused.value;

    if (hasChildFocus || hasOverlayFocus) {
      _showOverlay();
    } else {
      final hasFocus = _focusNode?.hasFocus ?? false;
      if (!hasFocus && !_isOverlayFocused.value) {
        _hideOverlay();
      }
    }
  }

  void _handleTap() {
    if (_controller.isShowing) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _handleSecondaryTap() {
    if (_controller.isShowing) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _handleLongPress() {
    if (_controller.isShowing) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
  }

  void _handleTapOutside(PointerDownEvent event) {
    if (_controller.isShowing) {
      final triggerMode = _effectiveTriggerMode;

      if (triggerMode is FocusTriggerMode && _effectiveDismissOnTapOutside) {
        _hideOverlay();
        _focusNode?.unfocus();
      } else {
        _hideOverlay();
      }
    }
  }

  void _handleShowRequested(VoidCallback showOverlay) {
    showOverlay();
    _animationController.forward();
  }

  void _handleHideRequested(VoidCallback hideOverlay) {
    _animationController.reverse().then((_) {
      if (mounted) {
        hideOverlay();
      }
    });
  }

  Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    if (_effectiveTransitionDuration == Duration.zero) {
      return child;
    }
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.ease),
      child: child,
    );
  }

  List<PositioningMiddleware> _buildMiddlewares(BuildContext context) {
    return switch (widget.middlewares) {
      final middlewares? => middlewares,
      _ => [
          OffsetMiddleware(mainAxis: OffsetValue.value(widget.spacing ?? 4)),
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled ?? true;
    final triggerMode = _effectiveTriggerMode;
    final enableHover = enabled && triggerMode is HoverTriggerMode;
    final enableTap = enabled && triggerMode is TapTriggerMode;
    final enableSecondaryTap =
        enabled && triggerMode is SecondaryTapTriggerMode;
    final enableLongPress = enabled && triggerMode is LongPressTriggerMode;
    final enableFocus = enabled && triggerMode is FocusTriggerMode;
    final enableOverlayHover =
        AnchorConfig.maybeOf(context)?.enableOverlayHover ?? true;

    var child = widget.child;

    if (enableFocus && triggerMode.focusNode == null) {
      child = Focus(
        focusNode: _focusNode,
        child: child,
      );
    }

    return RawAnchor(
      controller: _controller,
      placement: widget.placement ?? Placement.top,
      middlewares: _buildMiddlewares(context),
      offset: widget.offset,
      overlayHeight: widget.overlayHeight,
      overlayWidth: widget.overlayWidth,
      viewPadding: widget.viewPadding,
      scrollBehavior: widget.scrollBehavior,
      onShowRequested: _handleShowRequested,
      onHideRequested: _handleHideRequested,
      backdropBuilder: widget.backdropBuilder,
      onShow: widget.onShow,
      onHide: widget.onHide,
      overlayBuilder: (context) {
        return (widget.transitionBuilder ?? _defaultTransitionBuilder)(
          context,
          _animationController,
          TapRegion(
            groupId: enabled ? _tapRegionGroupId : null,
            onTapOutside: (enableTap ||
                    enableSecondaryTap ||
                    enableLongPress ||
                    (enableFocus && _effectiveDismissOnTapOutside))
                ? _handleTapOutside
                : null,
            consumeOutsideTaps: enabled && _effectiveConsumeOutsideTap,
            child: FocusScope(
              skipTraversal: true,
              onFocusChange: (hasFocus) {
                if (enableFocus) {
                  _isOverlayFocused.value = hasFocus;
                  _handleFocusChange();
                }
              },
              child: MouseRegion(
                onEnter: enableHover && enableOverlayHover
                    ? (_) => _isOverlayHovered.value = true
                    : null,
                onExit: enableHover && enableOverlayHover
                    ? (_) => _isOverlayHovered.value = false
                    : null,
                child: widget.overlayBuilder(context),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        groupId: enabled ? _tapRegionGroupId : null,
        child: GestureDetector(
          onTap: enableTap ? _handleTap : null,
          onSecondaryTap: enableSecondaryTap ? _handleSecondaryTap : null,
          onLongPress: enableLongPress ? _handleLongPress : null,
          child: MouseRegion(
            onEnter: enableHover
                ? (_) {
                    _isChildHovered.value = true;
                    _hideTimer?.cancel();
                    _tryShow();
                  }
                : null,
            onExit: enableHover
                ? (_) {
                    _showTimer?.cancel();
                    _isChildHovered.value = false;
                  }
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
