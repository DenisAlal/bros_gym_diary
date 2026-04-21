import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/workout.dart';

class WorkoutTemplateRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference _ref(String userId) =>
      _db.collection('users').doc(userId).collection('templates');

  Stream<List<WorkoutTemplate>> watchTemplates(String userId) {
    return _ref(userId).snapshots().map(
          (snap) => snap.docs
          .map((e) => WorkoutTemplate.fromJson(
        e.data() as Map<String, dynamic>,
        e.id,
      ))
          .toList(),
    );
  }

  Future<void> add(String userId, WorkoutTemplate template) async {
    await _ref(userId).add(template.toJson());
  }

  Future<void> update(String userId, WorkoutTemplate template) async {
    await _ref(userId).doc(template.id).update(template.toJson());
  }

  Future<void> delete(String userId, String id) async {
    await _ref(userId).doc(id).delete();
  }
}