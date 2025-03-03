import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const ScheduleCard({super.key, required this.schedule});

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

  @override
  Widget build(BuildContext context) {
    final subjectData = schedule['subjectData'] as Map<String, dynamic>?;
    final roomData = schedule['roomData'] as Map<String, dynamic>?;
    final startTime = schedule['startTime'] as Map<String, dynamic>?;
    final endTime = schedule['endTime'] as Map<String, dynamic>?;
    final units = subjectData?['units'] as Map<String, dynamic>?;
    final hasUnits =
        (units?['lec'] as int? ?? 0) > 0 || (units?['lab'] as int? ?? 0) > 0;

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
              context.colors.surface,
              context.colors.surface.withOpacity(0.8),
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
                          subjectData?['title'] ?? 'Unknown Subject',
                          style: context.textStyles.subtitle1.textPrimary,
                        ),
                        if (hasUnits) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if ((units?['lec'] as int? ?? 0) > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${units?['lec']} Units (Lec)',
                                    style: context.textStyles.caption2.primary,
                                  ),
                                ),
                              if ((units?['lab'] as int? ?? 0) > 0) ...[
                                if ((units?['lec'] as int? ?? 0) > 0)
                                  const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${units?['lab']} Units (Lab)',
                                    style: context.textStyles.caption2.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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
                      schedule['day'] ?? 'Unknown Day',
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
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.room_rounded,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        roomData?['name'] ?? 'Unknown Room',
                        style: context.textStyles.body2.textSecondary,
                      ),
                    ],
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
