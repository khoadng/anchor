import 'dart:ui';

import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';

const kTooltipHeight = 200.0;
const kTooltipWidth = 200.0;

class _BackdropClipper extends CustomClipper<Path> {
  const _BackdropClipper({this.exclude, this.excludeRadius});
  final Rect? exclude;
  final BorderRadius? excludeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (exclude != null) {
      if (excludeRadius != null) {
        path.addRRect(excludeRadius!.toRRect(exclude!));
      } else {
        path.addRect(exclude!);
      }
      path.fillType = PathFillType.evenOdd;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _BackdropClipper oldClipper) {
    return exclude != oldClipper.exclude ||
        excludeRadius != oldClipper.excludeRadius;
  }
}

class GridDemo extends StatelessWidget {
  const GridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid Demo')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          final colors = [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.teal,
          ];

          return AnchorPopover(
            backgroundColor: Colors.grey[900],
            overlayHeight: kTooltipHeight,
            overlayWidth: kTooltipWidth,
            triggerMode: const AnchorTriggerMode.tap(consumeOutsideTap: false),
            backdropBuilder: (context) => IgnorePointer(
              child: ClipPath(
                clipper: _BackdropClipper(
                  exclude: AnchorData.of(context).geometry.childBounds,
                  excludeRadius: BorderRadius.circular(8),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black26),
                ),
              ),
            ),
            arrowShape: const RoundedArrow(),
            borderRadius: BorderRadius.circular(16),
            border: const BorderSide(color: Colors.blue),
            overlayBuilder: (context) =>
                _TooltipContainer(title: 'Grid Item $index'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Item $index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TooltipContainer extends StatelessWidget {
  const _TooltipContainer({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kTooltipHeight,
      width: kTooltipWidth,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              primary: false,
              itemCount: 15,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.article, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () {
                            debugPrint('Tooltip title long-pressed: $title');
                          },
                          onTap: () {
                            debugPrint('Tooltip title tapped: $title');
                          },
                          child: Text(
                            'Property ${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
