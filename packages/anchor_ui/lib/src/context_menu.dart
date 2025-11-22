import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

/// Inherited widget that provides access to the [AnchorContextMenuController].
class _AnchorContextMenuScope extends InheritedWidget {
  const _AnchorContextMenuScope({
    required this.controller,
    required super.child,
  });

  final AnchorContextMenuController controller;

  @override
  bool updateShouldNotify(_AnchorContextMenuScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Controller for managing context menu state and position.
class AnchorContextMenuController extends ChangeNotifier {
  VirtualReference? _reference;
  AnchorController? _anchor;
  var _enabled = true;
  VirtualReference? get _internalReference => _reference;

  /// Retrieves the [AnchorContextMenuController] from the closest [AnchorContextMenu] ancestor.
  ///
  /// If no ancestor is found, returns null.
  static AnchorContextMenuController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AnchorContextMenuScope>()
        ?.controller;
  }

  /// Retrieves the [AnchorContextMenuController] from the closest [AnchorContextMenu] ancestor.
  ///
  /// Throws an error if no ancestor is found.
  static AnchorContextMenuController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No AnchorContextMenu found in context');
    return controller!;
  }

  /// Whether the menu is currently shown.
  bool get isShowing => _anchor?.isShowing ?? false;

  void _attach(AnchorController anchor) {
    if (_anchor == anchor) return;
    _anchor?.removeListener(_handleAnchorChange);
    _anchor = anchor;
    _anchor?.addListener(_handleAnchorChange);
    notifyListeners();
  }

  void _detach() {
    _anchor?.removeListener(_handleAnchorChange);
    _anchor = null;
    notifyListeners();
  }

  void _updateEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    notifyListeners();
  }

  void _handleAnchorChange() {
    if (!isShowing) {
      _reference = null;
    }
    notifyListeners();
  }

  /// Shows the menu at the specified position.
  void show(Offset position) {
    if (!_enabled) return;

    final reference = VirtualReference.fromPoint(position);
    _reference = reference;
    _anchor?.show();
    notifyListeners();
  }

  /// Hides the menu.
  void hide() {
    _anchor?.hide();
    notifyListeners();
  }

  /// Toggles the menu visibility at the specified position.
  void toggle(Offset position) {
    if (isShowing) {
      hide();
    } else {
      show(position);
    }
  }
}

/// Extension methods on [BuildContext] for convenient access methods of [AnchorContextMenuController].
extension AnchorContextMenuExtensions on BuildContext {
  /// Shows the context menu at the specified position.
  ///
  /// If a [ContextMenuRegion] is present, this will automatically coordinate
  /// with other menus (hiding siblings, showing the most specific menu based on depth).
  /// Otherwise, it directly shows the menu for this context.
  void showMenu(Offset position) {
    final registry = findAncestorStateOfType<_ContextMenuRegionState>();
    if (registry != null) {
      registry.showMenuAtPosition(position);
    } else {
      AnchorContextMenuController.of(this).show(position);
    }
  }

  /// Hides the context menu.
  void hideMenu() {
    AnchorContextMenuController.of(this).hide();
  }

  /// Toggles the context menu at the specified position.
  void toggleMenu(Offset position) {
    AnchorContextMenuController.of(this).toggle(position);
  }
}

/// Extension methods on [BuildContext] for convenient access to [AnchorContextMenuController].
extension AnchorContextMenuControllerExtensions on BuildContext {
  /// Returns the [AnchorContextMenuController] if available, otherwise null.
  AnchorContextMenuController? get contextMenuController {
    return AnchorContextMenuController.maybeOf(this);
  }
}

/// Manages the lifecycle of all context menu controllers in the tree.
///
/// **Optional**: Wrap your widget tree with this widget to enable nested context menu coordination.
/// Without this widget, context menus work normally but nested menus won't coordinate
/// (multiple menus might show at once).
///
/// This is typically placed near the root of your app or at the top of a screen with
/// nested context menus.
///
/// Example:
/// ```dart
/// ContextMenuRegion(
///   child: Scaffold(
///     body: AnchorContextMenu(...), // Multiple nested menus will coordinate
///   ),
/// )
/// ```
class ContextMenuRegion extends StatefulWidget {
  /// Creates a context menu region.
  const ContextMenuRegion({super.key, required this.child});

  /// The child widget.
  final Widget child;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  final Map<AnchorContextMenuController, _DetectorInfo> _controllers = {};

  void _register(
    AnchorContextMenuController controller,
    int depth,
    _ContextMenuDetectorState detector,
  ) {
    _controllers[controller] = _DetectorInfo(depth: depth, detector: detector);
  }

  void _unregister(AnchorContextMenuController controller) {
    _controllers.remove(controller);
  }

  /// Shows the most specific (deepest) context menu at the given position.
  ///
  /// This performs hit testing on all registered detectors and shows the menu
  /// for the deepest detector that contains the position. All other menus are hidden.
  void showMenuAtPosition(Offset globalPosition) {
    // Find all detectors that contain this point
    final hits = <_DetectorInfo>[];
    for (final info in _controllers.values) {
      if (info.detector.widget.enabled &&
          info.detector.hitTest(globalPosition)) {
        hits.add(info);
      }
    }

    if (hits.isEmpty) {
      return;
    }

    // Sort by depth (highest depth = deepest = most specific)
    hits.sort((a, b) => b.depth.compareTo(a.depth));
    final deepest = hits.first;

    // Hide all other controllers
    for (final entry in _controllers.entries) {
      if (entry.value != deepest) {
        entry.key.hide();
      }
    }

    // Show the deepest controller
    final controller =
        _controllers.entries.firstWhere((entry) => entry.value == deepest).key;
    controller.show(globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _DetectorInfo {
  _DetectorInfo({required this.depth, required this.detector});
  final int depth;
  final _ContextMenuDetectorState detector;
}

/// Internal widget that registers a context menu zone for hit testing.
class _ContextMenuDetector extends StatefulWidget {
  const _ContextMenuDetector({
    required this.controller,
    required this.enabled,
    required this.child,
    required this.depth,
    required this.onRegister,
    required this.onUnregister,
  });

  final AnchorContextMenuController controller;
  final bool enabled;
  final Widget child;
  final int depth;
  final void Function(
    AnchorContextMenuController,
    int,
    _ContextMenuDetectorState,
  ) onRegister;
  final void Function(AnchorContextMenuController) onUnregister;

  @override
  State<_ContextMenuDetector> createState() => _ContextMenuDetectorState();
}

class _ContextMenuDetectorState extends State<_ContextMenuDetector> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.onRegister(widget.controller, widget.depth, this);
  }

  @override
  void didUpdateWidget(_ContextMenuDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.onUnregister(oldWidget.controller);
      widget.onRegister(widget.controller, widget.depth, this);
    }
  }

  @override
  void dispose() {
    widget.onUnregister(widget.controller);
    super.dispose();
  }

  /// Returns true if the global position is within this detector's bounds.
  bool hitTest(Offset globalPosition) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final local = renderBox.globalToLocal(globalPosition);
    return renderBox.paintBounds.contains(local);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

/// Creates a context menu that appears at a virtual position.
class AnchorContextMenu extends StatefulWidget {
  /// Creates a context menu.
  const AnchorContextMenu({
    super.key,
    this.viewPadding,
    this.placement,
    this.onShow,
    this.onDismiss,
    this.enabled,
    this.controller,
    this.backdropBuilder,
    this.dismissOnTapOutside,
    required this.menuBuilder,
    required this.childBuilder,
  });

  /// The controller for managing the context menu.
  final AnchorContextMenuController? controller;

  /// Builder for the menu overlay.
  final WidgetBuilder menuBuilder;

  /// Builder for the child widget that triggers the menu.
  final WidgetBuilder childBuilder;

  /// The placement of the menu relative to the virtual reference.
  ///
  /// Defaults to [Placement.bottomStart].
  final Placement? placement;

  /// {@macro anchor_view_padding}
  final EdgeInsets? viewPadding;

  /// Callback when the menu is shown.
  final VoidCallback? onShow;

  /// Callback when the menu is dismissed.
  final VoidCallback? onDismiss;

  /// {@macro anchor_enabled}
  final bool? enabled;

  /// {@macro anchor_backdrop_builder}
  final WidgetBuilder? backdropBuilder;

  /// Whether to automatically hide the menu when tapping outside.
  ///
  /// Defaults to true.
  final bool? dismissOnTapOutside;

  @override
  State<AnchorContextMenu> createState() => _AnchorContextMenuState();
}

class _AnchorContextMenuState extends State<AnchorContextMenu> {
  late final AnchorController _anchorController;
  late final AnchorContextMenuController _controller;
  late int _depth;
  _ContextMenuRegionState? _registry;

  @override
  void initState() {
    super.initState();
    _anchorController = AnchorController();
    _controller = widget.controller ?? AnchorContextMenuController();
    _controller._attach(_anchorController);
    _controller._updateEnabled(widget.enabled ?? true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate depth based on how many AnchorContextMenu ancestors we have
    _depth = 0;
    var current = context;
    while (true) {
      final ancestor =
          current.findAncestorStateOfType<_AnchorContextMenuState>();
      if (ancestor == null) break;
      _depth++;
      current = ancestor.context;
    }

    // Find the registry
    _registry = context.findAncestorStateOfType<_ContextMenuRegionState>();
  }

  @override
  void didUpdateWidget(AnchorContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller._detach();
      _controller = widget.controller ?? AnchorContextMenuController();
      _controller._attach(_anchorController);
    }
    if (oldWidget.enabled != widget.enabled) {
      _controller._updateEnabled(widget.enabled ?? true);
    }
  }

  @override
  void dispose() {
    _controller._detach();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _anchorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled ?? true;

    return _AnchorContextMenuScope(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final ref = _controller._internalReference;

          return RawAnchor(
            controller: _anchorController,
            placement: widget.placement ?? Placement.bottomStart,
            middlewares: [
              if (ref != null) VirtualReferenceMiddleware(ref),
              const FlipMiddleware(),
              const ShiftMiddleware(),
            ],
            viewPadding: widget.viewPadding,
            onHide: widget.onDismiss,
            onShow: widget.onShow,
            backdropBuilder: (enabled && (widget.dismissOnTapOutside ?? true))
                ? (context) {
                    return Listener(
                      onPointerDown: (event) {
                        if (!_controller.isShowing) return;
                        // Only dismiss on primary button (left click/tap)
                        if (event.buttons == 1) {
                          _controller.hide();
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                      child: widget.backdropBuilder?.call(context) ??
                          const SizedBox.expand(),
                    );
                  }
                : widget.backdropBuilder,
            overlayBuilder: (context) {
              return _AnchorContextMenuScope(
                controller: _controller,
                child: Builder(builder: widget.menuBuilder),
              );
            },
            child: _AnchorContextMenuScope(
              controller: _controller,
              child: _ContextMenuDetector(
                controller: _controller,
                enabled: enabled,
                depth: _depth,
                onRegister: _registry?._register ?? (_, __, ___) {},
                onUnregister: _registry?._unregister ?? (_) {},
                child: Builder(builder: widget.childBuilder),
              ),
            ),
          );
        },
      ),
    );
  }
}
