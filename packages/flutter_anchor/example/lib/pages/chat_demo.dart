import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

class ListViewDemo extends StatelessWidget {
  const ListViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams Chat Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: 20,
          itemBuilder: (context, index) {
            final isMe = index % 3 == 0; // Every 3rd message is from "me"
            return _ChatMessage(isMe: isMe, messageIndex: index);
          },
        ),
      ),
    );
  }
}

class _ChatMessage extends StatefulWidget {
  const _ChatMessage({required this.isMe, required this.messageIndex});
  final bool isMe;
  final int messageIndex;

  @override
  State<_ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<_ChatMessage> {
  String? selectedReaction;

  final List<Map<String, String>> _sampleMessages = [
    {'text': "Hey everyone! How's the project going?", 'time': '9:30 AM'},
    {'text': 'We just finished the sprint planning', 'time': '9:32 AM'},
    {'text': "Great! I'll update the timeline", 'time': '9:35 AM'},
    {'text': 'The design mockups are ready for review', 'time': '9:40 AM'},
    {'text': 'Can we schedule a quick sync?', 'time': '9:45 AM'},
    {'text': 'Sure, how about 2 PM today?', 'time': '9:50 AM'},
    {'text': "Perfect! I'll send the meeting invite", 'time': '9:52 AM'},
    {'text': "Don't forget to review the docs", 'time': '10:00 AM'},
    {'text': 'Already done! Looks good 👍', 'time': '10:05 AM'},
    {'text': 'The deployment is scheduled for tomorrow', 'time': '10:15 AM'},
  ].reversed.toList();

  final _controller = AnchorController();
  final _menuController = MenuController();

  var _isChildHovered = false;

  @override
  void dispose() {
    _controller.dispose();
    _menuController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message =
        _sampleMessages[widget.messageIndex % _sampleMessages.length];
    final names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'];
    final avatarColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final userName =
        widget.isMe ? 'You' : names[widget.messageIndex % names.length];
    final avatarColor = avatarColors[widget.messageIndex % avatarColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[
            CircleAvatar(
              backgroundColor: avatarColor,
              radius: 18,
              child: Text(
                userName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Anchor(
              controller: _controller,
              triggerMode: const ManualTriggerMode(),
              placement: Placement.top,
              middlewares: const [
                OffsetMiddleware(mainAxis: OffsetValue.value(4)),
                ShiftMiddleware(),
              ],
              overlayBuilder: (context) => MouseRegion(
                onEnter: (event) {
                  _isChildHovered = true;
                },
                onExit: (event) {
                  if (!_menuController.isOpen) {
                    _controller.hide();
                  }
                  _isChildHovered = false;
                },
                child: _EmojiReactionBar(
                  menuController: _menuController,
                  onDismiss: () {
                    _menuController.close();
                    _controller.hide();
                  },
                  onEmojiSelected: (emoji) {
                    setState(() {
                      selectedReaction = emoji;
                    });
                  },
                ),
              ),
              child: MouseRegion(
                onEnter: (event) {
                  _controller.show();
                },
                onExit: (event) {
                  if (!_isChildHovered) {
                    _controller.hide();
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.isMe ? Colors.deepPurple : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: avatarColor,
                                    ),
                                  ),
                                ),
                              Text(
                                message['text']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isMe
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message['time']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: widget.isMe
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (selectedReaction != null)
                          const SizedBox(height: 24),
                      ],
                    ),
                    if (selectedReaction != null) ...[
                      Positioned(
                        left: 8,
                        bottom: 0,
                        child: Anchor(
                          triggerMode: const AnchorTriggerMode.hover(),
                          placement: Placement.bottom,
                          overlayBuilder: (context) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'You reacted to this message',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedReaction = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              child: Text(
                                selectedReaction!,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmojiReactionBar extends StatefulWidget {
  const _EmojiReactionBar({
    required this.onEmojiSelected,
    required this.menuController,
    required this.onDismiss,
  });
  final Function(String) onEmojiSelected;
  final MenuController menuController;
  final VoidCallback onDismiss;

  @override
  State<_EmojiReactionBar> createState() => _EmojiReactionBarState();
}

class _EmojiReactionBarState extends State<_EmojiReactionBar> {
  final _buttonFocusNode = FocusNode();

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojis = [
      {'emoji': '👍', 'label': 'Like'},
      {'emoji': '❤️', 'label': 'Love'},
      {'emoji': '😂', 'label': 'Laugh'},
      {'emoji': '😮', 'label': 'Surprised'},
      {'emoji': '😢', 'label': 'Sad'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...emojis.map(
            (emoji) {
              return _EmojiButton(
                emoji: emoji['emoji']!,
                label: emoji['label']!,
                onTap: () => widget.onEmojiSelected(emoji['emoji']!),
              );
            },
          ),
          const Divider(),
          Anchor(
            triggerMode: const HoverTriggerMode(),
            placement: Placement.top,
            spacing: 12,
            overlayBuilder: (context) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "The below menu is using Flutter's MenuAnchor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: MenuAnchor(
              controller: widget.menuController,
              childFocusNode: _buttonFocusNode,
              menuChildren: [
                TextButton(
                  onPressed: () {
                    widget.onDismiss();
                  },
                  child: const Text('Add Reaction'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDismiss();
                  },
                  child: const Text('Report Message'),
                ),
                SubmenuButton(
                  menuChildren: [
                    TextButton(
                      onPressed: () {
                        widget.onDismiss();
                      },
                      child: const Text('Block User'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onDismiss();
                      },
                      child: const Text('Mute Notifications'),
                    ),
                  ],
                  child: const Text('User Options'),
                ),
              ],
              builder: (context, controller, _) => IconButton(
                focusNode: _buttonFocusNode,
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  const _EmojiButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton> {
  var isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Anchor(
      triggerMode: const HoverTriggerMode(),
      placement: Placement.top,
      spacing: 12,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${widget.emoji} ${widget.label}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isHovered ? Colors.grey[200] : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
