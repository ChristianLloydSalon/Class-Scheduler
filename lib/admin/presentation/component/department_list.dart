import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/component/department_list_item.dart';
import 'package:scheduler/common/component/communication/empty_display.dart';
import 'package:scheduler/common/component/communication/error_display.dart';

class DepartmentList extends StatelessWidget {
  const DepartmentList({super.key, required this.semesterId});

  final String semesterId;

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('departments')
        .where('semesterId', isEqualTo: semesterId);

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
            title: 'No Departments Available',
            subtitle: 'Please add a department to get started',
          ),
      itemBuilder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DepartmentListItem(
            semesterId: semesterId,
            departmentId: snapshot.id,
            department: snapshot,
          ),
        );
      },
    );
  }
}
