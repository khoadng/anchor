import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  group('Shift', () {
    test('does not shift when overlay fits in viewport', () {
      const middleware = ShiftMiddleware();
      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (newState, data) = middleware.run(state);

      expect(data!.shift, Offset.zero);
      expect(newState.anchorPoints.offset, Offset.zero);
    });

    test('shifts to prevent overflow on each axis', () {
      const middleware = ShiftMiddleware();

      final testCases = [
        (
          description: 'shifts left when overflowing right edge',
          childPosition: childAtRightEdge(childSize, const Offset(10, 0)),
          placement: Placement.top,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dx < 0,
        ),
        (
          description: 'shifts right when overflowing left edge',
          childPosition: childAtLeftEdge(childSize, const Offset(-5, 0)),
          placement: Placement.top,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dx > 0,
        ),
        (
          description: 'shifts down when overflowing top edge',
          childPosition: childAtTopEdge(childSize, const Offset(0, -5)),
          placement: Placement.left,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dy > 0,
        ),
        (
          description: 'shifts up when overflowing bottom edge',
          childPosition: childAtBottomEdge(childSize, const Offset(0, 10)),
          placement: Placement.left,
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dy < 0,
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

        final (newState, _) = middleware.run(state);

        expect(
          testCase.checkOffset(newState),
          isTrue,
          reason: testCase.description,
        );
      }
    });

    test('respects viewport padding when shifting', () {
      const middleware = ShiftMiddleware();

      final testCases = [
        (
          description:
              'shifts left with right padding when overflowing right edge',
          childPosition: childAtRightEdge(childSize, const Offset(10, 0)),
          placement: Placement.top,
          padding: const EdgeInsets.only(right: 20),
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dx < -15,
        ),
        (
          description:
              'shifts right with left padding when overflowing left edge',
          childPosition: childAtLeftEdge(childSize, const Offset(-10, 0)),
          placement: Placement.top,
          padding: const EdgeInsets.only(left: 20),
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dx > 15,
        ),
        (
          description: 'shifts down with top padding when overflowing top edge',
          childPosition: childAtTopEdge(childSize, const Offset(0, -10)),
          placement: Placement.left,
          padding: const EdgeInsets.only(top: 20),
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dy > 15,
        ),
        (
          description:
              'shifts up with bottom padding when overflowing bottom edge',
          childPosition: childAtBottomEdge(childSize, const Offset(0, 10)),
          placement: Placement.left,
          padding: const EdgeInsets.only(bottom: 20),
          checkOffset: (PositionState state) =>
              state.anchorPoints.offset.dy < -15,
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
          padding: testCase.padding,
        );
        final state = PositionState.fromConfig(config);

        final (newState, _) = middleware.run(state);

        expect(
          testCase.checkOffset(newState),
          isTrue,
          reason: testCase.description,
        );
      }
    });

    test('no shift when overlay dimensions missing', () {
      const middleware = ShiftMiddleware();
      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: null,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data!.shift, Offset.zero);
    });
  });
}
