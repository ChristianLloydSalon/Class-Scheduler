import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamDetailBottomSheet extends StatelessWidget {
  final String examId;
  final Map<String, dynamic> examData;
  final String formattedDate;

  const ExamDetailBottomSheet({
    super.key,
    required this.examId,
    required this.examData,
    required this.formattedDate,
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
              examData['type'] ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              examData['title'] ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
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
                  '${examData['startTime'] ?? ''} - ${examData['endTime'] ?? ''}',
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
                  examData['location'] ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (examData['description'] != null &&
                examData['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                examData['description'] ?? '',
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
                    _editExam(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _manageGrades(context);
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Manage Grades'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editExam(BuildContext context) {
    // Navigate to edit screen or show edit dialog
  }

  void _manageGrades(BuildContext context) {
    // Navigate to grades screen
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ExamGradesScreen(examId: examId)));
  }
}
