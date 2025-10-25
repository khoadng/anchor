import 'package:meta/meta.dart';

import '../placement.dart';
import '../position.dart';

/// Data produced by [AutoPlacementMiddleware] after positioning.
@immutable
class AutoPlacementData {
  /// Creates [AutoPlacementData].
  const AutoPlacementData({
    required this.chosenPlacement,
    required this.availableSpace,
  });

  /// The placement that was automatically chosen.
  final Placement chosenPlacement;

  /// The available space in the chosen direction.
  final double availableSpace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoPlacementData &&
          runtimeType == other.runtimeType &&
          chosenPlacement == other.chosenPlacement &&
          availableSpace == other.availableSpace;

  @override
  int get hashCode => Object.hash(chosenPlacement, availableSpace);

  @override
  String toString() =>
      'AutoPlacementData(chosenPlacement: $chosenPlacement, availableSpace: $availableSpace)';
}

/// A middleware that automatically chooses the best placement
/// based on available space.
@immutable
class AutoPlacementMiddleware implements PositioningMiddleware<AutoPlacementData> {
  /// Creates an [AutoPlacementMiddleware].
  const AutoPlacementMiddleware({
    this.allowedPlacements = const [
      Placement.top,
      Placement.bottom,
      Placement.left,
      Placement.right,
    ],
  });

  /// The list of placements to consider. The middleware will choose the
  /// placement with the most available space from this list.
  final List<Placement> allowedPlacements;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AutoPlacementMiddleware) return false;
    if (allowedPlacements.length != other.allowedPlacements.length) {
      return false;
    }
    for (var i = 0; i < allowedPlacements.length; i++) {
      if (allowedPlacements[i] != other.allowedPlacements[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(allowedPlacements);

  @override
  (PositionState, AutoPlacementData?) run(PositionState state) {
    final config = state.config;
    final spaces = config.spaces;

    // Find the placement with the most available space
    final bestPlacement =
        allowedPlacements.fold<({Placement placement, double space})?>(
      null,
      (best, placement) {
        final availableSpace = spaces.inDirection(placement.direction);

        return switch (best) {
          null => (placement: placement, space: availableSpace),
          _ when availableSpace > best.space => (
              placement: placement,
              space: availableSpace
            ),
          _ => best,
        };
      },
    );

    return switch (bestPlacement) {
      null => (state, null),
      final result => (
          state.copyWith(
            anchorPoints: result.placement.toAnchorPoints().copyWith(
                  offset: state.anchorPoints.offset,
                ),
          ),
          AutoPlacementData(
            chosenPlacement: result.placement,
            availableSpace: result.space,
          ),
        ),
    };
  }
}
