import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/home',    label: 'Ana Sayfa', icon: Icons.home_outlined,   activeIcon: Icons.home),
    _TabItem(path: '/map',     label: 'Harita',    icon: Icons.map_outlined,    activeIcon: Icons.map),
    _TabItem(path: '/flash',   label: 'Flash Card',icon: Icons.style_outlined,  activeIcon: Icons.style),
    _TabItem(path: '/profile', label: 'Profil',    icon: Icons.person_outline,  activeIcon: Icons.person),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon:          Icon(t.icon),
          selectedIcon:  Icon(t.activeIcon),
          label:         t.label,
        )).toList(),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class _TabItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem({required this.path, required this.label, required this.icon, required this.activeIcon});
}
