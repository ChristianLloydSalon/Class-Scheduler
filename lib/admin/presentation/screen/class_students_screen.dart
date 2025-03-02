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
                .orderBy('studentId'),
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    data['studentId'][0],
                    style: context.textStyles.body2.primary,
                  ),
                ),
                title: Text(
                  data['studentId'],
                  style: context.textStyles.body1.textPrimary,
                ),
                subtitle: Text(
                  data['name'] ?? 'Student',
                  style: context.textStyles.caption1.textSecondary,
                ),
                trailing:
                    data['isIrregular'] == true
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Irregular',
                                style: context.textStyles.caption2.warning,
                              ),
                            ],
                          ),
                        )
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
