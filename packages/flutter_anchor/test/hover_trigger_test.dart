import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

const _wait = Duration(milliseconds: 500);
const _tileSize = 100.0;
const _firstTile = Offset(50, 150);
const _secondTile = Offset(150, 150);

void main() {
  testWidgets(
      'shows the overlay once the wait elapses after the pointer '
      'enters', (tester) async {
    await _pumpTiles(
      tester,
      const AnchorTriggerMode.hover(waitDuration: _wait),
    );
    final mouse = await _mouseAt(tester, Offset.zero);

    await mouse.moveTo(_firstTile);
    await tester.pump(_wait);
    await tester.pumpAndSettle();

    expect(find.text('Overlay 0'), findsOneWidget);
  });

  group('when pointer movement is required', () {
    const mode = AnchorTriggerMode.hover(
      waitDuration: _wait,
      requirePointerMovement: true,
    );

    testWidgets(
        'ignores content sliding under a still pointer until the '
        'pointer moves', (tester) async {
      final shift = ValueNotifier<double>(_tileSize * 3);
      await _pumpTiles(tester, mode, shift: shift);
      final mouse = await _mouseAt(tester, _firstTile);

      shift.value = 0;
      await tester.pump();
      await tester.pump(_wait * 2);
      await tester.pumpAndSettle();
      expect(find.text('Overlay 0'), findsNothing);

      await mouse.moveBy(const Offset(1, 0));
      await tester.pump(_wait);
      await tester.pumpAndSettle();
      expect(find.text('Overlay 0'), findsOneWidget);
    });

    testWidgets('cancels a pending show when the user scrolls over the child', (
      tester,
    ) async {
      await _pumpTiles(tester, mode);
      final mouse = await _mouseAt(tester, Offset.zero);

      await mouse.moveTo(_firstTile);
      await tester.pump(_wait ~/ 2);
      await tester.sendEventToBinding(
        const PointerScrollEvent(
          position: _firstTile,
          scrollDelta: Offset(0, 20),
        ),
      );
      await tester.pump(_wait * 2);
      await tester.pumpAndSettle();

      expect(find.text('Overlay 0'), findsNothing);
    });

    testWidgets(
        'stays hidden after being dismissed while the pointer keeps '
        'moving over the child', (tester) async {
      final controller = AnchorController();
      await _pumpTiles(tester, mode, controller: controller);
      final mouse = await _mouseAt(tester, Offset.zero);

      await mouse.moveTo(_firstTile);
      await tester.pump(_wait);
      await tester.pumpAndSettle();
      controller.hide();
      await tester.pumpAndSettle();

      await mouse.moveBy(const Offset(5, 5));
      await tester.pump(_wait * 2);
      await tester.pumpAndSettle();

      expect(find.text('Overlay 0'), findsNothing);
    });
  });

  group('with a rest tolerance', () {
    const mode = AnchorTriggerMode.hover(
      waitDuration: _wait,
      restTolerance: 4,
    );

    final cases = [
      (name: 'jitters within the tolerance', step: 3.0, shows: true),
      (name: 'keeps moving past the tolerance', step: 10.0, shows: false),
    ];
    for (final c in cases) {
      testWidgets(
          '${c.shows ? 'shows' : 'holds back'} the overlay when the '
          'pointer ${c.name}', (tester) async {
        await _pumpTiles(tester, mode);
        final mouse = await _mouseAt(tester, Offset.zero);

        await mouse.moveTo(_firstTile - const Offset(40, 0));
        for (var i = 0; i < 4; i++) {
          await tester.pump(_wait ~/ 3);
          await mouse.moveBy(Offset(i.isEven ? c.step : -c.step, 0));
        }
        await tester.pump(_wait ~/ 3);
        await tester.pumpAndSettle();

        expect(
          find.text('Overlay 0'),
          c.shows ? findsOneWidget : findsNothing,
        );
      });
    }
  });

  group('inside a hover group', () {
    const mode = AnchorTriggerMode.hover(waitDuration: _wait);
    const skipDelay = Duration(milliseconds: 300);

    Future<TestGesture> showFirstThenLeave(WidgetTester tester) async {
      await _pumpTiles(tester, mode, skipDelay: skipDelay);
      final mouse = await _mouseAt(tester, Offset.zero);
      await mouse.moveTo(_firstTile);
      await tester.pump(_wait);
      await tester.pumpAndSettle();
      return mouse;
    }

    testWidgets('shows the next overlay without waiting while browsing', (
      tester,
    ) async {
      final mouse = await showFirstThenLeave(tester);

      await mouse.moveTo(_secondTile);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Overlay 1'), findsOneWidget);
    });

    testWidgets('waits again once the group has been idle', (tester) async {
      final mouse = await showFirstThenLeave(tester);

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      await tester.pump(skipDelay * 2);
      await mouse.moveTo(_secondTile);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Overlay 1'), findsNothing);
    });
  });
}

Future<TestGesture> _mouseAt(WidgetTester tester, Offset position) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: position);
  addTearDown(mouse.removePointer);
  await tester.pump();
  return mouse;
}

Future<void> _pumpTiles(
  WidgetTester tester,
  AnchorTriggerMode triggerMode, {
  ValueNotifier<double>? shift,
  AnchorController? controller,
  Duration? skipDelay,
}) async {
  Widget tile(int index) => Anchor(
        controller: index == 0 ? controller : null,
        triggerMode: triggerMode,
        placement: Placement.top,
        overlayBuilder: (_) => Text('Overlay $index'),
        child: const SizedBox.square(dimension: _tileSize),
      );

  final tiles = ValueListenableBuilder<double>(
    valueListenable: shift ?? ValueNotifier(0),
    builder: (_, dx, __) => Stack(
      children: [
        Positioned(left: dx, top: _tileSize, child: tile(0)),
        Positioned(left: dx + _tileSize, top: _tileSize, child: tile(1)),
      ],
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: switch (skipDelay) {
        final skipDelay? => AnchorHoverGroup(
            skipDelayDuration: skipDelay,
            child: tiles,
          ),
        null => tiles,
      },
    ),
  );
}
