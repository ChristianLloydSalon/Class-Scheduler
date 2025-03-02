import 'package:flutter/cupertino.dart';
import 'package:scheduler/common/theme/app_theme.dart';

Future<bool?> showConfirmationModal(
  BuildContext context, {
  required VoidCallback onConfirm,
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
}) async {
  return await showCupertinoDialog<bool>(
    context: context,
    builder:
        (context) => ConfirmationModal(
          onConfirm: onConfirm,
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
        ),
  );
}

class ConfirmationModal extends StatelessWidget {
  final VoidCallback onConfirm;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  const ConfirmationModal({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title, style: context.textStyles.heading3.textPrimary),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          message,
          style: context.textStyles.body2.textSecondary,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText, style: context.textStyles.body1.textPrimary),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: context.textStyles.body1.baseStyle.copyWith(
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ),
      ],
    );
  }
}
