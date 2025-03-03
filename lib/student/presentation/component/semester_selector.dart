import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SemesterSelector extends StatelessWidget {
  final void Function(String) onSemesterSelected;

  const SemesterSelector({super.key, required this.onSemesterSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Semester',
            style: context.textStyles.subtitle1.textSecondary,
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('semesters')
                    .orderBy('startDate', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error loading semesters',
                  style: context.textStyles.body2.error,
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                );
              }

              final semesters = snapshot.data?.docs ?? [];
              if (semesters.isEmpty) {
                return Text(
                  'No semesters available',
                  style: context.textStyles.body2.textSecondary,
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      semesters.map((semester) {
                        final data = semester.data() as Map<String, dynamic>;
                        final name =
                            data['name'] as String? ?? 'Unknown Semester';

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(name),
                            selected: false,
                            onSelected: (_) => onSemesterSelected(semester.id),
                            labelStyle: context.textStyles.body2.textPrimary,
                            backgroundColor: context.colors.surface,
                            side: BorderSide(color: context.colors.border),
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
