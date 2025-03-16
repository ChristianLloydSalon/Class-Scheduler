import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class FacultyBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FacultyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primary.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: colorScheme.primary,
            ),
            selectedIcon: Icon(
              Icons.calendar_today,
              color: colorScheme.primary,
            ),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined, color: colorScheme.primary),
            selectedIcon: Icon(Icons.event_note, color: colorScheme.primary),
            label: 'Exams',
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined, color: colorScheme.primary),
            selectedIcon: Icon(Icons.announcement, color: colorScheme.primary),
            label: 'Announcements',
          ),
        ],
      ),
    );
  }
}
