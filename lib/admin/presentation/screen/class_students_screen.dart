import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class ClassStudentsScreen extends StatelessWidget {
  final String semesterId;
  final String departmentId;
  final String courseId;

  const ClassStudentsScreen({
    super.key,
    required this.semesterId,
    required this.departmentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Students',
                style: context.textStyles.heading1.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage students enrolled in this class. Add or remove students as needed.',
                style: context.textStyles.body2.textSecondary,
              ),
            ],
          ),
        ),
        Expanded(
          child: FirestoreListView<Map<String, dynamic>>(
            query: FirebaseFirestore.instance
                .collection('class_students')
                .where('semesterId', isEqualTo: semesterId)
                .where('departmentId', isEqualTo: departmentId)
                .where('courseId', isEqualTo: courseId)
                .orderBy('universityId'),
            loadingBuilder:
                (context) => const Center(child: CircularProgressIndicator()),
            errorBuilder:
                (context, error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading students',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: context.textStyles.caption1.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            emptyBuilder:
                (context) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Students Yet',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add students to this class',
                        style: context.textStyles.caption1.textSecondary,
                      ),
                    ],
                  ),
                ),
            itemBuilder: (context, snapshot) {
              final data = snapshot.data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          CircleAvatar(
                            backgroundColor: context.colors.primary.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              data['universityId']?[0] ?? '?',
                              style: context.textStyles.body2.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${data['universityId'] ?? 'N/A'}',
                                  style:
                                      context.textStyles.subtitle1.textPrimary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['email'] ?? 'No email',
                                  style: context.textStyles.body2.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          if (data['isIrregular'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: context.colors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Irregular',
                                    style: context.textStyles.caption2.warning,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Added on',
                                style:
                                    context.textStyles.caption1.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(data['createdAt']),
                                style: context.textStyles.body2.textPrimary,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Implement remove student
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text(
                                        'Remove Student',
                                        style:
                                            context
                                                .textStyles
                                                .subtitle1
                                                .textPrimary,
                                      ),
                                      content: Text(
                                        'Are you sure you want to remove this student from the class?',
                                        style:
                                            context
                                                .textStyles
                                                .body2
                                                .textSecondary,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style:
                                                context
                                                    .textStyles
                                                    .body2
                                                    .textSecondary,
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            // Delete the document
                                            snapshot.reference.delete();
                                            Navigator.pop(context);
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                context.colors.error,
                                          ),
                                          child: Text(
                                            'Remove',
                                            style:
                                                context
                                                    .textStyles
                                                    .body2
                                                    .surface,
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: context.colors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is! Timestamp) return 'Invalid date';

    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
