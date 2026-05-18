import 'dart:async';

import 'package:flutter/foundation.dart';

import 'scope.dart';
import 'state.dart';

class AnchorTourController extends ChangeNotifier {
  final ValueNotifier<AnchorTourState> _state =
      ValueNotifier<AnchorTourState>(const AnchorTourState.idle());

  AnchorTourScopeState? _scope;

  ValueListenable<AnchorTourState> get state => _state;

  AnchorTourState get value => _state.value;

  bool get isAttached => _scope != null;

  bool get isRunning => _state.value.isRunning;

  Future<void> start() {
    _debugAssertAttached('start');
    return _scope?.start() ?? Future<void>.value();
  }

  Future<void> next() {
    _debugAssertAttached('next');
    return _scope?.next() ?? Future<void>.value();
  }

  Future<void> previous() {
    _debugAssertAttached('previous');
    return _scope?.previous() ?? Future<void>.value();
  }

  Future<void> goTo(String stepId) {
    _debugAssertAttached('goTo');
    return _scope?.goTo(stepId) ?? Future<void>.value();
  }

  Future<void> skip() {
    _debugAssertAttached('skip');
    return _scope?.skip() ?? Future<void>.value();
  }

  Future<void> finish() {
    _debugAssertAttached('finish');
    return _scope?.finish() ?? Future<void>.value();
  }

  void refresh() {
    _debugAssertAttached('refresh');
    _scope?.refresh();
  }

  @internal
  void attachScope(AnchorTourScopeState scope) {
    assert(
      _scope == null || _scope == scope,
      'AnchorTourController is already attached to another AnchorTourScope.',
    );
    _scope = scope;
  }

  @internal
  void detachScope(AnchorTourScopeState scope) {
    if (_scope == scope) {
      _scope = null;
    }
  }

  @internal
  void setTourState(AnchorTourState state) {
    if (_state.value == state) return;
    _state.value = state;
    notifyListeners();
  }

  void _debugAssertAttached(String method) {
    assert(
      _scope != null,
      'AnchorTourController.$method() was called before the controller was '
      'attached to an AnchorTourScope.',
    );
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}
