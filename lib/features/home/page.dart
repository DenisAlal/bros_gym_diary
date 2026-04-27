import 'package:bros_gym_diary/features/profile/profile.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
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
            _tile(context, 'Тренировки', Icons.calendar_month, '/training'),
            _tile(
              context,
              'Шаблоны тренировок',
              Icons.library_books_sharp,
              '/training_patterns',
            ),
            _tile(
              context,
              'Статистика',
              Icons.auto_graph,
              '/stat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return InkWell(
      onTap: () => context.push(route),
      child: Card(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(icon, size: 60),
            const SizedBox(height: 10),
            Text(title, textAlign: .center),
          ],
        ),
      ),
    );
  }
}
