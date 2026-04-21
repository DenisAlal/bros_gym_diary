import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/exercise.dart';


class ExerciseRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference _ref(String userId) =>
      _db.collection('users').doc(userId).collection('exercises');

  Stream<List<Exercise>> watchExercises(String userId) {
    return _ref(userId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((e) => Exercise.fromJson(e.data() as Map<String, dynamic>, e.id))
          .toList(),
    );
  }

  Future<void> addExercise(String userId, Exercise exercise) async {
    await _ref(userId).add(exercise.toJson());
  }

  Future<void> updateExercise(String userId, Exercise exercise) async {
    await _ref(userId).doc(exercise.id).update(exercise.toJson());
  }

  Future<void> deleteExercise(String userId, String id) async {
    await _ref(userId).doc(id).delete();
  }
}