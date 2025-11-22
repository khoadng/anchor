import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class MacosDesktopDemo extends StatefulWidget {
  const MacosDesktopDemo({super.key});

  @override
  State<MacosDesktopDemo> createState() => _MacosDesktopDemoState();
}

class _MacosDesktopDemoState extends State<MacosDesktopDemo> {
  String? _activeMenuKey;
  var _isDockOnLeft = false;

  final _anchorControllers = <String, AnchorController>{
    'music': AnchorController(),
    'bluetooth': AnchorController(),
    'wifi': AnchorController(),
    'battery': AnchorController(),
  };

  @override
  void dispose() {
    _anchorControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleMenu(String menuKey) {
    if (_activeMenuKey != null) {
      _anchorControllers[_activeMenuKey!]!.hide();
    }

    if (_activeMenuKey != menuKey) {
      setState(() {
        _activeMenuKey = menuKey;
        _anchorControllers[menuKey]!.show();
      });
    } else {
      setState(() {
        _activeMenuKey = null;
      });
    }
  }

  Widget _buildMenuItem({
    required String key,
    required IconData icon,
    required Widget content,
  }) {
    return Anchor(
      controller: _anchorControllers[key],
      triggerMode: const AnchorTriggerMode.manual(),
      placement: Placement.bottomStart,
      offset: const Offset(0, 10),
      overlayBuilder: (context) => TapRegion(
        onTapOutside: (event) {
          if (_activeMenuKey != null) {
            _toggleMenu(_activeMenuKey!);
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      ),
      child: _MenuBarItem(
        icon: Icon(icon, color: Colors.black87),
        isActive: _activeMenuKey == key,
        onTap: () => _toggleMenu(key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(context),
            Expanded(
              child: AnchorContextMenu(
                placement: Placement.rightStart,
                viewPadding: const EdgeInsets.all(8),
                menuBuilder: _buildContextMenu,
                childBuilder: (context) => Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
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
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isDesktop
                                      ? 'Click an icon in the top-right bar, hover over dock icons, or right-click on background. 👆'
                                      : 'Click an icon in the top-right bar, hover over dock icons, or long-press on background. 👆',
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isDockOnLeft = !_isDockOnLeft;
                                    });
                                  },
                                  icon: Icon(
                                    _isDockOnLeft
                                        ? Icons.arrow_downward
                                        : Icons.arrow_back,
                                  ),
                                  label: Text(
                                    _isDockOnLeft
                                        ? 'Move Dock to Bottom'
                                        : 'Move Dock to Left',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!_isDockOnLeft)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(child: _MacosDock(isVertical: false)),
                      ),
                    if (_isDockOnLeft)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(child: _MacosDock(isVertical: true)),
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

  Widget _buildContextMenu(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ContextMenuItem(
              icon: Icons.refresh,
              label: 'Refresh',
            ),
            const _ContextMenuItem(
              icon: Icons.sort,
              label: 'Sort By',
            ),
            Divider(height: 1, color: Colors.grey[300]),
            const _ContextMenuItem(
              icon: Icons.display_settings,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final menuItems = [
      (
        key: 'music',
        icon: Icons.music_note,
        content: const _MusicPopoverContent()
      ),
      (
        key: 'bluetooth',
        icon: Icons.bluetooth,
        content: const _BluetoothPopoverContent()
      ),
      (key: 'wifi', icon: Icons.wifi, content: const _WifiPopoverContent()),
      (
        key: 'battery',
        icon: Icons.battery_charging_full,
        content: const _BatteryPopoverContent()
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          for (final item in menuItems) ...[
            _buildMenuItem(
              key: item.key,
              icon: item.icon,
              content: item.content,
            ),
            const SizedBox(width: 8),
          ],
          const SizedBox(width: 8),
          const _MenuBarClock(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _MenuBarItem extends StatelessWidget {
  const _MenuBarItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final Icon icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: icon,
      ),
    );
  }
}

class _PopoverContainer extends StatelessWidget {
  const _PopoverContainer({
    required this.width,
    required this.child,
  });
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _BatteryPopoverContent extends StatelessWidget {
  const _BatteryPopoverContent();

  @override
  Widget build(BuildContext context) {
    return const _PopoverContainer(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Battery',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('100%', style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Power Source: Power Adapter',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Fully Charged',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Divider(height: 24, color: Colors.white24),
          _SectionHeader(title: 'Using Significant Energy'),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.flash_on, color: Color(0xFFF75A0D), size: 20),
              SizedBox(width: 8),
              Text('Brave Browser', style: TextStyle(color: Colors.white)),
            ],
          ),
          Divider(height: 24, color: Colors.white24),
          Text('Battery Settings...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _WifiPopoverContent extends StatelessWidget {
  const _WifiPopoverContent();
  @override
  Widget build(BuildContext context) {
    return const _PopoverContainer(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Wi-Fi'),
          SizedBox(height: 8),
          _ContentRow(
            icon: Icons.wifi,
            text: 'MyHomeNetwork_5G',
            isConnected: true,
          ),
          _ContentRow(icon: Icons.wifi, text: 'CoffeeShop_Guest'),
          _ContentRow(icon: Icons.wifi_off, text: 'NeighborNet', isDim: true),
          Divider(height: 24, color: Colors.white24),
          Text('Network Settings...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _BluetoothPopoverContent extends StatelessWidget {
  const _BluetoothPopoverContent();
  @override
  Widget build(BuildContext context) {
    return const _PopoverContainer(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Bluetooth'),
          SizedBox(height: 8),
          _ContentRow(
            icon: Icons.headphones,
            text: 'My AirPods',
            isConnected: true,
          ),
          _ContentRow(icon: Icons.mouse, text: 'Magic Mouse'),
          Divider(height: 24, color: Colors.white24),
          Text('Bluetooth Settings...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _MusicPopoverContent extends StatelessWidget {
  const _MusicPopoverContent();
  @override
  Widget build(BuildContext context) {
    return _PopoverContainer(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  color: Colors.blueGrey,
                  height: 40,
                  width: 40,
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Song Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Artist Name',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.skip_previous, color: Colors.white),
              Icon(Icons.pause, color: Colors.white, size: 32),
              Icon(Icons.skip_next, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 13,
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({
    required this.icon,
    required this.text,
    this.isConnected = false,
    this.isDim = false,
  });
  final IconData icon;
  final String text;
  final bool isConnected;
  final bool isDim;

  @override
  Widget build(BuildContext context) {
    final color = isDim
        ? Colors.white38
        : isConnected
            ? Colors.blue
            : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
          if (isConnected)
            const Icon(Icons.check, color: Colors.blue, size: 20),
        ],
      ),
    );
  }
}

class _MenuBarClock extends StatelessWidget {
  const _MenuBarClock();

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('E d MMM HH:mm').format(DateTime.now());

    return Text(
      formattedTime,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

class _MacosDock extends StatelessWidget {
  _MacosDock({required this.isVertical});
  final bool isVertical;

  late final _apps = <_DockApp>[
    _DockApp(name: 'Finder', icon: Icons.folder, color: Colors.blue),
    _DockApp(name: 'Mail', icon: Icons.mail, color: Colors.blue[400]!),
    _DockApp(name: 'Messages', icon: Icons.message, color: Colors.green),
    if (isDesktop) ...[
      _DockApp(
        name: 'Photos',
        icon: Icons.photo_library,
        color: Colors.red[400]!,
      ),
      _DockApp(name: 'Music', icon: Icons.music_note, color: Colors.pink[400]!),
      _DockApp(
        name: 'Settings',
        icon: Icons.settings,
        color: Colors.grey[600]!,
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final app in _apps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _DockIcon(app: app, isVertical: isVertical),
                  ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final app in _apps)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _DockIcon(app: app, isVertical: isVertical),
                  ),
              ],
            ),
    );
  }
}

class _DockApp {
  _DockApp({required this.name, required this.icon, required this.color});
  final String name;
  final IconData icon;
  final Color color;
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({required this.app, required this.isVertical});
  final _DockApp app;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    return AnchorTooltip.arrow(
      content: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          app.name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      triggerMode: isDesktop
          ? const AnchorTriggerMode.hover()
          : const AnchorTriggerMode.tap(),
      placement: isVertical ? Placement.right : Placement.top,
      backgroundColor: Colors.grey[800],
      arrowShape: const RoundedArrow(),
      arrowSize: const Size(16, 8),
      border: BorderSide(color: Colors.grey[700]!, width: 2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: app.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(app.icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.hideMenu();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
