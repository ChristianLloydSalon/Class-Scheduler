import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../component/schedule/schedule_day_selector.dart';
import '../component/schedule/schedule_card.dart';
import '../component/schedule/empty_schedule_view.dart';
import '../component/announcement/announcements_tab.dart';
import '../../../../common/theme/app_theme.dart';

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
            const ExamScheduleTab(),
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

class ExamScheduleTab extends StatelessWidget {
  const ExamScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Exam Schedule Coming Soon',
        style: context.textStyles.subtitle1.textSecondary,
      ),
    );
  }
}

class StudentsTab extends HookWidget {
  final String courseId;
  final String semesterId;

  const StudentsTab({
    super.key,
    required this.courseId,
    required this.semesterId,
  });

  Future<List<DocumentSnapshot>> fetchStudents() async {
    final studentsSnapshot =
        await FirebaseFirestore.instance
            .collection('enrollments')
            .where('courseId', isEqualTo: courseId)
            .where('semesterId', isEqualTo: semesterId)
            .get();

    return studentsSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final students = useState<List<DocumentSnapshot>>([]);
    final isLoading = useState(true);
    final hasError = useState(false);

    useEffect(() {
      void loadStudents() async {
        try {
          final fetchedStudents = await fetchStudents();
          students.value = fetchedStudents;
          isLoading.value = false;
        } catch (e) {
          hasError.value = true;
          isLoading.value = false;
        }
      }

      loadStudents();
      return null;
    }, []);

    if (isLoading.value) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (hasError.value) {
      return Center(
        child: Text(
          'Failed to load students',
          style: context.textStyles.subtitle1.error,
        ),
      );
    }

    if (students.value.isEmpty) {
      return Center(
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
              'No students enrolled',
              style: context.textStyles.subtitle1.textPrimary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.value.length,
      itemBuilder: (context, index) {
        final enrollment = students.value[index];
        final data = enrollment.data() as Map<String, dynamic>;
        final studentData = data['studentData'] as Map<String, dynamic>?;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.colors.border),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.surface,
              child: Text(
                (studentData?['firstName'] as String? ?? '?')[0].toUpperCase(),
              ),
            ),
            title: Text(
              '${studentData?['lastName'] ?? ''}, ${studentData?['firstName'] ?? ''}',
              style: context.textStyles.subtitle1.textPrimary,
            ),
            subtitle: Text(
              studentData?['studentNumber'] ?? 'No student number',
              style: context.textStyles.body2.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
