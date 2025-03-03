import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

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
        backgroundColor: theme.colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Exams',
          ),
          NavigationDestination(
            icon: Icon(Icons.announcement_outlined),
            selectedIcon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
        ],
      ),
    );
  }
}
