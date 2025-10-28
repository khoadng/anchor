import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  group('Size', () {
    test('calculates available dimensions for centered overlay', () {
      const middleware = SizeMiddleware();

      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.bottom,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.availableWidth, greaterThan(0));
      expect(data.availableHeight, greaterThan(0));
    });

    test('respects viewport padding when calculating available space', () {
      const middleware = SizeMiddleware();
      const padding = EdgeInsets.all(20);

      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.bottom,
        padding: padding,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      // Available space should be less than or equal to viewport minus padding
      expect(
        data!.availableWidth,
        lessThanOrEqualTo(viewportSize.width - padding.horizontal),
      );
      expect(
        data.availableHeight,
        lessThanOrEqualTo(viewportSize.height - padding.vertical),
      );
    });

    test('calculates correct dimensions for top placement', () {
      const middleware = SizeMiddleware();

      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.top,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.availableWidth, greaterThan(0));
      expect(data.availableHeight, greaterThan(0));
    });

    test('calculates correct dimensions for left placement', () {
      const middleware = SizeMiddleware();

      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.left,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.availableWidth, greaterThan(0));
      expect(data.availableHeight, greaterThan(0));
    });

    test('calculates correct dimensions for right placement', () {
      const middleware = SizeMiddleware();

      final config = PositioningConfig(
        childPosition: childAtCenter(childSize),
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.right,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(data!.availableWidth, greaterThan(0));
      expect(data.availableHeight, greaterThan(0));
    });

    test('handles edge cases near viewport boundaries', () {
      const middleware = SizeMiddleware();

      final testCases = [
        (
          description: 'child near top edge',
          childPosition: childAtTopEdge(childSize, Offset.zero),
          placement: Placement.top,
        ),
        (
          description: 'child near bottom edge',
          childPosition: childAtBottomEdge(childSize, Offset.zero),
          placement: Placement.bottom,
        ),
        (
          description: 'child near left edge',
          childPosition: childAtLeftEdge(childSize, Offset.zero),
          placement: Placement.left,
        ),
        (
          description: 'child near right edge',
          childPosition: childAtRightEdge(childSize, Offset.zero),
          placement: Placement.right,
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

        final (_, data) = middleware.run(state);

        expect(
          data,
          isNotNull,
          reason: '${testCase.description}: data should not be null',
        );
        expect(
          data!.availableWidth,
          greaterThan(0),
          reason: '${testCase.description}: availableWidth',
        );
        expect(
          data.availableHeight,
          greaterThan(0),
          reason: '${testCase.description}: availableHeight',
        );
      }
    });

    test('works with aligned placements', () {
      const middleware = SizeMiddleware();

      final alignedPlacements = [
        Placement.topStart,
        Placement.topEnd,
        Placement.bottomStart,
        Placement.bottomEnd,
        Placement.leftStart,
        Placement.leftEnd,
        Placement.rightStart,
        Placement.rightEnd,
      ];

      for (final placement in alignedPlacements) {
        final config = PositioningConfig(
          childPosition: childAtCenter(childSize),
          childSize: childSize,
          viewportSize: viewportSize,
          overlayHeight: overlaySize.height,
          overlayWidth: overlaySize.width,
          placement: placement,
        );
        final state = PositionState.fromConfig(config);

        final (_, data) = middleware.run(state);

        expect(
          data,
          isNotNull,
          reason: '$placement: data should not be null',
        );
        expect(
          data!.availableWidth,
          greaterThan(0),
          reason: '$placement: availableWidth',
        );
        expect(
          data.availableHeight,
          greaterThan(0),
          reason: '$placement: availableHeight',
        );
      }
    });

    test('available dimensions never exceed viewport size', () {
      const middleware = SizeMiddleware();

      final config = PositioningConfig(
        childPosition: Offset.zero,
        childSize: childSize,
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        placement: Placement.bottomEnd,
      );
      final state = PositionState.fromConfig(config);

      final (_, data) = middleware.run(state);

      expect(data, isNotNull);
      expect(
        data!.availableWidth,
        lessThanOrEqualTo(viewportSize.width),
      );
      expect(
        data.availableHeight,
        lessThanOrEqualTo(viewportSize.height),
      );
    });
  });
}
