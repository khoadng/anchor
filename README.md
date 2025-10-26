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

## Contributing

Contributions are welcome! This is a monorepo. Feel free to open issues or submit pull requests on GitHub.
