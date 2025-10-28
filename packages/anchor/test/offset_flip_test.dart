import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  group('Flip then Offset', () {
    test('applies offset after flip', () {
      final testCases = [
        (
          description: 'applies both main and cross axis offset after flip',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          mainAxisOffset: 15.0,
          crossAxisOffset: 25.0,
          expectedOffset: const Offset(25, 15),
          expectedFlipped: true,
        ),
        (
          description: 'applies only main axis offset after flip',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          mainAxisOffset: 20.0,
          crossAxisOffset: null,
          expectedOffset: const Offset(0, 20),
          expectedFlipped: true,
        ),
        (
          description: 'applies only cross axis offset after flip',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          mainAxisOffset: null,
          crossAxisOffset: 30.0,
          expectedOffset: const Offset(30, 0),
          expectedFlipped: true,
        ),
      ];

      for (final testCase in testCases) {
        final pipeline = PositioningPipeline(
          middlewares: [
            const FlipMiddleware(),
            OffsetMiddleware(
              mainAxis: testCase.mainAxisOffset != null
                  ? OffsetValue.value(testCase.mainAxisOffset!)
                  : const OffsetValue.value(0),
              crossAxis: testCase.crossAxisOffset != null
                  ? OffsetValue.value(testCase.crossAxisOffset!)
                  : const OffsetValue.value(0),
            ),
          ],
        );

        final config = PositioningConfig(
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          childPosition: testCase.childPosition,
          placement: testCase.placement,
        );

        final result = pipeline.run(config: config);

        expect(
          result.metadata.get<FlipData>()?.wasFlipped,
          testCase.expectedFlipped,
          reason: testCase.description,
        );
        expect(
          result.state.anchorPoints.offset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
      }
    });
  });

  group('Offset then Flip', () {
    test('offset affects flip decision', () {
      final testCases = [
        (
          description: 'negative offset causes flip when at top edge',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          offset: -50.0,
          expectedFlipped: true,
          expectedDirection: AxisDirection.down,
        ),
        (
          description: 'negative offset on left causes flip to right',
          childPosition: childAtLeftEdge(childSize),
          placement: Placement.left,
          offset: -50.0,
          expectedFlipped: true,
          expectedDirection: AxisDirection.right,
        ),
      ];

      for (final testCase in testCases) {
        final pipeline = PositioningPipeline(
          middlewares: [
            OffsetMiddleware(mainAxis: OffsetValue.value(testCase.offset)),
            const FlipMiddleware(),
          ],
        );

        final config = PositioningConfig(
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          childPosition: testCase.childPosition,
          placement: testCase.placement,
        );

        final result = pipeline.run(config: config);

        expect(
          result.metadata.get<FlipData>()?.wasFlipped,
          testCase.expectedFlipped,
          reason: testCase.description,
        );
        expect(
          result.metadata.get<FlipData>()?.finalDirection,
          testCase.expectedDirection,
          reason: testCase.description,
        );
      }
    });

    test('offset maintains spacing after flip', () {
      final testCases = [
        (
          description: 'maintains spacing after vertical flip',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          offset: 50.0,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dy == 50.0,
        ),
        (
          description: 'maintains spacing after horizontal flip',
          childPosition: childAtLeftEdge(childSize),
          placement: Placement.left,
          offset: 30.0,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dx == 30.0,
        ),
      ];

      for (final testCase in testCases) {
        final pipeline = PositioningPipeline(
          middlewares: [
            OffsetMiddleware(mainAxis: OffsetValue.value(testCase.offset)),
            const FlipMiddleware(),
          ],
        );

        final config = PositioningConfig(
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          childPosition: testCase.childPosition,
          placement: testCase.placement,
        );

        final result = pipeline.run(config: config);

        expect(
          result.metadata.get<FlipData>()?.wasFlipped,
          isTrue,
          reason: testCase.description,
        );
        expect(
          testCase.checkOffset(result.state),
          isTrue,
          reason: testCase.description,
        );
      }
    });
  });

  group('Dynamic Offset', () {
    test('computed offset reacts to flip result', () {
      final testCases = [
        (
          description: 'uses larger offset when flipped to below',
          childPosition: childAtTopEdge(childSize),
          placement: Placement.top,
          offsetCompute: (PositionState state) =>
              state.anchorPoints.isBelow ? 30.0 : 10.0,
          expectedFlipped: true,
          expectedOffset: 30.0,
        ),
        (
          description: 'uses different offset when flipped to right',
          childPosition: childAtLeftEdge(childSize),
          placement: Placement.left,
          offsetCompute: (PositionState state) =>
              state.anchorPoints.isRight ? 25.0 : 5.0,
          expectedFlipped: true,
          expectedOffset: 25.0,
        ),
      ];

      for (final testCase in testCases) {
        final pipeline = PositioningPipeline(
          middlewares: [
            const FlipMiddleware(),
            OffsetMiddleware(
              mainAxis: OffsetValue.compute(testCase.offsetCompute),
            ),
          ],
        );

        final config = PositioningConfig(
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          childPosition: testCase.childPosition,
          placement: testCase.placement,
        );

        final result = pipeline.run(config: config);

        expect(
          result.metadata.get<FlipData>()?.wasFlipped,
          testCase.expectedFlipped,
          reason: testCase.description,
        );

        final isVertical = testCase.placement == Placement.top ||
            testCase.placement == Placement.bottom;
        final actualOffset = isVertical
            ? result.state.anchorPoints.offset.dy
            : result.state.anchorPoints.offset.dx;

        expect(
          actualOffset,
          testCase.expectedOffset,
          reason: testCase.description,
        );
      }
    });
  });
}
