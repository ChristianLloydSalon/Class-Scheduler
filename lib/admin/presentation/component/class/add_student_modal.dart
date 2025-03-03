import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddStudentModal extends HookWidget {
  final Function(String, bool) onConfirm;

  const AddStudentModal({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final studentId = useTextEditingController();
    final isIrregular = useState(false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Student ID',
              style: context.textStyles.heading4.textPrimary,
            ),
            const SizedBox(height: 16),
            PrimaryTextField(
              controller: studentId,
              hintText: '012345',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => isIrregular.value = !isIrregular.value,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isIrregular.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Is student irregular?',
                      style: context.textStyles.body1.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              width: double.infinity,
              onPressed: () {
                if (studentId.text.isNotEmpty ||
                    studentId.text.trim().isNotEmpty) {
                  onConfirm(studentId.text, isIrregular.value);
                  Navigator.pop(context);
                } else {
                  showToast(
                    'Invalid ID',
                    'Please enter a valid student ID',
                    ToastificationType.error,
                  );
                }
              },
              text: 'Confirm',
            ),
          ],
        ),
      ),
    );
  }
}
