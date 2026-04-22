import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils.dart';
import '../../models/workout.dart';
import '../../models/exercise.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/page.dart';
import '../new_workout/workout_repository.dart';

class TrainingHistoryViewScreen extends StatefulWidget {
  final Workout workout;

  const TrainingHistoryViewScreen({super.key, required this.workout});

  @override
  State<TrainingHistoryViewScreen> createState() =>
      _TrainingHistoryViewScreenState();
}

class _TrainingHistoryViewScreenState extends State<TrainingHistoryViewScreen> {
  final exerciseRepo = ExerciseRepository();
  final workoutRepo = WorkoutRepository();

  late Map<String, bool> doneMap;

  @override
  void initState() {
    super.initState();

    doneMap = {for (final e in widget.workout.exercises) e.exerciseId: e.done};
  }

  Future<void> _saveInstant(String userId) async {
    final updated = Workout(
      id: widget.workout.id,
      templateId: widget.workout.templateId,
      createdAtUtc: widget.workout.createdAtUtc,
      name: widget.workout.name,
      exercises: doneMap.entries
          .map((e) => WorkoutExerciseState(exerciseId: e.key, done: e.value))
          .toList(),
    );

    await workoutRepo.update(userId, updated);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Тренировка')),

      body: StreamBuilder<List<Exercise>>(
        stream: exerciseRepo.watchExercises(userId),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];

          final exercises = widget.workout.exercises
              .map(
                (w) => all.firstWhere(
                  (e) => e.id == w.exerciseId,
                  orElse: () => Exercise(
                    id: '',
                    name: 'Удалено',
                    simulatorName: '',
                    weightStart: 0,
                    weightEnd: 0,
                    muscleGroup: '',
                  ),
                ),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workout.name.isEmpty
                          ? 'Тренировка'
                          : widget.workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat(
                        'd MMMM yyyy',
                        'ru_RU',
                      ).format(widget.workout.createdAtUtc.toLocal()),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (_, i) {
                    final e = exercises[i];

                    return _ExerciseCard(
                      key: ValueKey(e.id),
                      exercise: e,
                      isSelected: doneMap[e.id] ?? false,
                      onToggle: (v) async {
                        setState(() {
                          doneMap[e.id] = v ?? false;
                        });

                        await _saveInstant(userId);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: e),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  final bool isSelected;
  final ValueChanged<bool?> onToggle;

  const _ExerciseCard({
    required Key key,
    required this.exercise,
    required this.onTap,
    required this.isSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = colorForMuscle(exercise.muscleGroup);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withAlpha(70), color.withAlpha(15)],
        ),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(55),
              child: Icon(iconForMuscle(exercise.muscleGroup), color: color),
            ),
          ],
        ),

        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          '${label(exercise.muscleGroup)} • ${exercise.weightStart}-${exercise.weightEnd} кг',
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Checkbox(value: isSelected, onChanged: onToggle)],
        ),
      ),
    );
  }
}
