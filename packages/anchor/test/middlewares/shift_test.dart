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

  group('ShiftMiddleware', () {
    test('no shift when overlay fits in viewport', () {
      const middleware = ShiftMiddleware();
      final state = PositionState.fromConfig(defaultConfig);

      final (newState, data) = middleware.run(state);

      expect(data!.shift, Offset.zero);
      expect(newState.anchorPoints.offset, Offset.zero);
    });

    test('shifts left when overflowing right edge', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(740, 275),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.shift.dx, lessThan(0));
      expect(newState.anchorPoints.offset.dx, lessThan(0));
    });

    test('shifts right when overflowing left edge', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(20, 275),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.shift.dx, greaterThan(0));
      expect(newState.anchorPoints.offset.dx, greaterThan(0));
    });

    test('shifts vertically for horizontal placement', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        placement: Placement.left,
        childPosition: const Offset(375, 20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.shift.dy, greaterThan(0));
      expect(newState.anchorPoints.offset.dy, greaterThan(0));
    });

    test('respects viewport padding', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(740, 275),
        padding: const EdgeInsets.all(20),
      );
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset.dx, lessThan(-15));
    });

    test('handles bottom placement correctly', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        placement: Placement.bottom,
        childPosition: const Offset(20, 275),
      );
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      expect(newState.anchorPoints.offset.dx, greaterThan(0));
    });

    test('no shift when overlay dimensions missing', () {
      const middleware = ShiftMiddleware();
      // Make test clear by explicitly setting overlayWidth to null
      // ignore: avoid_redundant_argument_values
      final config = defaultConfig.copyWith(overlayWidth: null);
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.shift, Offset.zero);
    });

    test('accumulates with existing offset', () {
      const middleware = ShiftMiddleware();
      final config = defaultConfig.copyWith(
        childPosition: const Offset(740, 275),
      );
      final state = PositionState.fromConfig(config).copyWith(
        anchorPoints: PositionState.fromConfig(config).anchorPoints.copyWith(
              offset: const Offset(10, 20),
            ),
      );

      final (newState, data) = middleware.run(state);

      expect(data!.shift.dx, lessThan(0));
      expect(newState.anchorPoints.offset.dx, lessThan(10));
      expect(newState.anchorPoints.offset.dy, 20);
    });
  });
}
