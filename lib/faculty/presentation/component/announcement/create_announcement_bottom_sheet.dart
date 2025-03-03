import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAnnouncementBottomSheet extends HookWidget {
  final String courseId;
  final VoidCallback onAnnouncementCreated;

  const CreateAnnouncementBottomSheet({
    super.key,
    required this.courseId,
    required this.onAnnouncementCreated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = useTextEditingController();
    final contentController = useTextEditingController();
    final categoryValue = useState<String>('General');
    final isSubmitting = useState<bool>(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Announcement',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: categoryValue.value,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(
                  value: 'Assignments',
                  child: Text('Assignments'),
                ),
                DropdownMenuItem(value: 'Exams', child: Text('Exams')),
              ],
              onChanged: (value) {
                if (value != null) {
                  categoryValue.value = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      isSubmitting.value
                          ? null
                          : () {
                            Navigator.pop(context);
                          },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      isSubmitting.value
                          ? null
                          : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              isSubmitting.value = true;

                              try {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;

                                if (userId == null) {
                                  throw Exception('User not authenticated');
                                }

                                await FirebaseFirestore.instance
                                    .collection('announcements')
                                    .add({
                                      'courseId': courseId,
                                      'facultyId': userId,
                                      'title': titleController.text,
                                      'content': contentController.text,
                                      'category': categoryValue.value,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                Navigator.pop(context);
                                onAnnouncementCreated();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Announcement created successfully',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                                isSubmitting.value = false;
                              }
                            }
                          },
                  child:
                      isSubmitting.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Post'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
