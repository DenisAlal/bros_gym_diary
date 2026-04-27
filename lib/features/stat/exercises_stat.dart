import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils.dart';
import '../../models/workout.dart';
import '../../models/exercise.dart';
import '../new_workout/workout_repository.dart';
import '../exercises/exercise_repository.dart';

class ExercisePoint {
  final DateTime date;
  final double weight;

  ExercisePoint({required this.date, required this.weight});
}

class ExerciseStatsScreen extends StatefulWidget {
  const ExerciseStatsScreen({super.key});

  @override
  State<ExerciseStatsScreen> createState() => _ExerciseStatsScreenState();
}

class _ExerciseStatsScreenState extends State<ExerciseStatsScreen> {
  final workoutRepo = WorkoutRepository();
  final exerciseRepo = ExerciseRepository();

  String? selectedExerciseId;

  Map<String, Exercise> exerciseMap = {};

  Map<String, List<ExercisePoint>> _buildStats(List<Workout> workouts) {
    final Map<String, List<ExercisePoint>> map = {};

    for (final w in workouts) {
      for (final ex in w.exercises) {
        if (!ex.done || ex.weight == null) continue;

        map.putIfAbsent(ex.exerciseId, () => []);

        map[ex.exerciseId]!.add(
          ExercisePoint(date: w.createdAtUtc, weight: ex.weight!),
        );
      }
    }

    for (final e in map.entries) {
      e.value.sort((a, b) => a.date.compareTo(b.date));
    }

    return map;
  }

  List<FlSpot> _toSpots(List<ExercisePoint> points) {
    if (points.isEmpty) return [];

    return points.map((p) {
      return FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.weight);
    }).toList();
  }

  double _calcYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;

    final max = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return (max / 4).clamp(1, 50);
  }

  double _calcXInterval(List<FlSpot> spots) {
    if (spots.length < 2) return 1;

    final span = spots.last.x - spots.first.x;
    return span / 4;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: StreamBuilder<List<Workout>>(
        stream: workoutRepo.watchWorkouts(userId),
        builder: (context, workoutSnap) {
          final workouts = workoutSnap.data ?? [];

          return StreamBuilder<List<Exercise>>(
            stream: exerciseRepo.watchExercises(userId),
            builder: (context, exerciseSnap) {
              final exercises = exerciseSnap.data ?? [];

              // build map exerciseId -> Exercise
              exerciseMap = {for (final e in exercises) e.id: e};

              final stats = _buildStats(workouts);
              final ids = stats.keys.toList();

              if (ids.isEmpty) {
                return const Center(child: Text('Нет данных'));
              }

              selectedExerciseId ??= ids.first;

              final selected = stats[selectedExerciseId] ?? [];
              final spots = _toSpots(selected);

              final selectedExercise = exerciseMap[selectedExerciseId];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // selector
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ids.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final id = ids[i];
                          final ex = exerciseMap[id];

                          return ChoiceChip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(ex?.name ?? id),
                                Text(
                                  label(ex?.muscleGroup ?? ''),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            selected: id == selectedExerciseId,
                            onSelected: (_) {
                              setState(() {
                                selectedExerciseId = id;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),


                    Expanded(
                      child: LineChart(
                        LineChartData(
                          minX: spots.first.x,
                          maxX: spots.last.x,

                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),

                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),

                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),

                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: _calcYInterval(spots),
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()} kg',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: _calcXInterval(spots),
                                getTitlesWidget: (value, meta) {
                                  final date =
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt());

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        '${date.day}.${date.month}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          lineTouchData: LineTouchData(
                            enabled: true,
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,

                              isCurved: true,
                              curveSmoothness: 0.25,

                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1), // индиго
                                  Color(0xFF22C55E), // зелёный прогресс
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),

                              barWidth: 3,

                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  final isMax = spot.y ==
                                      spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

                                  return FlDotCirclePainter(
                                    radius: isMax ? 5 : 3,
                                    color: isMax ? Colors.redAccent : Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF6366F1),
                                  );
                                },
                              ),

                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
