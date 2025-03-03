import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementCard({super.key, required this.announcement});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = (announcement['createdAt'] as Timestamp).toDate();
    final isNew = DateTime.now().difference(createdAt).inHours < 24;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isNew
                  ? context.colors.primary.withOpacity(0.05)
                  : context.colors.surface,
              context.colors.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['title'] ?? 'Untitled Announcement',
                          style: context.textStyles.subtitle1.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'New',
                              style: context.textStyles.caption2.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(createdAt),
                      style: context.textStyles.caption1.textSecondary,
                    ),
                  ),
                ],
              ),
              if (announcement['content']?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  announcement['content'],
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
