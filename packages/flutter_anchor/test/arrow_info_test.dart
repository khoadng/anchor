import 'package:anchor/anchor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_anchor/src/arrow/arrow_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArrowInfo', () {
    test('vertical overlay with left alignment', () {
      const points = AnchorPoints(
        childAnchor: Alignment.bottomLeft,
        overlayAnchor: Alignment.topLeft,
      );

      final arrowInfo = ArrowInfo.fromPoints(points: points);

      expect(arrowInfo.direction, AxisDirection.up);
      expect(arrowInfo.alignment, kArrowAlignmentStart);
    });

    test('vertical overlay with center alignment', () {
      const points = AnchorPoints(
        childAnchor: Alignment.bottomCenter,
        overlayAnchor: Alignment.topCenter,
      );

      final arrowInfo = ArrowInfo.fromPoints(points: points);

      expect(arrowInfo.direction, AxisDirection.up);
      expect(arrowInfo.alignment, kArrowAlignmentCenter);
    });

    test('horizontal overlay with top alignment', () {
      const points = AnchorPoints(
        childAnchor: Alignment.topLeft,
        overlayAnchor: Alignment.topRight,
      );

      final arrowInfo = ArrowInfo.fromPoints(points: points);

      expect(arrowInfo.direction, AxisDirection.right);
      expect(arrowInfo.alignment, kArrowAlignmentStart);
    });
  });
}
