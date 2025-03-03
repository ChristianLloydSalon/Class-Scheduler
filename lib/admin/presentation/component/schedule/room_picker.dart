import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class RoomPicker extends StatelessWidget {
  final Function(DocumentSnapshot) onSelect;

  const RoomPicker({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Room',
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
                  'Find Your Perfect Space',
                  style: context.textStyles.heading1.textPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose from our available rooms and labs, each equipped with the facilities you need.',
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: FirestoreListView<Map<String, dynamic>>(
              query: FirebaseFirestore.instance
                  .collection('rooms')
                  .orderBy('name'),
              itemBuilder: (context, snapshot) {
                final data = snapshot.data();
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
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  data['type'] == 'lab'
                                      ? Icons.computer
                                      : Icons.meeting_room,
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
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['code'],
                                    style:
                                        context
                                            .textStyles
                                            .caption1
                                            .textSecondary,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    children: [
                                      Icon(
                                        Icons.chair,
                                        size: 16,
                                        color: context.colors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${data['chairs']} chairs',
                                        style:
                                            context
                                                .textStyles
                                                .caption1
                                                .textSecondary,
                                      ),
                                      if (data['whiteboard'] == true) ...[
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.edit_square,
                                          size: 16,
                                          color: context.colors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Whiteboard',
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
