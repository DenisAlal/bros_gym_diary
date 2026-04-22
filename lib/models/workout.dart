class WorkoutTemplate {
  final String id;
  final String name;
  final List<String> exerciseIds;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json, String id) {
    return WorkoutTemplate(
      id: id,
      name: json['name'],
      exerciseIds: List<String>.from(json['exerciseIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'exerciseIds': exerciseIds,
  };
}

class Workout {
  final String id;
  final String name;
  final String templateId;
  final DateTime createdAtUtc;
  final List<WorkoutExerciseState> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.templateId,
    required this.createdAtUtc,
    required this.exercises,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'templateId': templateId,
    'createdAtUtc': createdAtUtc.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

class WorkoutExerciseState {
  final String exerciseId;
  final bool done;

  WorkoutExerciseState({
    required this.exerciseId,
    required this.done,
  });

  factory WorkoutExerciseState.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseState(
      exerciseId: json['exerciseId'],
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'done': done,
  };
}