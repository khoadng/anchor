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

  group('Offset', () {
    test('applies mainAxis offset for different placements', () {
      const middleware = OffsetMiddleware(mainAxis: OffsetValue.value(10));

      final testCases = [
        (
          description: 'top placement moves overlay up',
          placement: Placement.top,
          expectedOffset: const Offset(0, -10),
        ),
        (
          description: 'bottom placement moves overlay down',
          placement: Placement.bottom,
          expectedOffset: const Offset(0, 10),
        ),
        (
          description: 'left placement moves overlay left',
          placement: Placement.left,
          expectedOffset: const Offset(-10, 0),
        ),
        (
          description: 'right placement moves overlay right',
          placement: Placement.right,
          expectedOffset: const Offset(10, 0),
        ),
      ];

      for (final testCase in testCases) {
        final config = defaultConfig.copyWith(placement: testCase.placement);
        final state = PositionState.fromConfig(config);

        final (newState, data) = middleware.run(state);

        expect(
          data!.appliedOffset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
        expect(
          newState.anchorPoints.offset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
      }
    });

    test('applies crossAxis offset for different placements', () {
      const middleware = OffsetMiddleware(crossAxis: OffsetValue.value(15));

      final testCases = [
        (
          description: 'top placement moves overlay horizontally',
          placement: Placement.top,
          expectedOffset: const Offset(15, 0),
        ),
        (
          description: 'bottom placement moves overlay horizontally',
          placement: Placement.bottom,
          expectedOffset: const Offset(15, 0),
        ),
        (
          description: 'left placement moves overlay vertically',
          placement: Placement.left,
          expectedOffset: const Offset(0, 15),
        ),
        (
          description: 'right placement moves overlay vertically',
          placement: Placement.right,
          expectedOffset: const Offset(0, 15),
        ),
      ];

      for (final testCase in testCases) {
        final config = defaultConfig.copyWith(placement: testCase.placement);
        final state = PositionState.fromConfig(config);

        final (newState, data) = middleware.run(state);

        expect(
          data!.appliedOffset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
        expect(
          newState.anchorPoints.offset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
      }
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

    test('uses compute callback for dynamic offset', () {
      final middleware = OffsetMiddleware(
        mainAxis:
            OffsetValue.compute((state) => state.config.overlayHeight! / 2),
      );
      final state = PositionState.fromConfig(defaultConfig);

      final (_, data) = middleware.run(state);

      expect(data!.mainAxisOffset, 50);
      expect(data.appliedOffset, const Offset(0, -50));
    });
  });
}
