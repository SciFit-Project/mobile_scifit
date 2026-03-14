class ExerciseSet {
  final String id;
  final String name;
  final int sets;
  final String reps;
  bool done;

  ExerciseSet({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.done = false,
  });
}

class WorkoutExercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final String muscleGroup;
  bool done;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.done = false,
    required this.muscleGroup,
  });
}


//Session History
class ListSessionHistory {
  final int set;
  final double weight;
  final int reps;

  ListSessionHistory({
    required this.set,
    required this.weight,
    required this.reps,
  });
}

class LastSessionHistory {
  final String lastDate;
  final List<ListSessionHistory> sessionHistory;

  LastSessionHistory({
    required this.lastDate,
    required this.sessionHistory,
  });
}

//Sets
class WorkoutSet {
  double weight;
  int reps;
  bool done;

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.done = false,
  });
}
