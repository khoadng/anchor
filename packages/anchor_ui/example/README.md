# anchor_ui

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Common, high-level UI patterns for the Anchor toolkit. This package provides widgets for common overlay UIs like tooltips, popovers, and context menus.

These widgets are built on top of the `flutter_anchor` package and provide convenient, easy-to-use abstractions for common use cases.

If you need to build a completely custom UI, you may want to use `Anchor` or `RawAnchor` directly from the `flutter_anchor` package.

-----

## What's Included

* **`AnchorTooltip`**: A simple, styled tooltip that appears on hover (or long-press).
* **`AnchorPopover`**: A styled container with a customizable arrow, border, and background, perfect for more complex content.
* **`AnchorContextMenu`**: A complete solution for showing overlays at a virtual "cursor" position.

-----

## Usage

### 1. Simple Tooltip (`AnchorTooltip`)

The easiest way to get started is to wrap your widget with `AnchorTooltip`. It provides sensible defaults, including a hover trigger.

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

### 2. Styled Popover (`AnchorPopover`)

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

### 3. Context Menu (`AnchorContextMenu`)

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
