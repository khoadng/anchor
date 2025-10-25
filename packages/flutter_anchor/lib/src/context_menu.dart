import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';

import 'core/controller.dart';
import 'core/middlewares.dart';
import 'core/raw_anchor.dart';

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
  void showMenu(Offset position) {
    AnchorContextMenuController.of(this).show(position);
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

/// Creates a context menu that appears at a virtual position.
class AnchorContextMenu extends StatefulWidget {
  /// Creates a context menu.
  const AnchorContextMenu({
    super.key,
    this.placement,
    this.onShow,
    this.onDismiss,
    this.enabled,
    this.controller,
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

  /// Callback when the menu is shown.
  final VoidCallback? onShow;

  /// Callback when the menu is dismissed.
  final VoidCallback? onDismiss;

  /// {@macro anchor_enabled}
  final bool? enabled;

  @override
  State<AnchorContextMenu> createState() => _AnchorContextMenuState();
}

class _AnchorContextMenuState extends State<AnchorContextMenu> {
  late final AnchorController _anchorController;
  late final AnchorContextMenuController _controller;

  @override
  void initState() {
    super.initState();
    _anchorController = AnchorController();
    _controller = widget.controller ?? AnchorContextMenuController();
    _controller._attach(_anchorController);
    _controller._updateEnabled(widget.enabled ?? true);
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

          return AnchorMiddlewares(
            middlewares: [
              if (ref != null) VirtualReferenceMiddleware(ref),
              const FlipMiddleware(preferredDirection: AxisDirection.down),
              const ShiftMiddleware(preferredDirection: AxisDirection.down),
            ],
            child: RawAnchor(
              controller: _anchorController,
              placement: widget.placement ?? Placement.bottomStart,
              onHide: widget.onDismiss,
              onShow: widget.onShow,
              overlayBuilder: (context) {
              return TapRegion(
                onTapOutside: enabled ? (_) => _controller.hide() : null,
                child: _AnchorContextMenuScope(
                  controller: _controller,
                  child: Builder(builder: widget.menuBuilder),
                ),
              );
            },
            child: _AnchorContextMenuScope(
              controller: _controller,
              child: Builder(builder: widget.childBuilder),
            ),
              ),
          );
        },
      ),
    );
  }
}
