import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  group('Flip', () {
    test('flips based on child position and available space', () {
      const middleware = FlipMiddleware();

      final testCases = [
        // No flip - child at center with top placement (enough space above)
        (
          description: 'does not flip when preferred direction fits',
          childPosition: childAtCenter(childSize),
          placement: Placement.top,
          expectedFlipped: false,
          expectedDirection: AxisDirection.up,
          checkAnchor: (PositionState state) => state.anchorPoints.isAbove,
        ),
        // Flip vertical - child near top edge with top placement
        (
          description: 'flips to bottom when top does not fit',
          childPosition: childAtTopEdge(childSize, const Offset(0, -5)),
          placement: Placement.top,
          expectedFlipped: true,
          expectedDirection: AxisDirection.down,
          checkAnchor: (PositionState state) => state.anchorPoints.isBelow,
        ),
        // Flip horizontal - child near right edge with right placement
        (
          description: 'flips to left when right does not fit',
          childPosition: childAtRightEdge(childSize, const Offset(5, 0)),
          placement: Placement.right,
          expectedFlipped: true,
          expectedDirection: AxisDirection.left,
          checkAnchor: (PositionState state) => state.anchorPoints.isLeft,
        ),
        // Flip horizontal - child near left edge with left placement
        (
          description: 'flips to right when left does not fit',
          childPosition: childAtLeftEdge(childSize, const Offset(-5, 0)),
          placement: Placement.left,
          expectedFlipped: true,
          expectedDirection: AxisDirection.right,
          checkAnchor: (PositionState state) => state.anchorPoints.isRight,
        ),
        // Flip vertical - child near bottom edge with bottom placement
        (
          description: 'flips to top when bottom does not fit',
          childPosition: childAtBottomEdge(childSize, const Offset(0, 5)),
          placement: Placement.bottom,
          expectedFlipped: true,
          expectedDirection: AxisDirection.up,
          checkAnchor: (PositionState state) => state.anchorPoints.isAbove,
        ),
      ];

      for (final testCase in testCases) {
        final config = PositioningConfig(
          childPosition: testCase.childPosition,
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          placement: testCase.placement,
        );
        final state = PositionState.fromConfig(config);

        final (newState, data) = middleware.run(state);

        expect(
          data!.wasFlipped,
          testCase.expectedFlipped,
          reason: '${testCase.description}: wasFlipped',
        );
        expect(
          data.finalDirection,
          testCase.expectedDirection,
          reason: '${testCase.description}: finalDirection',
        );
        expect(
          testCase.checkAnchor(newState),
          isTrue,
          reason: '${testCase.description}: anchor position',
        );
      }
    });

    test('chooses side with more space when neither fits', () {
      const middleware = FlipMiddleware();
      final config = PositioningConfig(
        childPosition: const Offset(375, 250),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: 300,
        overlayWidth: overlaySize.width,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.finalDirection, AxisDirection.down);
    });

    test('preserves alignment when flipping', () {
      const middleware = FlipMiddleware();
      final config = PositioningConfig(
        childPosition: childAtTopEdge(childSize, const Offset(0, -5)),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.topStart,
      );
      final state = PositionState.fromConfig(config);

      final (newState, _) = middleware.run(state);

      expect(newState.config.placement, Placement.bottomStart);
    });

    test('stays with preferred when opposite also does not fit', () {
      const middleware = FlipMiddleware();
      final config = PositioningConfig(
        childPosition: const Offset(375, 270),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: 300,
        overlayWidth: overlaySize.width,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.finalDirection, AxisDirection.down);
    });
  });
}
