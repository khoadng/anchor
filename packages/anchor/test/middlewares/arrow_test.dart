import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);
  const arrowSize = Size(20, 20);

  final defaultConfig = PositioningConfig(
    childPosition: const Offset(375, 275),
    childSize: childSize,
    viewportSize: viewportSize,
    overlayHeight: overlaySize.height,
    overlayWidth: overlaySize.width,
    placement: Placement.top,
  );

  group('Arrow', () {
    test('calculates x position for vertical placement', () {
      const middleware = ArrowMiddleware(arrowSize: arrowSize);
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.x, isNotNull);
      expect(data.y, isNull);
      expect(data.centerOffset, 0);
    });

    test('calculates y position for horizontal placement', () {
      const middleware = ArrowMiddleware(arrowSize: arrowSize);
      final config = defaultConfig.copyWith(placement: Placement.left);
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.y, isNotNull);
      expect(data.x, isNull);
      expect(data.centerOffset, 0);
    });

    test('respects padding constraint', () {
      const middleware = ArrowMiddleware(arrowSize: arrowSize, padding: 10);
      final config = defaultConfig.copyWith(
        childPosition: const Offset(20, 275),
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.x! >= 10, isTrue);
    });

    test('returns null when arrow does not fit', () {
      const middleware = ArrowMiddleware(arrowSize: arrowSize, padding: 40);
      final config = defaultConfig.copyWith(
        overlayWidth: 60,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNull);
    });
  });
}
