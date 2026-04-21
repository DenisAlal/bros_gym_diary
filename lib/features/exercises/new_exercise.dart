import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
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
  final weightStartController = TextEditingController();
  final weightEndController = TextEditingController();

  String muscleGroup = 'chest';

  final repo = ExerciseRepository();

  @override
  void initState() {
    super.initState();

    final e = widget.exercise;
    if (e != null) {
      nameController.text = e.name;
      weightStartController.text = e.weightStart.toString();
      weightEndController.text = e.weightEnd.toString();
      muscleGroup = e.muscleGroup;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Создать' : 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (v) => v!.isEmpty ? 'Введите название' : null,
              ),

              TextFormField(
                controller: weightStartController,
                decoration: const InputDecoration(labelText: 'Начальный вес'),
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: weightEndController,
                decoration: const InputDecoration(labelText: 'Конечный вес'),
                keyboardType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                initialValue: muscleGroup,
                items: const [
                  DropdownMenuItem(value: 'chest', child: Text('Грудь')),
                  DropdownMenuItem(value: 'back', child: Text('Спина')),
                  DropdownMenuItem(value: 'legs', child: Text('Ноги')),
                ],
                onChanged: (v) => setState(() => muscleGroup = v!),
                decoration: const InputDecoration(labelText: 'Группа'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  String? uploadedUrl = widget.exercise?.imageUrl;

                  // if (imageFile != null) {
                  //   uploadedUrl = await storage.uploadExerciseImage(
                  //     userId: userId,
                  //     file: imageFile!,
                  //   );
                  // }

                  final exercise = Exercise(
                    id: widget.exercise?.id ?? '',
                    name: nameController.text,
                    imageUrl: uploadedUrl ?? '',
                    weightStart: int.tryParse(weightStartController.text) ?? 0,
                    weightEnd: int.tryParse(weightEndController.text) ?? 0,
                    muscleGroup: muscleGroup,
                  );

                  if (widget.exercise == null) {
                    await repo.addExercise(userId, exercise);
                  } else {
                    await repo.updateExercise(userId, exercise);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
