class WorkoutTemplate {
  final String id;
  final String name;
  final List<String> exerciseIds;
  final Map<String, double> defaultWeights;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exerciseIds,
    this.defaultWeights = const {},
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json, String id) {
    return WorkoutTemplate(
      id: id,
      name: json['name'],
      exerciseIds: List<String>.from(json['exerciseIds'] ?? []),
      defaultWeights: Map<String, double>.from(json['defaultWeights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'exerciseIds': exerciseIds,
    'defaultWeights': defaultWeights,
  };
}

class Workout {
  final String id;
  final String name;
  final String templateId;
  final DateTime createdAtUtc;
  final List<WorkoutExerciseState> exercises;
  final bool isCompleted;

  Workout({
    required this.id,
    required this.name,
    required this.templateId,
    required this.createdAtUtc,
    required this.exercises,
    this.isCompleted = false,
  });

  factory Workout.fromJson(Map<String, dynamic> json, String id) {
    return Workout(
      id: id,
      name: json['name'],
      templateId: json['templateId'],
      createdAtUtc: DateTime.parse(json['createdAtUtc']).toUtc(),
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExerciseState.fromJson(e))
          .toList(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'templateId': templateId,
    'createdAtUtc': createdAtUtc.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'isCompleted': isCompleted,
  };
}

class WorkoutExerciseState {
  final String exerciseId;
  final bool done;
  final double? weight;
  final int? reps;
  final int? sets;

  WorkoutExerciseState({
    required this.exerciseId,
    required this.done,
    this.weight,
    this.reps,
    this.sets,
  });

  factory WorkoutExerciseState.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseState(
      exerciseId: json['exerciseId'],
      done: json['done'] ?? false,
      weight: json['weight'],
      reps: json['reps'],
      sets: json['sets'],
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'done': done,
    'weight': weight,
    'reps': reps,
    'sets': sets,
  };

  WorkoutExerciseState copyWith({
    bool? done,
    double? weight,
    int? reps,
    int? sets,
  }) {
    return WorkoutExerciseState(
      exerciseId: exerciseId,
      done: done ?? this.done,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
    );
  }
}