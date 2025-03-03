import 'package:flutter/material.dart';
import '../../../../common/theme/app_theme.dart';

class ExamScheduleCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room;
  final VoidCallback? onDelete;

  const ExamScheduleCard({
    super.key,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
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
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: context.colors.error,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  date.toString().split(' ')[0],
                  style: context.textStyles.body2.textSecondary,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${startTime.format(context)} - ${endTime.format(context)}',
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.room_outlined,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(room, style: context.textStyles.body2.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
