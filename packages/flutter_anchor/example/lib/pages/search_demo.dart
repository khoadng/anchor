import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';

class SearchDemo extends StatefulWidget {
  const SearchDemo({super.key});

  @override
  State<SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<SearchDemo> {
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
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final padding = viewPadding + viewInsets;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Demo')),
      body: Center(
        child: Column(
          children: [
            _SearchAnchor(
              suggestions: _suggestions,
              hintText: 'Search fruits...',
              spacing: 8,
              viewPadding: padding,
            ),
            const Spacer(),
            _SearchAnchor(
              suggestions: _countries,
              hintText: 'Search countries...',
              spacing: -8,
              viewPadding: padding,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAnchor extends StatefulWidget {
  const _SearchAnchor({
    required this.suggestions,
    required this.hintText,
    required this.spacing,
    required this.viewPadding,
  });
  final List<String> suggestions;
  final String hintText;
  final double spacing;
  final EdgeInsets viewPadding;

  @override
  State<_SearchAnchor> createState() => _SearchAnchorState();
}

class _SearchAnchorState extends State<_SearchAnchor> {
  final _controller = TextEditingController();
  late List<String> _filtered;
  void _filter() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filtered = widget.suggestions
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filtered = widget.suggestions;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: AnchorAutocomplete(
        controller: _controller,
        viewPadding: widget.viewPadding,
        placement: Placement.bottom,
        spacing: widget.spacing,
        overlayBuilder: (context, _, focusNode) {
          return Container(
            width: AnchorData.maybeOf(context)?.geometry.childBounds?.width,
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
                        onTap: () {
                          _controller.text = suggestion;
                          focusNode.unfocus();
                        },
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
        childBuilder: (context, _, focusNode) {
          return TextField(
            controller: _controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }
}
