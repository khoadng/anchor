import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

/// Signature for a function that builds a widget given a [TextEditingController]
/// and [FocusNode].
typedef AutocompleteWidgetBuilder = Widget Function(
  BuildContext context,
  TextEditingController controller,
  FocusNode focusNode,
);

/// A widget that wraps an autocomplete input with anchor positioning behavior.
///
/// This widget can manage a [TextEditingController] and [FocusNode] internally
/// or accept externally provided ones. The child is typically a
/// [TextField] or similar input widget.
///
/// The widget automatically shows an overlay when the input is focused,
/// making it ideal for autocomplete, search suggestions, or dropdown menus.
class AnchorAutocomplete extends StatefulWidget {
  /// Creates an autocomplete widget.
  const AnchorAutocomplete({
    super.key,
    required this.childBuilder,
    required this.overlayBuilder,
    this.controller,
    this.focusNode,
    this.spacing,
    this.offset,
    this.overlayHeight,
    this.overlayWidth,
    this.viewPadding,
    this.placement,
    this.transitionDuration,
    this.transitionBuilder,
    this.backdropBuilder,
    this.onShow,
    this.onHide,
    this.enabled,
  });

  /// Builder for the autocomplete input widget.
  ///
  /// Receives a [TextEditingController] and [FocusNode] that should be
  /// passed to the input widget (typically a [TextField]).
  final AutocompleteWidgetBuilder childBuilder;

  /// A builder for the content of the overlay.
  final AutocompleteWidgetBuilder overlayBuilder;

  /// Optional [TextEditingController] for the autocomplete input.
  ///
  /// If provided, this controller will be used instead of creating an internal one.
  /// This allows you to control the text input externally and read/update its value.
  final TextEditingController? controller;

  /// Optional [FocusNode] for the autocomplete input.
  ///
  /// If provided, this focus node will be used instead of creating an internal one.
  /// This allows you to control the focus state externally.
  final FocusNode? focusNode;

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

  /// {@macro anchor_placement}
  final Placement? placement;

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

  /// {@macro anchor_enabled}
  final bool? enabled;

  @override
  State<AnchorAutocomplete> createState() => _AnchorAutocompleteState();
}

class _AnchorAutocompleteState extends State<AnchorAutocomplete> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Anchor(
      triggerMode: AnchorTriggerMode.focus(focusNode: _effectiveFocusNode),
      overlayBuilder: (context) => widget.overlayBuilder(
        context,
        _effectiveController,
        _effectiveFocusNode,
      ),
      spacing: widget.spacing,
      offset: widget.offset,
      overlayHeight: widget.overlayHeight,
      overlayWidth: widget.overlayWidth,
      viewPadding: widget.viewPadding,
      placement: widget.placement,
      transitionDuration: widget.transitionDuration,
      transitionBuilder: widget.transitionBuilder,
      backdropBuilder: widget.backdropBuilder,
      onShow: widget.onShow,
      onHide: widget.onHide,
      enabled: widget.enabled,
      child: widget.childBuilder(
        context,
        _effectiveController,
        _effectiveFocusNode,
      ),
    );
  }
}
