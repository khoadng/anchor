import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('flips to left when virtual cursor near right edge', () {
    final cursorNearRight = cursorNearRightEdge();

    final pipeline = PositioningPipeline(
      middlewares: [
        VirtualReferenceMiddleware(cursorNearRight),
        const FlipMiddleware(),
      ],
    );

    const config = PositioningConfig(
      childSize: viewportSize,
      viewportSize: viewportSize,
      overlayHeight: 100,
      overlayWidth: 200,
      childPosition: Offset.zero,
      placement: Placement.rightStart,
    );

    final result = pipeline.run(config: config);

    expect(result.metadata.get<FlipData>()?.wasFlipped, isTrue);
  });

  test('does not flip when virtual cursor at overlay-width boundary', () {
    const testOverlayWidth = 200.0;
    final cursorAtBoundary = cursorAtCenter(
      Offset(viewportSize.width / 2 - testOverlayWidth, 0),
    );

    final pipeline = PositioningPipeline(
      middlewares: [
        VirtualReferenceMiddleware(cursorAtBoundary),
        const FlipMiddleware(),
      ],
    );

    const config = PositioningConfig(
      childSize: viewportSize,
      viewportSize: viewportSize,
      overlayHeight: 100,
      overlayWidth: testOverlayWidth,
      childPosition: Offset.zero,
      placement: Placement.rightStart,
    );

    final result = pipeline.run(config: config);

    expect(result.metadata.get<FlipData>()?.wasFlipped, isFalse);
  });
}
