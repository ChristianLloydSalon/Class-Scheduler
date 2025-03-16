import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class AnnouncementDetailBottomSheet extends StatelessWidget {
  final String announcementId;
  final Map<String, dynamic> announcementData;
  final String formattedDate;

  const AnnouncementDetailBottomSheet({
    super.key,
    required this.announcementId,
    required this.announcementData,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          announcementData['category'] ?? '',
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        announcementData['category'] ?? 'General',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryTextColor(
                            announcementData['category'] ?? '',
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  announcementData['title'] ?? '',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  announcementData['content'] ?? '',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editAnnouncement(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    final themeData = ThemeData();
    final colorScheme = themeData.colorScheme.copyWith(
      primary: const Color(0xFF4F6D7A), // Our muted blue-gray
    );

    switch (category.toLowerCase()) {
      case 'assignments':
        return colorScheme.primary.withOpacity(0.1);
      case 'exams':
        return Colors.red.shade100;
      case 'general':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryTextColor(String category) {
    final themeData = ThemeData();
    final colorScheme = themeData.colorScheme.copyWith(
      primary: const Color(0xFF4F6D7A), // Our muted blue-gray
    );

    switch (category.toLowerCase()) {
      case 'assignments':
        return colorScheme.primary;
      case 'exams':
        return Colors.red.shade900;
      case 'general':
        return Colors.green.shade900;
      default:
        return Colors.grey.shade900;
    }
  }

  void _editAnnouncement(BuildContext context) {
    // Navigate to edit screen or show edit dialog
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Announcement'),
            content: const Text(
              'Are you sure you want to delete this announcement? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                  _deleteAnnouncement(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteAnnouncement(BuildContext context) {
    FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .delete()
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Announcement deleted')));
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        });
  }
}
