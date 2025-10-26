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
  var _isRefreshing = false;

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

  Future<void> _refreshInbox() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _emails.clear();
      _emails.addAll(_sampleEmails);
      _selectedEmails.clear();
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inbox refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showBackgroundAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action),
        duration: const Duration(seconds: 1),
      ),
    );
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDesktop
                        ? 'Right-click on background (Layer 1), sections (Layer 2), or emails (Layer 3) to show different context menus'
                        : 'Long-press on background (Layer 1), sections (Layer 2), or emails (Layer 3) to show different context menus',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnchorContextMenu(
              menuBuilder: (context) {
                return Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[700]!, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header to show this is Layer 1
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.dashboard,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'WORKSPACE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ContextMenuItem(
                          icon: Icons.create_new_folder,
                          label: 'New Folder',
                          onTap: () {
                            context.hideMenu();
                            _showBackgroundAction('Create new folder');
                          },
                          textColor: Colors.white,
                          iconColor: Colors.blue[300],
                        ),
                        _ContextMenuItem(
                          icon: Icons.note_add,
                          label: 'New Email',
                          onTap: () {
                            context.hideMenu();
                            _showBackgroundAction('Compose new email');
                          },
                          textColor: Colors.white,
                          iconColor: Colors.blue[300],
                        ),
                        _ContextMenuItem(
                          icon: Icons.refresh,
                          label: 'Refresh All',
                          onTap: () {
                            context.hideMenu();
                            _refreshInbox();
                          },
                          textColor: Colors.white,
                          iconColor: Colors.blue[300],
                        ),
                        Divider(height: 1, color: Colors.grey[700]),
                        _ContextMenuItem(
                          icon: Icons.view_module,
                          label: 'View Options',
                          onTap: () {
                            context.hideMenu();
                            _showBackgroundAction('View options');
                          },
                          textColor: Colors.white,
                          iconColor: Colors.grey[400],
                        ),
                        _ContextMenuItem(
                          icon: Icons.settings,
                          label: 'Preferences',
                          onTap: () {
                            context.hideMenu();
                            _showBackgroundAction('Preferences');
                          },
                          textColor: Colors.white,
                          iconColor: Colors.grey[400],
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
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        // Section 1: Starred emails (Layer 2)
                        _EmailSection(
                          title: 'Starred',
                          emails: _emails
                              .asMap()
                              .entries
                              .where((e) => e.value.isStarred)
                              .toList(),
                          selectedEmails: _selectedEmails,
                          onTap: (entry) {
                            final index = entry.key;
                            setState(() {
                              if (_selectedEmails.contains(index)) {
                                _selectedEmails.remove(index);
                              } else {
                                _selectedEmails.add(index);
                              }
                            });
                          },
                          onStar: (entry) => _toggleStar(entry.key),
                          onArchive: (entry) =>
                              _handleAction('Archived', entry.key),
                          onDelete: (entry) => _deleteEmail(entry.key),
                          onMarkAsRead: (entry) => _markAsRead(entry.key),
                          onMarkAsUnread: (entry) =>
                              _handleAction('Marked as unread', entry.key),
                          onMute: (entry) => _handleAction('Muted', entry.key),
                        ),
                        // Section 2: Unread emails (Layer 2)
                        _EmailSection(
                          title: 'Unread',
                          emails: _emails
                              .asMap()
                              .entries
                              .where((e) => !e.value.isRead)
                              .toList(),
                          selectedEmails: _selectedEmails,
                          onTap: (entry) {
                            final index = entry.key;
                            setState(() {
                              if (_selectedEmails.contains(index)) {
                                _selectedEmails.remove(index);
                              } else {
                                _selectedEmails.add(index);
                              }
                            });
                          },
                          onStar: (entry) => _toggleStar(entry.key),
                          onArchive: (entry) =>
                              _handleAction('Archived', entry.key),
                          onDelete: (entry) => _deleteEmail(entry.key),
                          onMarkAsRead: (entry) => _markAsRead(entry.key),
                          onMarkAsUnread: (entry) =>
                              _handleAction('Marked as unread', entry.key),
                          onMute: (entry) => _handleAction('Muted', entry.key),
                        ),
                        // Section 3: All other emails (Layer 2)
                        _EmailSection(
                          title: 'Other',
                          emails: _emails
                              .asMap()
                              .entries
                              .where(
                                (e) => e.value.isRead && !e.value.isStarred,
                              )
                              .toList(),
                          selectedEmails: _selectedEmails,
                          onTap: (entry) {
                            final index = entry.key;
                            setState(() {
                              if (_selectedEmails.contains(index)) {
                                _selectedEmails.remove(index);
                              } else {
                                _selectedEmails.add(index);
                              }
                            });
                          },
                          onStar: (entry) => _toggleStar(entry.key),
                          onArchive: (entry) =>
                              _handleAction('Archived', entry.key),
                          onDelete: (entry) => _deleteEmail(entry.key),
                          onMarkAsRead: (entry) => _markAsRead(entry.key),
                          onMarkAsUnread: (entry) =>
                              _handleAction('Marked as unread', entry.key),
                          onMute: (entry) => _handleAction('Muted', entry.key),
                        ),
                      ],
                    ),
                    if (_isRefreshing)
                      const ColoredBox(
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header to show this is Layer 3 (Email)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'EMAIL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _ContextMenuItem(
                  icon: Icons.reply,
                  label: 'Reply',
                  onTap: () {
                    context.hideMenu();
                    onArchive();
                  },
                  textColor: Colors.green[900],
                  iconColor: Colors.green[700],
                ),
                _ContextMenuItem(
                  icon: Icons.forward,
                  label: 'Forward',
                  onTap: () {
                    context.hideMenu();
                    onArchive();
                  },
                  textColor: Colors.green[900],
                  iconColor: Colors.green[700],
                ),
                Divider(height: 1, color: Colors.green[200]),
                _ContextMenuItem(
                  icon: email.isRead
                      ? Icons.mark_email_unread
                      : Icons.mark_email_read,
                  label: email.isRead ? 'Mark Unread' : 'Mark Read',
                  onTap: () {
                    context.hideMenu();
                    if (email.isRead) {
                      onMarkAsUnread();
                    } else {
                      onMarkAsRead();
                    }
                  },
                  textColor: Colors.green[900],
                  iconColor: Colors.green[700],
                ),
                _ContextMenuItem(
                  icon: email.isStarred ? Icons.star : Icons.star_outline,
                  label: email.isStarred ? 'Unstar' : 'Star',
                  onTap: () {
                    context.hideMenu();
                    onStar();
                  },
                  textColor: Colors.green[900],
                  iconColor: Colors.green[700],
                ),
                Divider(height: 1, color: Colors.green[200]),
                _ContextMenuItem(
                  icon: Icons.archive_outlined,
                  label: 'Archive',
                  onTap: () {
                    context.hideMenu();
                    onArchive();
                  },
                  textColor: Colors.green[900],
                  iconColor: Colors.green[700],
                ),
                _ContextMenuItem(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onTap: () {
                    context.hideMenu();
                    onDelete();
                  },
                  textColor: Colors.red[700],
                  iconColor: Colors.red[600],
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

class _EmailSection extends StatelessWidget {
  const _EmailSection({
    required this.title,
    required this.emails,
    required this.selectedEmails,
    required this.onTap,
    required this.onStar,
    required this.onArchive,
    required this.onDelete,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
    required this.onMute,
  });

  final String title;
  final List<MapEntry<int, Email>> emails;
  final Set<int> selectedEmails;
  final void Function(MapEntry<int, Email>) onTap;
  final void Function(MapEntry<int, Email>) onStar;
  final void Function(MapEntry<int, Email>) onArchive;
  final void Function(MapEntry<int, Email>) onDelete;
  final void Function(MapEntry<int, Email>) onMarkAsRead;
  final void Function(MapEntry<int, Email>) onMarkAsUnread;
  final void Function(MapEntry<int, Email>) onMute;

  @override
  Widget build(BuildContext context) {
    if (emails.isEmpty) return const SizedBox.shrink();

    return AnchorContextMenu(
      menuBuilder: (context) {
        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header to show this is Layer 2 (Folder)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'FOLDER: ${title.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _ContextMenuItem(
                  icon: Icons.select_all,
                  label: 'Select All ($title)',
                  onTap: () {
                    context.hideMenu();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Select all in $title folder'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  textColor: Colors.orange[900],
                  iconColor: Colors.orange[700],
                ),
                _ContextMenuItem(
                  icon: Icons.mark_email_read,
                  label: 'Mark All Read',
                  onTap: () {
                    context.hideMenu();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mark all as read in $title folder'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  textColor: Colors.orange[900],
                  iconColor: Colors.orange[700],
                ),
                Divider(height: 1, color: Colors.orange[200]),
                _ContextMenuItem(
                  icon: Icons.drive_file_move,
                  label: 'Move Folder',
                  onTap: () {
                    context.hideMenu();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Move $title folder'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  textColor: Colors.orange[900],
                  iconColor: Colors.orange[700],
                ),
                _ContextMenuItem(
                  icon: Icons.edit,
                  label: 'Rename Folder',
                  onTap: () {
                    context.hideMenu();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rename $title folder'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  textColor: Colors.orange[900],
                  iconColor: Colors.orange[700],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[200],
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            // Section emails (Layer 3)
            ...emails.map(
              (entry) => _EmailItem(
                email: entry.value,
                isSelected: selectedEmails.contains(entry.key),
                onTap: () => onTap(entry),
                onStar: () => onStar(entry),
                onArchive: () => onArchive(entry),
                onDelete: () => onDelete(entry),
                onMarkAsRead: () => onMarkAsRead(entry),
                onMarkAsUnread: () => onMarkAsUnread(entry),
                onMute: () => onMute(entry),
              ),
            ),
          ],
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
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
