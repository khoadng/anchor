import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';

import 'core/controller.dart';
import 'core/raw_anchor.dart';

/// Controller for managing context menu state and position.
class AnchorContextMenuController extends ChangeNotifier {
  VirtualReference? _reference;
  AnchorController? _anchor;
  VirtualReference? get _internalReference => _reference;

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

  void _handleAnchorChange() {
    if (!isShowing) {
      _reference = null;
    }
    notifyListeners();
  }

  /// Shows the menu at the specified position.
  void show(Offset position) {
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

/// Creates a context menu that appears at a virtual position.
class AnchorContextMenu extends StatefulWidget {
  /// Creates a context menu.
  const AnchorContextMenu({
    super.key,
    required this.child,
    required this.controller,
    required this.menuBuilder,
    this.placement,
    this.onShow,
    this.onDismiss,
  });

  /// The widget that the context menu is anchored to.
  final Widget child;

  /// Controller for managing the menu state and position.
  final AnchorContextMenuController controller;

  /// Builder for the menu overlay.
  final WidgetBuilder menuBuilder;

  /// The placement of the menu relative to the virtual reference.
  ///
  /// Defaults to [Placement.bottomStart].
  final Placement? placement;

  /// Callback when the menu is shown.
  final VoidCallback? onShow;

  /// Callback when the menu is dismissed.
  final VoidCallback? onDismiss;

  @override
  State<AnchorContextMenu> createState() => _AnchorContextMenuState();
}

class _AnchorContextMenuState extends State<AnchorContextMenu> {
  late final AnchorController _anchorController;

  @override
  void initState() {
    super.initState();
    _anchorController = AnchorController();
    widget.controller._attach(_anchorController);
  }

  @override
  void didUpdateWidget(AnchorContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach();
      widget.controller._attach(_anchorController);
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    _anchorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final ref = widget.controller._internalReference;

        return RawAnchor(
          controller: _anchorController,
          placement: widget.placement ?? Placement.bottomStart,
          onHide: widget.onDismiss,
          onShow: widget.onShow,
          middlewares: [
            if (ref != null) VirtualReferenceMiddleware(ref),
            const FlipMiddleware(preferredDirection: AxisDirection.down),
            const ShiftMiddleware(preferredDirection: AxisDirection.down),
          ],
          overlayBuilder: (context) {
            return TapRegion(
              onTapOutside: (_) => widget.controller.hide(),
              child: widget.menuBuilder(context),
            );
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
