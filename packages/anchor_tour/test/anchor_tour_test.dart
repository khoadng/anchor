import 'package:anchor_tour/anchor_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller reports attachment and asserts when used unattached', () {
    final controller = AnchorTourController();
    addTearDown(controller.dispose);

    expect(controller.isAttached, isFalse);
    expect(controller.start, throwsAssertionError);
  });

  testWidgets('starts, shows the first step, advances, and finishes',
      (tester) async {
    final controller = AnchorTourController();
    final shownSteps = <String>[];
    final previousSteps = <String?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: AnchorTourScope(
          controller: controller,
          onStepShown: (previous, current) {
            previousSteps.add(previous?.id);
            shownSteps.add(current.id);
          },
          steps: [
            AnchorTourStep(
              id: 'first',
              target: 'one',
              builder: (context, tour) => TextButton(
                onPressed: tour.next,
                child: const Text('First step'),
              ),
            ),
            AnchorTourStep(
              id: 'second',
              target: 'two',
              builder: (context, tour) => TextButton(
                onPressed: tour.finish,
                child: const Text('Second step'),
              ),
            ),
          ],
          child: const Column(
            children: [
              AnchorTourTarget(
                id: 'one',
                child: SizedBox(width: 80, height: 40, child: Text('One')),
              ),
              AnchorTourTarget(
                id: 'two',
                child: SizedBox(width: 80, height: 40, child: Text('Two')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(controller.isAttached, isTrue);

    final start = controller.start();
    await _pumpTour(tester);
    await start;

    expect(controller.value.status, AnchorTourStatus.showing);
    expect(controller.value.activeStepId, 'first');
    expect(find.text('First step'), findsOneWidget);
    expect(shownSteps, ['first']);
    expect(previousSteps, [null]);

    await tester.tap(find.text('First step'));
    await _pumpTour(tester);

    expect(controller.value.status, AnchorTourStatus.showing);
    expect(controller.value.activeStepId, 'second');
    expect(find.text('Second step'), findsOneWidget);
    expect(shownSteps, ['first', 'second']);
    expect(previousSteps, [null, 'first']);

    await tester.tap(find.text('Second step'));
    await _pumpTour(tester);

    expect(controller.value.status, AnchorTourStatus.finished);
    expect(controller.value.activeStepId, isNull);
  });

  testWidgets('runs enter before resolving a target', (tester) async {
    final controller = AnchorTourController();

    await tester.pumpWidget(
      MaterialApp(
        home: _DelayedTargetHarness(controller: controller),
      ),
    );

    expect(find.text('Delayed'), findsNothing);

    final start = controller.start();
    await _pumpTour(tester);
    await start;

    expect(find.text('Delayed'), findsOneWidget);
    expect(find.text('Delayed step'), findsOneWidget);
    expect(controller.value.status, AnchorTourStatus.showing);
  });

  testWidgets('calls onTargetNotFound before timing out a missing target',
      (tester) async {
    final controller = AnchorTourController();
    final missingStepIds = <String>[];
    final missingTargetRects = <Rect?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: _TargetNotFoundHarness(
          controller: controller,
          onTargetNotFound: (tour) {
            missingStepIds.add(tour.step.id);
            missingTargetRects.add(tour.targetRect);
          },
        ),
      ),
    );

    final start = controller.start();
    await _pumpTour(tester);
    await start;

    expect(controller.value.status, AnchorTourStatus.showing);
    expect(controller.value.activeStepId, 'recovered');
    expect(find.text('Recovered'), findsOneWidget);
    expect(find.text('Recovered step'), findsOneWidget);
    expect(missingStepIds, ['recovered']);
    expect(missingTargetRects, [null]);
  });
}

Future<void> _pumpTour(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
}

class _DelayedTargetHarness extends StatefulWidget {
  const _DelayedTargetHarness({required this.controller});

  final AnchorTourController controller;

  @override
  State<_DelayedTargetHarness> createState() => _DelayedTargetHarnessState();
}

class _DelayedTargetHarnessState extends State<_DelayedTargetHarness> {
  var _showDelayedTarget = false;

  @override
  Widget build(BuildContext context) {
    return AnchorTourScope(
      controller: widget.controller,
      steps: [
        AnchorTourStep(
          id: 'delayed',
          target: 'delayed-target',
          enter: (context, tour) {
            expect(tour.step.id, 'delayed');
            setState(() {
              _showDelayedTarget = true;
            });
          },
          builder: (context, tour) => const Text('Delayed step'),
        ),
      ],
      child: Column(
        children: [
          if (_showDelayedTarget)
            const AnchorTourTarget(
              id: 'delayed-target',
              child: SizedBox(
                width: 80,
                height: 40,
                child: Text('Delayed'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TargetNotFoundHarness extends StatefulWidget {
  const _TargetNotFoundHarness({
    required this.controller,
    required this.onTargetNotFound,
  });

  final AnchorTourController controller;
  final ValueChanged<AnchorTourContext> onTargetNotFound;

  @override
  State<_TargetNotFoundHarness> createState() => _TargetNotFoundHarnessState();
}

class _TargetNotFoundHarnessState extends State<_TargetNotFoundHarness> {
  var _showRecoveredTarget = false;

  @override
  Widget build(BuildContext context) {
    return AnchorTourScope(
      controller: widget.controller,
      targetTimeout: const Duration(seconds: 1),
      onTargetNotFound: (context, tour) {
        widget.onTargetNotFound(tour);
        setState(() {
          _showRecoveredTarget = true;
        });
      },
      steps: [
        AnchorTourStep(
          id: 'recovered',
          target: 'recovered-target',
          builder: (context, tour) => const Text('Recovered step'),
        ),
      ],
      child: Column(
        children: [
          if (_showRecoveredTarget)
            const AnchorTourTarget(
              id: 'recovered-target',
              child: SizedBox(
                width: 80,
                height: 40,
                child: Text('Recovered'),
              ),
            ),
        ],
      ),
    );
  }
}
