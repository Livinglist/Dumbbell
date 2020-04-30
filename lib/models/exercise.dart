import 'dart:convert';

import 'package:flutter/material.dart';

enum WorkoutType { Cardio, Weight }

class Exercise {
  String name;
  double weight;
  int sets;
  String reps;
  WorkoutType workoutType;
  Map exHistory;

  Exercise(
      {@required this.name,
        @required this.weight,
        @required this.sets,
        @required this.reps,
        this.workoutType,
        this.exHistory}) {
    if (name == null) name = '';
    if (weight == null) weight = 0;
    if (sets == null) sets = 0;
    if (reps == null) reps = '';
    if (workoutType == null) {
      workoutType = WorkoutType.Weight;
    }
    if (exHistory == null) {
      exHistory = {};
    }
  }

  Exercise.fromMap(Map<String, dynamic> map) {
    exHistory = Map();
    name = map["name"];
    weight = double.parse(map["weight"] == '' ? '0' : map["weight"]);
    sets = int.parse(map["sets"].toString());
    reps = map["reps"];
    workoutType = intToWorkoutTypeConverter(map['workoutType'] ?? 1);
    exHistory.addAll(map["history"] == null ? {} : jsonDecode(map['history']));
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'weight': weight.toStringAsFixed(1),
    'sets': sets,
    'reps': reps,
    'workoutType': workoutTypeToIntConverter(workoutType),
    'history': jsonEncode(exHistory)
  };

  Exercise.copyFromExercise(Exercise ex) {
    name = ex.name;
    weight = ex.weight;
    sets = ex.sets;
    reps = ex.reps;
    workoutType = ex.workoutType;
    //exHistory = ex.exHistory; this seems to be shallow copy?
    exHistory = {};
    for (var key in ex.exHistory.keys) {
      exHistory[key] = ex.exHistory[key];
    }
  }

  Exercise.copyFromExerciseWithoutHistory(Exercise ex) {
    name = ex.name;
    weight = ex.weight;
    sets = ex.sets;
    reps = ex.reps;
    workoutType = ex.workoutType;
    //exHistory = ex.exHistory; this seems to be shallow copy?
    exHistory = {};
  }

  String toString(){
    return "Instance of Exercise: name: ${this.name}";
  }
}

int workoutTypeToIntConverter(WorkoutType wt) {
  switch (wt) {
    case WorkoutType.Cardio:
      return 0;
    case WorkoutType.Weight:
      return 1;
    default:
      throw Exception(
          'Inside of WorkoutTypeToIntConverter, wt is ${wt.toString()}');
  }
}

WorkoutType intToWorkoutTypeConverter(int i) {
  switch (i) {
    case 0:
      return WorkoutType.Cardio;
    case 1:
      return WorkoutType.Weight;
    default:
      throw Exception(
          'Inside of intToWorkoutTypeConverter, i is ${i.toString()}');
  }
}