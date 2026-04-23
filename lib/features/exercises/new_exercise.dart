import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../models/muscle_group.dart';
import 'exercise_repository.dart';

class ExerciseNewScreen extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseNewScreen({super.key, this.exercise});

  @override
  State<ExerciseNewScreen> createState() => _ExerciseNewScreenState();
}

class _ExerciseNewScreenState extends State<ExerciseNewScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final simulatorNameController = TextEditingController();
  final descriptionController = TextEditingController();

  String muscleGroup = 'chest';

  final repo = ExerciseRepository();

  @override
  void initState() {
    super.initState();

    final e = widget.exercise;
    if (e != null) {
      nameController.text = e.name;
      simulatorNameController.text = e.simulatorName;
      descriptionController.text = e.description.toString();
      muscleGroup = e.muscleGroup;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Создать' : 'Редактировать'),
        actions: [
          IconButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final exercise = Exercise(
                id: widget.exercise?.id ?? '',
                name: nameController.text,
                simulatorName: simulatorNameController.text,
                description: descriptionController.text,
                muscleGroup: muscleGroup,
              );

              if (widget.exercise == null) {
                await repo.addExercise(userId, exercise);
              } else {
                await repo.updateExercise(userId, exercise);
              }

              Navigator.pop(context);
            },
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Введите название' : null,
              ),
              TextFormField(
                controller: simulatorNameController,
                decoration: const InputDecoration(
                  labelText: 'Название тренажера',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Введите название тренажера' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: muscleGroup,
                items: muscleGroups.map((m) {
                  return DropdownMenuItem(value: m.id, child: Text(m.label));
                }).toList(),
                onChanged: (v) => setState(() => muscleGroup = v!),
                decoration: const InputDecoration(
                  labelText: 'Группа',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
