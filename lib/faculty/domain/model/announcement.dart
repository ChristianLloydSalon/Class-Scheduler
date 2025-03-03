import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;
  final String teacherId;
  final String courseId;
  final String semesterId;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.teacherId,
    required this.courseId,
    required this.semesterId,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      teacherId: map['teacherId'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      semesterId: map['semesterId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'teacherId': teacherId,
      'courseId': courseId,
      'semesterId': semesterId,
    };
  }

  DateTime get createdAtDateTime => createdAt.toDate();
}
