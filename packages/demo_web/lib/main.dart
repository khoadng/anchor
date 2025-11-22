import 'dart:js_interop';

import 'package:anchor_ui_example/demos.dart' as anchor_ui;
import 'package:flutter/material.dart';
import 'package:flutter_anchor_example/demos.dart' as flutter_anchor;
import 'package:web/web.dart' as web;

void main() {
  web.document.addEventListener(
    'contextmenu',
    (web.Event event) {
      event.preventDefault();
    }.toJS,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchor Demos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anchor Demos'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Anchor UI Package',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          anchor_ui.DemoCard(
            title: 'Grid View Popovers',
            description: 'Tap-triggered popovers on a scrollable grid',
            icon: Icons.view_quilt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const anchor_ui.GridDemo(
                  itemCount: 100,
                  crossAxisCount: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          anchor_ui.DemoCard(
            title: 'Wikipedia-like Links',
            description: 'Hover over links to preview information',
            icon: Icons.link,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const anchor_ui.WikiLinkDemo()),
            ),
          ),
          const SizedBox(height: 16),
          anchor_ui.DemoCard(
            title: 'macOS Desktop UI',
            description: 'Manual-click menus and dock hover-tooltips',
            icon: Icons.desktop_mac,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const anchor_ui.MacosDesktopDemo(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          anchor_ui.DemoCard(
            title: 'Mailbox Context Menus',
            description: 'Right-click context menus in a mailbox UI',
            icon: Icons.mouse,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const anchor_ui.ContextMenuDemo(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Flutter Anchor Package',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          flutter_anchor.DemoCard(
            title: 'Search Bar Autocomplete',
            description: 'Focus-triggered popover for suggestions',
            icon: Icons.search,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const flutter_anchor.SearchDemo(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          flutter_anchor.DemoCard(
            title: 'Chat Interface',
            description: 'Hover-triggered emoji reaction menus',
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const flutter_anchor.ListViewDemo(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          flutter_anchor.DemoCard(
            title: 'Pointer-Following Tooltip',
            description:
                'Tooltip that follows your cursor or finger position smoothly',
            icon: Icons.touch_app,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const flutter_anchor.PointerFollowDemo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
