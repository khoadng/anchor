import 'package:meta/meta.dart';

enum AnchorTourStatus {
  idle,
  resolving,
  showing,
  finished,
  skipped,
  error,
}

@immutable
class AnchorTourState {
  const AnchorTourState({
    required this.status,
    this.activeStepId,
    this.activeTargetId,
    this.activeIndex = -1,
    this.stepCount = 0,
    this.error,
  });

  const AnchorTourState.idle()
      : status = AnchorTourStatus.idle,
        activeStepId = null,
        activeTargetId = null,
        activeIndex = -1,
        stepCount = 0,
        error = null;

  final AnchorTourStatus status;
  final String? activeStepId;
  final String? activeTargetId;
  final int activeIndex;
  final int stepCount;
  final Object? error;

  bool get isRunning =>
      status == AnchorTourStatus.resolving ||
      status == AnchorTourStatus.showing;

  AnchorTourState copyWith({
    AnchorTourStatus? status,
    String? activeStepId,
    String? activeTargetId,
    int? activeIndex,
    int? stepCount,
    Object? error,
    bool clearActiveStepId = false,
    bool clearActiveTargetId = false,
    bool clearError = false,
  }) {
    return AnchorTourState(
      status: status ?? this.status,
      activeStepId:
          clearActiveStepId ? null : activeStepId ?? this.activeStepId,
      activeTargetId:
          clearActiveTargetId ? null : activeTargetId ?? this.activeTargetId,
      activeIndex: activeIndex ?? this.activeIndex,
      stepCount: stepCount ?? this.stepCount,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnchorTourState &&
            status == other.status &&
            activeStepId == other.activeStepId &&
            activeTargetId == other.activeTargetId &&
            activeIndex == other.activeIndex &&
            stepCount == other.stepCount &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(
        status,
        activeStepId,
        activeTargetId,
        activeIndex,
        stepCount,
        error,
      );

  @override
  String toString() {
    return 'AnchorTourState('
        'status: $status, '
        'activeStepId: $activeStepId, '
        'activeTargetId: $activeTargetId, '
        'activeIndex: $activeIndex, '
        'stepCount: $stepCount, '
        'error: $error'
        ')';
  }
}
