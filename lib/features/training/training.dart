
import 'package:bros_gym_diary/features/new_workout/new_workout.dart';
import 'package:bros_gym_diary/features/training/training_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout.dart';
import '../new_workout/workout_repository.dart';

class TrainingScreen extends StatelessWidget {
  TrainingScreen({super.key});

  final repo = WorkoutRepository();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Тренировки')),

      body: StreamBuilder<List<Workout>>(
        stream: repo.watchWorkouts(userId),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text('Нет тренировок'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final w = list[i];
              final formattedDate = DateFormat('d MMMM yyyy', 'ru_RU')
                  .format(w.createdAtUtc.toLocal());
              return Card(
                child: ListTile(
                  title: Text(w.name),
                  subtitle: Text(formattedDate),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TrainingHistoryViewScreen(workout: w),
                      ),
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Удалить тренировку?'),
                          content: Text('Удалить "${w.name}"?'),
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
                        await repo.delete(userId, w.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewWorkoutScreen(),
            ),
          );
        },
      ),
    );
  }
}