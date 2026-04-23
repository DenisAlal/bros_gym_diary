class Exercise {
  final String id;
  final String name;
  final String simulatorName;
  final String description;
  final String muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    required this.simulatorName,
    required this.description,
    required this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, String id) {
    return Exercise(
      id: id,
      name: json['name'],
      simulatorName: json['simulatorName'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'simulatorName': simulatorName,
    'description': description,
    'muscleGroup': muscleGroup,
  };
}