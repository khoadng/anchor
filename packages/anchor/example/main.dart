import 'dart:ui';

import 'package:anchor/anchor.dart';

void main() {
  // 1. Define the geometry
  const config = PositioningConfig(
    childPosition: Offset(100, 100),
    childSize: Size(50, 50),
    viewportSize: Size(800, 600),
    overlayHeight: 20,
    overlayWidth: 20,
  );

  // 2. Define the positioning logic
  const pipeline = PositioningPipeline(
    middlewares: [
      // Add a 10px "gap" between the child and overlay
      OffsetMiddleware(mainAxis: 10),
    ],
  );

  // 3. Run the calculation
  final state = pipeline.run(
    // We want to place the overlay on top of the child
    placement: Placement.top,
    config: config,
  );

  // 4. Get the result
  // The 'OffsetMiddleware' modified the anchorPoints' offset.
  // For 'top' placement, a positive mainAxis moves it up (negative Y).
  // ignore: avoid_print
  print(state.anchorPoints.offset);
}
