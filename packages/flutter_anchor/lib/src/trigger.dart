import 'package:flutter/widgets.dart';

import 'controller.dart' show AnchorController;

/// {@template anchor_trigger_mode}
/// Defines what user action triggers the anchor's overlay to show and hide.
///
/// Each trigger mode can have its own specific configuration.
/// {@endtemplate}
sealed class AnchorTriggerMode {
  const AnchorTriggerMode();

  /// {@macro hover_trigger_mode}
  const factory AnchorTriggerMode.hover({
    Duration? waitDuration,
    Duration? debounceDuration,
  }) = HoverTriggerMode;

  /// {@macro tap_trigger_mode}
  const factory AnchorTriggerMode.tap({
    bool? consumeOutsideTap,
  }) = TapTriggerMode;

  /// {@macro secondary_tap_trigger_mode}
  const factory AnchorTriggerMode.secondaryTap({
    bool? consumeOutsideTap,
  }) = SecondaryTapTriggerMode;

  /// {@macro focus_trigger_mode}
  const factory AnchorTriggerMode.focus({
    FocusNode? focusNode,
    bool? dismissOnTapOutside,
  }) = FocusTriggerMode;

  /// {@macro long_press_trigger_mode}
  const factory AnchorTriggerMode.longPress({
    bool? consumeOutsideTap,
  }) = LongPressTriggerMode;

  /// {@macro manual_trigger_mode}
  const factory AnchorTriggerMode.manual() = ManualTriggerMode;
}

/// {@macro anchor_trigger_mode}
/// {@template hover_trigger_mode}
///
/// Shows the anchor's overlay on mouse enter and hides on mouse exit.
///
/// {@endtemplate}
class HoverTriggerMode extends AnchorTriggerMode {
  /// Creates a hover trigger mode.
  const HoverTriggerMode({
    this.waitDuration,
    this.debounceDuration,
  });

  /// The delay before the overlay is shown after the mouse enters.
  ///
  /// Defaults to `Duration.zero`, the overlay shows immediately.
  final Duration? waitDuration;

  /// The delay before hiding the overlay after the mouse exits.
  ///
  /// This debounce duration prevents accidental dismissal when moving the
  /// cursor between the trigger and the overlay content.
  ///
  /// Defaults to 50 milliseconds.
  final Duration? debounceDuration;
}

/// {@macro anchor_trigger_mode}
/// {@template tap_trigger_mode}
///
/// Toggles the anchor's overlay visibility on tap.
///
/// {@endtemplate}
class TapTriggerMode extends AnchorTriggerMode with _ConsumeOutsideTapMixin {
  /// Creates a tap trigger mode.
  const TapTriggerMode({
    this.consumeOutsideTap,
  });

  /// {@macro trigger_mode.consume_outside_tap}
  @override
  final bool? consumeOutsideTap;
}

/// {@macro anchor_trigger_mode}
/// {@template secondary_tap_trigger_mode}
///
/// Toggles the anchor's overlay visibility on secondary tap (right-click).
///
/// {@endtemplate}
class SecondaryTapTriggerMode extends AnchorTriggerMode
    with _ConsumeOutsideTapMixin {
  /// Creates a secondary tap trigger mode.
  const SecondaryTapTriggerMode({
    this.consumeOutsideTap,
  });

  /// {@macro trigger_mode.consume_outside_tap}
  @override
  final bool? consumeOutsideTap;
}

/// {@macro anchor_trigger_mode}
/// {@template manual_trigger_mode}
///
/// The overlay is controlled exclusively via an [AnchorController].
///
/// In this mode, the anchor's child will not respond to any user interaction.
/// Show and hide operations must be performed programmatically using the
/// controller.
/// {@endtemplate}
class ManualTriggerMode extends AnchorTriggerMode {
  /// Creates a manual trigger mode.
  const ManualTriggerMode();
}

/// {@macro anchor_trigger_mode}
/// {@template focus_trigger_mode}
///
/// Shows the overlay when focus is gained and hides when focus is lost.
///
/// {@endtemplate}
class FocusTriggerMode extends AnchorTriggerMode {
  /// Creates a focus trigger mode.
  const FocusTriggerMode({
    this.focusNode,
    this.dismissOnTapOutside,
  });

  /// Optional focus node to listen to. If not provided, a focus node will be
  /// created internally and the child widget will be wrapped in a Focus widget.
  ///
  /// If provided, the user is responsible for attaching this focus node to
  /// their focusable widget (e.g., TextField).
  final FocusNode? focusNode;

  /// Whether tapping outside the overlay should dismiss it by removing focus.
  ///
  /// Defaults to `true`.
  final bool? dismissOnTapOutside;
}

/// {@macro anchor_trigger_mode}
/// {@template long_press_trigger_mode}
///
/// Shows the anchor's overlay when the user performs a long press.
///
/// {@endtemplate}
class LongPressTriggerMode extends AnchorTriggerMode
    with _ConsumeOutsideTapMixin {
  /// Creates a long press trigger mode.
  const LongPressTriggerMode({
    this.consumeOutsideTap,
  });

  /// {@macro trigger_mode.consume_outside_tap}
  @override
  final bool? consumeOutsideTap;
}

mixin _ConsumeOutsideTapMixin on AnchorTriggerMode {
  /// {@template trigger_mode.consume_outside_tap}
  /// Whether a tap outside the overlay is consumed, preventing it from
  /// reaching widgets below.
  ///
  /// Defaults to `false`, allowing taps to propagate to underlying widgets.
  /// {@endtemplate}
  abstract final bool? consumeOutsideTap;
}
