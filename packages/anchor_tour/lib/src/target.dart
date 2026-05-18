import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import 'diagnostics.dart';
import 'scope.dart';
import 'spotlight.dart';
import 'step.dart';

class AnchorTourTarget extends StatefulWidget {
  const AnchorTourTarget({
    super.key,
    required this.id,
    this.enabled = true,
    required this.child,
  });

  final String id;
  final bool enabled;
  final Widget child;

  @override
  State<AnchorTourTarget> createState() => _AnchorTourTargetState();
}

class _AnchorTourTargetState extends State<AnchorTourTarget> {
  final AnchorController _anchorController = AnchorController();

  AnchorTourScopeState? _scope;
  AnchorTourTargetRegistration? _registration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextScope = AnchorTourHost.maybeOf(context);
    if (_scope != nextScope) {
      _unregister();
      _scope = nextScope;
      _register();
    }
  }

  @override
  void didUpdateWidget(covariant AnchorTourTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _unregister();
      _register();
    } else if (oldWidget.enabled != widget.enabled) {
      _unregister();
      _register();
    }
  }

  @override
  void dispose() {
    _unregister();
    _anchorController.dispose();
    super.dispose();
  }

  void _register() {
    final scope = _scope;
    if (scope == null) return;
    if (_registration != null) return;
    final registration = AnchorTourTargetRegistration(
      id: widget.id,
      enabled: widget.enabled,
      hideOverlay: _anchorController.hide,
    );
    _registration = registration;
    scope.registerTarget(registration);
  }

  void _unregister() {
    final registration = _registration;
    if (registration == null) return;
    _scope?.unregisterTarget(registration);
    _registration = null;
  }

  void _syncOverlay(AnchorTourStep? step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (step != null && widget.enabled) {
        _anchorController.show();
      } else {
        _anchorController.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = _scope;
    final step = widget.enabled ? scope?.stepForTarget(widget.id) : null;
    _syncOverlay(step);

    if (scope == null || step == null) {
      return widget.child;
    }

    return Anchor(
      controller: _anchorController,
      triggerMode: const AnchorTriggerMode.manual(),
      placement: step.placement,
      spacing: step.spacing,
      viewPadding: step.viewPadding ?? _defaultViewPadding(context),
      scrollBehavior: step.scrollBehavior,
      middlewares: step.middlewares ?? _defaultMiddlewares(step),
      transitionDuration: Duration.zero,
      onShow: () => _markOverlayShownAfterLayout(scope, step),
      backdropBuilder: (context) {
        final data = AnchorData.of(context);
        return IgnorePointer(
          ignoring: !scope.isStepInteractive(step),
          child: AnchorTourSpotlightBackdrop(
            targetRect: data.geometry.childBounds,
            spotlight: step.spotlight ?? AnchorTourSpotlight.defaults,
          ),
        );
      },
      overlayBuilder: (context) {
        final data = AnchorData.of(context);
        try {
          final content = step.builder(
            context,
            AnchorTourContext(
              controller: scope.widget.controller,
              state: scope.widget.controller.value,
              step: step,
              targetRect: data.geometry.childBounds,
              overlayRect: data.geometry.overlayBounds,
              direction: data.geometry.direction,
              hasNext: scope.hasNextStep(step),
              hasPrevious: scope.hasPreviousStep(step),
            ),
          );
          return IgnorePointer(
            ignoring: !scope.isStepInteractive(step),
            child: TooltipVisibility(
              visible: false,
              child: content,
            ),
          );
        } catch (error, stackTrace) {
          scope.widget.onDiagnostic?.call(AnchorTourDiagnosticEvent(
            kind: AnchorTourDiagnosticKind.builderThrew,
            step: step,
            targetId: step.target,
            error: error,
            stackTrace: stackTrace,
          ));
          rethrow;
        }
      },
      child: widget.child,
    );
  }

  EdgeInsets _defaultViewPadding(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return EdgeInsets.fromLTRB(
      viewPadding.left + viewInsets.left + 12,
      viewPadding.top + viewInsets.top + 12,
      viewPadding.right + viewInsets.right + 12,
      viewPadding.bottom + viewInsets.bottom + 12,
    );
  }

  List<PositioningMiddleware> _defaultMiddlewares(AnchorTourStep step) {
    return [
      OffsetMiddleware(mainAxis: OffsetValue.value(step.spacing)),
      const FlipMiddleware(),
      const ShiftMiddleware(),
    ];
  }

  void _markOverlayShownAfterLayout(
    AnchorTourScopeState scope,
    AnchorTourStep step,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        scope.markStepOverlayShown(step);
      });
    });
  }
}
