import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'anchor.dart';
import 'geometry.dart';

/// Manages the state of an [Anchor]
///
/// An [AnchorController] can be used to programmatically show, hide, or toggle
/// an overlay.
class AnchorController extends ChangeNotifier {
  var _isShowing = false;
  var _points = const AnchorPoints(
    childAnchor: Alignment.topLeft,
    overlayAnchor: Alignment.bottomLeft,
  );
  var _geometry = const AnchorGeometry(
    overlayBounds: null,
    childBounds: null,
    direction: AxisDirection.down,
    alignment: Alignment.topLeft,
  );
  var _metadata = const PositionMetadata();

  /// Whether the overlay is currently showing.
  bool get isShowing => _isShowing;

  /// The current anchor point configuration for positioning the overlay.
  AnchorPoints get points => _points;

  /// The current geometry information for the overlay.
  AnchorGeometry get geometry => _geometry;

  /// The metadata produced by positioning middleware during the last calculation.
  PositionMetadata get metadata => _metadata;

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

  /// Updates the overlay's anchor points, geometry, and metadata.
  @internal
  void setData(
    AnchorPoints points,
    AnchorGeometry geometry,
    PositionMetadata metadata, {
    bool notify = true,
  }) {
    if (_points != points || _geometry != geometry || _metadata != metadata) {
      _points = points;
      _geometry = geometry;
      _metadata = metadata;
      if (notify) notifyListeners();
    }
  }
}
