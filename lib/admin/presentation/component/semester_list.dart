import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/component/communication/empty_display.dart';
import 'package:scheduler/common/component/communication/error_display.dart';
import 'semester_list_item.dart';

class SemesterList extends StatelessWidget {
  const SemesterList({super.key});

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'semesters',
    );

    // Always filter out archived semesters
    query =
        query.where('status', isNotEqualTo: 'archived')
            as Query<Map<String, dynamic>>;

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
            title: 'No Semesters Available',
            subtitle: 'Please add a semester to get started',
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
