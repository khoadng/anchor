import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

const _screen = Size(400, 800);
const _keyboardHeight = 300.0;

void main() {
  final cases = [
    (name: 'directly in the app', resizingScaffold: false),
    (name: 'inside a Scaffold that resizes for it', resizingScaffold: true),
  ];
  for (final c in cases) {
    testWidgets('flips the overlay above its anchor when the keyboard covers '
        'the space below, ${c.name}', (tester) async {
      _setScreen(tester, keyboard: true);
      final controller = AnchorController();

      final anchor = RawAnchor(
        controller: controller,
        placement: Placement.bottom,
        middlewares: const [FlipMiddleware()],
        overlayHeight: 100,
        overlayWidth: 100,
        overlayBuilder: (_) => const SizedBox(key: _overlayKey, width: 200, height: 100),
        child: const SizedBox.square(dimension: 40),
      );
      final keyboardTop = _screen.height - _keyboardHeight;
      final positioned = Stack(
        children: [Positioned(top: keyboardTop - 60, left: 0, child: anchor)],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: c.resizingScaffold
              ? Scaffold(body: positioned)
              : Material(child: positioned),
        ),
      );
      controller.show();
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(_overlayKey)).bottom,
        lessThanOrEqualTo(keyboardTop - 60),
      );
    });
  }

  testWidgets('keeps the overlay out of the side safe areas', (tester) async {
    _setScreen(tester, padding: const FakeViewPadding(right: 50));
    final controller = AnchorController();

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Positioned(
              top: 100,
              right: 60,
              child: RawAnchor(
                controller: controller,
                placement: Placement.bottomStart,
                middlewares: const [ShiftMiddleware()],
                overlayHeight: 100,
                overlayWidth: 200,
                overlayBuilder: (_) => const SizedBox(key: _overlayKey, width: 200, height: 100),
                child: const SizedBox.square(dimension: 40),
              ),
            ),
          ],
        ),
      ),
    );
    controller.show();
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(_overlayKey)).right,
      lessThanOrEqualTo(_screen.width - 50),
    );
  });
}

const _overlayKey = ValueKey('overlay');

void _setScreen(
  WidgetTester tester, {
  bool keyboard = false,
  FakeViewPadding padding = FakeViewPadding.zero,
}) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = _screen
    ..padding = padding
    ..viewPadding = padding
    ..viewInsets = FakeViewPadding(bottom: keyboard ? _keyboardHeight : 0);
  addTearDown(tester.view.reset);
}
