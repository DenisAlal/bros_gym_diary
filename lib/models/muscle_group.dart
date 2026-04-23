import 'package:flutter/material.dart';

class MuscleGroup {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const MuscleGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const muscleGroups = [
  MuscleGroup(
    id: 'chest',
    label: 'Грудь',
    icon: Icons.fitness_center,
    color: Colors.redAccent,
  ),
  MuscleGroup(
    id: 'back',
    label: 'Спина',
    icon: Icons.accessibility_new,
    color: Colors.blueAccent,
  ),
  MuscleGroup(
    id: 'fullbody',
    label: 'Фулл Боди',
    icon: Icons.sports_martial_arts,
    color: Colors.deepPurpleAccent,
  ),
  MuscleGroup(
    id: 'legs',
    label: 'Ноги',
    icon: Icons.directions_run,
    color: Colors.greenAccent,
  ),
  MuscleGroup(
    id: 'cardio',
    label: 'Кардио',
    icon: Icons.run_circle_outlined,
    color: Colors.deepOrangeAccent,
  ),
  MuscleGroup(
    id: 'hands',
    label: 'Руки',
    icon: Icons.sports_handball,
    color: Colors.indigoAccent,
  ),
];
