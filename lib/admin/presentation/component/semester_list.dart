import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/component/communication/empty_display.dart';
import 'package:scheduler/common/component/communication/error_display.dart';
import 'semester_list_item.dart';

class SemesterList extends StatefulWidget {
  const SemesterList({super.key});

  @override
  State<SemesterList> createState() => _SemesterListState();
}

class _SemesterListState extends State<SemesterList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Semesters'),
            Tab(text: 'Archived Semesters'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _SemesterListView(isArchived: false),
              _SemesterListView(isArchived: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SemesterListView extends StatelessWidget {
  final bool isArchived;

  const _SemesterListView({required this.isArchived});

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'semesters',
    );

    // Filter based on archived status
    if (isArchived) {
      query =
          query.where('status', isEqualTo: 'archived')
              as Query<Map<String, dynamic>>;
    } else {
      query =
          query.where('status', isNotEqualTo: 'archived')
              as Query<Map<String, dynamic>>;
    }

    query = query
        .orderBy('status')
        .orderBy('year', descending: true)
        .orderBy('semester');

    return FirestoreListView<Map<String, dynamic>>(
      query: query,
      loadingBuilder:
          (context) => const Center(child: CircularProgressIndicator()),
      errorBuilder:
          (context, error, _) => ErrorDisplay(
            title: 'Something went wrong',
            subtitle: 'Please try again later',
          ),
      emptyBuilder:
          (context) => EmptyDisplay(
            title: isArchived ? 'No Archived Semesters' : 'No Active Semesters',
            subtitle:
                isArchived
                    ? 'Archived semesters will appear here'
                    : 'Please add a semester to get started',
          ),
      itemBuilder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SemesterListItem(semesterId: snapshot.id, semester: snapshot),
        );
      },
    );
  }
}
