import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:toastification/toastification.dart';
import '../../../domain/model/announcement.dart';
import '../../../../common/component/action/primary_button.dart';
import '../../../../common/component/communication/custom_toast.dart';
import '../../../../common/theme/app_theme.dart';
import 'announcement_card.dart';
import 'announcement_form.dart';

class AnnouncementsTab extends HookWidget {
  final String courseId;
  final String semesterId;

  const AnnouncementsTab({
    super.key,
    required this.courseId,
    required this.semesterId,
  });

  Future<void> addAnnouncement(
    BuildContext context,
    String title,
    String content,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final announcement = Announcement(
        id: '',
        title: title,
        content: content,
        createdAt: Timestamp.now(),
        teacherId: userId,
        courseId: courseId,
        semesterId: semesterId,
      );

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcement.toMap());

      if (context.mounted) {
        showToast(
          'Success',
          'Announcement added successfully',
          ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          'Error',
          'Failed to add announcement',
          ToastificationType.error,
        );
      }
      rethrow;
    }
  }

  Future<void> updateAnnouncement(
    BuildContext context,
    String id,
    String title,
    String content,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .update({'title': title, 'content': content});

      if (context.mounted) {
        showToast(
          'Success',
          'Announcement updated successfully',
          ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          'Error',
          'Failed to update announcement',
          ToastificationType.error,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .delete();

      if (context.mounted) {
        showToast(
          'Success',
          'Announcement deleted successfully',
          ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          'Error',
          'Failed to delete announcement',
          ToastificationType.error,
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = useState(false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final announcementsQuery = FirebaseFirestore.instance
        .collection('announcements')
        .where('courseId', isEqualTo: courseId)
        .where('semesterId', isEqualTo: semesterId)
        .where('teacherId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    void showAddAnnouncementDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: context.colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AnnouncementForm(
                isLoading: isSubmitting.value,
                onSubmit: (title, content) async {
                  isSubmitting.value = true;
                  try {
                    await addAnnouncement(context, title, content);
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    isSubmitting.value = false;
                  }
                },
              ),
            ),
      );
    }

    void showEditAnnouncementDialog(Announcement announcement) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: context.colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AnnouncementForm(
                isLoading: isSubmitting.value,
                initialTitle: announcement.title,
                initialContent: announcement.content,
                isEditing: true,
                onSubmit: (title, content) async {
                  isSubmitting.value = true;
                  try {
                    await updateAnnouncement(
                      context,
                      announcement.id,
                      title,
                      content,
                    );
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    isSubmitting.value = false;
                  }
                },
              ),
            ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FirestoreListView<Map<String, dynamic>>(
            query: announcementsQuery,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            loadingBuilder:
                (context) => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
            errorBuilder:
                (context, error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: context.colors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load announcements',
                          style: context.textStyles.subtitle1.error,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: context.textStyles.body3.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            // Force refresh
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.surface,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Retry',
                            style: context.textStyles.body2.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            emptyBuilder:
                (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 64,
                        color: context.colors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements yet',
                        style: context.textStyles.subtitle1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create one by tapping the button below',
                        style: context.textStyles.body2.textHint,
                      ),
                    ],
                  ),
                ),
            itemBuilder: (context, snapshot) {
              final data = snapshot.data();
              final announcement = Announcement.fromMap(snapshot.id, data);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnnouncementCard(
                  title: announcement.title,
                  content: announcement.content,
                  createdAt: announcement.createdAt,
                  onEdit: () => showEditAnnouncementDialog(announcement),
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(
                              'Delete Announcement',
                              style: context.textStyles.subtitle1.textPrimary,
                            ),
                            content: Text(
                              'Are you sure you want to delete this announcement?',
                              style: context.textStyles.body2.textSecondary,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: context.textStyles.body2.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: context.textStyles.body2.error,
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      try {
                        await deleteAnnouncement(context, announcement.id);
                      } catch (e) {
                        // Error is already handled in deleteAnnouncement
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: PrimaryButton(
            onPressed: showAddAnnouncementDialog,
            text: 'Add Announcement',
          ),
        ),
      ],
    );
  }
}
