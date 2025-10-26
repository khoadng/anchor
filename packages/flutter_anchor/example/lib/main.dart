import 'package:flutter/material.dart';

import 'pages/chat_demo.dart';
import 'pages/search_demo.dart';
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
        ],
      ),
    );
  }
}
