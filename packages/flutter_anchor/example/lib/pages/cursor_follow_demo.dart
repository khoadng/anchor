import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import '../utils.dart';

class CursorFollowDemo extends StatefulWidget {
  const CursorFollowDemo({super.key});

  @override
  State<CursorFollowDemo> createState() => _CursorFollowDemoState();
}

class _CursorFollowDemoState extends State<CursorFollowDemo> {
  late final AnchorController _anchorController;
  VirtualReference? _cursorReference;
  Offset _currentPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _anchorController = AnchorController();
  }

  @override
  void dispose() {
    _anchorController.dispose();
    super.dispose();
  }

  void _updatePosition(Offset position) {
    setState(() {
      _currentPosition = position;
      _cursorReference = VirtualReference.fromPoint(position);
      if (!_anchorController.isShowing) {
        _anchorController.show();
      }
    });
  }

  void _hideOverlay() {
    if (_anchorController.isShowing) {
      _anchorController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Material(
            child: GestureDetector(
              onPanStart: !isDesktop
                  ? (details) => _updatePosition(details.globalPosition)
                  : null,
              onPanUpdate: !isDesktop
                  ? (details) => _updatePosition(details.globalPosition)
                  : null,
              onPanEnd: !isDesktop ? (_) => _hideOverlay() : null,
              onTapDown: !isDesktop
                  ? (details) => _updatePosition(details.globalPosition)
                  : null,
              onTapUp: !isDesktop ? (_) => _hideOverlay() : null,
              child: MouseRegion(
                onEnter: (event) => _updatePosition(event.position),
                onHover: (event) => _updatePosition(event.position),
                child: AnchorMiddlewares(
                  middlewares: [
                    if (_cursorReference != null)
                      VirtualReferenceMiddleware(_cursorReference!),
                    const FlipMiddleware(),
                    const ShiftMiddleware(),
                  ],
                  child: RawAnchor(
                    viewPadding: MediaQuery.viewPaddingOf(context),
                    controller: _anchorController,
                    placement: Placement.rightStart,
                    overlayBuilder: (context) {
                      return IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pointer Position',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'X: ${_currentPosition.dx.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Y: ${_currentPosition.dy.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade50,
                            Colors.purple.shade50,
                          ],
                        ),
                      ),
                      child: const _Content(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mouse,
            size: 64,
            color: Colors.black26,
          ),
          SizedBox(height: 16),
          Text(
            'Move your cursor or tap and drag in this area',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'A tooltip will follow your pointer position',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
