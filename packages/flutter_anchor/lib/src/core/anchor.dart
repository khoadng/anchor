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

/// A widget that displays a pop-up overlay relative to its child.
class Anchor extends StatefulWidget {
  /// Creates an anchor widget.
  const Anchor({
    super.key,
    required this.child,
    required this.overlayBuilder,
    this.controller,
    this.spacing,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
    this.triggerMode,
    this.placement,
    this.enableFlip,
    this.enableShift,
    this.scrollBehavior,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
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

  /// {@template anchor_trigger_mode}
  /// How the overlay is triggered and its mode-specific configuration.
  /// {@endtemplate}
  final AnchorTriggerMode? triggerMode;

  /// {@macro anchor_placement}
  final Placement? placement;

  /// {@template anchor_enable_flip}
  /// Whether to enable flipping the overlay to the opposite side if it
  /// doesn't fit in the preferred placement direction.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool? enableFlip;

  /// {@template anchor_enable_shift}
  /// Whether to enable shifting the overlay's alignment along the cross-axis
  /// to prevent it from overflowing the viewport edges.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
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

  @override
  State<Anchor> createState() => _AnchorState();
}

class _AnchorState extends State<Anchor> {
  final _tapRegionGroupId = Object();

  final _isChildHovered = ValueNotifier<bool>(false);
  final _isOverlayHovered = ValueNotifier<bool>(false);
  final _isOverlayFocused = ValueNotifier<bool>(false);

  Timer? _showTimer;
  Timer? _hideTimer;

  AnchorController? _internalController;
  FocusNode? _internalFocusNode;

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
        _ => _defaultConsumeOutsideTap,
      };

  bool get _effectiveDismissOnTapOutside => switch (_effectiveTriggerMode) {
        FocusTriggerMode(:final dismissOnTapOutside?) => dismissOnTapOutside,
        _ => _defaultDismissOnTapOutside,
      };

  @override
  void initState() {
    super.initState();
    _isChildHovered.addListener(_handleHoverChange);
    _isOverlayHovered.addListener(_handleHoverChange);
    _focusNode?.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(Anchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerMode != widget.triggerMode) {
      final oldTriggerMode = oldWidget.triggerMode;
      final oldFocusNode =
          oldTriggerMode is FocusTriggerMode ? oldTriggerMode.focusNode : null;
      final newFocusNode = _focusNode;

      if (oldFocusNode != newFocusNode) {
        oldFocusNode?.removeListener(_handleFocusChange);
        newFocusNode?.addListener(_handleFocusChange);
      }
    }
  }

  @override
  void dispose() {
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
      _hideTimer = Timer(_effectiveDebounceDuration, () {
        final hasFocus = _focusNode?.hasFocus ?? false;
        if (!hasFocus && !_isOverlayFocused.value) {
          _hideOverlay();
        }
      });
    }
  }

  void _handleTap() {
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

  List<PositioningMiddleware> _buildMiddlewares() {
    final placement = widget.placement ?? Placement.top;
    final enableFlip = widget.enableFlip ?? true;
    final enableShift = widget.enableShift ?? true;
    final spacing = widget.spacing ?? 8.0;

    return [
      if (enableFlip)
        FlipMiddleware(
          preferredDirection: placement.direction,
        ),
      if (enableShift)
        ShiftMiddleware(
          preferredDirection: placement.direction,
        ),
      OffsetMiddleware(mainAxis: spacing),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final triggerMode = _effectiveTriggerMode;
    final enableHover = triggerMode is HoverTriggerMode;
    final enableTap = triggerMode is TapTriggerMode;
    final enableFocus = triggerMode is FocusTriggerMode;
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
      middlewares: _buildMiddlewares(),
      offset: widget.offset,
      overlayHeight: widget.overlayHeight,
      overlayWidth: widget.overlayWidth,
      scrollBehavior: widget.scrollBehavior,
      transitionDuration: widget.transitionDuration,
      transitionBuilder: widget.transitionBuilder,
      backdropBuilder: widget.backdropBuilder,
      onShow: widget.onShow,
      onHide: widget.onHide,
      overlayBuilder: (context) {
        return TapRegion(
          groupId: _tapRegionGroupId,
          onTapOutside:
              (enableTap || (enableFocus && _effectiveDismissOnTapOutside))
                  ? _handleTapOutside
                  : null,
          consumeOutsideTaps: _effectiveConsumeOutsideTap,
          child: FocusScope(
            descendantsAreTraversable: false,
            canRequestFocus: false,
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
        );
      },
      child: TapRegion(
        groupId: _tapRegionGroupId,
        child: GestureDetector(
          onTap: enableTap ? _handleTap : null,
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
