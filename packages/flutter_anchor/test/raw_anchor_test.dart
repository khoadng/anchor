import 'package:anchor/anchor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_anchor/src/controller.dart';
import 'package:flutter_anchor/src/data.dart';
import 'package:flutter_anchor/src/raw_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

const _testMiddlewares = <PositioningMiddleware>[];

void main() {
  group('RawAnchor', () {
    testWidgets('shows overlay when controller shows', (tester) async {
      final controller = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            child: const Text('Child'),
          ),
        ),
      );

      expect(find.text('Overlay'), findsNothing);

      controller.show();
      await tester.pumpAndSettle();

      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('hides overlay when controller hides', (tester) async {
      final controller = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();

      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('toggles overlay visibility', (tester) async {
      final controller = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            child: const Text('Child'),
          ),
        ),
      );

      controller.toggle();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      controller.toggle();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('calls onShowRequested when showing', (tester) async {
      final controller = AnchorController();
      var showRequestedCount = 0;
      var showOverlayCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onShowRequested: (showOverlay) {
              showRequestedCount++;
              showOverlay();
            },
            onShow: () => showOverlayCount++,
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      expect(showRequestedCount, greaterThan(0));
      expect(showOverlayCount, equals(1));
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('calls onHideRequested when hiding', (tester) async {
      final controller = AnchorController();
      var hideRequestedCount = 0;
      var hideOverlayCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onHideRequested: (hideOverlay) {
              hideRequestedCount++;
              hideOverlay();
            },
            onHide: () => hideOverlayCount++,
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      controller.hide();
      await tester.pumpAndSettle();

      expect(hideRequestedCount, greaterThan(0));
      expect(hideOverlayCount, equals(1));
      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('onShow called once when overlay shows', (tester) async {
      final controller = AnchorController();
      var onShowCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onShow: () => onShowCallCount++,
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      expect(onShowCallCount, equals(1));
    });

    testWidgets('onHide called once when overlay hides', (tester) async {
      final controller = AnchorController();
      var onHideCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onHide: () => onHideCallCount++,
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      controller.hide();
      await tester.pumpAndSettle();

      expect(onHideCallCount, equals(1));
    });

    testWidgets('provides AnchorData to overlay content', (tester) async {
      final controller = AnchorController();
      AnchorData? capturedData;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) {
              capturedData = AnchorData.of(context);
              return const Text('Overlay');
            },
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      expect(capturedData, isNotNull);
      expect(capturedData!.controller, equals(controller));
    });

    testWidgets('renders backdrop when provided', (tester) async {
      final controller = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            backdropBuilder: (context) => Container(
              key: const Key('backdrop'),
              color: Colors.black54,
            ),
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('backdrop')), findsOneWidget);
    });

    testWidgets('dismisses on scroll by default', (tester) async {
      final controller = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            children: [
              RawAnchor(
                controller: controller,
                placement: Placement.bottom,
                middlewares: _testMiddlewares,
                overlayBuilder: (context) => const Text('Overlay'),
                child: const Text('Child'),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();

      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('responds to new controller after update', (tester) async {
      final controller1 = AnchorController();
      final controller2 = AnchorController();

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller1,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            child: const Text('Child'),
          ),
        ),
      );

      controller1.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller2,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            child: const Text('Child'),
          ),
        ),
      );
      await tester.pump();

      controller1.hide();
      await tester.pumpAndSettle();
      expect(controller2.isShowing, isFalse);

      controller2.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('delayed show via onShowRequested', (tester) async {
      final controller = AnchorController();
      VoidCallback? pendingShowOverlay;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onShowRequested: (showOverlay) {
              pendingShowOverlay = showOverlay;
            },
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsNothing);

      pendingShowOverlay?.call();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('delayed hide via onHideRequested', (tester) async {
      final controller = AnchorController();
      VoidCallback? pendingHideOverlay;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) => const Text('Overlay'),
            onHideRequested: (hideOverlay) {
              pendingHideOverlay = hideOverlay;
            },
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      pendingHideOverlay?.call();
      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('overlay rebuilds when controller data changes',
        (tester) async {
      final controller = AnchorController();
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.bottom,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) {
              buildCount++;
              return Text('Build $buildCount');
            },
            child: const Text('Child'),
          ),
        ),
      );

      controller.show();
      await tester.pumpAndSettle();
      final initialCount = buildCount;

      await tester.pumpWidget(
        MaterialApp(
          home: RawAnchor(
            controller: controller,
            placement: Placement.top,
            middlewares: _testMiddlewares,
            overlayBuilder: (context) {
              buildCount++;
              return Text('Build $buildCount');
            },
            child: const Text('Child'),
          ),
        ),
      );
      await tester.pump();

      expect(buildCount, greaterThan(initialCount));
    });
  });
}
