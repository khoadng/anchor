
# Anchor

  ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A package for building highly-customizable overlay UIs. `flutter_anchor` makes it easy to create tooltips, popovers, menus, and more. Its core positioning engine is inspired by the powerful JavaScript library [Floating UI](https://floating-ui.com/).

-----

## Usage

### 1\. Simple Tooltip (`AnchorTooltip`)

The easiest way to get started is to wrap your widget with `AnchorTooltip`.

```dart
AnchorTooltip(
  message: const Text(
    'This is a simple tooltip',
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.grey[800],
  arrowShape: const RoundedArrow(),
  child: const Icon(Icons.info),
)
```

### 2\. Styled Popover (`AnchorPopover`)

For more complex content, use `AnchorPopover`. It provides a styled container with an arrow, border, and background color.

```dart
AnchorPopover(
  // Show the popover on tap
  triggerMode: const AnchorTriggerMode.tap(),
  placement: Placement.bottom,
  overlayWidth: 250,
  // Use a built-in arrow shape
  arrowShape: const RoundedArrow(),
  backgroundColor: Colors.white,
  border: BorderSide(color: Colors.grey[300]!),
  
  // Build your custom overlay content
  overlayBuilder: (context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('This is a styled popover!'),
        ElevatedButton(
          onPressed: () {},
          child: const Text('A Button'),
        ),
      ],
    ),
  ),
  
  // The widget that triggers the popover
  child: ElevatedButton(
    child: const Text('Tap Me'),
    onPressed: () {},
  ),
)
```

### 3\. Full Control (`Anchor`)

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

Use `AnchorTriggerMode.manual` and an `AnchorController` to show/hide overlays programmatically.

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

### 4\. Context Menu (`AnchorContextMenu`)

Use `AnchorContextMenu` to show a menu at a specific screen coordinate, such as a cursor position.

```dart
// 1. Wrap your main content area
AnchorContextMenu(
  menuBuilder: (context) {
    // 3. Build your menu
    return Material(
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Copy'),
            onTap: () => context.hideMenu(),
          ),
          ListTile(
            title: const Text('Paste'),
            onTap: () => context.hideMenu(),
          ),
        ],
      ),
    );
  },
  // 2. Add a gesture detector to show the menu
  childBuilder: (context) => GestureDetector(
    onSecondaryTapDown: (event) {
      // Show the menu at the global cursor position
      context.showMenu(event.globalPosition);
    },
    onLongPressStart: (details) {
      // Also show for long-press on mobile
      context.showMenu(details.globalPosition);
    },
    child: Container(
      color: Colors.grey[100],
      child: const Center(child: Text('Right-click or long-press me')),
    ),
  ),
)
```

-----

## Advanced Customization

### Positioning Middleware

While `AnchorTooltip` and `AnchorPopover` or `Anchor` handle common cases, the base `RawAnchor` widget gives you full control over the positioning logic via a **middleware pipeline**.
This system allows you to compose a list of behaviors that run in order to compute the final position of the overlay. You can implement a custom middleware by extending the `PositioningMiddleware` class to create your own placement logic.

```dart
final _controller = AnchorController();

RawAnchor(
  // A controller to manage the overlay state
  controller: _controller,

  // This is the initial, preferred placement
  placement: Placement.top,

  // Define the middleware pipeline
  middlewares: const [
    // 1. Add a 10px gap between the child and overlay
    OffsetMiddleware(mainAxis: 10),
    
    // 2. If it overflows, try Placement.bottom
    FlipMiddleware(preferredDirection: AxisDirection.up),
    
    // 3. If it still overflows (e.g., on the sides), shift it
    ShiftMiddleware(preferredDirection: AxisDirection.up),
  ],

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
)
```

### Backdrop

You can create a backdrop (like a modal barrier or blur filter) by providing a `backdropBuilder`.

```dart
AnchorPopover(
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

// See the `grid_demo.dart` file for the `_BackdropClipper` implementation.
```


## Demos

This package can be used to build a wide variety of common UI patterns.

| Demo                 | Description                                                              |
| :------------------- | :----------------------------------------------------------------------- |
| **Wikipedia Links** | Hover over links to show a rich preview card, just like on Wikipedia.    |
| **Search Autocomplete**| Display a list of suggestions when a `TextField` gains focus.            |
| **Chat Reactions** | Show an emoji reaction bar on hover, just like in MS Teams or Slack.     |
| **Desktop UI** | Build macOS-style menu bars (manual click) and dock tooltips (hover).    |
| **Grid Popovers** | Tap grid items to show a detailed popover with a beautiful blur backdrop. |
| **Context Menus** | Open a menu at the cursor's position on right-click or long-press.       |


## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests on GitHub.
