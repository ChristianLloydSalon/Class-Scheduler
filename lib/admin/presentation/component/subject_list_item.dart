import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SubjectListItem extends StatelessWidget {
  final QueryDocumentSnapshot subject;

  const SubjectListItem({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final data = subject.data() as Map<String, dynamic>;
    final units = data['units'] as Map<String, dynamic>? ?? const {};

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.indigo.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to subject detail
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
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    data['code'].substring(0, 1).toUpperCase(),
                    style: context.textStyles.heading3.baseStyle.copyWith(
                      color: Colors.indigo,
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
                      data['title'],
                      style: context.textStyles.body1.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['code'],
                      style: context.textStyles.caption1.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'LEC: ${units['lec']}',
                          style: context.textStyles.caption1.textSecondary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'LAB: ${units['lab']}',
                          style: context.textStyles.caption1.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.textHint.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
