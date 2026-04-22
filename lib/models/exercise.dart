class Exercise {
  final String id;
  final String name;
  final String simulatorName;
  final int weightStart;
  final int weightEnd;
  final String muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    required this.simulatorName,
    required this.weightStart,
    required this.weightEnd,
    required this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, String id) {
    return Exercise(
      id: id,
      name: json['name'],
      simulatorName: json['simulatorName'],
      weightStart: json['weightStart'],
      weightEnd: json['weightEnd'],
      muscleGroup: json['muscleGroup'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'simulatorName': simulatorName,
    'weightStart': weightStart,
    'weightEnd': weightEnd,
    'muscleGroup': muscleGroup,
  };
}