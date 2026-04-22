import 'package:bros_gym_diary/features/training_patterns/training_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/utils.dart';
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
      selected = List.from(t.exerciseIds);
    }
  }

  List<Exercise> orderedList() {
    final selectedExercises = selected
        .map(
          (id) => allExercises.firstWhere(
            (e) => e.id == id,
            orElse: () => Exercise(
              id: '',
              name: 'Удалено',
              weightStart: 0,
              weightEnd: 0,
              muscleGroup: '',
              simulatorName: '',
            ),
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList();

    final notSelected = allExercises
        .where((e) => !selected.contains(e.id))
        .toList();

    return [...selectedExercises, ...notSelected];
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Шаблон тренировки'),
        actions: [
          IconButton(
            onPressed: () async {
              final template = WorkoutTemplate(
                id: widget.template?.id ?? '',
                name: nameController.text,
                exerciseIds: selected,
              );

              if (widget.template == null) {
                await templateRepo.add(userId, template);
              } else {
                await templateRepo.update(userId, template);
              }

              Navigator.pop(context);
            },
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: .symmetric(horizontal: 15),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Exercise>>(
              stream: exerciseRepo.watchExercises(userId),
              builder: (context, snapshot) {
                final exercises = snapshot.data ?? [];
                allExercises = exercises;

                final list = orderedList();

                return ReorderableListView.builder(
                  itemCount: list.length,

                  onReorder: (oldIndex, newIndex) {
                    final selectedCount = selected.length;

                    if (oldIndex >= selectedCount || newIndex > selectedCount)
                      return;

                    setState(() {
                      if (newIndex > oldIndex) newIndex--;

                      final item = selected.removeAt(oldIndex);
                      selected.insert(newIndex, item);
                    });
                  },

                  itemBuilder: (context, index) {
                    final e = list[index];
                    final isSelected = selected.contains(e.id);

                    return _ExerciseCard(
                      key: ValueKey(e.id),
                      exercise: e,
                      isSelected: isSelected,
                      isDraggable: index < selected.length,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: e),
                          ),
                        );
                      },

                      onToggle: (v) {
                        setState(() {
                          if (v == true) {
                            if (!selected.contains(e.id)) {
                              selected.add(e.id);
                            }
                          } else {
                            selected.remove(e.id);
                          }
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
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  final bool isSelected;
  final bool isDraggable;
  final ValueChanged<bool?> onToggle;

  const _ExerciseCard({
    required Key key,
    required this.exercise,
    required this.onTap,
    required this.isSelected,
    required this.onToggle,
    required this.isDraggable,
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
