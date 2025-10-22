import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'geometry.dart';

/// Defines how the overlay responds to scrolling of ancestor scrollable widgets.
enum AnchorScrollBehavior {
  /// Hide the overlay immediately when any ancestor scrollable widget scrolls.
  ///
  /// This is the default behavior and prevents awkward positioning issues when
  /// the child widget scrolls offscreen or gets clipped.
  dismiss,

  /// Recalculate positioning during scroll to handle screen bounds properly.
  ///
  /// The overlay visually follows its child automatically
  /// but this mode recalculates anchor points on every scroll event to ensure proper
  /// positioning, flipping, and alignment relative to screen bounds.
  ///
  /// Automatically hides when the child scrolls completely outside the viewport.
  ///
  /// Note: Recalculating positioning on every scroll event may impact performance
  /// for complex overlay content.
  reposition,

  /// No special scroll handling.
  ///
  /// The overlay will remain in its initial position.
  none,
}

/// Provides the [AnchorController] to the overlay's content.
class AnchorData extends InheritedWidget {
  /// Creates an [AnchorData] widget.
  const AnchorData({
    super.key,
    required this.controller,
    required this.geometry,
    required super.child,
  });

  /// The controller for the anchor.
  final AnchorController controller;

  /// The geometric information of the overlay.
  final AnchorGeometry geometry;

  /// Retrieves the [AnchorController] from the nearest [AnchorData] ancestor.
  ///
  /// This method asserts that an `AnchorData` is found in the widget tree.
  static AnchorData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AnchorData>();
    assert(
      data != null,
      'AnchorData not found in context. Make sure you are calling AnchorData.of() inside an Anchor overlayBuilder.',
    );
    return data!;
  }

  /// Retrieves the [AnchorController] from the nearest [AnchorData] ancestor,
  /// returning null if none is found.
  static AnchorData? maybeOf(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AnchorData>();
    return data;
  }

  @override
  bool updateShouldNotify(AnchorData oldWidget) {
    return controller != oldWidget.controller || geometry != oldWidget.geometry;
  }
}
