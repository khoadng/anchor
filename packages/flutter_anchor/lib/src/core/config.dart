import 'package:flutter/widgets.dart';

/// Configuration for anchor behavior within the widget tree.
class AnchorConfig extends InheritedWidget {
  /// Internal configuration for anchor behavior.
  const AnchorConfig({
    super.key,
    required this.enableOverlayHover,
    required super.child,
  });

  /// Whether to enable hover interactions on overlays.
  final bool enableOverlayHover;

  /// Retrieves the nearest [AnchorConfig] from the widget tree.
  static AnchorConfig? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnchorConfig>();
  }

  @override
  bool updateShouldNotify(AnchorConfig oldWidget) {
    return enableOverlayHover != oldWidget.enableOverlayHover;
  }
}
