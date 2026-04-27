import 'package:bros_gym_diary/features/new_workout/workout_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/utils.dart';
import '../../models/workout.dart';
import '../../models/exercise.dart';
import '../../shared/widgets/stepper.dart';
import '../exercises/page.dart';
import '../training_patterns/training_repository.dart';
import '../exercises/exercise_repository.dart';

class NewWorkoutScreen extends StatefulWidget {
  final Workout? workout;
  final DateTime? date;

  const NewWorkoutScreen({super.key, this.workout, this.date});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final templateRepo = WorkoutTemplateRepository();
  final exerciseRepo = ExerciseRepository();
  final workoutRepo = WorkoutRepository();
  DateTime _selectedDate = DateTime.now();
  String? selectedTemplateId;
  Map<String, double> weightMap = {};
  Map<String, bool> doneMap = {};
  List<String> _orderedIds = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final w = widget.workout;
    if (w != null) {
      selectedTemplateId = w.templateId;
      _nameController.text = w.name;

      _orderedIds = w.exercises.map((e) => e.exerciseId).toList();
      _selectedDate = w.createdAtUtc.toLocal();
      doneMap = {for (final e in w.exercises) e.exerciseId: e.done};

      weightMap = {
        for (final e in w.exercises)
          if (e.weight != null) e.exerciseId: e.weight!,
      };
    }
    if (widget.workout != null) {
      _selectedDate = widget.workout!.createdAtUtc.toLocal();
    }
    if(widget.date != null){
      _selectedDate = widget.date!;
    }
  }
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая тренировка'),
        actions: [
          IconButton(
            onPressed: selectedTemplateId == null
                ? null
                : () async {
                    final userId = FirebaseAuth.instance.currentUser!.uid;

                    final workout = Workout(
                      id: '',
                      name: _nameController.text.trim().isEmpty
                          ? 'Тренировка'
                          : _nameController.text.trim(),
                      templateId: selectedTemplateId!,
                      createdAtUtc: _selectedDate.toUtc(),
                      exercises: _orderedIds.map((id) {
                        return WorkoutExerciseState(
                          exerciseId: id,
                          done: doneMap[id] ?? false,
                          weight: weightMap[id],
                        );
                      }).toList(),
                    );

                    if (widget.workout != null) {
                      await workoutRepo.update(
                        userId,
                        widget.workout!.id,
                        workout,
                      );
                    } else {
                      await workoutRepo.add(userId, workout);
                    }

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: StreamBuilder<List<WorkoutTemplate>>(
                stream: templateRepo.watchTemplates(userId),
                builder: (context, snapshot) {
                  final templates = snapshot.data ?? [];

                  return DropdownButton<String>(
                    value: selectedTemplateId,
                    hint: const Text('Выбери шаблон'),
                    isExpanded: true,
                    items: templates.map((t) {
                      return DropdownMenuItem(value: t.id, child: Text(t.name));
                    }).toList(),
                    onChanged: (id) {
                      final t = templates.firstWhere((e) => e.id == id);

                      setState(() {
                        selectedTemplateId = id;

                        final newOrdered = List<String>.from(t.exerciseIds);

                        final newDoneMap = <String, bool>{};
                        final newWeightMap = <String, double>{};

                        for (final exId in newOrdered) {
                          if (doneMap.containsKey(exId)) {
                            newDoneMap[exId] = doneMap[exId]!;
                            if (weightMap.containsKey(exId)) {
                              newWeightMap[exId] = weightMap[exId]!;
                            }
                          } else {
                            newDoneMap[exId] = false;

                            if (t.defaultWeights.containsKey(exId)) {
                              newWeightMap[exId] = t.defaultWeights[exId]!;
                            }
                          }
                        }

                        _orderedIds = newOrdered;
                        doneMap = newDoneMap;
                        weightMap = newWeightMap;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название тренировки',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        _selectedDate.hour,
                        _selectedDate.minute,
                      );
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Дата тренировки',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    formatDate(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selectedTemplateId == null
                  ? const Center(child: Text('Выбери шаблон'))
                  : StreamBuilder<List<Exercise>>(
                      stream: exerciseRepo.watchExercises(userId),
                      builder: (context, snapshot) {
                        final all = snapshot.data ?? [];

                        final exerciseMap = {for (final e in all) e.id: e};

                        final exercises = _orderedIds
                            .map((id) => exerciseMap[id])
                            .whereType<Exercise>()
                            .toList();

                        return ReorderableListView.builder(
                          itemCount: exercises.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;

                              final item = _orderedIds.removeAt(oldIndex);
                              _orderedIds.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, i) {
                            final e = exercises[i];

                            return _ExerciseCard(
                              key: ValueKey(e.id),
                              exercise: e,
                              isDraggable: true,
                              onDelete: () {
                                setState(() {
                                  _orderedIds.remove(e.id);
                                  weightMap.remove(e.id);
                                  doneMap.remove(e.id);
                                });
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exercise: e),
                                  ),
                                );
                              },
                              weight: weightMap[e.id],
                              onWeightChanged: (w) {
                                setState(() {
                                  weightMap[e.id] = w;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final bool isDraggable;
  final double? weight;
  final ValueChanged<double>? onWeightChanged;
  final VoidCallback? onDelete;

  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onWeightChanged,
    required this.onDelete,
    required this.weight,
    this.isDraggable = false,
  });

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
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDraggable)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.drag_handle),
              ),
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
        subtitle: Text(label(exercise.muscleGroup)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              child: WeightInput(
                value: weight ?? 20,
                onChanged: (v) {
                  if (onWeightChanged != null) {
                    onWeightChanged!(v);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
