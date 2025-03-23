import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/component/schedule_card.dart';

class StudentScheduleTab extends StatefulWidget {
  final String semesterId;

  const StudentScheduleTab({super.key, required this.semesterId});

  @override
  State<StudentScheduleTab> createState() => _StudentScheduleTabState();
}

class _StudentScheduleTabState extends State<StudentScheduleTab> {
  final weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Always select Monday (index 0) by default
    selectedDayIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: weekdays.length,
            itemBuilder: (context, index) {
              final isSelected = selectedDayIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(weekdays[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedDayIndex = index);
                    }
                  },
                  labelStyle:
                      isSelected
                          ? context.textStyles.body2.textPrimary.copyWith(
                            color: Colors.white,
                          )
                          : context.textStyles.body2.textSecondary,
                  backgroundColor: context.colors.surface,
                  selectedColor: context.colors.primary,
                  side: BorderSide(
                    color:
                        isSelected
                            ? context.colors.primary
                            : context.colors.border,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance
                    .collection('class_students')
                    .where('studentId', isEqualTo: userId)
                    .where('semesterId', isEqualTo: widget.semesterId)
                    .snapshots(),
            builder: (context, enrollmentsSnapshot) {
              if (!enrollmentsSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                );
              }

              final enrollments = enrollmentsSnapshot.data?.docs ?? [];
              if (enrollments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: context.colors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes found',
                        style: context.textStyles.subtitle1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are not enrolled in any classes',
                        style: context.textStyles.body2.textSecondary,
                      ),
                    ],
                  ),
                );
              }

              // Get all course IDs from enrollments
              final courseIds =
                  enrollments
                      .map((doc) => doc.data()['courseId'] as String)
                      .toList();

              return FirestoreListView<Map<String, dynamic>>(
                query: FirebaseFirestore.instance
                    .collection('schedules')
                    .where('courseId', whereIn: courseIds)
                    .where('semesterId', isEqualTo: widget.semesterId)
                    .where('day', isEqualTo: weekdays[selectedDayIndex])
                    .orderBy('startTime.hour')
                    .orderBy('startTime.minute'),
                padding: const EdgeInsets.all(16),
                emptyBuilder:
                    (context) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: context.colors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No schedules found',
                            style: context.textStyles.subtitle1.textPrimary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have no classes scheduled for ${weekdays[selectedDayIndex]}',
                            style: context.textStyles.body2.textSecondary,
                          ),
                        ],
                      ),
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
                            'Error loading schedules',
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
                loadingBuilder:
                    (context) => Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                      ),
                    ),
                itemBuilder: (context, snapshot) {
                  final data = snapshot.data();

                  // Fetch teacher data if teacherId exists
                  if (data['teacherId'] != null) {
                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(data['teacherId'])
                              .get(),
                      builder: (context, teacherSnapshot) {
                        final Map<String, dynamic> scheduleWithTeacher = {
                          ...data,
                        };

                        if (teacherSnapshot.hasData &&
                            teacherSnapshot.data != null) {
                          scheduleWithTeacher['teacherData'] =
                              teacherSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ScheduleCard(schedule: scheduleWithTeacher),
                        );
                      },
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScheduleCard(schedule: data),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
