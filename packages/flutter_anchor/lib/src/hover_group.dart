import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'trigger.dart' show HoverTriggerMode;

const _defaultSkipDelayDuration = Duration(milliseconds: 300);

/// Lets hover anchors below it skip their wait once the user is browsing.
///
/// After an overlay of one [HoverTriggerMode] anchor in the group shows,
/// hovering another anchor in the group shows its overlay right away. The
/// group goes back to waiting once no overlay in it has been visible for
/// [skipDelayDuration].
class AnchorHoverGroup extends StatefulWidget {
  /// Creates a hover group.
  const AnchorHoverGroup({
    super.key,
    this.skipDelayDuration,
    required this.child,
  });

  /// How long after the last overlay hides that the next one still shows
  /// without waiting.
  ///
  /// Defaults to 300 milliseconds.
  final Duration? skipDelayDuration;

  /// The subtree whose hover anchors share this group.
  final Widget child;

  /// The nearest group above [context], if any.
  @internal
  static AnchorHoverGroupState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_AnchorHoverGroupScope>()
      ?.state;

  @override
  State<AnchorHoverGroup> createState() => AnchorHoverGroupState();
}

/// The shared state of an [AnchorHoverGroup].
@internal
class AnchorHoverGroupState extends State<AnchorHoverGroup> {
  var _showingCount = 0;
  Timer? _cooldownTimer;

  /// Whether an overlay in the group is showing or hid moments ago.
  bool get isWarm => _showingCount > 0 || (_cooldownTimer?.isActive ?? false);

  /// Records that an overlay in the group became visible.
  void didShow() {
    _showingCount++;
    _cooldownTimer?.cancel();
  }

  /// Records that an overlay in the group stopped being visible.
  void didHide() {
    _showingCount = _showingCount > 0 ? _showingCount - 1 : 0;
    if (_showingCount > 0) return;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(
      widget.skipDelayDuration ?? _defaultSkipDelayDuration,
      () {},
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnchorHoverGroupScope(
      state: this,
      child: widget.child,
    );
  }
}

class _AnchorHoverGroupScope extends InheritedWidget {
  const _AnchorHoverGroupScope({
    required this.state,
    required super.child,
  });

  final AnchorHoverGroupState state;

  @override
  bool updateShouldNotify(_AnchorHoverGroupScope oldWidget) =>
      state != oldWidget.state;
}
