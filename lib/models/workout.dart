class WorkoutTemplate {
  final String id;
  final String name;
  final String muscleGroup;
  final List<String> exerciseIds;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.exerciseIds,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json, String id) {
    return WorkoutTemplate(
      id: id,
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      exerciseIds: List<String>.from(json['exerciseIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'muscleGroup': muscleGroup,
    'exerciseIds': exerciseIds,
  };
}