# anchor_tour

Guided tours and coach marks built on top of `flutter_anchor`.

`anchor_tour` separates tour sequencing from widget placement:

- `AnchorTourTarget` marks widgets in the rendered tree.
- `AnchorTourStep` describes what to show for a target.
- `AnchorTourScope` resolves targets and owns tour policy.
- `AnchorTourController` starts, advances, skips, and finishes the tour.

```dart
final tour = AnchorTourController();

AnchorTourScope(
  controller: tour,
  steps: [
    AnchorTourStep(
      id: 'billing',
      target: 'billing-tab',
      enter: (context, tour) {
        context.read<TabsController>().showBilling();
      },
      builder: (context, tour) {
        return TextButton(
          onPressed: tour.next,
          child: const Text('This is billing'),
        );
      },
    ),
  ],
  child: App(),
);

AnchorTourTarget(
  id: 'billing-tab',
  child: BillingTab(),
);

tour.start();
```

The core package is state-management agnostic. Put `AnchorTourController`
wherever the app already stores state, and use step `enter` hooks to update
tabs, routes, or async UI before the target is resolved.

If a target is missing, `onTargetNotFound` is called once for that step
activation. Use it for side effects such as logging or revealing fallback UI;
the package keeps waiting until `targetTimeout`. The callback receives the same
`AnchorTourContext` shape as step hooks.

`AnchorTourContext.targetRect`, `overlayRect`, and `direction` are only
available while building tour content. Lifecycle hooks run before overlay
layout, so their geometry fields are null.

Material tooltips inside tour content are suppressed by default. Nested overlay
tooltips can conflict with anchored tour overlays during hover layout.
