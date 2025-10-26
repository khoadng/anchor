import 'package:flutter/material.dart';

import 'pages/grid_demo.dart';
import 'pages/macos_desktop_demo.dart';
import 'pages/mailbox_demo.dart';
import 'pages/wiki_link_demo.dart';
import 'widgets/demo_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchor Demo',
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
      appBar: AppBar(title: const Text('Anchor Demos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DemoCard(
            title: 'Grid View Popovers',
            description: 'Tap-triggered popovers on a scrollable grid',
            icon: Icons.view_quilt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GridDemo()),
            ),
          ),
          const SizedBox(height: 16),
          DemoCard(
            title: 'Wikipedia-like Links',
            description: 'Hover over links to preview information',
            icon: Icons.link,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WikiLinkDemo()),
            ),
          ),
          const SizedBox(height: 16),
          DemoCard(
            title: 'macOS Desktop UI',
            description: 'Manual-click menus and dock hover-tooltips',
            icon: Icons.desktop_mac,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MacosDesktopDemo()),
            ),
          ),
          const SizedBox(height: 16),
          DemoCard(
            title: 'Mailbox Context Menus',
            description: 'Right-click context menus in a mailbox UI',
            icon: Icons.mouse,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContextMenuDemo()),
            ),
          ),
        ],
      ),
    );
  }
}
