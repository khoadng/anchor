import 'package:anchor/anchor.dart';
import 'package:flutter/rendering.dart';

void main() {
  // Example 1: Basic offset middleware
  _basicExample();

  // Example 2: Using metadata from middleware
  _metadataExample();
}

void _basicExample() {
  // Print example header
  // ignore: avoid_print
  print('=== Basic Example ===');

  // 1. Define the geometry
  const config = PositioningConfig(
    childPosition: Offset(100, 100),
    childSize: Size(50, 50),
    viewportSize: Size(800, 600),
    overlayHeight: 20,
    overlayWidth: 20,
    placement: Placement.top,
  );

  // 2. Define the positioning logic
  const pipeline = PositioningPipeline(
    middlewares: [
      // Add a 10px "gap" between the child and overlay
      OffsetMiddleware(mainAxis: OffsetValue.value(10)),
    ],
  );

  // 3. Run the calculation
  final result = pipeline.run(
    config: config,
  );

  // 4. Get the result
  // The 'OffsetMiddleware' modified the anchorPoints' offset.
  // For 'top' placement, a positive mainAxis moves it up (negative Y).
  // Print final offset
  // ignore: avoid_print
  print('Final offset: ${result.state.anchorPoints.offset}');

  final offsetData = result.metadata.get<OffsetData>();
  // Print offset middleware data
  // ignore: avoid_print
  print('Offset data: $offsetData');
}

void _metadataExample() {
  // Print example header
  // ignore: avoid_print
  print('\n=== Metadata Example ===');

  // Position overlay near top edge to force a flip
  const config = PositioningConfig(
    childPosition: Offset(400, 50), // Near top edge
    childSize: Size(50, 50),
    viewportSize: Size(800, 600),
    overlayHeight: 100,
    overlayWidth: 150,
    placement: Placement.top,
  );

  const pipeline = PositioningPipeline(
    middlewares: [
      FlipMiddleware(),
      ShiftMiddleware(),
    ],
  );

  final result = pipeline.run(config: config);

  // Access middleware metadata
  final flipData = result.metadata.get<FlipData>();
  final shiftData = result.metadata.get<ShiftData>();

  // Print flip data
  // ignore: avoid_print
  print('Was flipped: ${flipData?.wasFlipped}');
  // Print final direction
  // ignore: avoid_print
  print('Final direction: ${flipData?.finalDirection}');
  // Print applied shift
  // ignore: avoid_print
  print('Applied shift: ${shiftData?.shift}');
}
