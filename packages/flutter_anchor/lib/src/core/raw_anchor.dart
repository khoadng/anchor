import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'anchor.dart';
import 'controller.dart';
import 'data.dart';
import 'geometry.dart';
import 'middlewares.dart';

const _defaultTransitionDuration = Duration(milliseconds: 100);
const _defaultScrollBehavior = AnchorScrollBehavior.dismiss;

/// A low-level widget that displays a pop-up overlay relative to its child.
///
/// For positioning, this widget uses [PositioningMiddleware] obtained from
/// an ancestor [AnchorMiddlewares] widget. If no [AnchorMiddlewares] is found,
/// the overlay will show at the preferred placement without any adjustment logic.
///
/// For a widget that includes built-in trigger logic and default positioning
/// middlewares, see [Anchor].
class RawAnchor extends StatefulWidget {
  /// Creates a [RawAnchor] widget.
  const RawAnchor({
    super.key,
    required this.child,
    required this.overlayBuilder,
    required this.placement,
    required this.controller,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
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

  /// The preferred placement to show the overlay if space allows.
  final Placement placement;

  /// {@template anchor_controller}
  /// An controller to manage the overlay's state programmatically.
  /// {@endtemplate}
  final AnchorController controller;

  /// {@template anchor_offset}
  /// Absolute position adjustment applied after middleware calculations.
  /// Use this for fine-tuning when automatic positioning needs adjustment.
  /// {@endtemplate}
  final Offset? offset;

  /// {@template anchor_overlay_height}
  /// The height of the overlay content. Providing this helps with positioning.
  /// {@endtemplate}
  final double? overlayHeight;

  /// {@template anchor_overlay_width}
  /// The width of the overlay content. Providing this helps with positioning.
  /// {@endtemplate}
  final double? overlayWidth;

  /// {@template anchor_scroll_behavior}
  /// Defines how the overlay responds to scrolling of ancestor scrollable widgets.
  ///
  /// - [AnchorScrollBehavior.dismiss] (default): Immediately hides when scrolling
  ///   begins, preventing awkward positioning issues.
  /// - [AnchorScrollBehavior.reposition]: Recalculates positioning during scroll
  ///   to handle screen bounds, flipping, and alignment. Hides when child scrolls
  ///   completely offscreen.
  /// - [AnchorScrollBehavior.none]: No special handling; overlay may appear
  ///   misaligned or detached during scroll.
  /// {@endtemplate}
  final AnchorScrollBehavior? scrollBehavior;

  /// {@template anchor_transition_duration}
  /// The duration for the entry and exit animations.
  /// {@endtemplate}
  final Duration? transitionDuration;

  /// {@template anchor_transition_builder}
  /// A custom builder for the overlay's animation.
  /// {@endtemplate}
  final AnimatedTransitionBuilder? transitionBuilder;

  /// {@template anchor_backdrop_builder}
  /// A builder for the backdrop widget displayed behind the overlay.
  /// {@endtemplate}
  final WidgetBuilder? backdropBuilder;

  /// {@template anchor_on_show}
  /// Called when the overlay is shown.
  /// {@endtemplate}
  final VoidCallback? onShow;

  /// {@template anchor_on_hide}
  /// Called when the overlay begins hiding.
  /// {@endtemplate}
  final VoidCallback? onHide;

  @override
  State<RawAnchor> createState() => _RawAnchorState();
}

class _RawAnchorState extends State<RawAnchor>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  Size? _lastScreenSize;
  late final AnimationController _animationController;

  ScrollPosition? _scrollPosition;

  Size? _measuredOverlaySize;

  List<PositioningMiddleware>? _lastMiddlewares;

  bool get _isWaitingForMeasurement {
    final needsWidth = widget.overlayWidth == null;
    final needsHeight = widget.overlayHeight == null;
    return (needsWidth || needsHeight) && _measuredOverlaySize == null;
  }

  AnchorController get _controller => widget.controller;

  Duration get _effectiveTransitionDuration =>
      widget.transitionDuration ?? _defaultTransitionDuration;

  AnchorScrollBehavior get _effectiveScrollBehavior =>
      widget.scrollBehavior ?? _defaultScrollBehavior;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _effectiveTransitionDuration,
    );
    _animationController.addStatusListener(_handleAnimationStatusChanged);
    _controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(RawAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      _controller.addListener(_handleControllerChange);
    }
    if (oldWidget.transitionDuration != widget.transitionDuration) {
      _animationController.duration = _effectiveTransitionDuration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentSize = MediaQuery.sizeOf(context);
    final currentMiddlewares = AnchorMiddlewares.of(context);

    // Check if middlewares changed (AnchorMiddlewares.updateShouldNotify already
    // filtered most cases, but didChangeDependencies can be called for other
    // reasons like MediaQuery or Scrollable changes, so we verify here)
    final middlewaresChanged = !identical(_lastMiddlewares, currentMiddlewares);

    if (_lastScreenSize != currentSize && _overlayController.isShowing) {
      _lastScreenSize = currentSize;
      _calculateAnchorPoints(notify: false);
    } else {
      _lastScreenSize = currentSize;
    }

    // Recalculate if middlewares changed and overlay is showing
    if (middlewaresChanged && _overlayController.isShowing) {
      _lastMiddlewares = currentMiddlewares;
      _measuredOverlaySize = null;
      _calculateAnchorPoints(notify: false);
    } else {
      _lastMiddlewares = currentMiddlewares;
    }

    if (widget.scrollBehavior != AnchorScrollBehavior.none) {
      final newScrollPosition = Scrollable.maybeOf(context)?.position;
      if (_scrollPosition != newScrollPosition) {
        _scrollPosition?.removeListener(_handleScroll);
        _scrollPosition = newScrollPosition;
        _scrollPosition?.addListener(_handleScroll);
      }
    } else {
      _scrollPosition?.removeListener(_handleScroll);
      _scrollPosition = null;
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_handleAnimationStatusChanged);
    _animationController.dispose();
    _controller.removeListener(_handleControllerChange);
    _scrollPosition?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  void _handleControllerChange() {
    if (_controller.isShowing) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayController.isShowing) return;
    if (widget.overlayHeight == null || widget.overlayWidth == null) {
      _measuredOverlaySize = null;
    }
    _calculateAnchorPoints();
    _overlayController.show();
    _animationController.forward();
    widget.onShow?.call();
  }

  void _handleOverlaySizeMeasured(Size size) {
    if (!mounted) return;
    final needsWidth = widget.overlayWidth == null;
    final needsHeight = widget.overlayHeight == null;

    if (!needsWidth && !needsHeight) return;

    final newSize = Size(
      needsWidth ? size.width : _measuredOverlaySize?.width ?? 0,
      needsHeight ? size.height : _measuredOverlaySize?.height ?? 0,
    );

    if (_measuredOverlaySize != newSize) {
      setState(() {
        _measuredOverlaySize = newSize;
      });
      _calculateAnchorPoints();
    }
  }

  void _hideOverlay() {
    if (!_overlayController.isShowing) return;
    _animationController.reverse();
    widget.onHide?.call();
  }

  void _calculateAnchorPoints({
    bool notify = true,
  }) {
    final childSize = _layerLink.leaderSize;
    if (childSize == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final childGlobalPosition = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);

    final effectiveOverlayHeight =
        widget.overlayHeight ?? _measuredOverlaySize?.height;
    final effectiveOverlayWidth =
        widget.overlayWidth ?? _measuredOverlaySize?.width;

    final config = PositioningConfig(
      childPosition: childGlobalPosition,
      childSize: childSize,
      viewportSize: screenSize,
      overlayHeight: effectiveOverlayHeight,
      overlayWidth: effectiveOverlayWidth,
    );

    final middlewares = _lastMiddlewares ?? AnchorMiddlewares.of(context);
    final result = PositioningPipeline(
      middlewares: middlewares,
    ).run(
      placement: widget.placement,
      config: config,
    );

    var newPoints = result.state.anchorPoints;

    if (widget.offset case final offset?) {
      newPoints = newPoints.copyWith(
        offset: newPoints.offset + offset,
      );
    }

    final geometry = AnchorGeometry.fromPoints(
      points: newPoints,
      offset: newPoints.offset,
      childGlobalPosition: childGlobalPosition,
      childSize: childSize,
      overlayWidth: effectiveOverlayWidth,
      overlayHeight: effectiveOverlayHeight,
    );

    _controller.setData(newPoints, geometry, notify: notify);
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

  void _handleScroll() {
    if (!_overlayController.isShowing) return;
    if (_animationController.isAnimating) return;

    switch (_effectiveScrollBehavior) {
      case AnchorScrollBehavior.dismiss:
        _hideOverlay();
      case AnchorScrollBehavior.reposition:
        if (_isChildInViewport()) {
          _calculateAnchorPoints();
        } else {
          _hideOverlay();
        }
      case AnchorScrollBehavior.none:
        break;
    }
  }

  bool _isChildInViewport() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final childGlobalPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;
    final screenSize = MediaQuery.sizeOf(context);

    final childRect = childGlobalPosition & childSize;
    final screenRect = Offset.zero & screenSize;

    return screenRect.overlaps(childRect);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final points = _controller.points;
            final geometry = _controller.geometry;
            final offset = points.offset;

            return AnchorData(
              controller: _controller,
              geometry: geometry,
              child: Stack(
                children: [
                  if (widget.backdropBuilder case final builder?)
                    Positioned.fill(
                      child: Builder(
                        builder: builder,
                      ),
                    ),
                  CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: points.childAnchor,
                    followerAnchor: points.overlayAnchor,
                    offset: offset,
                    child: Align(
                      alignment: points.overlayAlignment,
                      child: Opacity(
                        opacity: _isWaitingForMeasurement ? 0.0 : 1.0,
                        child: (widget.transitionBuilder ??
                            _defaultTransitionBuilder)(
                          context,
                          _animationController,
                          _MeasureSize(
                            onChange: _handleOverlaySizeMeasured,
                            child: widget.overlayBuilder(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: widget.child,
      ),
    );
  }
}

/// A widget that measures its child's size and reports changes.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange: onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize({required ValueChanged<Size> onChange})
      : _onChange = onChange;

  ValueChanged<Size> _onChange;
  ValueChanged<Size> get onChange => _onChange;
  set onChange(ValueChanged<Size> value) {
    if (_onChange == value) return;
    _onChange = value;
  }

  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize != null && _previousSize != newSize) {
      _previousSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onChange(newSize);
      });
    }
  }
}
