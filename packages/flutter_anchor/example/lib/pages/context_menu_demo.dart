import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import '../utils.dart';

/// Demonstrates virtual positioning for context menus.
///
/// This example shows how to use [AnchorContextMenu] to create
/// context menus that appear at the cursor position.
class ContextMenuDemo extends StatelessWidget {
  const ContextMenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Context Menu Demo')),
      body: AnchorContextMenu(
        menuBuilder: (context) {
          return Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContextMenuItem(
                    icon: Icons.content_cut,
                    label: 'Cut',
                    onTap: () {
                      context.hideMenu();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Cut')));
                    },
                  ),
                  _ContextMenuItem(
                    icon: Icons.content_copy,
                    label: 'Copy',
                    onTap: () {
                      context.hideMenu();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Copy')));
                    },
                  ),
                  _ContextMenuItem(
                    icon: Icons.content_paste,
                    label: 'Paste',
                    onTap: () {
                      context.hideMenu();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Paste')));
                    },
                  ),
                ],
              ),
            ),
          );
        },
        childBuilder: (context) => GestureDetector(
          onSecondaryTapDown: isDesktop
              ? (event) {
                  context.showMenu(event.globalPosition);
                }
              : null,
          onLongPressStart: !isDesktop
              ? (details) {
                  context.showMenu(details.globalPosition);
                }
              : null,
          child: Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    isDesktop ? 'Right-click anywhere' : 'Long-press anywhere',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'to open the context menu',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
