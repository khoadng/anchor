import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  const viewportSize = Size(800, 600);
  const overlaySize = Size(100, 100);
  const childSize = Size(50, 50);

  // A default config with the child in the center
  final defaultConfig = PositioningConfig(
    childPosition: const Offset(375, 275), // Center of 800x600
    childSize: childSize,
    viewportSize: viewportSize,
    overlayHeight: overlaySize.height,
    overlayWidth: overlaySize.width,
  );

  group('Basic Middleware Tests', () {
    test('OffsetMiddleware adds mainAxis gap', () {
      const middleware = OffsetMiddleware(mainAxis: 10);
      final initialState = PositionState.fromPlacement(
        Placement.top,
        defaultConfig,
      );

      final (state, _) = middleware.run(initialState);

      // For `top` placement, mainAxis is vertical.
      // -10 moves it "away" from the child (upwards).
      expect(state.anchorPoints.offset, const Offset(0, -10));
    });

    test('FlipMiddleware flips when preferredDirection does not fit', () {
      const middleware = FlipMiddleware(
        preferredDirection: AxisDirection.up,
      );

      // Child placed near top edge to force a flip
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20), // Only 20px of space above
      );
      final initialState = PositionState.fromPlacement(Placement.top, config);

      final (state, _) = middleware.run(initialState);

      // It should flip from 'up' (isAbove) to 'down' (isBelow)
      expect(state.anchorPoints.isAbove, isFalse);
      expect(state.anchorPoints.isBelow, isTrue);
    });

    test('ShiftMiddleware shifts to stay in viewport', () {
      const middleware = ShiftMiddleware(
        preferredDirection: AxisDirection.up,
      );

      // Child placed near right edge to force a shift
      // Placement.top centers the 100px overlay, which would overflow
      final config = defaultConfig.copyWith(
        childPosition: const Offset(740, 275), // 740 + 25 (half child) = 765
      );
      final initialState = PositionState.fromPlacement(Placement.top, config);

      // Logic:
      // Child center = 740 + 25 = 765
      // Overlay center = 50 (half overlay)
      // Overlay starts at 765 - 50 = 715
      // Overlay ends at 715 + 100 = 815
      // Viewport ends at 800. Overflow = 15.
      // Shift should be -15.
      final (state, _) = middleware.run(initialState);

      expect(state.anchorPoints.offset, const Offset(-15, 0));
    });

    test('AutoPlacementMiddleware chooses direction with most space', () {
      const middleware = AutoPlacementMiddleware(
        allowedPlacements: [Placement.top, Placement.bottom, Placement.left],
      );

      // Child placed near top edge (20px space)
      final config = defaultConfig.copyWith(
        childPosition: const Offset(375, 20),
      );
      // Spaces: above: 20, below: 530, left: 375
      final initialState = PositionState.fromPlacement(Placement.top, config);

      final (state, _) = middleware.run(initialState);

      // It should choose 'bottom' as it has the most space (530px)
      expect(state.anchorPoints.isBelow, isTrue);
    });

    test('VirtualReferenceMiddleware updates offset and explicitSpaces', () {
      const virtualPoint = Offset(50, 60);
      const middleware = VirtualReferenceMiddleware(
        VirtualReference.fromPoint(virtualPoint),
      );

      // Initial state uses default config (child at 375, 275)
      final initialState = PositionState.fromPlacement(
        Placement.topStart,
        defaultConfig,
      );

      final (state, _) = middleware.run(initialState);

      // 1. Check if the offset was calculated correctly to move the overlay
      // from the child's position (375, 275) to the virtual point (50, 60).
      final expectedOffset = Offset(
        virtualPoint.dx - defaultConfig.childPosition.dx,
        virtualPoint.dy - defaultConfig.childPosition.dy,
      );
      expect(state.anchorPoints.offset, expectedOffset);

      // 2. Check if it set new spaces based on the virtual point
      final spaces = state.config.spaces;
      expect(spaces.above, 60);
      expect(spaces.left, 50);
      expect(spaces.below, viewportSize.height - 60); // 600 - 60 = 540
      expect(spaces.right, viewportSize.width - 50); // 800 - 50 = 750
    });
  });

  group('PositioningPipeline 4-Corners Test (Flip + Shift)', () {
    // This pipeline tries to place 'top', then flips, then shifts.
    const pipeline = PositioningPipeline(
      middlewares: [
        FlipMiddleware(preferredDirection: AxisDirection.up),
        ShiftMiddleware(preferredDirection: AxisDirection.up),
      ],
    );

    // Config for a small child and 100x100 overlay
    final config = PositioningConfig(
      childSize: const Size(10, 10),
      viewportSize: viewportSize,
      overlayHeight: overlaySize.height,
      overlayWidth: overlaySize.width,
      childPosition: const Offset(395, 295),
    );

    test('top-left corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(10, 10),
      );
      final result = pipeline.run(
        placement: Placement.top,
        config: cornerConfig,
      );

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
      final result = pipeline.run(
        placement: Placement.top,
        config: cornerConfig,
      );

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
      final result = pipeline.run(
        placement: Placement.top,
        config: cornerConfig,
      );

      // 1. Flips: 'top' (580px) has enough space, so it stays 'top'.
      expect(result.state.anchorPoints.isAbove, isTrue);
      // 2. Shifts: Same as top-left case. Shifts right by 35.
      expect(result.state.anchorPoints.offset.dx, 35);
    });

    test('bottom-right corner', () {
      final cornerConfig = config.copyWith(
        childPosition: const Offset(780, 580),
      );
      final result = pipeline.run(
        placement: Placement.top,
        config: cornerConfig,
      );

      // 1. Flips: 'top' (580px) has enough space, so it stays 'top'.
      expect(result.state.anchorPoints.isAbove, isTrue);
      // 2. Shifts: Same as top-right case. Shifts left by -35.
      expect(result.state.anchorPoints.offset.dx, -35);
    });
  });
}
