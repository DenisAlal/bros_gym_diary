import 'package:flutter/material.dart';

import '../models/muscle_group.dart';

MuscleGroup getMuscle(String id) {
  return muscleGroups.firstWhere(
        (e) => e.id == id,
    orElse: () => const MuscleGroup(
      id: 'unknown',
      label: 'Неизвестно',
      icon: Icons.help,
      color: Colors.grey,
    ),
  );
}

IconData iconForMuscle(String group) => getMuscle(group).icon;

Color colorForMuscle(String group) => getMuscle(group).color;

String label(String group) => getMuscle(group).label;