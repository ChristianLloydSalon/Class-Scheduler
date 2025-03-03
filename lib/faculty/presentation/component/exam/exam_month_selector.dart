import 'package:flutter/material.dart';

class ExamMonthSelector extends StatelessWidget {
  final List<String> months;
  final int selectedIndex;
  final Function(int) onMonthSelected;

  const ExamMonthSelector({
    super.key,
    required this.months,
    required this.selectedIndex,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        itemCount: months.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onMonthSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? theme.colorScheme.secondaryContainer
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                months[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
