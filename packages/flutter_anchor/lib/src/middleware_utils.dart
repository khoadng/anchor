import 'package:anchor/anchor.dart';

/// Utilities for working with positioning middlewares.
class MiddlewareUtils {
  const MiddlewareUtils._();

  /// Checks if two lists of middlewares are equal.
  ///
  /// This performs a deep equality check on the middleware lists.
  /// Returns `true` if both lists are null, or if they have the same length
  /// and all corresponding elements are equal.
  static bool areMiddlewaresEqual(
    List<PositioningMiddleware>? a,
    List<PositioningMiddleware>? b,
  ) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Checks if middlewares have changed between widget updates.
  ///
  /// This is a convenience method that can be used in `didUpdateWidget`
  /// to determine if the middlewares list has been modified.
  ///
  /// Returns `true` if the middlewares have changed.
  static bool haveMiddlewaresChanged(
    List<PositioningMiddleware>? oldMiddlewares,
    List<PositioningMiddleware>? newMiddlewares,
  ) {
    return !areMiddlewaresEqual(oldMiddlewares, newMiddlewares);
  }

  /// Creates a hash code for a list of middlewares.
  ///
  /// This can be used for efficient comparison or caching of middleware
  /// configurations.
  static int hashMiddlewares(List<PositioningMiddleware>? middlewares) {
    if (middlewares == null) return 0;
    return Object.hashAll(middlewares);
  }
}
