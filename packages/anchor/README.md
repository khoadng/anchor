# Anchor: Positioning Engine

This is the core positioning engine for the `flutter_anchor` package. It provides a middleware-based pipeline for calculating the optimal position of a floating element (like a tooltip or popover) relative to an anchor element.

This engine is inspired by the powerful JavaScript library [Floating UI](https://floating-ui.com/) and provides a similar, extensible architecture in pure Dart.

-----

## Available Middleware

This engine includes several common middlewares:

  * **`OffsetMiddleware`**: Applies a positional offset, commonly used to add a "gap" between the anchor and the overlay or create custom positional adjustments.
  * **`FlipMiddleware`**: Flips the overlay to the opposite side (e.g., `top` to `bottom`) if it overflows the viewport in its preferred direction.
  * **`ShiftMiddleware`**: Adjusts the overlay's alignment along its cross-axis (e.g., shifting it left or right) to prevent it from overflowing the viewport.
  * **`AutoPlacementMiddleware`**: Automatically chooses the best placement (e.g., `top`, `bottom`, `left`, `right`) based on which side has the most available space.
  * **`SizeMiddleware`**: Calculates and suggests optimal sizes for the overlay based on available space and constraints.
  * **`VirtualReferenceMiddleware`**: Positions the overlay relative to a virtual `Rect` or `Offset` in space (like a cursor position) instead of a physical widget.

-----

## Basic Usage

A typical calculation looks like this:

```dart
import 'package:anchor/position.dart';
import 'package:anchor/middlewares/flip.dart';
import 'package:anchor/middlewares/offset.dart';
import 'package:anchor/middlewares/shift.dart';

// 1. Define the geometric configuration
final config = PositioningConfig(
  childPosition: const Offset(100, 100),
  childSize: const Size(50, 50),
  viewportSize: const Size(800, 600),
  overlayWidth: 150,
  overlayHeight: 75,
  placement: Placement.top,
);

// 2. Create a pipeline with your desired logic
final pipeline = PositioningPipeline(
  middlewares: [
    // Add a 10px gap
    const OffsetMiddleware(mainAxis: 10),
    
    // Flip if it overflows
    const FlipMiddleware(),
    
    // Shift if it still overflows
    const ShiftMiddleware(),
  ],
);

// 3. Run the calculation
// Start by trying to place the overlay on top
final result = pipeline.run(
  config: config,
);

// 4. Use the results
// finalState.anchorPoints contains the final computed anchors and offset.
print(result.state.anchorPoints.offset);
```
