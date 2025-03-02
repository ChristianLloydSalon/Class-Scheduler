import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class RoomListItem extends StatelessWidget {
  final QueryDocumentSnapshot room;

  const RoomListItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final data = room.data() as Map<String, dynamic>;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to room detail
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
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    data['type'] == 'lab' ? Icons.computer : Icons.meeting_room,
                    color: Colors.teal,
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
                    Text(
                      data['code'],
                      style: context.textStyles.caption1.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['chairs']} chairs • ${_getFacilities(data)}',
                      style: context.textStyles.caption1.textSecondary,
                    ),
                  ],
                ),
              ),
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

  String _getFacilities(Map<String, dynamic> data) {
    final facilities = <String>[];
    if (data['whiteboard'] == true) facilities.add('Whiteboard');
    if (data['blackboard'] == true) facilities.add('Blackboard');
    if (data['tv'] == true) facilities.add('TV');
    if (data['pc'] == true) facilities.add('PC');
    return facilities.join(' • ');
  }
}
