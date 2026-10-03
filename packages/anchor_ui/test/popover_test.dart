import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a popover fitting the available space ends above the keyboard '
      'and scrolls its content', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 800)
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);
    final controller = AnchorController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: AnchorPopover(
              controller: controller,
              fitToAvailableSpace: true,
              placement: Placement.bottom,
              overlayBuilder: (_) => SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(height: 40, child: Text('Item $i')),
                  ],
                ),
              ),
              child: const SizedBox(width: 200, height: 40),
            ),
          ),
        ),
      ),
    );
    controller.show();
    await tester.pumpAndSettle();

    final popover = tester.getRect(find.byType(SingleChildScrollView));
    expect(popover.bottom, lessThanOrEqualTo(500));

    await tester.scrollUntilVisible(find.text('Item 39'), 200);
    expect(tester.getRect(find.text('Item 39')).bottom, lessThanOrEqualTo(500));
  });
}
