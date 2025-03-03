import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleDetailBottomSheet extends StatelessWidget {
  final String scheduleId;
  final Map<String, dynamic> scheduleData;

  const ScheduleDetailBottomSheet({
    super.key,
    required this.scheduleId,
    required this.scheduleData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scheduleData['type'] ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scheduleData['topic'] ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${scheduleData['startTime'] ?? ''} - ${scheduleData['endTime'] ?? ''}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  scheduleData['location'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (scheduleData['description'] != null &&
                scheduleData['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scheduleData['description'] ?? '',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editSchedule(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _markAsComplete(context);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editSchedule(BuildContext context) {
    // Navigate to edit screen or show edit dialog
  }

  void _markAsComplete(BuildContext context) {
    FirebaseFirestore.instance
        .collection('schedules')
        .doc(scheduleId)
        .update({'status': 'completed'})
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Marked as completed')));
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        });
  }
}
