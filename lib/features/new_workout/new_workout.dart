import 'package:flutter/material.dart';

class NewWorkoutScreen extends StatelessWidget {
  const NewWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новая тренировка')),
      body: Text('Новая тренировка'),
    );
  }
}
