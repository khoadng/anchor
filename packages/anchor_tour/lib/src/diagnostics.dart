import 'package:meta/meta.dart';

import 'step.dart';

enum AnchorTourDiagnosticKind {
  duplicateTargetId,
  missingTarget,
  targetTimedOut,
  activeTargetUnmounted,
  enterHookThrew,
  exitHookThrew,
  targetNotFoundHookThrew,
  builderThrew,
}

@immutable
class AnchorTourDiagnosticEvent {
  const AnchorTourDiagnosticEvent({
    required this.kind,
    this.step,
    this.targetId,
    this.error,
    this.stackTrace,
    this.message,
  });

  final AnchorTourDiagnosticKind kind;
  final AnchorTourStep? step;
  final String? targetId;
  final Object? error;
  final StackTrace? stackTrace;
  final String? message;

  @override
  String toString() {
    return 'AnchorTourDiagnosticEvent('
        'kind: $kind, '
        'step: ${step?.id}, '
        'targetId: $targetId, '
        'error: $error, '
        'message: $message'
        ')';
  }
}
