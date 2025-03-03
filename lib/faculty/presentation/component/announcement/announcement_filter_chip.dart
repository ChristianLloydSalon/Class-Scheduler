import 'package:flutter/material.dart';

class AnnouncementFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const AnnouncementFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
