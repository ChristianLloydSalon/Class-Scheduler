import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../common/component/input/primary_text_field.dart';
import '../../../../common/theme/app_theme.dart';

class AnnouncementForm extends HookWidget {
  final Function(String title, String content) onSubmit;
  final bool isLoading;
  final String? initialTitle;
  final String? initialContent;
  final bool isEditing;

  const AnnouncementForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialTitle,
    this.initialContent,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController(text: initialTitle);
    final contentController = useTextEditingController(text: initialContent);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Announcement' : 'New Announcement',
              style: context.textStyles.heading3.textPrimary,
            ),
            const SizedBox(height: 16),
            PrimaryTextField(
              controller: titleController,
              labelText: 'Title',
              hintText: 'Enter announcement title',
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PrimaryTextField(
              controller: contentController,
              labelText: 'Content',
              hintText: 'Enter announcement content',
              maxLines: 5,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          if (formKey.currentState?.validate() ?? false) {
                            onSubmit(
                              titleController.text,
                              contentController.text,
                            );
                          }
                        },
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.surface,
                            ),
                          ),
                        )
                        : Text(
                          isEditing ? 'Save Changes' : 'Post Announcement',
                          style: context.textStyles.body1.surface,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
