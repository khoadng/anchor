import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

class SearchDemo extends StatefulWidget {
  const SearchDemo({super.key});

  @override
  State<SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<SearchDemo> {
  final _focusNode = FocusNode();
  final _focusNode2 = FocusNode();
  final _searchController = TextEditingController();
  final _searchController2 = TextEditingController();

  final _suggestions = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  final _countries = [
    'United States',
    'Canada',
    'Mexico',
    'United Kingdom',
    'Germany',
    'France',
    'Japan',
    'Australia',
  ];

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode2.dispose();
    _searchController.dispose();
    _searchController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _SearchAnchor(
                suggestions: _suggestions,
                controller: _searchController,
                focusNode: _focusNode,
                hintText: 'Search fruits...',
                width: 300,
                height: 200,
              ),
              const Spacer(),
              _SearchAnchor(
                suggestions: _countries,
                controller: _searchController2,
                focusNode: _focusNode2,
                hintText: 'Search countries...',
                width: 300,
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAnchor extends StatefulWidget {
  const _SearchAnchor({
    required this.suggestions,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.width,
    required this.height,
  });
  final List<String> suggestions;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double width;
  final double height;

  @override
  State<_SearchAnchor> createState() => _SearchAnchorState();
}

class _SearchAnchorState extends State<_SearchAnchor> {
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.suggestions;
    widget.controller.addListener(_filter);
  }

  @override
  void didUpdateWidget(covariant _SearchAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions) {
      _filtered = widget.suggestions;
      _filter();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_filter);
    super.dispose();
  }

  void _filter() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      _filtered = widget.suggestions
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  void _select(String suggestion) {
    widget.controller.text = suggestion;
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Anchor(
        triggerMode: AnchorTriggerMode.focus(focusNode: widget.focusNode),
        placement: Placement.bottom,
        overlayWidth: widget.width,
        overlayHeight: widget.height,
        overlayBuilder: (context) {
          return Container(
            width: widget.width,
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final suggestion = _filtered[index];
                      return InkWell(
                        onTap: () => _select(suggestion),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(suggestion),
                        ),
                      );
                    },
                  ),
          );
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}
