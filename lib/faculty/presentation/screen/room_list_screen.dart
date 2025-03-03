import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../common/component/input/primary_text_field.dart';
import '../../../../common/theme/app_theme.dart';

class RoomListScreen extends HookWidget {
  final Function(DocumentSnapshot room) onSelect;

  const RoomListScreen({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final roomsQuery = useMemoized(() {
      final query = FirebaseFirestore.instance.collection('rooms');
      if (searchQuery.value.isEmpty) return query;

      final searchLower = searchQuery.value.toLowerCase();
      return query
          .where('name_search', isGreaterThanOrEqualTo: searchLower)
          .where('name_search', isLessThan: '${searchLower}z');
    }, [searchQuery.value]);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          'Select Room',
          style: context.textStyles.heading3.textPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: context.colors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryTextField(
              controller: searchController,
              hintText: 'Search rooms...',
              onChanged: (value) => searchQuery.value = value,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: roomsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load rooms',
                      style: context.textStyles.subtitle1.error,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                }

                final rooms = snapshot.data?.docs ?? [];

                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: context.colors.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No rooms found',
                          style: context.textStyles.subtitle1.textPrimary,
                        ),
                        if (searchQuery.value.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: context.textStyles.body2.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final data = room.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: context.colors.border),
                      ),
                      child: ListTile(
                        title: Text(
                          data['name'] ?? '',
                          style: context.textStyles.subtitle1.textPrimary,
                        ),
                        subtitle: Text(
                          'Capacity: ${data['chairs'] ?? 0} seats',
                          style: context.textStyles.body2.textSecondary,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: context.colors.textSecondary,
                        ),
                        onTap: () => onSelect(room),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
