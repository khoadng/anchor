import 'package:flutter/material.dart';
import 'package:flutter_anchor/flutter_anchor.dart';

import '../utils.dart';

/// Email model for the demo.
class Email {
  const Email({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    this.isRead = false,
    this.isStarred = false,
  });

  final String sender;
  final String subject;
  final String preview;
  final String time;
  final bool isRead;
  final bool isStarred;
}

/// Sample email data.
final _sampleEmails = [
  const Email(
    sender: 'Google Cloud',
    subject: 'Your monthly invoice is ready',
    preview: 'View your Google Cloud invoice for the month of October...',
    time: '10:30 AM',
    isStarred: true,
  ),
  const Email(
    sender: 'GitHub',
    subject: 'New security vulnerability detected',
    preview: 'We found a potential security vulnerability in one of your...',
    time: '9:15 AM',
  ),
  const Email(
    sender: 'Sarah Johnson',
    subject: 'Re: Project proposal review',
    preview: 'Thanks for sending over the proposal. I had a chance to...',
    time: 'Yesterday',
    isRead: true,
  ),
  const Email(
    sender: 'Team Calendar',
    subject: 'Reminder: Sprint planning tomorrow',
    preview: 'Your sprint planning meeting is scheduled for tomorrow at...',
    time: 'Yesterday',
    isRead: true,
  ),
  const Email(
    sender: 'LinkedIn',
    subject: 'You appeared in 12 searches this week',
    preview: 'Your profile is getting attention! See who viewed your...',
    time: 'Oct 24',
  ),
  const Email(
    sender: 'Figma',
    subject: 'John shared a new design with you',
    preview: 'John has invited you to view and comment on their design...',
    time: 'Oct 24',
    isStarred: true,
  ),
  const Email(
    sender: 'Stripe',
    subject: 'Payment successful',
    preview: r'We received your payment of $29.99 for your monthly...',
    time: 'Oct 23',
    isRead: true,
  ),
  const Email(
    sender: 'Newsletter',
    subject: 'Top 10 Flutter packages this week',
    preview: 'Discover the most popular Flutter packages trending...',
    time: 'Oct 23',
  ),
];

/// Demonstrates virtual positioning for context menus.
///
/// This example shows how to use [AnchorContextMenu] to create
/// Gmail-like context menus for each email in a list.
class ContextMenuDemo extends StatefulWidget {
  const ContextMenuDemo({super.key});

  @override
  State<ContextMenuDemo> createState() => _ContextMenuDemoState();
}

class _ContextMenuDemoState extends State<ContextMenuDemo> {
  final _emails = List<Email>.from(_sampleEmails);
  final _selectedEmails = <int>{};

  void _handleAction(String action, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action: ${_emails[index].subject}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleStar(int index) {
    setState(() {
      final email = _emails[index];
      _emails[index] = Email(
        sender: email.sender,
        subject: email.subject,
        preview: email.preview,
        time: email.time,
        isRead: email.isRead,
        isStarred: !email.isStarred,
      );
    });
  }

  void _markAsRead(int index) {
    setState(() {
      final email = _emails[index];
      _emails[index] = Email(
        sender: email.sender,
        subject: email.subject,
        preview: email.preview,
        time: email.time,
        isRead: true,
        isStarred: email.isStarred,
      );
    });
  }

  void _deleteEmail(int index) {
    setState(() {
      _emails.removeAt(index);
      _selectedEmails.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _emails.length,
        itemBuilder: (context, index) => _EmailItem(
          email: _emails[index],
          isSelected: _selectedEmails.contains(index),
          onTap: () {
            setState(() {
              if (_selectedEmails.contains(index)) {
                _selectedEmails.remove(index);
              } else {
                _selectedEmails.add(index);
              }
            });
          },
          onStar: () => _toggleStar(index),
          onArchive: () => _handleAction('Archived', index),
          onDelete: () => _deleteEmail(index),
          onMarkAsRead: () => _markAsRead(index),
          onMarkAsUnread: () => _handleAction('Marked as unread', index),
          onMute: () => _handleAction('Muted', index),
        ),
      ),
    );
  }
}

/// Individual email item with context menu.
class _EmailItem extends StatelessWidget {
  const _EmailItem({
    required this.email,
    required this.isSelected,
    required this.onTap,
    required this.onStar,
    required this.onArchive,
    required this.onDelete,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
    required this.onMute,
  });

  final Email email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onStar;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    return AnchorContextMenu(
      menuBuilder: (context) {
        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ContextMenuItem(
                  icon: Icons.archive_outlined,
                  label: 'Archive',
                  onTap: () {
                    context.hideMenu();
                    onArchive();
                  },
                ),
                _ContextMenuItem(
                  icon: email.isRead
                      ? Icons.mark_email_unread
                      : Icons.mark_email_read,
                  label: email.isRead ? 'Mark as unread' : 'Mark as read',
                  onTap: () {
                    context.hideMenu();
                    if (email.isRead) {
                      onMarkAsUnread();
                    } else {
                      onMarkAsRead();
                    }
                  },
                ),
                _ContextMenuItem(
                  icon: email.isStarred ? Icons.star : Icons.star_outline,
                  label: email.isStarred ? 'Remove star' : 'Add star',
                  onTap: () {
                    context.hideMenu();
                    onStar();
                  },
                ),
                const Divider(height: 1),
                _ContextMenuItem(
                  icon: Icons.volume_off_outlined,
                  label: 'Mute',
                  onTap: () {
                    context.hideMenu();
                    onMute();
                  },
                ),
                _ContextMenuItem(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onTap: () {
                    context.hideMenu();
                    onDelete();
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue[50]
                : (email.isRead ? Colors.white : Colors.grey[50]),
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  // Star
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: GestureDetector(
                      onTap: onStar,
                      child: Icon(
                        email.isStarred ? Icons.star : Icons.star_outline,
                        size: 20,
                        color:
                            email.isStarred ? Colors.amber : Colors.grey[600],
                      ),
                    ),
                  ),
                  // Email content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                email.sender,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: email.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              email.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email.subject,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: email.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email.preview,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
