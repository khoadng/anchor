import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';

import 'raw_anchor.dart';

/// An inherited widget that provides positioning middlewares to descendant
/// [RawAnchor] widgets.
class AnchorMiddlewares extends InheritedWidget {
  /// Creates an [AnchorMiddlewares] widget.
  const AnchorMiddlewares({
    super.key,
    required this.middlewares,
    required super.child,
  });

  /// The list of positioning middlewares to apply.
  final List<PositioningMiddleware> middlewares;

  /// Returns the middlewares from the closest [AnchorMiddlewares] ancestor,
  /// or null if none is found.
  static List<PositioningMiddleware>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AnchorMiddlewares>()
        ?.middlewares;
  }

  /// Returns the middlewares from the closest [AnchorMiddlewares] ancestor.
  ///
  /// If no ancestor is found, returns an empty list, meaning the overlay will
  /// show at the preferred placement without any adjustment logic.
  static List<PositioningMiddleware> of(BuildContext context) {
    return maybeOf(context) ?? const [];
  }

  @override
  bool updateShouldNotify(AnchorMiddlewares oldWidget) {
    return _middlewaresChanged(oldWidget.middlewares, middlewares);
  }

  bool _middlewaresChanged(
    List<PositioningMiddleware> oldList,
    List<PositioningMiddleware> newList,
  ) {
    if (identical(oldList, newList)) return false;
    if (oldList.length != newList.length) return true;

    for (var i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return true;
    }

    return false;
  }
}
