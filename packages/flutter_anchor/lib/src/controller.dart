import 'package:flutter/material.dart';

import 'anchor.dart';

/// Manages the state of an [Anchor]
///
/// An [AnchorController] can be used to programmatically show, hide, or toggle
/// an overlay.
class AnchorController extends ChangeNotifier {
  var _isShowing = false;

  /// Whether the overlay is currently showing.
  bool get isShowing => _isShowing;

  /// Shows the overlay.
  void show() {
    _isShowing = true;
    notifyListeners();
  }

  /// Hides the overlay.
  void hide() {
    _isShowing = false;
    notifyListeners();
  }

  /// Toggles the overlay's visibility.
  void toggle() {
    _isShowing = !_isShowing;
    notifyListeners();
  }
}
