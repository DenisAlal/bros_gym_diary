import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/utils.dart';
import '../../models/workout.dart';
import '../../models/exercise.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/page.dart';

class WorkoutTemplateViewScreen extends StatelessWidget {
  final WorkoutTemplate template;

  const WorkoutTemplateViewScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final exerciseRepo = ExerciseRepository();

    return Scaffold(
      appBar: AppBar(title: Text(template.name)),
      body: StreamBuilder<List<Exercise>>(
        stream: exerciseRepo.watchExercises(userId),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];
          final exercises = template.exerciseIds
              .map(
                (id) => all.firstWhere(
                  (e) => e.id == id,
                  orElse: () => Exercise(
                    id: '',
                    name: 'Удалено',
                    description: '',
                    muscleGroup: '',
                    simulatorName: '',
                  ),
                ),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();

          if (exercises.isEmpty) {
            return const Center(child: Text('Нет упражнений'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: exercises.length,
            itemBuilder: (context, i) {
              final e = exercises[i];

              return ExerciseViewCard(
                key: ValueKey(e.id),
                exercise: e,
                index: i,
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
          );
        },
      ),
    );
  }
}

class ExerciseViewCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final int? index;

  const ExerciseViewCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final muscle = getMuscle(exercise.muscleGroup);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [muscle.color.withAlpha(70), muscle.color.withAlpha(15)],
        ),
        border: Border.all(color: muscle.color.withAlpha(30)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: muscle.color.withAlpha(55),
              child: Icon(muscle.icon, color: muscle.color),
            ),

            if (index != null)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index! + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Тренажер: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: exercise.simulatorName),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Описание: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: exercise.description),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Группа: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: muscle.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
