import 'package:flutter/material.dart';

class ScheduleDaySelector extends StatelessWidget {
  final List<String> days;
  final int selectedIndex;
  final Function(int) onDaySelected;

  const ScheduleDaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayNumber(index),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayNumber(int dayIndex) {
    // Calculate the day number based on the current date
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final day = firstDayOfWeek.add(Duration(days: dayIndex));
    return day.day.toString();
  }
}
