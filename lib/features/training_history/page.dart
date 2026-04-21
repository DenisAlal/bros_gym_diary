import 'package:flutter/material.dart';

class TrainingHistoryScreen extends StatelessWidget {

  const TrainingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('История тренировок')),
      body: Text('История тренировок')
    );
  }
}