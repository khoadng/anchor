import 'package:flutter/material.dart';

import 'scope.dart';

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
    super.dispose();
  }

  void _register() {
    final scope = _scope;
    if (scope == null) return;
    if (_registration != null) return;
    final registration = AnchorTourTargetRegistration(
      id: widget.id,
      enabled: widget.enabled,
      rectGetter: _targetRect,
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

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Rect? _targetRect() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
