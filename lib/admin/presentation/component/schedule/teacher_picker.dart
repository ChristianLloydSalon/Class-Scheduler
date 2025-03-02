import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class TeacherPicker extends StatelessWidget {
  final Function(DocumentSnapshot) onSelect;

  const TeacherPicker({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Teacher',
          style: context.textStyles.heading2.textPrimary,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Instructor',
                  style: context.textStyles.heading1.textPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select from our experienced faculty members to complete your class schedule.',
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: FirestoreListView<Map<String, dynamic>>(
              query: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'faculty')
                  .orderBy('name'),
              itemBuilder: (context, snapshot) {
                final data = snapshot.data();
                final nameParts = data['name'].toString().split(' ');
                final initials =
                    nameParts.length > 1
                        ? '${nameParts.first[0]}${nameParts.last[0]}'
                        : nameParts.first[0];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        onSelect(snapshot);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  initials.toUpperCase(),
                                  style: context.textStyles.body1.baseStyle
                                      .copyWith(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'],
                                    style: context.textStyles.body1.textPrimary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 16,
                                        color: context.colors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          data['email'],
                                          style:
                                              context
                                                  .textStyles
                                                  .caption1
                                                  .textSecondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.school_outlined,
                                        size: 16,
                                        color: context.colors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['department'] ?? 'Faculty',
                                        style:
                                            context
                                                .textStyles
                                                .caption1
                                                .textSecondary,
                                      ),
                                      if (data['isFullTime'] == true) ...[
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.work_outline,
                                          size: 16,
                                          color: context.colors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Full Time',
                                          style:
                                              context
                                                  .textStyles
                                                  .caption1
                                                  .textSecondary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.colors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: context.colors.inputBorder),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
