import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/admin/presentation/component/search_bar.dart';

class SubjectPicker extends HookWidget {
  final Function(DocumentSnapshot) onSelect;

  const SubjectPicker({super.key, required this.onSelect});

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
          .collection('subjects')
          .orderBy('title');

      if (search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        final searchUpper = '${search.toLowerCase()}\uf8ff';
        query = query
            .where('title_search', isGreaterThanOrEqualTo: searchLower)
            .where('title_search', isLessThan: searchUpper);
      }

      return query;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Subject',
          style: context.textStyles.heading2.textPrimary,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: searchController,
              onClear: () => searchQuery.value = '',
              hintText: 'Search subjects...',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Subject',
                  style: context.textStyles.heading1.textPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select from our comprehensive list of academic subjects to create your schedule.',
                  style: context.textStyles.body2.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: FirestoreListView<Map<String, dynamic>>(
              query: getQuery(searchQuery.value),
              loadingBuilder:
                  (context) => const Center(child: CircularProgressIndicator()),
              errorBuilder:
                  (context, error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading subjects',
                          style: context.textStyles.body1.textPrimary,
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
                          Icons.book_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No subjects found',
                          style: context.textStyles.body1.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No subjects available'
                              : 'Try a different search',
                          style: context.textStyles.caption1.textSecondary,
                        ),
                      ],
                    ),
                  ),
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
                                color: Colors.indigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.book_outlined,
                                  color: Colors.indigo,
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
                                    style:
                                        context
                                            .textStyles
                                            .caption1
                                            .textSecondary,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: context.colors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LEC: ${data['units']?['lec'] ?? 0}, LAB: ${data['units']?['lab'] ?? 0}',
                                        style:
                                            context
                                                .textStyles
                                                .caption1
                                                .textSecondary,
                                      ),
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
