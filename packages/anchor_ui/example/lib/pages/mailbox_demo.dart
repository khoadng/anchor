import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

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
  final _emails = List<_Email>.from(_sampleEmails);
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

  void _updateEmail(int index, {bool? isRead, bool? isStarred}) {
    setState(() {
      _emails[index] = _emails[index].copyWith(
        isRead: isRead,
        isStarred: isStarred,
      );
    });
  }

  void _toggleStar(int index) {
    final email = _emails[index];
    _updateEmail(index, isStarred: !email.isStarred);
  }

  void _markAsRead(int index) {
    _updateEmail(index, isRead: true);
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

  void _toggleEmailSelection(int index) {
    setState(() {
      if (_selectedEmails.contains(index)) {
        _selectedEmails.remove(index);
      } else {
        _selectedEmails.add(index);
      }
    });
  }

  Widget _buildEmailSection({
    required String title,
    required bool Function(MapEntry<int, _Email>) filter,
  }) {
    return _EmailSectionWidget(
      title: title,
      emails: _emails,
      filter: filter,
      selectedEmails: _selectedEmails,
      onToggleSelection: _toggleEmailSelection,
      onToggleStar: _toggleStar,
      onArchive: (i) => _handleAction('Archived', i),
      onDelete: _deleteEmail,
      onMarkAsRead: _markAsRead,
      onMarkAsUnread: (i) => _handleAction('Marked as unread', i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      child: Scaffold(
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
            _InfoBanner(),
            Expanded(
              child: _WorkspaceContextMenu(
                onRefresh: _refreshInbox,
                onShowAction: _showBackgroundAction,
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        _buildEmailSection(
                          title: 'Starred',
                          filter: (e) => e.value.isStarred,
                        ),
                        _buildEmailSection(
                          title: 'Unread',
                          filter: (e) => !e.value.isRead,
                        ),
                        _buildEmailSection(
                          title: 'Other',
                          filter: (e) => e.value.isRead && !e.value.isStarred,
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
          ],
        ),
      ),
    );
  }
}

class _EmailCheckbox extends StatelessWidget {
  const _EmailCheckbox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 4),
      child: Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        size: 20,
        color: Colors.grey[600],
      ),
    );
  }
}

class _EmailStarIcon extends StatelessWidget {
  const _EmailStarIcon({
    required this.isStarred,
    required this.onTap,
  });

  final bool isStarred;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          isStarred ? Icons.star : Icons.star_outline,
          size: 20,
          color: isStarred ? Colors.amber : Colors.grey[600],
        ),
      ),
    );
  }
}

class _EmailContent extends StatelessWidget {
  const _EmailContent({required this.email});

  final _Email email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                email.sender,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      email.isRead ? FontWeight.normal : FontWeight.bold,
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
            fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
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
    );
  }
}

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
  });

  final _Email email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onStar;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;

  @override
  Widget build(BuildContext context) {
    final colors = _MenuColorScheme.green;
    return AnchorContextMenu(
      placement: Placement.rightStart,
      viewPadding: const EdgeInsets.all(8),
      menuBuilder: (context) => _MenuContainer(
        color: colors.background,
        borderColor: colors.border,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuHeader(
              icon: Icons.email,
              label: 'EMAIL',
              backgroundColor: colors.header,
            ),
            _ContextMenuItem(
              icon: Icons.reply,
              label: 'Reply',
              onTap: onArchive,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.forward,
              label: 'Forward',
              onTap: onArchive,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            const Divider(height: 1),
            _ContextMenuItem(
              icon: email.isRead
                  ? Icons.mark_email_unread
                  : Icons.mark_email_read,
              label: email.isRead ? 'Mark Unread' : 'Mark Read',
              onTap: email.isRead ? onMarkAsUnread : onMarkAsRead,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: email.isStarred ? Icons.star : Icons.star_outline,
              label: email.isStarred ? 'Unstar' : 'Star',
              onTap: onStar,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            const Divider(height: 1),
            _ContextMenuItem(
              icon: Icons.archive_outlined,
              label: 'Archive',
              onTap: onArchive,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: onDelete,
              textColor: Colors.red[700],
              iconColor: Colors.red[600],
            ),
          ],
        ),
      ),
      childBuilder: (context) => _ContextMenuGestureDetector(
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
                  _EmailCheckbox(isSelected: isSelected),
                  _EmailStarIcon(isStarred: email.isStarred, onTap: onStar),
                  Expanded(child: _EmailContent(email: email)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _WorkspaceContextMenu extends StatelessWidget {
  const _WorkspaceContextMenu({
    required this.child,
    required this.onRefresh,
    required this.onShowAction,
  });

  final Widget child;
  final VoidCallback onRefresh;
  final void Function(String) onShowAction;

  @override
  Widget build(BuildContext context) {
    final colors = _MenuColorScheme.workspace;
    return AnchorContextMenu(
      placement: Placement.rightStart,
      menuBuilder: (context) => _MenuContainer(
        color: colors.background,
        borderColor: colors.border,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuHeader(
              icon: Icons.dashboard,
              label: 'WORKSPACE',
              backgroundColor: colors.header,
            ),
            _ContextMenuItem(
              icon: Icons.create_new_folder,
              label: 'New Folder',
              onTap: () => onShowAction('Create new folder'),
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.note_add,
              label: 'New Email',
              onTap: () => onShowAction('Compose new email'),
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.refresh,
              label: 'Refresh All',
              onTap: onRefresh,
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            const Divider(height: 1),
            _ContextMenuItem(
              icon: Icons.view_module,
              label: 'View Options',
              onTap: () => onShowAction('View options'),
              textColor: colors.text,
              iconColor: Colors.grey[400],
            ),
            _ContextMenuItem(
              icon: Icons.settings,
              label: 'Preferences',
              onTap: () => onShowAction('Preferences'),
              textColor: colors.text,
              iconColor: Colors.grey[400],
            ),
          ],
        ),
      ),
      childBuilder: (context) => _ContextMenuGestureDetector(child: child),
    );
  }
}

class _ContextMenuGestureDetector extends StatelessWidget {
  const _ContextMenuGestureDetector({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: child,
    );
  }
}

class _MenuContainer extends StatelessWidget {
  const _MenuContainer({
    required this.child,
    required this.color,
    required this.borderColor,
  });

  final Widget child;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: child,
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailSectionWidget extends StatelessWidget {
  const _EmailSectionWidget({
    required this.title,
    required this.emails,
    required this.filter,
    required this.selectedEmails,
    required this.onToggleSelection,
    required this.onToggleStar,
    required this.onArchive,
    required this.onDelete,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
  });

  final String title;
  final List<_Email> emails;
  final bool Function(MapEntry<int, _Email>) filter;
  final Set<int> selectedEmails;
  final void Function(int) onToggleSelection;
  final void Function(int) onToggleStar;
  final void Function(int) onArchive;
  final void Function(int) onDelete;
  final void Function(int) onMarkAsRead;
  final void Function(int) onMarkAsUnread;

  @override
  Widget build(BuildContext context) {
    final filteredEmails = emails.asMap().entries.where(filter).toList();
    if (filteredEmails.isEmpty) return const SizedBox.shrink();

    final colors = _MenuColorScheme.orange;
    return AnchorContextMenu(
      placement: Placement.rightStart,
      menuBuilder: (context) => _MenuContainer(
        color: colors.background,
        borderColor: colors.border,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuHeader(
              icon: Icons.folder,
              label: 'FOLDER: ${title.toUpperCase()}',
              backgroundColor: colors.header,
            ),
            _ContextMenuItem(
              icon: Icons.select_all,
              label: 'Select All ($title)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Select all in $title folder'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.mark_email_read,
              label: 'Mark All Read',
              onTap: () {},
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            const Divider(height: 1),
            _ContextMenuItem(
              icon: Icons.drive_file_move,
              label: 'Move Folder',
              onTap: () {},
              textColor: colors.text,
              iconColor: colors.icon,
            ),
            _ContextMenuItem(
              icon: Icons.edit,
              label: 'Rename Folder',
              onTap: () {},
              textColor: colors.text,
              iconColor: colors.icon,
            ),
          ],
        ),
      ),
      childBuilder: (context) => _ContextMenuGestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ...filteredEmails.map(
              (entry) => _EmailItem(
                email: entry.value,
                isSelected: selectedEmails.contains(entry.key),
                onTap: () => onToggleSelection(entry.key),
                onStar: () => onToggleStar(entry.key),
                onArchive: () => onArchive(entry.key),
                onDelete: () => onDelete(entry.key),
                onMarkAsRead: () => onMarkAsRead(entry.key),
                onMarkAsUnread: () => onMarkAsUnread(entry.key),
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
      onTap: () {
        context.hideMenu();
        onTap();
      },
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

class _Email {
  const _Email({
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

  _Email copyWith({
    String? sender,
    String? subject,
    String? preview,
    String? time,
    bool? isRead,
    bool? isStarred,
  }) {
    return _Email(
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}

class _MenuColorScheme {
  const _MenuColorScheme({
    required this.background,
    required this.border,
    required this.header,
    required this.text,
    required this.icon,
    this.divider,
  });

  final Color background;
  final Color border;
  final Color header;
  final Color text;
  final Color icon;
  final Color? divider;

  static final green = _MenuColorScheme(
    background: Colors.green[50]!,
    border: Colors.green[300]!,
    header: Colors.green[600]!,
    text: Colors.green[900]!,
    icon: Colors.green[700]!,
    divider: Colors.green[200],
  );

  static final orange = _MenuColorScheme(
    background: Colors.orange[50]!,
    border: Colors.orange[300]!,
    header: Colors.orange[600]!,
    text: Colors.orange[900]!,
    icon: Colors.orange[700]!,
    divider: Colors.orange[200],
  );

  static final workspace = _MenuColorScheme(
    background: Colors.grey[900]!,
    border: Colors.grey[700]!,
    header: Colors.blue[700]!,
    text: Colors.white,
    icon: Colors.blue[300]!,
    divider: Colors.grey[700],
  );
}

final _sampleEmails = [
  const _Email(
    sender: 'Google Cloud',
    subject: 'Your monthly invoice is ready',
    preview: 'View your Google Cloud invoice for the month of October...',
    time: '10:30 AM',
    isStarred: true,
  ),
  const _Email(
    sender: 'GitHub',
    subject: 'New security vulnerability detected',
    preview: 'We found a potential security vulnerability in one of your...',
    time: '9:15 AM',
  ),
  const _Email(
    sender: 'Sarah Johnson',
    subject: 'Re: Project proposal review',
    preview: 'Thanks for sending over the proposal. I had a chance to...',
    time: 'Yesterday',
    isRead: true,
  ),
  const _Email(
    sender: 'Team Calendar',
    subject: 'Reminder: Sprint planning tomorrow',
    preview: 'Your sprint planning meeting is scheduled for tomorrow at...',
    time: 'Yesterday',
    isRead: true,
  ),
];
