import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/component/schedule/schedule_list_item.dart';
import 'package:scheduler/admin/presentation/screen/add_schedule_screen.dart';
import 'package:scheduler/admin/presentation/screen/class_students_screen.dart';
import 'package:scheduler/admin/presentation/component/class/add_student_modal.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart'
    show showToast;
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class ScheduleScreen extends HookWidget {
  final String semesterId;
  final String departmentId;
  final String courseId;

  const ScheduleScreen({
    super.key,
    required this.semesterId,
    required this.departmentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Class Management',
          style: context.textStyles.heading2.textPrimary,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: tabController,
          tabs: const [Tab(text: 'Schedule'), Tab(text: 'Students')],
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _ScheduleTab(
            semesterId: semesterId,
            departmentId: departmentId,
            courseId: courseId,
          ),
          ClassStudentsScreen(
            semesterId: semesterId,
            departmentId: departmentId,
            courseId: courseId,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddScheduleScreen(
                      semesterId: semesterId,
                      departmentId: departmentId,
                      courseId: courseId,
                      day: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][0],
                    ),
              ),
            );
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: AddStudentModal(
                      onConfirm: (studentId, isIrregular) async {
                        try {
                          // Check if student already exists in this class
                          final existingStudent =
                              await FirebaseFirestore.instance
                                  .collection('class_students')
                                  .where('semesterId', isEqualTo: semesterId)
                                  .where(
                                    'departmentId',
                                    isEqualTo: departmentId,
                                  )
                                  .where('courseId', isEqualTo: courseId)
                                  .where('studentId', isEqualTo: studentId)
                                  .get();

                          if (existingStudent.docs.isNotEmpty) {
                            if (context.mounted) {
                              showToast(
                                'Error',
                                'Student is already in this class',
                                ToastificationType.error,
                              );
                            }
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection('class_students')
                              .add({
                                'semesterId': semesterId,
                                'departmentId': departmentId,
                                'courseId': courseId,
                                'studentId': studentId,
                                'isIrregular': isIrregular,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                          if (context.mounted) {
                            showToast(
                              'Success',
                              'Student added successfully',
                              ToastificationType.success,
                            );
                          }
                        } catch (e) {
                          showToast(
                            'Error',
                            'Failed to add student',
                            ToastificationType.error,
                          );
                        }
                      },
                    ),
                  ),
            );
          }
        },
        child: Icon(tabController.index == 0 ? Icons.add : Icons.person_add),
      ),
    );
  }
}

class _ScheduleTab extends HookWidget {
  final String semesterId;
  final String departmentId;
  final String courseId;

  const _ScheduleTab({
    required this.semesterId,
    required this.departmentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDay = useState(days[0]);

    Query<Map<String, dynamic>> getQuery(String day) {
      return FirebaseFirestore.instance
          .collection('schedules')
          .where('semesterId', isEqualTo: semesterId)
          .where('departmentId', isEqualTo: departmentId)
          .where('courseId', isEqualTo: courseId)
          .where('day', isEqualTo: day)
          .orderBy('startTime.hour')
          .orderBy('startTime.minute');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Schedule',
                style: context.textStyles.heading1.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your weekly class schedule efficiently. Add and organize classes for each day.',
                style: context.textStyles.body2.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day == currentDay.value;
              return InkWell(
                onTap: () => currentDay.value = day,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.indigo
                            : Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: context.textStyles.body1.baseStyle.copyWith(
                        color: isSelected ? Colors.white : Colors.indigo,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FirestoreListView<Map<String, dynamic>>(
            query: getQuery(currentDay.value),
            loadingBuilder:
                (context) => const Center(child: CircularProgressIndicator()),
            errorBuilder:
                (context, error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading schedules',
                          style: context.textStyles.body1.textPrimary,
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
                ),
            emptyBuilder:
                (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Classes on ${currentDay.value}',
                          style: context.textStyles.body1.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a class schedule',
                          style: context.textStyles.caption1.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
            itemBuilder: (context, snapshot) {
              return ScheduleListItem(schedule: snapshot);
            },
          ),
        ),
      ],
    );
  }
}
