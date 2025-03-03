import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/component/input/primary_text_field.dart';
import '../../../../common/theme/app_theme.dart';
import '../../screen/room_list_screen.dart';

class ExamScheduleForm extends StatefulWidget {
  final Function(
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String room,
  )
  onSubmit;
  final bool isLoading;

  const ExamScheduleForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ExamScheduleForm> createState() => _ExamScheduleFormState();
}

class _ExamScheduleFormState extends State<ExamScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late final ValueNotifier<DateTime> _selectedDate;
  late final ValueNotifier<TimeOfDay> _selectedStartTime;
  late final ValueNotifier<TimeOfDay> _selectedEndTime;
  late final ValueNotifier<DocumentSnapshot?> _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedDate = ValueNotifier(DateTime.now());
    _selectedStartTime = ValueNotifier(TimeOfDay.now());
    _selectedEndTime = ValueNotifier(
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );
    _selectedRoom = ValueNotifier(null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _selectedDate.dispose();
    _selectedStartTime.dispose();
    _selectedEndTime.dispose();
    _selectedRoom.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (_selectedRoom.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a room',
            style: context.textStyles.body2.surface,
          ),
          backgroundColor: context.colors.error,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Exam Schedule',
              style: context.textStyles.heading3.textPrimary,
            ),
            const SizedBox(height: 16),
            PrimaryTextField(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Enter exam title',
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _selectedDate,
              builder:
                  (context, date, _) => InkWell(
                    onTap: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (newDate != null) {
                        _selectedDate.value = newDate;
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Date',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      subtitle: Text(
                        date.toString().split(' ')[0],
                        style: context.textStyles.body1.textPrimary,
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
            ),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _selectedStartTime,
                    builder:
                        (context, startTime, _) => InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (time != null) {
                              _selectedStartTime.value = time;
                            }
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Start Time',
                              style: context.textStyles.body2.textSecondary,
                            ),
                            subtitle: Text(
                              startTime.format(context),
                              style: context.textStyles.body1.textPrimary,
                            ),
                            trailing: Icon(
                              Icons.access_time,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _selectedEndTime,
                    builder:
                        (context, endTime, _) => InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (time != null) {
                              _selectedEndTime.value = time;
                            }
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'End Time',
                              style: context.textStyles.body2.textSecondary,
                            ),
                            subtitle: Text(
                              endTime.format(context),
                              style: context.textStyles.body1.textPrimary,
                            ),
                            trailing: Icon(
                              Icons.access_time,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _selectedRoom,
              builder:
                  (context, room, _) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RoomListScreen(
                                onSelect: (selectedRoom) {
                                  _selectedRoom.value = selectedRoom;
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Room',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      subtitle: Text(
                        room?.get('name') ?? 'Select a room',
                        style:
                            room == null
                                ? context.textStyles.body2.textHint
                                : context.textStyles.body1.textPrimary,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed:
                    widget.isLoading
                        ? null
                        : () {
                          if (_validateForm()) {
                            widget.onSubmit(
                              _titleController.text,
                              _selectedDate.value,
                              _selectedStartTime.value,
                              _selectedEndTime.value,
                              _selectedRoom.value!.get('name'),
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
                    widget.isLoading
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
                          'Add Exam Schedule',
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
