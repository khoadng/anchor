import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' as meta;

import 'controller.dart';
import 'diagnostics.dart';
import 'state.dart';
import 'step.dart';

typedef AnchorTourDiagnosticCallback = void Function(
  AnchorTourDiagnosticEvent event,
);

class AnchorTourScope extends StatefulWidget {
  const AnchorTourScope({
    super.key,
    required this.controller,
    required this.steps,
    this.targetTimeout = const Duration(seconds: 3),
    this.onTargetNotFound,
    this.onStepShown,
    this.onFinish,
    this.onSkip,
    this.onDiagnostic,
    required this.child,
  });

  final AnchorTourController controller;
  final List<AnchorTourStep> steps;
  final Duration targetTimeout;
  final AnchorTourTargetNotFoundCallback? onTargetNotFound;
  final AnchorTourStepShownCallback? onStepShown;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;
  final AnchorTourDiagnosticCallback? onDiagnostic;
  final Widget child;

  @override
  State<AnchorTourScope> createState() => AnchorTourScopeState();
}

@meta.internal
class AnchorTourScopeState extends State<AnchorTourScope> {
  final Map<String, Set<AnchorTourTargetRegistration>> _targets = {};
  final Map<String, List<Completer<void>>> _targetWaiters = {};
  final Set<String> _pendingDuplicateChecks = {};

  int _activeIndex = -1;
  int _visibleIndex = -1;
  int _pendingVisibleIndex = -1;
  int _runToken = 0;

  AnchorTourStep? get _activeStep {
    if (_activeIndex < 0 || _activeIndex >= widget.steps.length) return null;
    return widget.steps[_activeIndex];
  }

  AnchorTourStep? get _visibleStep {
    if (_visibleIndex < 0 || _visibleIndex >= widget.steps.length) return null;
    return widget.steps[_visibleIndex];
  }

  AnchorTourStep? get _pendingVisibleStep {
    if (_pendingVisibleIndex < 0 ||
        _pendingVisibleIndex >= widget.steps.length) {
      return null;
    }
    return widget.steps[_pendingVisibleIndex];
  }

  AnchorTourState get _state => widget.controller.value;

  @override
  void initState() {
    super.initState();
    widget.controller.attachScope(this);
    _publishState(const AnchorTourState.idle().copyWith(
      stepCount: widget.steps.length,
    ));
  }

  @override
  void didUpdateWidget(covariant AnchorTourScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachScope(this);
      widget.controller.attachScope(this);
    }
    _publishState(_state.copyWith(stepCount: widget.steps.length));
  }

  @override
  void dispose() {
    for (final waiters in _targetWaiters.values) {
      for (final waiter in waiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
    }
    _targetWaiters.clear();
    _pendingDuplicateChecks.clear();
    widget.controller.detachScope(this);
    super.dispose();
  }

  Future<void> start() {
    if (widget.steps.isEmpty) return Future<void>.value();
    _runToken++;
    return _activateIndex(0, token: _runToken);
  }

  Future<void> next() async {
    if (!_state.isRunning) return;
    final nextIndex = _activeIndex + 1;
    if (nextIndex >= widget.steps.length) {
      await finish();
      return;
    }
    _runToken++;
    await _activateIndex(nextIndex, token: _runToken);
  }

  Future<void> previous() async {
    if (!_state.isRunning) return;
    final previousIndex = _activeIndex - 1;
    if (previousIndex < 0) return;
    _runToken++;
    await _activateIndex(previousIndex, token: _runToken);
  }

  Future<void> goTo(String stepId) async {
    final index = widget.steps.indexWhere((step) => step.id == stepId);
    if (index < 0) {
      throw ArgumentError.value(stepId, 'stepId', 'Unknown tour step.');
    }
    _runToken++;
    await _activateIndex(index, token: _runToken);
  }

  Future<void> skip() async {
    _runToken++;
    _activeIndex = -1;
    _visibleIndex = -1;
    _pendingVisibleIndex = -1;
    _publishState(AnchorTourState(
      status: AnchorTourStatus.skipped,
      activeIndex: -1,
      stepCount: widget.steps.length,
    ));
    widget.onSkip?.call();
  }

  Future<void> finish() async {
    _runToken++;
    final previous = _activeStep;
    final exit = previous?.exit;
    if (previous != null && exit != null) {
      try {
        await exit(context, _contextForStep(previous));
      } catch (error, stackTrace) {
        _diagnose(AnchorTourDiagnosticEvent(
          kind: AnchorTourDiagnosticKind.exitHookThrew,
          step: previous,
          error: error,
          stackTrace: stackTrace,
        ));
      }
    }
    _activeIndex = -1;
    _visibleIndex = -1;
    _pendingVisibleIndex = -1;
    _publishState(AnchorTourState(
      status: AnchorTourStatus.finished,
      activeIndex: -1,
      stepCount: widget.steps.length,
    ));
    widget.onFinish?.call();
  }

  void refresh() {
    setState(() {});
  }

  void registerTarget(AnchorTourTargetRegistration target) {
    final registrations = _targets.putIfAbsent(target.id, () => {});
    registrations.add(target);
    _scheduleDuplicateTargetCheck(target.id);
    _notifyTargetWaiters(target.id);
  }

  void updateTarget(AnchorTourTargetRegistration target) {
    _scheduleDuplicateTargetCheck(target.id);
    _notifyTargetWaiters(target.id);
  }

  void unregisterTarget(AnchorTourTargetRegistration target) {
    final registrations = _targets[target.id];
    registrations?.remove(target);
    if (registrations == null || registrations.isEmpty) {
      _targets.remove(target.id);
    }
    if (_state.activeTargetId == target.id && _state.isRunning) {
      _diagnose(AnchorTourDiagnosticEvent(
        kind: AnchorTourDiagnosticKind.activeTargetUnmounted,
        step: _activeStep,
        targetId: target.id,
      ));
    }
  }

  bool isTargetActive(String targetId) {
    final step = _activeStep;
    return _state.status == AnchorTourStatus.showing &&
        step?.target == targetId;
  }

  AnchorTourStep? stepForTarget(String targetId) {
    if (_state.status != AnchorTourStatus.resolving &&
        _state.status != AnchorTourStatus.showing) {
      return null;
    }

    final pendingStep = _pendingVisibleStep;
    if (pendingStep?.target == targetId) return pendingStep;

    final step = _visibleStep;
    if (step?.target != targetId) return null;
    return step;
  }

  bool hasNextStep(AnchorTourStep step) {
    final index =
        widget.steps.indexWhere((candidate) => candidate.id == step.id);
    return index >= 0 && index < widget.steps.length - 1;
  }

  bool hasPreviousStep(AnchorTourStep step) {
    final index =
        widget.steps.indexWhere((candidate) => candidate.id == step.id);
    return index > 0;
  }

  bool isStepInteractive(AnchorTourStep step) {
    return _activeStep?.id == step.id;
  }

  Future<void> _activateIndex(int index, {required int token}) async {
    if (index < 0 || index >= widget.steps.length) return;

    final previous = _activeStep;
    final exit = previous?.exit;
    if (previous != null && exit != null) {
      try {
        await exit(context, _contextForStep(previous));
      } catch (error, stackTrace) {
        _diagnose(AnchorTourDiagnosticEvent(
          kind: AnchorTourDiagnosticKind.exitHookThrew,
          step: previous,
          error: error,
          stackTrace: stackTrace,
        ));
      }
    }
    if (token != _runToken || !mounted) return;

    final step = widget.steps[index];
    _activeIndex = index;
    _publishState(AnchorTourState(
      status: AnchorTourStatus.resolving,
      activeStepId: step.id,
      activeTargetId: step.target,
      activeIndex: index,
      stepCount: widget.steps.length,
    ));

    try {
      await step.enter?.call(context, _contextForStep(step));
    } catch (error, stackTrace) {
      _diagnose(AnchorTourDiagnosticEvent(
        kind: AnchorTourDiagnosticKind.enterHookThrew,
        step: step,
        targetId: step.target,
        error: error,
        stackTrace: stackTrace,
      ));
      _publishState(_state.copyWith(
        status: AnchorTourStatus.error,
        error: error,
      ));
      return;
    }
    if (token != _runToken || !mounted) return;

    final resolved = await _resolveTarget(step, token: token);
    if (!resolved || token != _runToken || !mounted) return;

    if (_visibleIndex != index) {
      _pendingVisibleIndex = index;
    }
    _publishState(_state.copyWith(
      status: AnchorTourStatus.showing,
      activeStepId: step.id,
      activeTargetId: step.target,
      activeIndex: index,
      stepCount: widget.steps.length,
      clearError: true,
    ));
    widget.onStepShown?.call(previous, step);
  }

  void markStepOverlayShown(AnchorTourStep step) {
    final index =
        widget.steps.indexWhere((candidate) => candidate.id == step.id);
    if (index < 0 || index != _pendingVisibleIndex) return;

    final previousTarget = _visibleStep?.target;
    if (previousTarget != null && previousTarget != step.target) {
      for (final target in _targets[previousTarget] ??
          const <AnchorTourTargetRegistration>{}) {
        target.hideOverlay();
      }
    }

    _pendingVisibleIndex = -1;
    _visibleIndex = index;
    setState(() {});
  }

  AnchorTourContext _contextForStep(AnchorTourStep step) {
    return AnchorTourContext(
      controller: widget.controller,
      state: _state,
      step: step,
      hasNext: hasNextStep(step),
      hasPrevious: hasPreviousStep(step),
    );
  }

  Future<bool> _resolveTarget(
    AnchorTourStep step, {
    required int token,
  }) async {
    final startedAt = DateTime.now();
    var notifiedTargetNotFound = false;

    while (mounted && token == _runToken) {
      await WidgetsBinding.instance.endOfFrame;
      if (_hasEnabledTarget(step.target)) return true;

      if (!notifiedTargetNotFound) {
        notifiedTargetNotFound = true;
        final recovered = await _notifyTargetNotFound(step);
        if (!recovered || token != _runToken || !mounted) return false;
        continue;
      }

      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed >= widget.targetTimeout) {
        await _handleTargetTimeout(step);
        return false;
      }

      await _waitForTargetChange(step.target, widget.targetTimeout - elapsed);
    }

    return false;
  }

  Future<bool> _notifyTargetNotFound(AnchorTourStep step) async {
    _diagnose(AnchorTourDiagnosticEvent(
      kind: AnchorTourDiagnosticKind.missingTarget,
      step: step,
      targetId: step.target,
    ));

    try {
      await widget.onTargetNotFound?.call(context, _contextForStep(step));
      return true;
    } catch (error, stackTrace) {
      _diagnose(AnchorTourDiagnosticEvent(
        kind: AnchorTourDiagnosticKind.targetNotFoundHookThrew,
        step: step,
        targetId: step.target,
        error: error,
        stackTrace: stackTrace,
      ));
      _publishState(_state.copyWith(
        status: AnchorTourStatus.error,
        error: error,
      ));
      return false;
    }
  }

  Future<void> _handleTargetTimeout(AnchorTourStep step) async {
    final error = StateError('Anchor tour target not found: ${step.target}');
    _diagnose(AnchorTourDiagnosticEvent(
      kind: AnchorTourDiagnosticKind.targetTimedOut,
      step: step,
      targetId: step.target,
      error: error,
    ));
    assert(() {
      _publishState(_state.copyWith(
        status: AnchorTourStatus.error,
        error: error,
      ));
      throw FlutterError.fromParts([
        ErrorSummary('Anchor tour target not found: ${step.target}'),
        ErrorDescription(
          'Step "${step.id}" could not find an enabled AnchorTourTarget '
          'before targetTimeout elapsed.',
        ),
        ErrorHint(
          'Use step.enter or AnchorTourScope.onTargetNotFound to reveal the '
          'target before the timeout.',
        ),
      ]);
    }());

    await skip();
  }

  Future<void> _waitForTargetChange(String targetId, Duration timeout) async {
    if (timeout <= Duration.zero) return;
    final completer = Completer<void>();
    _targetWaiters.putIfAbsent(targetId, () => []).add(completer);
    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      // The caller owns timeout policy.
    } finally {
      _targetWaiters[targetId]?.remove(completer);
    }
  }

  bool _hasEnabledTarget(String targetId) {
    return _targets[targetId]?.any((target) => target.enabled) ?? false;
  }

  void _notifyTargetWaiters(String targetId) {
    final waiters = _targetWaiters.remove(targetId);
    if (waiters == null) return;
    for (final waiter in waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  void _checkDuplicateTargets(String targetId) {
    final enabledCount =
        _targets[targetId]?.where((target) => target.enabled).length ?? 0;
    if (enabledCount <= 1) return;

    final event = AnchorTourDiagnosticEvent(
      kind: AnchorTourDiagnosticKind.duplicateTargetId,
      targetId: targetId,
      message: 'Multiple enabled AnchorTourTarget widgets use id "$targetId".',
    );
    _diagnose(event);
    assert(() {
      throw FlutterError(event.message!);
    }());
  }

  void _scheduleDuplicateTargetCheck(String targetId) {
    if (!_pendingDuplicateChecks.add(targetId)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pendingDuplicateChecks.remove(targetId);
      _checkDuplicateTargets(targetId);
    });
  }

  void _publishState(AnchorTourState state) {
    widget.controller.setTourState(state);
    setState(() {});
  }

  void _diagnose(AnchorTourDiagnosticEvent event) {
    widget.onDiagnostic?.call(event);
  }

  @override
  Widget build(BuildContext context) {
    return AnchorTourHost(
      scope: this,
      state: _state,
      child: widget.child,
    );
  }
}

@meta.internal
class AnchorTourHost extends InheritedWidget {
  const AnchorTourHost({
    super.key,
    required this.scope,
    required this.state,
    required super.child,
  });

  final AnchorTourScopeState scope;
  final AnchorTourState state;

  static AnchorTourScopeState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnchorTourHost>()?.scope;
  }

  @override
  bool updateShouldNotify(AnchorTourHost oldWidget) {
    return state != oldWidget.state || scope != oldWidget.scope;
  }
}

@meta.internal
class AnchorTourTargetRegistration {
  const AnchorTourTargetRegistration({
    required this.id,
    required this.enabled,
    required this.hideOverlay,
  });

  final String id;
  final bool enabled;
  final VoidCallback hideOverlay;
}
