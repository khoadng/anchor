import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  const viewportSize = Size(800, 600);
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  final defaultConfig = PositioningConfig(
    childPosition: const Offset(375, 275),
    childSize: childSize,
    viewportSize: viewportSize,
    overlayHeight: overlaySize.height,
    overlayWidth: overlaySize.width,
    placement: Placement.top,
  );

  group('AutoPlacementMiddleware', () {
    test('chooses placement with most space', () {
      const middleware = AutoPlacementMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.chosenPlacement, Placement.bottom);
      expect(newState.anchorPoints.isBelow, isTrue);
    });

    test('respects allowed placements list', () {
      const middleware = AutoPlacementMiddleware(
        allowedPlacements: [Placement.left, Placement.right],
      );
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.chosenPlacement, anyOf(Placement.left, Placement.right));
    });

    test('chooses left when child is near right edge', () {
      const middleware = AutoPlacementMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(730, 275),
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.chosenPlacement, Placement.left);
    });

    test('preserves existing offset', () {
      const middleware = AutoPlacementMiddleware();
      const testOffset = Offset(10, 20);
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config).copyWith(
        anchorPoints: PositionState.fromConfig(config).anchorPoints.copyWith(
              offset: testOffset,
            ),
      );

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset, testOffset);
    });

    test('returns null data when no allowed placements', () {
      const middleware = AutoPlacementMiddleware(allowedPlacements: []);
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data, isNull);
    });
  });
}
