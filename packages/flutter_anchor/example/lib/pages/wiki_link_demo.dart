import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

// Wikipedia-like Link Preview Demo
class WikiLinkDemo extends StatelessWidget {
  const WikiLinkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikipedia-like Link Preview'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flutter Framework',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const _WikiParagraph(
                children: [
                  _WikiText('Flutter is an open-source '),
                  _WikiLink(
                    text: 'UI software development kit',
                    previewTitle: 'UI Software Development Kit',
                    previewContent:
                        'A UI software development kit (SDK) is a collection of software development tools that allows developers to create user interfaces for applications. It typically includes libraries, documentation, code samples, and tools that simplify the development process.',
                    previewImage: Icons.developer_board,
                  ),
                  _WikiText(' created by '),
                  _WikiLink(
                    text: 'Google',
                    previewTitle: 'Google LLC',
                    previewContent:
                        'Google is an American multinational technology company focusing on search engine technology, online advertising, cloud computing, computer software, quantum computing, e-commerce, and consumer electronics.',
                    previewImage: Icons.business,
                  ),
                  _WikiText(
                    '. It is used to develop cross-platform applications from a single ',
                  ),
                  _WikiLink(
                    text: 'codebase',
                    previewTitle: 'Codebase',
                    previewContent:
                        'A codebase is the complete body of source code for a software program or application. It includes all the files and folders that contain the code, along with configuration files, documentation, and other resources.',
                    previewImage: Icons.code,
                  ),
                  _WikiText(' for '),
                  _WikiLink(
                    text: 'Android',
                    previewTitle: 'Android (operating system)',
                    previewContent:
                        'Android is a mobile operating system based on a modified version of the Linux kernel and other open-source software, designed primarily for touchscreen mobile devices such as smartphones and tablets.',
                    previewImage: Icons.android,
                  ),
                  _WikiText(', '),
                  _WikiLink(
                    text: 'iOS',
                    previewTitle: 'iOS',
                    previewContent:
                        "iOS is a mobile operating system developed by Apple Inc. exclusively for its hardware. It powers many of the company's mobile devices, including the iPhone and iPod Touch.",
                    previewImage: Icons.phone_iphone,
                  ),
                  _WikiText(', Linux, macOS, Windows, and the web.'),
                ],
              ),
              const SizedBox(height: 16),
              const _WikiParagraph(
                children: [
                  _WikiText('The first version of Flutter was known as '),
                  _WikiLink(
                    text: '"Sky"',
                    previewTitle: 'Sky (Flutter)',
                    previewContent:
                        'Sky was the codename for Flutter during its early development. It was first unveiled at the 2015 Dart developer summit with the goal of rendering consistently at 120 frames per second.',
                    previewImage: Icons.cloud,
                  ),
                  _WikiText(' and ran on the '),
                  _WikiLink(
                    text: 'Android',
                    previewTitle: 'Android (operating system)',
                    previewContent:
                        'Android is a mobile operating system based on a modified version of the Linux kernel and other open-source software, designed primarily for touchscreen mobile devices.',
                    previewImage: Icons.android,
                  ),
                  _WikiText(' operating system. Flutter uses the '),
                  _WikiLink(
                    text: 'Dart',
                    previewTitle: 'Dart (programming language)',
                    previewContent:
                        'Dart is a programming language designed by Google for building mobile, desktop, server, and web applications. It is an object-oriented, class-based language with C-style syntax.',
                    previewImage: Icons.code_outlined,
                  ),
                  _WikiText(
                    ' programming language, which was created by ',
                  ),
                  _WikiLink(
                    text: 'Google',
                    previewTitle: 'Google LLC',
                    previewContent:
                        'Google is an American multinational technology company focusing on search engine technology, online advertising, cloud computing, and artificial intelligence.',
                    previewImage: Icons.business,
                  ),
                  _WikiText(' in 2011.'),
                ],
              ),
              const SizedBox(height: 16),
              const _WikiParagraph(
                children: [
                  _WikiText('Flutter uses a '),
                  _WikiLink(
                    text: 'reactive programming',
                    previewTitle: 'Reactive Programming',
                    previewContent:
                        'Reactive programming is a declarative programming paradigm concerned with data streams and the propagation of change. It means that when a data flow is emitted by one component, the change will automatically propagate to other components.',
                    previewImage: Icons.sync,
                  ),
                  _WikiText(' style framework. It includes a '),
                  _WikiLink(
                    text: 'rendering engine',
                    previewTitle: 'Rendering Engine',
                    previewContent:
                        'A rendering engine is software that draws text and images on the screen. In Flutter, the rendering engine is called Skia, which is a 2D graphics library developed by Google.',
                    previewImage: Icons.brush,
                  ),
                  _WikiText(', ready-made '),
                  _WikiLink(
                    text: 'widgets',
                    previewTitle: 'Widget (Flutter)',
                    previewContent:
                        "In Flutter, widgets are the basic building blocks of a Flutter app's user interface. Each widget is an immutable declaration of part of the user interface. Everything in Flutter is a widget.",
                    previewImage: Icons.widgets,
                  ),
                  _WikiText(', testing and integration '),
                  _WikiLink(
                    text: 'APIs',
                    previewTitle: 'Application Programming Interface',
                    previewContent:
                        'An API is a set of protocols and tools for building software applications. It specifies how software components should interact and are used when programming graphical user interface (GUI) components.',
                    previewImage: Icons.api,
                  ),
                  _WikiText(', and command-line tools.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WikiParagraph extends StatelessWidget {
  const _WikiParagraph({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _WikiText extends StatelessWidget {
  const _WikiText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }
}

class _WikiLink extends StatefulWidget {
  const _WikiLink({
    required this.text,
    required this.previewTitle,
    required this.previewContent,
    required this.previewImage,
  });

  final String text;
  final String previewTitle;
  final String previewContent;
  final IconData previewImage;

  @override
  State<_WikiLink> createState() => _WikiLinkState();
}

class _WikiLinkState extends State<_WikiLink> {
  var isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnchorPopover(
      overlayHeight: 180,
      overlayWidth: 320,
      triggerMode: const AnchorTriggerMode.hover(
        waitDuration: Duration(milliseconds: 400),
      ),
      placement: Placement.topStart,
      backgroundColor: const Color(0xFF1E293B),
      arrowAlignment: 0.05,
      arrowSize: const Size(20, 10),
      borderRadius: BorderRadius.circular(8),
      overlayBuilder: (context) => _WikiPreviewCardContent(
        title: widget.previewTitle,
        content: widget.previewContent,
        icon: widget.previewImage,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigating to: ${widget.previewTitle}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isHovered ? Colors.indigo[700] : Colors.indigo,
              decoration:
                  isHovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: Colors.indigo[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _WikiPreviewCardContent extends StatelessWidget {
  const _WikiPreviewCardContent({
    required this.title,
    required this.content,
    required this.icon,
  });
  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF60A5FA), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(
                content,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border(top: BorderSide(color: Color(0xFF334155))),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 4),
                Text(
                  'Click to view full article',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
