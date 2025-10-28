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

  group('Virtual', () {
    test('positions overlay at virtual point', () {
      const virtualPoint = Offset(100, 150);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.virtualPosition, virtualPoint);
      expect(data.virtualSize, Size.zero);
      expect(newState.anchorPoints.offset, isNot(Offset.zero));
    });

    test('positions overlay at virtual rect', () {
      const virtualRect = Rect.fromLTWH(100, 150, 50, 30);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromRect(virtualRect),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data!.virtualRect, virtualRect);
      expect(data.virtualSize, const Size(50, 30));
    });

    test('updates available spaces based on virtual position', () {
      const virtualPoint = Offset(100, 150);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, _) = middleware.run(state);

      final spaces = newState.config.spaces;
      expect(spaces.above, 150);
      expect(spaces.left, 100);
      expect(spaces.below, 450);
      expect(spaces.right, 700);
    });

    test('handles top placement correctly', () {
      const virtualRect = Rect.fromLTWH(200, 300, 40, 20);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromRect(virtualRect),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset.dy, lessThan(0));
    });

    test('handles bottom placement correctly', () {
      const virtualRect = Rect.fromLTWH(200, 300, 40, 20);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromRect(virtualRect),
      );
      final config = defaultConfig.copyWith(placement: Placement.bottom);
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset.dy, greaterThan(0));
    });

    test('respects viewport padding in space calculation', () {
      const virtualPoint = Offset(100, 150);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );
      final config = defaultConfig.copyWith(
        padding: const EdgeInsets.all(20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      final spaces = newState.config.spaces;
      expect(spaces.above, 130);
      expect(spaces.left, 80);
    });

    test('sets topLeft anchors for both child and overlay', () {
      const virtualPoint = Offset(100, 150);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.childAnchor, Alignment.topLeft);
      expect(newState.anchorPoints.overlayAnchor, Alignment.topLeft);
    });

    test('calculates offset relative to child position', () {
      const virtualPoint = Offset(100, 150);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data!.appliedOffset.dx, lessThan(0));
      expect(data.appliedOffset.dy, lessThan(0));
    });
  });
}
