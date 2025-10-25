import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import '../utils.dart';

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
              overlayHeight: 80,
              overlayWidth: 420,
              triggerMode: isDesktop
                  ? const HoverTriggerMode(
                      waitDuration: Duration(milliseconds: 200),
                    )
                  : const LongPressTriggerMode(),
              offset: Offset.zero,
              placement: Placement.top,
              enableFlip: false,
              overlayBuilder: (context) => _EmojiReactionBar(
                onEmojiSelected: (emoji) {
                  setState(() {
                    selectedReaction = emoji;
                  });
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.deepPurple : Colors.white,
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
                        color: widget.isMe ? Colors.white : Colors.black87,
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
                            color:
                                widget.isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (selectedReaction != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isMe
                                  ? Colors.deepPurple[700]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedReaction!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _EmojiReactionBar extends StatelessWidget {
  const _EmojiReactionBar({required this.onEmojiSelected});
  final Function(String) onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    final emojis = [
      {'emoji': '👍', 'label': 'Like'},
      {'emoji': '❤️', 'label': 'Love'},
      {'emoji': '😂', 'label': 'Laugh'},
      {'emoji': '😮', 'label': 'Surprised'},
      {'emoji': '😢', 'label': 'Sad'},
      {'emoji': '🎉', 'label': 'Celebrate'},
    ];

    return IntrinsicHeight(
      child: Container(
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
          children: emojis.map((emoji) {
            return _EmojiButton(
              emoji: emoji['emoji']!,
              label: emoji['label']!,
              onTap: () => onEmojiSelected(emoji['emoji']!),
            );
          }).toList(),
        ),
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
      triggerMode: const HoverTriggerMode(
        waitDuration: Duration(milliseconds: 400),
      ),
      placement: Placement.top,
      enableFlip: false,
      overlayBuilder: (context) => IntrinsicHeight(
        child: IntrinsicWidth(
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.emoji,
                  style: TextStyle(fontSize: isHovered ? 26 : 22),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: isHovered ? 14 : 0,
                  child: isHovered
                      ? Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
