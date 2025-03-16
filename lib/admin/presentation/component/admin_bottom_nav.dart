import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: colorScheme.primary.withOpacity(0.2),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, color: colorScheme.primary),
          selectedIcon: Icon(Icons.calendar_month, color: colorScheme.primary),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined, color: colorScheme.primary),
          selectedIcon: Icon(Icons.school, color: colorScheme.primary),
          label: 'Academic',
        ),
      ],
    );
  }
}
