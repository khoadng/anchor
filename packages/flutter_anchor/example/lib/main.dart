import 'package:flutter/material.dart';

import 'pages/chat_demo.dart';
import 'pages/context_menu_demo.dart';
import 'pages/grid_demo.dart';
import 'pages/macos_desktop_demo.dart';
import 'pages/search_demo.dart';
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
            title: 'Search Bar Autocomplete',
            description: 'Focus-triggered popover for suggestions',
            icon: Icons.search,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchDemo()),
            ),
          ),
          const SizedBox(height: 16),
          DemoCard(
            title: 'Chat Interface',
            description: 'Hover-triggered emoji reaction menus',
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListViewDemo()),
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
            title: 'Context Menu',
            description: 'Right-click or long-press for a virtual menu',
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
