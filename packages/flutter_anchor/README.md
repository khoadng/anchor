# flutter_anchor

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Core Flutter widgets for the Anchor overlay system. This package provides the foundational widgets (`Anchor`, `RawAnchor`) for connecting a floating overlay to an anchor widget.

**Note:** This package provides the core *functionality* (triggers, positioning) but *no* default styling. If you are looking for common pre-styled containers, like tooltips with arrows, see the **[`anchor_ui`](../anchor_ui) package.**

-----

## What's Included

* **`Anchor`**: A high-level widget that includes built-in trigger logic (tap, hover, focus, manual).
* **`RawAnchor`**: A low-level widget that only handles positioning. It gives you full control over the overlay state and requires you to provide your own positioning middleware.
* **`AnchorContextMenu`**: A solution for showing overlays at a virtual "cursor" position.
* **`AnchorMiddlewares`**: An `InheritedWidget` that provides custom `PositioningMiddleware` to `RawAnchor` widgets.

-----

## Usage

### 1. Full Control (`Anchor`)

The base `Anchor` widget gives you full control over triggers and appearance.

#### Focus Trigger (e.g., Search Bar)

Use `AnchorTriggerMode.focus` to show an overlay when a `TextField` is focused.

```dart
final _focusNode = FocusNode();

Anchor(
  triggerMode: AnchorTriggerMode.focus(focusNode: _focusNode),
  placement: Placement.bottom,
  // The overlay doesn't have any default styling
  overlayBuilder: (context) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        children: const [
          ListTile(title: Text('Suggestion 1')),
          ListTile(title: Text('Suggestion 2')),
        ],
      ),
    );
  },
  child: TextField(
    focusNode: _focusNode,
    decoration: const InputDecoration(hintText: 'Search...'),
  ),
)
```

#### Manual Trigger (e.g., Menu Bar)

Use an `AnchorController` to show/hide overlays programmatically.

```dart
final _controller = AnchorController();

Anchor(
  controller: _controller,
  triggerMode: const AnchorTriggerMode.manual(),
  placement: Placement.bottomStart,
  overlayBuilder: (context) => _buildMenuContent(),
  child: IconButton(
    icon: const Icon(Icons.menu),
    // Toggle the menu on button press
    onPressed: () => _controller.toggle(),
  ),
)
```

-----

## Advanced Customization

### Custom Positioning (`RawAnchor`)

While `Anchor` handles common cases, you can use `RawAnchor` and `AnchorMiddlewares` to compose a custom positioning pipeline.

```dart
final _controller = AnchorController();

// Wrap your RawAnchor with AnchorMiddlewares to define custom positioning
AnchorMiddlewares(
  middlewares: const [
    // 1. Add a 10px gap between the child and overlay
    OffsetMiddleware(mainAxis: 10),

    // 2. If it overflows, try the opposite side
    FlipMiddleware(),

    // 3. If it still overflows (e.g., on the sides), shift it
    ShiftMiddleware(),
  ],
  child: RawAnchor(
    // A controller to manage the overlay state
    controller: _controller,

    // This is the initial, preferred placement
    placement: Placement.top,

    overlayBuilder: (context) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black,
        child: const Text('My Overlay', style: TextStyle(color: Colors.white)),
      );
    },
    child: ElevatedButton(
      onPressed: () {},
      child: const Text('Tap Me'),
    ),
  ),
)
```

#### Avoiding Keyboard and System UI

When using `Anchor` with text fields, you'll often want the overlay to avoid the on-screen keyboard and system UI elements (status bar, navigation bar). Use the `viewPadding` parameter to define safe areas.

**Important:** Due to how Flutter's `OverlayPortal` works, overlays are rendered in a separate layer that doesn't receive keyboard insets from `MediaQuery`. You must read these values **before** the overlay layer and pass them explicitly.

```dart
@override
Widget build(BuildContext context) {
  // Read MediaQuery values at the Scaffold level (before entering OverlayPortal)
  final viewPadding = MediaQuery.viewPaddingOf(context);
  final viewInsets = MediaQuery.viewInsetsOf(context);

  // Combine both to avoid system UI AND keyboard
  final padding = viewPadding + viewInsets;

  return Scaffold(
    body: Center(
      child: Anchor(
        // Pass the padding to keep overlay away from edges and keyboard
        viewPadding: padding,
        overlayBuilder: (context) => _buildOverlayContent(),
      ),
    ),
  );
}
```

### Backdrop

You can create a backdrop (like a modal barrier or blur filter) by providing a `backdropBuilder` to `Anchor` or `RawAnchor`.

```dart
Anchor(
  // ... other properties
  backdropBuilder: (context) => ClipPath(
    // Clip a "hole" where the child widget is
    clipper: _BackdropClipper(
      exclude: AnchorData.of(context).geometry.childBounds,
      excludeRadius: BorderRadius.circular(8),
    ),
    // Apply a blur filter to the entire backdrop
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(color: Colors.black26),
    ),
  ),
  child: YourGridItem(),
)
```

## Demos


| Demo | Description |
| :--- | :--- |
| **Search Autocomplete**| Display a list of suggestions when a `TextField` gains focus. |
| **Chat Reactions** | Show an emoji reaction bar on hover, just like in MS Teams or Slack. |
