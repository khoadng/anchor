import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'anchor.dart';
import 'controller.dart';
import 'data.dart';
import 'geometry.dart';
import 'middleware_utils.dart';

const _defaultScrollBehavior = AnchorScrollBehavior.dismiss;

/// Signature for the callback used by [RawAnchor.onShowRequested] to
/// intercept requests to show the overlay.
typedef RawAnchorShowRequestedCallback = void Function(
  VoidCallback showOverlay,
);

/// Signature for the callback used by [RawAnchor.onHideRequested] to
/// intercept requests to hide the overlay.
typedef RawAnchorHideRequestedCallback = void Function(
  VoidCallback hideOverlay,
);

/// A low-level widget that displays a pop-up overlay relative to its child.
///
/// This widget provides explicit control over positioning through the
/// [middlewares] parameter. All positioning behavior must be explicitly
/// configured via the middlewares list.
///
/// For a widget that includes built-in trigger logic and default positioning
/// middlewares with animations, consider using [Anchor] instead.
class RawAnchor extends StatefulWidget {
  /// Creates a [RawAnchor] widget.
  const RawAnchor({
    super.key,
    required this.child,
    required this.overlayBuilder,
    required this.placement,
    required this.controller,
    required this.middlewares,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
    this.viewPadding,
    this.scrollBehavior,
    this.onShowRequested = _defaultOnShowRequested,
    this.onHideRequested = _defaultOnHideRequested,
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

  /// {@template anchor_middlewares_raw}
  /// The list of positioning middlewares to apply when calculating the
  /// overlay position.
  ///
  /// Middlewares are applied in order and can modify the positioning behavior.
  /// {@endtemplate}
  final List<PositioningMiddleware> middlewares;

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

  /// {@template anchor_view_padding}
  /// Padding to apply to the viewport boundaries when positioning the overlay.
  ///
  /// This reduces the available space on all sides, ensuring the overlay stays
  /// within the padded area. This is particularly useful for avoiding system UI
  /// elements like status bars, navigation bars, or you may want to keep some
  /// distance from the screen edges for aesthetic reasons.
  ///
  /// If not specified, defaults to [EdgeInsets.zero]
  /// {@endtemplate}
  final EdgeInsets? viewPadding;

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

  /// Called when a request is made to show the overlay.
  ///
  /// This callback is triggered when [AnchorController.show] is called.
  ///
  /// After a show request is intercepted, the `showOverlay` callback should be
  /// called when the overlay is ready to be shown. This can occur immediately
  /// (the default behavior), or after a delay or animation setup. Calling
  /// `showOverlay` makes the overlay visible in the widget tree.
  ///
  /// If `showOverlay` is not called, the overlay will stay hidden.
  ///
  /// Defaults to a callback that immediately shows the overlay.
  final RawAnchorShowRequestedCallback onShowRequested;

  /// Called when a request is made to hide the overlay.
  ///
  /// This callback is triggered when [AnchorController.hide] is called or when
  /// scroll behavior triggers a hide.
  ///
  /// After a hide request is intercepted and any closing behaviors have completed
  /// (such as exit animations), the `hideOverlay` callback should be called to
  /// actually remove the overlay from the widget tree.
  ///
  /// If the overlay uses animations, `hideOverlay` should be called after the
  /// exit animation completes.
  ///
  /// Defaults to a callback that immediately hides the overlay.
  final RawAnchorHideRequestedCallback onHideRequested;

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

  static void _defaultOnShowRequested(VoidCallback showOverlay) {
    showOverlay();
  }

  static void _defaultOnHideRequested(VoidCallback hideOverlay) {
    hideOverlay();
  }

  @override
  State<RawAnchor> createState() => _RawAnchorState();
}

class _RawAnchorState extends State<RawAnchor> with WidgetsBindingObserver {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  Size? _lastScreenSize;
  ScrollPosition? _scrollPosition;

  Size? _measuredOverlaySize;

  late PositioningPipeline _pipeline;

  var _points = const AnchorPoints(
    childAnchor: Alignment.topLeft,
    overlayAnchor: Alignment.bottomLeft,
  );
  var _geometry = const AnchorGeometry(
    overlayBounds: null,
    childBounds: null,
    direction: AxisDirection.down,
    alignment: Alignment.topLeft,
  );
  var _metadata = const PositionMetadata();

  bool get _isWaitingForMeasurement {
    final needsWidth = widget.overlayWidth == null;
    final needsHeight = widget.overlayHeight == null;
    return (needsWidth || needsHeight) && _measuredOverlaySize == null;
  }

  AnchorController get _controller => widget.controller;

  AnchorScrollBehavior get _effectiveScrollBehavior =>
      widget.scrollBehavior ?? _defaultScrollBehavior;

  @override
  void initState() {
    super.initState();
    _pipeline = PositioningPipeline(middlewares: widget.middlewares);
    _controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(RawAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      _controller.addListener(_handleControllerChange);
    }
    if (MiddlewareUtils.haveMiddlewaresChanged(
      oldWidget.middlewares,
      widget.middlewares,
    )) {
      _pipeline = PositioningPipeline(middlewares: widget.middlewares);
      if (_overlayController.isShowing) {
        _calculateAnchorPoints(notify: false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentSize = MediaQuery.sizeOf(context);

    if (_lastScreenSize != currentSize) {
      _lastScreenSize = currentSize;

      if (_overlayController.isShowing) {
        _calculateAnchorPoints(notify: false);
      }
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
    _controller.removeListener(_handleControllerChange);
    _scrollPosition?.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayController.isShowing) {
        _calculateAnchorPoints();
      }
    });
  }

  void _handleControllerChange() {
    if (_controller.isShowing) {
      handleShowRequest();
    } else {
      handleHideRequest();
    }
  }

  void handleShowRequest() {
    widget.onShowRequested(_showOverlay);
  }

  void handleHideRequest() {
    widget.onHideRequested(_hideOverlay);
  }

  void _showOverlay() {
    if (_overlayController.isShowing) return;
    if (widget.overlayHeight == null || widget.overlayWidth == null) {
      _measuredOverlaySize = null;
    }
    // Prevent re-entrant calls, the below show method will call the overlay builder which will read the updated controller state anyway
    _calculateAnchorPoints(notify: false);
    _overlayController.show();
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
    _overlayController.hide();
    widget.onHide?.call();
  }

  (AnchorPoints, AnchorGeometry, PositionMetadata)? _calculateAnchorPoints({
    bool notify = true,
  }) {
    final childSize = _layerLink.leaderSize;
    if (childSize == null) return null;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

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
      padding: widget.viewPadding ?? EdgeInsets.zero,
      placement: widget.placement,
    );

    final result = _pipeline.run(config: config);

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

    if (_points != newPoints ||
        _geometry != geometry ||
        _metadata != result.metadata) {
      if (notify) {
        setState(() {
          _points = newPoints;
          _geometry = geometry;
          _metadata = result.metadata;
        });
      } else {
        _points = newPoints;
        _geometry = geometry;
        _metadata = result.metadata;
      }
    }

    return (newPoints, geometry, result.metadata);
  }

  void _handleScroll() {
    if (!_overlayController.isShowing) return;

    switch (_effectiveScrollBehavior) {
      case AnchorScrollBehavior.dismiss:
        handleHideRequest();
      case AnchorScrollBehavior.reposition:
        if (_isChildInViewport()) {
          _calculateAnchorPoints();
        } else {
          handleHideRequest();
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
        return AnchorData(
          controller: _controller,
          geometry: _geometry,
          metadata: _metadata,
          points: _points,
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
                targetAnchor: _points.childAnchor,
                followerAnchor: _points.overlayAnchor,
                offset: _points.offset,
                child: Align(
                  alignment: _points.overlayAlignment,
                  child: Offstage(
                    offstage: _isWaitingForMeasurement,
                    child: _MeasureSize(
                      onChange: _handleOverlaySizeMeasured,
                      child: _AnchorConstrainedBox(
                        recalculate: switch (_metadata.get<SizeData>()) {
                          null => null,
                          _ => () => _calculateAnchorPoints(
                                notify: false,
                              ),
                        },
                        child: Builder(
                          builder: widget.overlayBuilder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

class _AnchorConstrainedBox extends StatelessWidget {
  const _AnchorConstrainedBox({
    required this.recalculate,
    required this.child,
  });

  final (AnchorPoints, AnchorGeometry, PositionMetadata)? Function()?
      recalculate;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final calcFunc = recalculate;
    if (calcFunc == null) return child;

    final result = calcFunc();
    if (result == null) return child;

    final (_, _, data) = result;
    final sizeData = data.get<SizeData>();
    if (sizeData == null) return child;

    final _ = MediaQuery.viewInsetsOf(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: sizeData.availableWidth,
        maxHeight: sizeData.availableHeight,
      ),
      child: child,
    );
  }
}
