import 'package:bros_gym_diary/features/training_patterns/training_edit.dart';
import 'package:bros_gym_diary/features/training_patterns/training_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/workout.dart';

class WorkoutTemplateListScreen extends StatelessWidget {
  WorkoutTemplateListScreen({super.key});

  final repo = WorkoutTemplateRepository();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Шаблоны тренировок')),

      body: StreamBuilder(
        stream: repo.watchTemplates(userId),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text('Нет шаблонов'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final t = list[i];

              return _TemplateCard(
                template: t,
                onDelete: () async {
                  await repo.delete(userId, t.id);
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutTemplateEditScreen(template: t),
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
            MaterialPageRoute(builder: (_) => const WorkoutTemplateEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TemplateCard({
    required this.template,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: ListTile(
        title: Text(template.name),
        subtitle: Text('Упражнений: ${template.exerciseIds.length}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}