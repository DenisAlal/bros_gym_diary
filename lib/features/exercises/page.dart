import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import 'new_exercise.dart';
import 'exercise_repository.dart';

class ExerciseListScreen extends StatelessWidget {
  ExerciseListScreen({super.key});

  final repo = ExerciseRepository();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Упражнения')),

      body: StreamBuilder<List<Exercise>>(
        stream: repo.watchExercises(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text('Нет упражнений'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = list[i];

              return _ExerciseCard(
                exercise: e,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(exercise: e),
                    ),
                  );
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Удалить упражнение?'),
                      content: Text('Удалить "${e.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Удалить',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await repo.deleteExercise(userId, e.id);
                  }
                },
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ExerciseNewScreen(exercise: e),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExerciseNewScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  IconData _iconForMuscle(String group) {
    switch (group) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Color _colorForMuscle(String group) {
    switch (group) {
      case 'chest':
        return Colors.redAccent;
      case 'back':
        return Colors.blueAccent;
      case 'legs':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _label(String group) {
    switch (group) {
      case 'chest':
        return 'Грудь';
      case 'back':
        return 'Спина';
      case 'legs':
        return 'Ноги';
      default:
        return group;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForMuscle(exercise.muscleGroup);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(_iconForMuscle(exercise.muscleGroup), color: color),
        ),

        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(
          '${_label(exercise.muscleGroup)} • ${exercise.weightStart}-${exercise.weightEnd} кг',
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  String _label(String group) {
    switch (group) {
      case 'chest':
        return 'Грудь';
      case 'back':
        return 'Спина';
      case 'legs':
        return 'Ноги';
      default:
        return group;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  exercise.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            Text(
              exercise.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Группа: ${_label(exercise.muscleGroup)}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              'Вес: ${exercise.weightStart} - ${exercise.weightEnd} кг',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
