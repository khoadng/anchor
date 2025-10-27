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

  group('FlipMiddleware', () {
    test('does not flip when preferred direction fits', () {
      const middleware = FlipMiddleware();
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.wasFlipped, isFalse);
      expect(data.finalDirection, AxisDirection.up);
      expect(newState.anchorPoints.isAbove, isTrue);
    });

    test('flips to opposite when preferred does not fit', () {
      const middleware = FlipMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.wasFlipped, isTrue);
      expect(data.finalDirection, AxisDirection.down);
      expect(newState.anchorPoints.isBelow, isTrue);
    });

    test('chooses side with more space when neither fits', () {
      const middleware = FlipMiddleware();
      final config = defaultConfig.copyWith(
        overlayHeight: 300,
        childPosition: const Offset(375, 250),
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.finalDirection, AxisDirection.down);
    });

    test('flips horizontal placement', () {
      const middleware = FlipMiddleware();
      final config = defaultConfig.copyWith(
        placement: Placement.right,
        childPosition: const Offset(730, 275),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.wasFlipped, isTrue);
      expect(data.finalDirection, AxisDirection.left);
      expect(newState.anchorPoints.isLeft, isTrue);
    });

    test('preserves alignment when flipping', () {
      const middleware = FlipMiddleware();
      final config = defaultConfig.copyWith(
        placement: Placement.topStart,
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      expect(newState.config.placement, Placement.bottomStart);
    });

    test('stays with preferred when opposite also does not fit', () {
      const middleware = FlipMiddleware();
      final config = defaultConfig.copyWith(
        overlayHeight: 300,
        childPosition: const Offset(375, 270),
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.finalDirection, AxisDirection.down);
    });
  });
}
