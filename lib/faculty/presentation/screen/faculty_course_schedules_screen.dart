import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../component/schedule/schedule_day_selector.dart';
import '../component/schedule/schedule_card.dart';
import '../component/schedule/empty_schedule_view.dart';
import '../component/announcement/announcements_tab.dart';
import '../../../../common/theme/app_theme.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:toastification/toastification.dart';
import '../../../../common/component/action/primary_button.dart';
import '../../../../common/component/communication/custom_toast.dart';
import '../component/exam/exam_schedule_card.dart';
import '../component/exam/exam_schedule_form.dart';
import '../component/exam/empty_exam_view.dart';

class FacultyCourseSchedulesScreen extends HookWidget {
  final String semesterId;
  final String courseId;
  final String courseName;
  final String courseCode;

  const FacultyCourseSchedulesScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(courseCode, style: context.textStyles.subtitle1.textPrimary),
              Text(courseName, style: context.textStyles.body2.textSecondary),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: context.colors.textPrimary,
          ),
          bottom: TabBar(
            isScrollable: true,
            labelStyle: context.textStyles.body1.regular,
            unselectedLabelStyle: context.textStyles.body2.regular,
            labelColor: context.colors.primary,
            unselectedLabelColor: context.colors.textSecondary,
            indicatorColor: context.colors.primary,
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'Exam Schedule'),
              Tab(text: 'Announcements'),
              Tab(text: 'Students'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScheduleTab(semesterId: semesterId, courseId: courseId),
            ExamScheduleTab(courseId: courseId, semesterId: semesterId),
            AnnouncementsTab(courseId: courseId, semesterId: semesterId),
            StudentsTab(courseId: courseId, semesterId: semesterId),
          ],
        ),
      ),
    );
  }
}

class ScheduleTab extends HookWidget {
  final String semesterId;
  final String courseId;

  const ScheduleTab({
    super.key,
    required this.semesterId,
    required this.courseId,
  });

  Future<List<DocumentSnapshot>> fetchScheduleItems({
    required String userId,
    required String semesterId,
    required String courseId,
    required String day,
  }) async {
    final scheduleSnapshot =
        await FirebaseFirestore.instance
            .collection('schedules')
            .where('semesterId', isEqualTo: semesterId)
            .where('courseId', isEqualTo: courseId)
            .where('teacherId', isEqualTo: userId)
            .where('day', isEqualTo: day)
            .orderBy('startTime.hour')
            .orderBy('startTime.minute')
            .get();

    return scheduleSnapshot.docs;
  }

  String formatTime(Map<String, dynamic> time) {
    final hour = time['hour'] as int?;
    final minute = time['minute'] as int?;
    if (hour == null || minute == null) return '';

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayIndex = useState<int>(0);
    final weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final scheduleItems = useState<List<DocumentSnapshot>>([]);
    final isLoading = useState<bool>(true);
    final hasError = useState<bool>(false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    useEffect(() {
      final now = DateTime.now();
      selectedDayIndex.value = (now.weekday - 1) % 7;
      return null;
    }, const []);

    useEffect(() {
      if (userId == null) return null;

      void loadScheduleItems() async {
        isLoading.value = true;
        hasError.value = false;

        try {
          final day = weekdays[selectedDayIndex.value];
          scheduleItems.value = await fetchScheduleItems(
            userId: userId,
            semesterId: semesterId,
            courseId: courseId,
            day: day,
          );
          isLoading.value = false;
        } catch (e) {
          hasError.value = true;
          isLoading.value = false;
        }
      }

      loadScheduleItems();
      return null;
    }, [courseId, selectedDayIndex.value, userId]);

    return Column(
      children: [
        ScheduleDaySelector(
          days: weekdays,
          selectedIndex: selectedDayIndex.value,
          onDaySelected: (index) {
            selectedDayIndex.value = index;
          },
        ),
        Expanded(
          child:
              isLoading.value
                  ? Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  )
                  : hasError.value
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load schedule',
                          style: context.textStyles.subtitle1.error,
                        ),
                      ],
                    ),
                  )
                  : scheduleItems.value.isEmpty
                  ? const EmptyScheduleView(
                    message: 'No classes scheduled for this day',
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scheduleItems.value.length,
                    itemBuilder: (context, index) {
                      final schedule = scheduleItems.value[index];
                      final data = schedule.data() as Map<String, dynamic>;
                      final roomData =
                          data['roomData'] as Map<String, dynamic>?;
                      final startTime =
                          data['startTime'] as Map<String, dynamic>?;
                      final endTime = data['endTime'] as Map<String, dynamic>?;
                      final subjectData =
                          data['subjectData'] as Map<String, dynamic>?;
                      final units =
                          subjectData?['units'] as Map<String, dynamic>?;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ScheduleCard(
                          room: roomData?['name'] ?? '',
                          timeSlot:
                              startTime != null && endTime != null
                                  ? '${formatTime(startTime)} - ${formatTime(endTime)}'
                                  : 'Time not set',
                          day: data['day'] ?? '',
                          subjectName: subjectData?['title'] ?? '',
                          lectureUnits: units?['lec'] as int?,
                          laboratoryUnits: units?['lab'] as int?,
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class ExamScheduleTab extends StatefulWidget {
  final String courseId;
  final String semesterId;

  const ExamScheduleTab({
    super.key,
    required this.courseId,
    required this.semesterId,
  });

  @override
  State<ExamScheduleTab> createState() => _ExamScheduleTabState();
}

class _ExamScheduleTabState extends State<ExamScheduleTab> {
  final _isSubmitting = ValueNotifier<bool>(false);

  Future<void> addExamSchedule(
    BuildContext context,
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String room,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final examData = {
        'title': title,
        'date': Timestamp.fromDate(date),
        'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
        'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
        'room': room,
        'courseId': widget.courseId,
        'semesterId': widget.semesterId,
        'teacherId': userId,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('exam_schedules')
          .add(examData);

      if (context.mounted) {
        showToast(
          'Success',
          'Exam schedule added successfully',
          ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          'Error',
          'Failed to add exam schedule',
          ToastificationType.error,
        );
      }
    }
  }

  Future<void> deleteExamSchedule(BuildContext context, String examId) async {
    try {
      await FirebaseFirestore.instance
          .collection('exam_schedules')
          .doc(examId)
          .delete();

      if (context.mounted) {
        showToast(
          'Success',
          'Exam schedule deleted successfully',
          ToastificationType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          'Error',
          'Failed to delete exam schedule',
          ToastificationType.error,
        );
      }
    }
  }

  void showAddExamDialog(BuildContext context) {
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
            child: ValueListenableBuilder(
              valueListenable: _isSubmitting,
              builder:
                  (context, isSubmitting, _) => ExamScheduleForm(
                    isLoading: isSubmitting,
                    onSubmit: (title, date, startTime, endTime, room) async {
                      _isSubmitting.value = true;
                      try {
                        await addExamSchedule(
                          context,
                          title,
                          date,
                          startTime,
                          endTime,
                          room,
                        );
                        if (context.mounted) Navigator.pop(context);
                      } finally {
                        _isSubmitting.value = false;
                      }
                    },
                  ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _isSubmitting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final examSchedulesQuery = FirebaseFirestore.instance
        .collection('exam_schedules')
        .where('courseId', isEqualTo: widget.courseId)
        .where('semesterId', isEqualTo: widget.semesterId)
        .where('teacherId', isEqualTo: userId)
        .orderBy('date')
        .orderBy('startTime.hour')
        .orderBy('startTime.minute');

    return Column(
      children: [
        Expanded(
          child: FirestoreListView<Map<String, dynamic>>(
            query: examSchedulesQuery,
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
                          'Failed to load exam schedules',
                          style: context.textStyles.subtitle1.error,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: context.textStyles.body3.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            emptyBuilder: (context) => const EmptyExamView(),
            itemBuilder: (context, snapshot) {
              final data = snapshot.data();
              final date = (data['date'] as Timestamp).toDate();
              final startTime = TimeOfDay(
                hour: data['startTime']['hour'] as int,
                minute: data['startTime']['minute'] as int,
              );
              final endTime = TimeOfDay(
                hour: data['endTime']['hour'] as int,
                minute: data['endTime']['minute'] as int,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ExamScheduleCard(
                  title: data['title'] as String,
                  date: date,
                  startTime: startTime,
                  endTime: endTime,
                  room: data['room'] as String,
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(
                              'Delete Exam Schedule',
                              style: context.textStyles.subtitle1.textPrimary,
                            ),
                            content: Text(
                              'Are you sure you want to delete this exam schedule?',
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
                      await deleteExamSchedule(context, snapshot.id);
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
            onPressed: () => showAddExamDialog(context),
            text: 'Add Exam Schedule',
          ),
        ),
      ],
    );
  }
}

class StudentsTab extends StatelessWidget {
  final String courseId;
  final String semesterId;

  const StudentsTab({
    super.key,
    required this.courseId,
    required this.semesterId,
  });

  @override
  Widget build(BuildContext context) {
    return FirestoreListView<Map<String, dynamic>>(
      query: FirebaseFirestore.instance
          .collection('class_students')
          .where('courseId', isEqualTo: courseId)
          .where('semesterId', isEqualTo: semesterId)
          .orderBy('universityId'),
      padding: const EdgeInsets.all(16),
      loadingBuilder:
          (context) => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
      errorBuilder:
          (context, error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading students',
                  style: context.textStyles.body1.error,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: context.colors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Students Yet',
                  style: context.textStyles.subtitle1.textPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Students will appear here once enrolled',
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ),
          ),
      itemBuilder: (context, snapshot) {
        final data = snapshot.data();
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['studentId'])
                  .snapshots(),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data?.data();
            final firstName = userData?['firstName'] as String? ?? '';
            final lastName = userData?['lastName'] as String? ?? '';
            final fullName = '$firstName $lastName'.trim();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                            firstName.isNotEmpty ? firstName[0] : '?',
                            style: context.textStyles.body2.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (fullName.isNotEmpty) ...[
                                Text(
                                  fullName,
                                  style:
                                      context.textStyles.subtitle1.textPrimary,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                'ID: ${data['universityId'] ?? 'N/A'}',
                                style:
                                    fullName.isEmpty
                                        ? context
                                            .textStyles
                                            .subtitle1
                                            .textPrimary
                                        : context
                                            .textStyles
                                            .body2
                                            .textSecondary,
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
                              style: context.textStyles.caption1.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(data['createdAt']),
                              style: context.textStyles.body2.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is! Timestamp) return 'Invalid date';

    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
