import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  const viewportSize = Size(800, 600);
  const overlaySize = Size(100, 100);

  group('PositioningPipeline 4-Corners Test (Flip + Shift)', () {
    // This pipeline tries to place 'top', then flips, then shifts.
    const pipeline = PositioningPipeline(
      middlewares: [
        FlipMiddleware(),
        ShiftMiddleware(),
      ],
    );

    // Config for a small child and 100x100 overlay
    final config = PositioningConfig(
      childSize: const Size(10, 10),
      viewportSize: viewportSize,
      overlayHeight: overlaySize.height,
      overlayWidth: overlaySize.width,
      childPosition: const Offset(395, 295),
      placement: Placement.top,
    );

    test('top-left corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(10, 10),
      );
      final result = pipeline.run(config: cornerConfig);

      // 1. Flips: 'top' (10px) is not enough space, so it flips 'down'.
      expect(result.state.anchorPoints.isBelow, isTrue);
      // 2. Shifts: 'top' placement tries to center.
      //    Child center-x = 15. Overlay center-x = 50.
      //    Overlay start-x = 15 - 50 = -35.
      //    Overflows left by 35. Shifts right by 35.
      expect(result.state.anchorPoints.offset.dx, 35);
    });

    test('top-right corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(780, 10), // 800 - 10 - 10
      );
      final result = pipeline.run(config: cornerConfig);

      // 1. Flips: 'top' (10px) is not enough space, so it flips 'down'.
      expect(result.state.anchorPoints.isBelow, isTrue);
      // 2. Shifts: 'top' placement tries to center.
      //    Child center-x = 785. Overlay center-x = 50.
      //    Overlay start-x = 785 - 50 = 735.
      //    Overlay end-x = 735 + 100 = 835.
      //    Overflows right by 35. Shifts left by -35.
      expect(result.state.anchorPoints.offset.dx, -35);
    });

    test('bottom-left corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(10, 580), // 600 - 10 - 10
      );
      final result = pipeline.run(config: cornerConfig);

      // 1. Flips: 'top' (580px) has enough space, so it stays 'top'.
      expect(result.state.anchorPoints.isAbove, isTrue);
      // 2. Shifts: Same as top-left case. Shifts right by 35.
      expect(result.state.anchorPoints.offset.dx, 35);
    });

    test('bottom-right corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(780, 580),
      );
      final result = pipeline.run(config: cornerConfig);

      // 1. Flips: 'top' (580px) has enough space, so it stays 'top'.
      expect(result.state.anchorPoints.isAbove, isTrue);
      // 2. Shifts: Same as top-right case. Shifts left by -35.
      expect(result.state.anchorPoints.offset.dx, -35);
    });
  });

  group('PositioningPipeline Flip + Offset', () {
    test('flip then offset both axes', () {
      const pipeline = PositioningPipeline(
        middlewares: [
          FlipMiddleware(),
          OffsetMiddleware(
            mainAxis: OffsetValue.value(15),
            crossAxis: OffsetValue.value(25),
          ),
        ],
      );

      final config = PositioningConfig(
        childSize: const Size(10, 10),
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        childPosition: const Offset(395, 50),
        placement: Placement.top,
      );

      final result = pipeline.run(config: config);

      expect(result.state.anchorPoints.isBelow, isTrue);
      expect(result.state.anchorPoints.offset, const Offset(25, 15));
    });

    test('offset before flip affects flip decision', () {
      const pipeline = PositioningPipeline(
        middlewares: [
          OffsetMiddleware(mainAxis: OffsetValue.value(-50)),
          FlipMiddleware(),
        ],
      );

      final config = PositioningConfig(
        childSize: const Size(10, 10),
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        childPosition: const Offset(395, 120),
        placement: Placement.top,
      );

      final result = pipeline.run(config: config);

      // Offset pulls overlay 50px further up, causing overflow and flip
      expect(result.state.anchorPoints.isBelow, isTrue);
    });

    test('dynamic offset based on flip result', () {
      final pipeline = PositioningPipeline(
        middlewares: [
          const FlipMiddleware(),
          OffsetMiddleware(
            mainAxis: OffsetValue.compute((state) {
              // Add different offset based on whether we flipped
              return state.anchorPoints.isBelow ? 30.0 : 10.0;
            }),
          ),
        ],
      );

      final config = PositioningConfig(
        childSize: const Size(10, 10),
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        childPosition: const Offset(395, 50),
        placement: Placement.top,
      );

      final result = pipeline.run(config: config);

      expect(result.state.anchorPoints.isBelow, isTrue);
      // Should use 30px offset since it flipped to below
      expect(result.state.anchorPoints.offset.dy, 30);
    });

    test('offset maintains spacing after flip (not pushed into child)', () {
      const pipeline = PositioningPipeline(
        middlewares: [
          OffsetMiddleware(mainAxis: OffsetValue.value(50)),
          FlipMiddleware(),
        ],
      );

      final config = PositioningConfig(
        childSize: const Size(10, 10),
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        childPosition: const Offset(395, 80),
        placement: Placement.top,
      );

      final result = pipeline.run(config: config);

      // Should flip to below because:
      // - top has 80px space
      // - offset pushes 50px further up (away from child)
      // - total needed: 100 + 50 = 150px
      // - doesn't fit, so flips to below
      expect(result.state.anchorPoints.isBelow, isTrue);

      // CRITICAL: After flipping to below, the offset should maintain
      // 50px spacing AWAY from the child (positive Y direction when below)
      // NOT -50px which would push the overlay INTO the child
      expect(
        result.state.anchorPoints.offset.dy,
        50,
        reason: 'Offset should maintain spacing away from child after flip',
      );

      // Verify the overlay is actually positioned below the child
      // Child bottom = 80 + 10 = 90
      // Overlay should start at 90 + 50 = 140
      final childBottom = config.childPosition.dy + config.childSize.height;
      final expectedOverlayTop =
          childBottom + result.state.anchorPoints.offset.dy;
      expect(expectedOverlayTop, 140);
    });

    test('negative offset maintains inward spacing after flip', () {
      // Test that negative offsets (moving toward child) also maintain
      // their semantic meaning after flip
      const pipeline = PositioningPipeline(
        middlewares: [
          OffsetMiddleware(mainAxis: OffsetValue.value(-30)),
          FlipMiddleware(),
        ],
      );

      final config = PositioningConfig(
        childSize: const Size(10, 10),
        viewportSize: viewportSize,
        overlayHeight: overlaySize.height,
        overlayWidth: overlaySize.width,
        childPosition: const Offset(395, 50),
        placement: Placement.top,
      );

      final result = pipeline.run(config: config);

      // Should flip to below because:
      // - top has 50px space
      // - negative offset moves 30px closer to child (reduces needed space)
      // - total needed: 100 - 30 = 70px
      // - still doesn't fit (50 < 70), so flips
      expect(result.state.anchorPoints.isBelow, isTrue);

      // After flipping, negative offset should still mean "toward child"
      // When below, that's negative Y direction
      expect(
        result.state.anchorPoints.offset.dy,
        -30,
        reason: 'Negative offset should maintain inward direction after flip',
      );
    });
  });
}
