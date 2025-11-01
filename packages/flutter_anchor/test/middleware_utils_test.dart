import 'package:flutter_anchor/flutter_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MiddlewareUtils', () {
    group('areMiddlewaresEqual', () {
      test('returns true for identical lists', () {
        final middlewares = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(middlewares, middlewares),
          isTrue,
        );
      });

      test('returns false for different lengths', () {
        final a = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        final b = <PositioningMiddleware>[
          const FlipMiddleware(),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(a, b),
          isFalse,
        );
      });

      test('returns false for different order', () {
        final a = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        final b = <PositioningMiddleware>[
          const ShiftMiddleware(),
          const FlipMiddleware(),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(a, b),
          isFalse,
        );
      });

      test('returns false for different middleware types', () {
        final a = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        final b = <PositioningMiddleware>[
          const FlipMiddleware(),
          const SizeMiddleware(),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(a, b),
          isFalse,
        );
      });

      test('returns false for different OffsetMiddleware values', () {
        final a = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        ];

        final b = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(8)),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(a, b),
          isFalse,
        );
      });

      test('returns true for equal OffsetMiddleware values', () {
        final a = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        ];

        final b = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        ];

        expect(
          MiddlewareUtils.areMiddlewaresEqual(a, b),
          isTrue,
        );
      });
    });

    group('hashMiddlewares', () {
      test('returns 0 for null', () {
        expect(
          MiddlewareUtils.hashMiddlewares(null),
          equals(0),
        );
      });

      test('returns same hash for equal middlewares', () {
        final a = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        final b = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        expect(
          MiddlewareUtils.hashMiddlewares(a),
          equals(MiddlewareUtils.hashMiddlewares(b)),
        );
      });

      test('returns different hash for different middlewares', () {
        final a = <PositioningMiddleware>[
          const FlipMiddleware(),
          const ShiftMiddleware(),
        ];

        final b = <PositioningMiddleware>[
          const ShiftMiddleware(),
          const FlipMiddleware(),
        ];

        expect(
          MiddlewareUtils.hashMiddlewares(a),
          isNot(equals(MiddlewareUtils.hashMiddlewares(b))),
        );
      });

      test('handles OffsetMiddleware values', () {
        final a = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        ];

        final b = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(4)),
        ];

        final c = [
          const OffsetMiddleware(mainAxis: OffsetValue.value(8)),
        ];

        expect(
          MiddlewareUtils.hashMiddlewares(a),
          equals(MiddlewareUtils.hashMiddlewares(b)),
        );

        expect(
          MiddlewareUtils.hashMiddlewares(a),
          isNot(equals(MiddlewareUtils.hashMiddlewares(c))),
        );
      });
    });
  });
}
