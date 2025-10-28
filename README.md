# Anchor

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Anchor is a headless overlay toolkit for Flutter. Anchor makes it easy to create tooltips, popovers, context menus, and other floating UI elements in Flutter.

Its core positioning engine is inspired by the powerful JavaScript library [Floating UI](https://floating-ui.com/) and provides a similar, extensible architecture in pure Dart.

-----

## Packages in this Monorepo

| Package | Description | Version |
| :--- | :--- | :--- |
| **`anchor`** | The core positioning engine. A mininal Flutter package that provides the `PositioningPipeline` and all middleware (`Flip`, `Shift`, `Offset`, etc.). | [![pub package](https://img.shields.io/pub/v/anchor.svg)](https://pub.dev/packages/anchor) |
| **`flutter_anchor`** | The core Flutter widgets. Provides `RawAnchor` (for custom logic) and `Anchor` (with built-in triggers) to connect the positioning engine to the widget tree. | [![pub package](https://img.shields.io/pub/v/flutter_anchor.svg)](https://pub.dev/packages/flutter_anchor) |
| **`anchor_ui`** | Provides common UI patterns like `AnchorTooltip`, `AnchorPopover`, and `AnchorContextMenu` built on `flutter_anchor`. | [![pub package](https://img.shields.io/pub/v/anchor_ui.svg)](https://pub.dev/packages/anchor_ui) |

-----


## Which Package Should I Use?

You should import the package that matches your needs:

  * **For common UI behaviors (Tooltips, Popovers, Context Menus):**
    Start with **`anchor_ui`**. This package is headless but provides convenient, easy-to-use abstractions for common UI patterns like `AnchorTooltip` and `AnchorPopover`. Use this if you want the behavior for these components without building the interaction logic from scratch.

  * **For custom UIs (Search suggestions, Menus):**
    Use **`flutter_anchor`**. This package provides the main widgets for connecting an overlay to a child.

      * **`Anchor`**: A high-level widget built on `RawAnchor` that includes built-in trigger logic (tap, hover, focus, manual), animations, and default middlewares. This is the best choice for most custom UIs.

      * **`RawAnchor`**: A low-level widget that only handles positioning. Use this when `Anchor` is not flexible enough and you need full, manual control over the overlay state and complex positioning logic.

  * **For the positioning engine only:**
    Use **`anchor`**. This is the minimal Flutter package that provides *only* the core positioning engine. You should use this if you are building your own overlay and layout widgets from scratch and just need the raw `PositioningPipeline` and middleware to perform the position calculations.

## Contributing

Contributions are welcome! This is a monorepo. Feel free to open issues or submit pull requests on GitHub.


