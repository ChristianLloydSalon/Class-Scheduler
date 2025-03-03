import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;

  const ExamCard({super.key, required this.exam});

  String _formatTime(Map<String, dynamic>? time) {
    if (time == null) return '';
    final hour = time['hour'] as int?;
    final minute = time['minute'] as int?;
    if (hour == null || minute == null) return '';

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 =
        hour > 12
            ? hour - 12
            : hour == 0
            ? 12
            : hour;
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final date = (exam['date'] as Timestamp).toDate();
    final startTime = exam['startTime'] as Map<String, dynamic>;
    final endTime = exam['endTime'] as Map<String, dynamic>;
    final isUpcoming = date.isAfter(DateTime.now());

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isUpcoming
                  ? context.colors.primary.withOpacity(0.05)
                  : context.colors.surface,
              isUpcoming
                  ? context.colors.surface.withOpacity(0.95)
                  : context.colors.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['title'] ?? 'Untitled Exam',
                          style: context.textStyles.subtitle1.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isUpcoming
                                    ? context.colors.primary.withOpacity(0.1)
                                    : context.colors.textSecondary.withOpacity(
                                      0.1,
                                    ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isUpcoming ? 'Upcoming' : 'Past',
                            style:
                                isUpcoming
                                    ? context.textStyles.caption2.primary
                                    : context.textStyles.caption2.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getDayName(date),
                      style: context.textStyles.caption1.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: context.colors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(date),
                          style: context.textStyles.body2.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                        style: context.textStyles.body2.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.room_rounded,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exam['room'] ?? 'No Room Assigned',
                    style: context.textStyles.body2.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
