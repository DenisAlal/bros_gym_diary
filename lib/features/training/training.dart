import 'package:bros_gym_diary/features/new_workout/new_workout.dart';
import 'package:bros_gym_diary/features/training/training_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/workout.dart';
import '../new_workout/workout_repository.dart';

class WorkoutCalendarDataSource extends CalendarDataSource {
  WorkoutCalendarDataSource(List<Workout> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final w = appointments![index] as Workout;
    return w.createdAtUtc.toLocal();
  }

  @override
  DateTime getEndTime(int index) {
    final w = appointments![index] as Workout;
    return w.createdAtUtc.toLocal().add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    final w = appointments![index] as Workout;
    return w.name;
  }
}

enum TrainingViewMode { list, calendar }

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final repo = WorkoutRepository();

  TrainingViewMode mode = TrainingViewMode.list;
  DateTime? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _selectedDay ??= DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировки'),
        actions: [
          IconButton(
            icon: Icon(
              mode == TrainingViewMode.list ? Icons.calendar_month : Icons.list,
            ),
            onPressed: () {
              setState(() {
                mode = mode == TrainingViewMode.list
                    ? TrainingViewMode.calendar
                    : TrainingViewMode.list;
              });
            },
          ),
        ],
      ),
      floatingActionButton: mode == TrainingViewMode.list
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewWorkoutScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: StreamBuilder<List<Workout>>(
        stream: repo.watchWorkouts(userId),
        builder: (context, snapshot) {
          final workouts = snapshot.data ?? [];

          if (workouts.isEmpty) {
            return const Center(child: Text('Нет тренировок'));
          }

          if (mode == TrainingViewMode.list) {
            return _buildList(context, workouts, userId);
          }

          return _buildCalendar(context, workouts, userId);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Workout> list, String userId) {
    final repo = WorkoutRepository();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final w = list[i];

        return Card(
          child: ListTile(
            title: Text(w.name),
            subtitle: Text(
              DateFormat(
                'd MMMM yyyy',
                'ru_RU',
              ).format(w.createdAtUtc.toLocal()),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrainingHistoryViewScreen(workout: w),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewWorkoutScreen(workout: w),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await repo.delete(userId, w.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<Workout> workouts,
    String userId,
  ) {
    final repo = WorkoutRepository();

    List<Workout> getWorkoutsForDay(DateTime date) {
      return workouts.where((w) {
        final d = w.createdAtUtc.toLocal();
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList();
    }

    final dayWorkouts = _selectedDay == null
        ? []
        : getWorkoutsForDay(_selectedDay!);

    return Column(
      children: [
        Expanded(
          child: SfCalendar(
            view: CalendarView.month,
            initialSelectedDate: _selectedDay ?? DateTime.now(),
            onLongPress: (date) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  NewWorkoutScreen(date: date.date,)),
              );
            },
            onSelectionChanged: (details) {
              final date = details.date;
              if (date == null) return;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                setState(() {
                  _selectedDay = date;
                });
              });
            },
            dataSource: WorkoutCalendarDataSource(workouts),

            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
              showAgenda: false,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: _selectedDay == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
                    const Text('Выбери день'),
                    SizedBox(height: 40),
                  ],
                )
              : dayWorkouts.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NewWorkoutScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить тренировку'),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...dayWorkouts.map(
                      (w) => Card(
                        child: ListTile(
                          title: Text(w.name),
                          subtitle: Text(
                            DateFormat(
                              'd MMMM yyyy',
                              'ru_RU',
                            ).format(w.createdAtUtc.toLocal()),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TrainingHistoryViewScreen(workout: w),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NewWorkoutScreen(workout: w),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await repo.delete(userId, w.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
        ),
      ],
    );
  }
}
