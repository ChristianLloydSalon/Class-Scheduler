import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/component/schedule/room_picker.dart';
import 'package:scheduler/admin/presentation/component/schedule/subject_picker.dart';
import 'package:scheduler/admin/presentation/component/schedule/teacher_picker.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/time_picker_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddScheduleScreen extends HookWidget {
  final String semesterId;
  final String departmentId;
  final String courseId;
  final String day;

  const AddScheduleScreen({
    super.key,
    required this.semesterId,
    required this.departmentId,
    required this.courseId,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final subject = useState<DocumentSnapshot?>(null);
    final room = useState<DocumentSnapshot?>(null);
    final teacher = useState<DocumentSnapshot?>(null);
    final startTime = useState<TimeOfDay?>(null);
    final endTime = useState<TimeOfDay?>(null);
    final notifyBefore = useState<int>(15);

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      if (subject.value == null ||
          room.value == null ||
          teacher.value == null ||
          startTime.value == null ||
          endTime.value == null) {
        showToast(
          'Error',
          'Please fill in all required fields',
          ToastificationType.error,
        );
        return;
      }

      // Convert TimeOfDay to minutes since midnight for comparison
      final startMinutes = startTime.value!.hour * 60 + startTime.value!.minute;
      final endMinutes = endTime.value!.hour * 60 + endTime.value!.minute;

      if (endMinutes <= startMinutes) {
        showToast(
          'Error',
          'End time must be after start time',
          ToastificationType.error,
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('schedules').add({
          'semesterId': semesterId,
          'departmentId': departmentId,
          'courseId': courseId,
          'day': day,
          'subjectId': subject.value!.id,
          'subjectData': subject.value?.data(),
          'roomId': room.value?.id,
          'roomData': room.value?.data(),
          'teacherId': teacher.value!.id,
          'teacherData': teacher.value?.data(),
          'startTime': {
            'hour': startTime.value?.hour,
            'minute': startTime.value?.minute,
          },
          'endTime': {
            'hour': endTime.value?.hour,
            'minute': endTime.value?.minute,
          },
          'notifyBefore': notifyBefore.value,
        });

        if (!context.mounted) return;
        showToast(
          'Success',
          'Schedule added successfully',
          ToastificationType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        showToast('Error', 'Failed to add schedule', ToastificationType.error);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Schedule',
          style: context.textStyles.heading2.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a Perfect Schedule',
                        style: context.textStyles.heading1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Design your ideal class schedule with ease. Choose the perfect combination of subject, room, and teacher.',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: context.colors.inputBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Subject',
                                style: context.textStyles.body1.textPrimary,
                              ),
                              subtitle: Text(
                                subject.value?.get('title') ??
                                    'Select a subject',
                                style:
                                    subject.value == null
                                        ? context.textStyles.body2.textHint
                                        : context
                                            .textStyles
                                            .body2
                                            .textSecondary,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder:
                                      (context) => SubjectPicker(
                                        onSelect: (doc) => subject.value = doc,
                                      ),
                                );
                              },
                            ),
                            Divider(
                              height: 1,
                              color: context.colors.inputBorder,
                            ),
                            ListTile(
                              title: Text(
                                'Room',
                                style: context.textStyles.body1.textPrimary,
                              ),
                              subtitle: Text(
                                room.value?.get('name') ?? 'Select a room',
                                style:
                                    room.value == null
                                        ? context.textStyles.body2.textHint
                                        : context
                                            .textStyles
                                            .body2
                                            .textSecondary,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder:
                                      (context) => RoomPicker(
                                        onSelect: (doc) => room.value = doc,
                                      ),
                                );
                              },
                            ),
                            Divider(
                              height: 1,
                              color: context.colors.inputBorder,
                            ),
                            ListTile(
                              title: Text(
                                'Teacher',
                                style: context.textStyles.body1.textPrimary,
                              ),
                              subtitle: Text(
                                teacher.value?.get('name') ??
                                    'Select a teacher',
                                style:
                                    teacher.value == null
                                        ? context.textStyles.body2.textHint
                                        : context
                                            .textStyles
                                            .body2
                                            .textSecondary,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder:
                                      (context) => TeacherPicker(
                                        onSelect: (doc) => teacher.value = doc,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TimePickerField(
                        label: 'Start Time',
                        value: startTime.value,
                        onChanged: (time) => startTime.value = time,
                        errorText: startTime.value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TimePickerField(
                        label: 'End Time',
                        value: endTime.value,
                        onChanged: (time) => endTime.value = time,
                        errorText: endTime.value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownField<int>(
                        label: 'Notify Before',
                        value: notifyBefore.value,
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 minutes')),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10 minutes'),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 minutes'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 minutes'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) notifyBefore.value = value;
                        },
                        placeholder: 'Select notification time',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    width: double.infinity,
                    onPressed: handleSubmit,
                    text: 'Add Schedule',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure all fields are filled correctly',
                    style: context.textStyles.caption1.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
