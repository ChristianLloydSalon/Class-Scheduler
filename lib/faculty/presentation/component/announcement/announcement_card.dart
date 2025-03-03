import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/model/announcement.dart';
import '../../../../common/theme/app_theme.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final Timestamp createdAt;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.createdAt,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textStyles.subtitle1.textPrimary,
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: context.colors.textSecondary,
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          if (onEdit != null)
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: context.colors.textPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: context.textStyles.body2.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: context.colors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: context.textStyles.body2.error,
                                  ),
                                ],
                              ),
                            ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: context.textStyles.body2.textPrimary),
            const SizedBox(height: 8),
            Text(
              timeago.format(createdAt.toDate()),
              style: context.textStyles.caption1.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
