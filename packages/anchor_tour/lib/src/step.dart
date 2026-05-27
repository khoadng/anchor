import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'controller.dart';
import 'spotlight.dart';
import 'state.dart';

typedef AnchorTourStepBuilder = Widget Function(
  BuildContext context,
  AnchorTourContext tour,
);

typedef AnchorTourStepCallback = FutureOr<void> Function(
  BuildContext context,
  AnchorTourContext tour,
);

typedef AnchorTourTargetNotFoundCallback = FutureOr<void> Function(
  BuildContext context,
  AnchorTourContext tour,
);

@immutable
class AnchorTourStep {
  const AnchorTourStep({
    required this.id,
    required this.target,
    required this.builder,
    this.enter,
    this.exit,
    this.placement = Placement.bottom,
    this.spacing = 12,
    this.offset,
    this.spotlight,
    this.viewPadding,
    this.scrollBehavior,
    this.middlewares,
  });

  final String id;
  final String target;
  final AnchorTourStepBuilder builder;
  final AnchorTourStepCallback? enter;
  final AnchorTourStepCallback? exit;
  final Placement placement;
  final double spacing;
  final Offset? offset;
  final AnchorTourSpotlight? spotlight;
  final EdgeInsets? viewPadding;
  final AnchorScrollBehavior? scrollBehavior;
  final List<PositioningMiddleware>? middlewares;

  @override
  String toString() => 'AnchorTourStep(id: $id, target: $target)';
}

class AnchorTourContext {
  const AnchorTourContext({
    required this.controller,
    required this.state,
    required this.step,
    required this.hasNext,
    required this.hasPrevious,
    this.targetRect,
    this.overlayRect,
    this.direction,
  });

  final AnchorTourController controller;
  final AnchorTourState state;
  final AnchorTourStep step;
  final Rect? targetRect;
  final Rect? overlayRect;
  final AxisDirection? direction;
  final bool hasNext;
  final bool hasPrevious;

  Future<void> next() => controller.next();

  Future<void> previous() => controller.previous();

  Future<void> skip() => controller.skip();

  Future<void> finish() => controller.finish();
}

typedef AnchorTourStepShownCallback = void Function(
  AnchorTourStep? previous,
  AnchorTourStep current,
);
