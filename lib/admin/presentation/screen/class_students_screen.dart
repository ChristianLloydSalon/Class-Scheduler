import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showImportDialog(context),
                  icon: const Icon(
                    Icons.group_add,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text('Import Students'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
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
                          InkWell(
                            onTap:
                                () => _toggleIrregularStatus(context, snapshot),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (data['isIrregular'] == true)
                                        ? context.colors.warning.withOpacity(
                                          0.1,
                                        )
                                        : context.colors.success.withOpacity(
                                          0.1,
                                        ),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color:
                                      (data['isIrregular'] == true)
                                          ? context.colors.warning
                                          : context.colors.success,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    (data['isIrregular'] == true)
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_outline,
                                    size: 16,
                                    color:
                                        (data['isIrregular'] == true)
                                            ? context.colors.warning
                                            : context.colors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (data['isIrregular'] == true)
                                        ? 'Irregular'
                                        : 'Regular',
                                    style:
                                        (data['isIrregular'] == true)
                                            ? context
                                                .textStyles
                                                .caption2
                                                .warning
                                            : TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: context.colors.success,
                                            ),
                                  ),
                                ],
                              ),
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

  void _showImportDialog(BuildContext context) {
    bool isLoading = false;
    String courseCode = '';
    String yearLevel = '';
    String section = '';

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              // Fetch current course details when dialog opens
              if (courseCode.isEmpty) {
                setState(() => isLoading = true);
                FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .get()
                    .then((courseDoc) {
                      if (courseDoc.exists) {
                        final data = courseDoc.data();
                        courseCode = data?['code'] ?? '';
                        yearLevel = data?['year'] ?? '';
                        section = data?['section'] ?? '';
                      }
                      setState(() => isLoading = false);
                    })
                    .catchError((e) {
                      showToast(
                        'Error',
                        'Failed to fetch course details: $e',
                        ToastificationType.error,
                      );
                      setState(() => isLoading = false);
                    });
              }

              return AlertDialog(
                title: const Text('Import Students'),
                content:
                    isLoading
                        ? const Center(
                          heightFactor: 3,
                          child: CircularProgressIndicator(),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'This will automatically import all students matching the course details below into this class.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDetailRow(context, 'Course', courseCode),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              'Year Level',
                              'Year $yearLevel',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              'Section',
                              'Section $section',
                            ),
                          ],
                        ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  if (isLoading)
                    const SizedBox.shrink()
                  else
                    ElevatedButton(
                      onPressed: () async {
                        if (courseCode.isEmpty) {
                          showToast(
                            'Error',
                            'Course information is missing',
                            ToastificationType.error,
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          // Query for students matching the criteria
                          Query<Map<String, dynamic>> query = FirebaseFirestore
                              .instance
                              .collection('users')
                              .where('role', isEqualTo: 'student')
                              .where('course', isEqualTo: courseCode);

                          if (yearLevel.isNotEmpty) {
                            query = query.where(
                              'yearLevel',
                              isEqualTo: yearLevel,
                            );
                          }

                          if (section.isNotEmpty) {
                            query = query.where('section', isEqualTo: section);
                          }

                          final matchingStudents = await query.get();

                          if (matchingStudents.docs.isEmpty) {
                            showToast(
                              'Info',
                              'No students found matching the course criteria',
                              ToastificationType.info,
                            );
                            setState(() => isLoading = false);
                            return;
                          }

                          // For each student, check if already in class and add if not
                          int addedCount = 0;
                          for (final studentDoc in matchingStudents.docs) {
                            final studentId = studentDoc.id;
                            final studentData = studentDoc.data();

                            // Check if student is already in this class
                            final existingStudent =
                                await FirebaseFirestore.instance
                                    .collection('class_students')
                                    .where('semesterId', isEqualTo: semesterId)
                                    .where(
                                      'departmentId',
                                      isEqualTo: departmentId,
                                    )
                                    .where('courseId', isEqualTo: courseId)
                                    .where('studentId', isEqualTo: studentId)
                                    .get();

                            // Skip if already enrolled
                            if (existingStudent.docs.isNotEmpty) {
                              continue;
                            }

                            // Add student to class
                            await FirebaseFirestore.instance
                                .collection('class_students')
                                .add({
                                  'semesterId': semesterId,
                                  'departmentId': departmentId,
                                  'courseId': courseId,
                                  'studentId': studentId,
                                  'universityId':
                                      studentData['universityId'] ?? '',
                                  'email': studentData['email'] ?? '',
                                  'name': studentData['name'] ?? '',
                                  'isIrregular': false, // Default to regular
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            addedCount++;
                          }

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          showToast(
                            'Success',
                            'Added $addedCount student(s) to the class',
                            ToastificationType.success,
                          );
                        } catch (e) {
                          setState(() => isLoading = false);
                          showToast(
                            'Error',
                            'Failed to import students: $e',
                            ToastificationType.error,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Import'),
                    ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleIrregularStatus(BuildContext context, DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final isCurrentlyIrregular = data['isIrregular'] == true;
    final newStatus = !isCurrentlyIrregular;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Change Student Status',
              style: context.textStyles.subtitle1.textPrimary,
            ),
            content: Text(
              'Are you sure you want to mark this student as ${newStatus ? "Irregular" : "Regular"}?',
              style: context.textStyles.body2.textSecondary,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: context.textStyles.body2.textSecondary,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    // Update the document
                    await snapshot.reference.update({'isIrregular': newStatus});

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      showToast(
                        'Success',
                        'Student status updated to ${newStatus ? "Irregular" : "Regular"}',
                        ToastificationType.success,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      showToast(
                        'Error',
                        'Failed to update student status: $e',
                        ToastificationType.error,
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                ),
                child: Text('Confirm', style: context.textStyles.body2.surface),
              ),
            ],
          ),
    );
  }
}
