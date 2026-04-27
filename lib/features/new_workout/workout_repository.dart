import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/workout.dart';

class WorkoutRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference _ref(String userId) =>
      _db.collection('users').doc(userId).collection('workouts');

  Stream<List<Workout>> watchWorkouts(String userId) {
    return _ref(userId)
        .orderBy('createdAtUtc', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => Workout.fromJson(
      d.data() as Map<String, dynamic>,
      d.id,
    ))
        .toList());
  }

  Future<void> add(String userId, Workout workout) async {
    await _ref(userId).add(workout.toJson());
  }

  Future<void> update(String userId, String id, Workout workout) async {
    await _ref(userId).doc(id).update(workout.toJson());
  }

  Future<void> delete(String userId, String id) async {
    await _ref(userId).doc(id).delete();
  }
}