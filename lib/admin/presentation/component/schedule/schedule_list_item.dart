import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class ScheduleListItem extends StatelessWidget {
  final DocumentSnapshot schedule;

  const ScheduleListItem({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final data = schedule.data() as Map<String, dynamic>;
    final subject = data['subjectData'] as Map<String, dynamic>;
    final room = data['roomData'] as Map<String, dynamic>;
    final teacher = data['teacherData'] as Map<String, dynamic>;
    final startTime = TimeOfDay(
      hour: data['startTime']['hour'],
      minute: data['startTime']['minute'],
    );
    final endTime = TimeOfDay(
      hour: data['endTime']['hour'],
      minute: data['endTime']['minute'],
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.inputBorder),
      ),
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${startTime.format(context)} - ${endTime.format(context)}',
                    style: context.textStyles.caption1.baseStyle.copyWith(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_outlined,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data['notifyBefore']} mins before',
                  style: context.textStyles.caption2.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subject['title'],
              style: context.textStyles.body1.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subject['code'],
              style: context.textStyles.caption1.textSecondary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        room['type'] == 'lab'
                            ? Icons.computer
                            : Icons.meeting_room,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room['name'],
                          style: context.textStyles.caption1.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          teacher['name'],
                          style: context.textStyles.caption1.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
