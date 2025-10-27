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

  group('OffsetMiddleware', () {
    test('applies mainAxis offset for vertical placement', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.mainAxisOffset, 10);
      expect(data.appliedOffset, const Offset(0, -10));
      expect(newState.anchorPoints.offset, const Offset(0, -10));
    });

    test('applies crossAxis offset for vertical placement', () {
      const middleware = OffsetMiddleware(crossAxis: OffsetValue.value(15));
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.crossAxisOffset, 15);
      expect(data.appliedOffset, const Offset(15, 0));
      expect(newState.anchorPoints.offset, const Offset(15, 0));
    });

    test('combines mainAxis and crossAxis offsets', () {
      const middleware = OffsetMiddleware(
        mainAxis: OffsetValue.value(10),
        crossAxis: OffsetValue.value(20),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.appliedOffset, const Offset(20, -10));
      expect(newState.anchorPoints.offset, const Offset(20, -10));
    });

    test('applies mainAxis offset for horizontal placement', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));
      final config = defaultConfig.copyWith(placement: Placement.left);
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.mainAxisOffset, 10);
      expect(data.appliedOffset, const Offset(-10, 0));
      expect(newState.anchorPoints.offset, const Offset(-10, 0));
    });

    test('uses compute callback for dynamic offset', () {
      final middleware = OffsetMiddleware(
        mainAxis: OffsetValue.compute((state) => state.config.overlayHeight! / 2),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data!.mainAxisOffset, 50);
      expect(data.appliedOffset, const Offset(0, -50));
    });

    test('accumulates offset with existing offset', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));
      final state = PositionState.fromConfig(defaultConfig).copyWith(
        anchorPoints: PositionState.fromConfig(defaultConfig).anchorPoints.copyWith(
              offset: const Offset(5, 5),
            ),
      );

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset, const Offset(5, -5));
    });

    test('handles bottom placement correctly', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));
      final config = defaultConfig.copyWith(placement: Placement.bottom);
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.appliedOffset, const Offset(0, 10));
    });

    test('handles right placement correctly', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));
      final config = defaultConfig.copyWith(placement: Placement.right);
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.appliedOffset, const Offset(10, 0));
    });
  });
}
