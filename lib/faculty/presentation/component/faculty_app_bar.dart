import 'package:flutter/material.dart';

class FacultyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;

  const FacultyAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
        ],
      ),
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
