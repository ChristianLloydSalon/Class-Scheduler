import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/screen/department_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SemesterListItem extends StatelessWidget {
  final QueryDocumentSnapshot semester;
  final String semesterId;

  const SemesterListItem({
    super.key,
    required this.semester,
    required this.semesterId,
  });

  @override
  Widget build(BuildContext context) {
    final data = semester.data() as Map<String, dynamic>;
    final colorScheme = Theme.of(context).colorScheme;
    final currentStatus = data['status'] as String? ?? 'active';

    // Function to update semester status
    Future<void> _updateSemesterStatus(String status) async {
      try {
        await FirebaseFirestore.instance
            .collection('semesters')
            .doc(semesterId)
            .update({'status': status});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Semester status updated to $status')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating semester status: $e')),
          );
        }
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepartmentScreen(semesterId: semesterId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${data['semester']}',
                    style: context.textStyles.heading3.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Year ${data['year']}',
                      style: context.textStyles.body1.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semester ${data['semester']}',
                      style: context.textStyles.caption1.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          currentStatus,
                          colorScheme,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentStatus,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(currentStatus, colorScheme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: context.colors.textHint,
                  size: 20,
                ),
                onSelected: _updateSemesterStatus,
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'active',
                        child: Text('Set Active'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'upcoming',
                        child: Text('Set Upcoming'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'completed',
                        child: Text('Set Completed'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'archived',
                        child: Text('Set Archived'),
                      ),
                    ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.textHint.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return colorScheme.primary;
      case 'completed':
        return Colors.grey;
      case 'archived':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
