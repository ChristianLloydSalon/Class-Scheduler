import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/component/room_list_item.dart';
import 'package:scheduler/admin/presentation/component/search_bar.dart';
import 'package:scheduler/admin/presentation/screen/add_room_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class RoomListScreen extends HookWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void searchListener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(searchListener);
      return () => searchController.removeListener(searchListener);
    }, [searchController]);

    Query<Map<String, dynamic>> getQuery(String search) {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('rooms')
          .orderBy('name');

      if (search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        final searchUpper = '${search.toLowerCase()}\uf8ff';
        query = query
            .where('name_search', isGreaterThanOrEqualTo: searchLower)
            .where('name_search', isLessThan: searchUpper);
      }

      return query;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms', style: context.textStyles.heading2.textPrimary),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: searchController,
              onClear: () => searchQuery.value = '',
              hintText: 'Search rooms...',
            ),
          ),
        ),
      ),
      body: FirestoreListView<Map<String, dynamic>>(
        query: getQuery(searchQuery.value),
        loadingBuilder:
            (context) => const Center(child: CircularProgressIndicator()),
        errorBuilder:
            (context, error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading rooms',
                    style: context.textStyles.body1.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: context.textStyles.caption1.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        emptyBuilder:
            (context) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms found',
                    style: context.textStyles.body1.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchQuery.value.isEmpty
                        ? 'Add your first room'
                        : 'Try a different search',
                    style: context.textStyles.caption1.textSecondary,
                  ),
                ],
              ),
            ),
        itemBuilder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RoomListItem(room: snapshot),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRoomScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
