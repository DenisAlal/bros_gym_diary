import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _tile(context, 'Упражнения', Icons.fitness_center, '/exercises'),
            _tile(context, 'История тренировок', Icons.calendar_month, '/training_history'),
            _tile(context, 'Шаблоны тренировок', Icons.list_alt, '/training_patterns'),
            _tile(context, 'Новая тренировка', Icons.play_arrow, '/new_workout'),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}