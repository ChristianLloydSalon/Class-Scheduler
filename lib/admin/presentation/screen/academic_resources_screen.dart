import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/screen/room_list_screen.dart';
import 'package:scheduler/admin/presentation/screen/subject_list_screen.dart';
import 'package:scheduler/admin/presentation/screen/faculty_list_screen.dart';
import 'package:scheduler/admin/presentation/screen/student_list_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class AcademicResourcesScreen extends HookWidget {
  const AcademicResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = context.colors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Resources',
            style: context.textStyles.heading2.textPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your subjects, rooms, faculty, and students efficiently',
            style: context.textStyles.body2.textSecondary,
          ),
          const SizedBox(height: 32),
          _ResourceCard(
            title: 'Subjects',
            description:
                'Add and manage course subjects, set credit hours, and organize curriculum',
            icon: Icons.book_outlined,
            color: primaryColor,
            onTap: () {
              // Navigate to subjects screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubjectListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ResourceCard(
            title: 'Rooms',
            description:
                'Configure classrooms, labs, and other teaching spaces',
            icon: Icons.meeting_room_outlined,
            color: primaryColor,
            onTap: () {
              // Navigate to rooms screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoomListScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _ResourceCard(
            title: 'Faculty',
            description:
                'Manage faculty members, their departments, and specializations',
            icon: Icons.people_outline,
            color: primaryColor,
            onTap: () {
              // Navigate to faculty management screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FacultyListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ResourceCard(
            title: 'Students',
            description:
                'Manage student records, enrollment, and class assignments',
            icon: Icons.school_outlined,
            color: primaryColor,
            onTap: () {
              // Navigate to student management screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentListScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          Center(
            child: Text(
              'Select a category to get started',
              style: context.textStyles.caption1.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.body1.textPrimary),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textStyles.caption1.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
