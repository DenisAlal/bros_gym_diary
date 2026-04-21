import 'package:bros_gym_diary/features/training_patterns/training_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/page.dart';

class WorkoutTemplateEditScreen extends StatefulWidget {
  final WorkoutTemplate? template;

  const WorkoutTemplateEditScreen({super.key, this.template});

  @override
  State<WorkoutTemplateEditScreen> createState() =>
      _WorkoutTemplateEditScreenState();
}

class _WorkoutTemplateEditScreenState extends State<WorkoutTemplateEditScreen> {
  final nameController = TextEditingController();
  String muscleGroup = 'chest';
  List<Exercise> allExercises = [];
  List<String> selected = [];

  final exerciseRepo = ExerciseRepository();
  final templateRepo = WorkoutTemplateRepository();

  @override
  void initState() {
    super.initState();

    final t = widget.template;
    if (t != null) {
      nameController.text = t.name;
      muscleGroup = t.muscleGroup;
      selected = List.from(t.exerciseIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Шаблон')),

      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Название'),
          ),

          DropdownButton<String>(
            value: muscleGroup,
            items: const [
              DropdownMenuItem(value: 'chest', child: Text('Грудь')),
              DropdownMenuItem(value: 'back', child: Text('Спина')),
              DropdownMenuItem(value: 'legs', child: Text('Ноги')),
            ],
            onChanged: (v) {
              setState(() {
                muscleGroup = v!;

                selected = selected.where((id) {
                  final e = allExercises.firstWhere(
                    (x) => x.id == id,
                    orElse: () => Exercise(
                      id: '',
                      name: 'Удалено',
                      imageUrl: '',
                      weightStart: 0,
                      weightEnd: 0,
                      muscleGroup: '',
                    ),
                  );
                  return e.muscleGroup == muscleGroup;
                }).toList();
              });
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Exercise>>(
              stream: exerciseRepo.watchExercises(userId),
              builder: (context, snapshot) {
                final exercises = snapshot.data ?? [];
                allExercises = exercises;

                final filtered = allExercises
                    .where((e) => e.muscleGroup == muscleGroup)
                    .toList();

                return Column(
                  children: [
                    if (filtered.isNotEmpty && allExercises.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final e = filtered[index];
                            final isSelected = selected.contains(e.id);

                            return ListTile(
                              title: Text(e.name),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exercise: e),
                                  ),
                                );
                              },

                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true && !selected.contains(e.id)) {
                                      selected.add(e.id);
                                    } else {
                                      selected.remove(e.id);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const Divider(),

                    Expanded(
                      child: SizedBox(
                        height: 200,
                        child: ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = selected.removeAt(oldIndex);
                              selected.insert(newIndex, item);
                            });
                          },
                          children: selected.map((id) {
                            final e = allExercises.firstWhere(
                              (x) => x.id == id,
                              orElse: () => Exercise(
                                id: '',
                                name: 'Удалено',
                                imageUrl: '',
                                weightStart: 0,
                                weightEnd: 0,
                                muscleGroup: '',
                              ),
                            );
                            if (e.id.isEmpty) return const SizedBox();
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exercise: e),
                                  ),
                                );
                              },
                              key: ValueKey(id),
                              title: Text(e.name),
                              leading: const Icon(Icons.drag_handle),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              final template = WorkoutTemplate(
                id: widget.template?.id ?? '',
                name: nameController.text,
                muscleGroup: muscleGroup,
                exerciseIds: selected,
              );

              if (widget.template == null) {
                await templateRepo.add(userId, template);
              } else {
                await templateRepo.update(userId, template);
              }

              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
