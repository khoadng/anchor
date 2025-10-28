import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  group('AutoPlacement', () {
    test('chooses placement with most space', () {
      const middleware = AutoPlacementMiddleware();

      final testCases = [
        (
          description: 'chooses bottom when child is near top edge',
          childPosition: childAtTopEdge(childSize, const Offset(0, -20)),
          expectedPlacement: Placement.bottom,
          checkState: (PositionState state) => state.anchorPoints.isBelow,
        ),
        (
          description: 'chooses top when child is near bottom edge',
          childPosition: childAtBottomEdge(childSize, const Offset(0, 20)),
          expectedPlacement: Placement.top,
          checkState: (PositionState state) => state.anchorPoints.isAbove,
        ),
        (
          description: 'chooses left when child is near right edge',
          childPosition: childAtRightEdge(childSize, const Offset(20, 0)),
          expectedPlacement: Placement.left,
          checkState: (PositionState state) => state.anchorPoints.isLeft,
        ),
        (
          description: 'chooses right when child is near left edge',
          childPosition: childAtLeftEdge(childSize, const Offset(-20, 0)),
          expectedPlacement: Placement.right,
          checkState: (PositionState state) => state.anchorPoints.isRight,
        ),
      ];

      for (final testCase in testCases) {
        final config = PositioningConfig(
          childPosition: testCase.childPosition,
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          placement: Placement.top,
        );
        final state = PositionState.fromConfig(config);

        final (newState, data) = middleware.run(state);

        expect(
          data!.chosenPlacement,
          testCase.expectedPlacement,
          reason: testCase.description,
        );
        expect(
          testCase.checkState(newState),
          isTrue,
          reason: testCase.description,
        );
      }
    });

    test('respects allowed placements list', () {
      const middleware = AutoPlacementMiddleware(
        allowedPlacements: [Placement.left, Placement.right],
      );
      final config = PositioningConfig(
        childPosition: childAtTopEdge(childSize, const Offset(0, -20)),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.chosenPlacement, anyOf(Placement.left, Placement.right));
    });
  });
}
