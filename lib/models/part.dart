import 'package:flutter/material.dart';

import 'exercise.dart';

export 'exercise.dart';

enum TargetedBodyPart {
  Abs,
  Arm,
  Back,
  Chest,
  Leg,
  Shoulder,
  FullBody,
  Tricep,
  Bicep
}
enum SetType { Regular, Drop, Super, Tri, Giant }

class Part {
  bool defaultName;
  SetType setType;
  TargetedBodyPart targetedBodyPart;
  String partName;
  List<Exercise> exercises;
  String additionalNotes;

  Part(
      {@required this.setType,
        @required this.targetedBodyPart,
        @required this.exercises,
        this.partName}) {
    if (partName != null && partName.trim().isEmpty) {
      switch (setType) {
        case SetType.Regular:
          this.partName = exercises[0].name;
          break;
        case SetType.Drop:
          this.partName = exercises[0].name;
          break;
        case SetType.Super:
          this.partName = exercises[0].name + ' and ' + exercises[1].name;
          break;
        case SetType.Tri:
          this.partName = 'Tri-set of ' + exercises[0].name + ' and more';
          break;
        case SetType.Giant:
          this.partName = 'Giant Set of ' + exercises[0].name + ' and more';
          break;
      }
    }
    if (targetedBodyPart == null) targetedBodyPart = TargetedBodyPart.Abs;
    if (setType == null) setType = SetType.Regular;
    if (exercises == null) {
      exercises = new List<Exercise>();
    }
    if (additionalNotes == null) {
      additionalNotes = '';
    }
  }

  static Map<bool, String> checkIfAnyNull(Part part) {
    if (part.setType == null) {
      return {false: 'Please select a type of set.'};
    }
    if (part.targetedBodyPart == null) {
      return {false: 'Please select a targeted body part.'};
    }
    for (int i = 0; i < part.exercises.length; i++) {
      if (part.exercises[i].name == null ||
          part.exercises[i].name.trim() == '') {
        return {false: 'Please complete the names of exercises.'};
      }
      if (part.exercises[i].reps == null) {
        return {false: 'Reps of exercises need to be defined.'};
      }
      if (part.exercises[i].sets == null) {
        return {false: 'Sets of exercises need to be defined.'};
      }
      if (part.exercises[i].weight == null) {
        return {false: 'Weight of exercises need to be defined. '};
      }
    }
    return {true: ''};
  }

  Part.fromMap(Map<String, dynamic> map) {
    defaultName = map["isDefaultName"];
    setType = intToSetTypeConverter(map['setType']);
    targetedBodyPart = intToTargetedBodyPartConverter(map['bodyPart']);
    additionalNotes = map['notes'];
    exercises =
        (map['exercises'] as List).map((e) => Exercise.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'isDefaultName': defaultName,
      'setType': setTypeToIntConverter(setType),
      'bodyPart': targetedBodyPartToIntConverter(targetedBodyPart),
      'notes': additionalNotes,
      'exercises': exercises.map((e) => e.toMap()).toList()
    };
  }

  Part.copyFromPart(Part part) {
    defaultName = part.defaultName;
    setType = part.setType;
    targetedBodyPart = part.targetedBodyPart;
    additionalNotes = part.additionalNotes;
    exercises =
        part.exercises.map((ex) => Exercise.copyFromExercise(ex)).toList();
  }

  Part.copyFromPartWithoutHistory(Part part) {
    defaultName = part.defaultName;
    setType = part.setType;
    targetedBodyPart = part.targetedBodyPart;
    additionalNotes = part.additionalNotes;
    exercises =
        part.exercises.map((ex) => Exercise.copyFromExercise(ex)).toList();
  }
}

int setTypeToIntConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return 0;
    case SetType.Drop:
      return 1;
    case SetType.Super:
      return 2;
    case SetType.Tri:
      return 3;
    case SetType.Giant:
      return 4;
    default:
      throw Exception(
          "Inside setTypeToIntConverter, setType is ${setType.toString()}");
  }
}

SetType intToSetTypeConverter(int i) {
  switch (i) {
    case 0:
      return SetType.Regular;
    case 1:
      return SetType.Drop;
    case 2:
      return SetType.Super;
    case 3:
      return SetType.Tri;
    case 4:
      return SetType.Giant;
    default:
      throw Exception("Inside intToSetTypeConverter, i is ${i.toString()}");
  }
}

TargetedBodyPart intToTargetedBodyPartConverter(int i) {
  switch (i) {
    case 0:
      return TargetedBodyPart.Abs;
    case 1:
      return TargetedBodyPart.Arm;
    case 2:
      return TargetedBodyPart.Back;
    case 3:
      return TargetedBodyPart.Chest;
    case 4:
      return TargetedBodyPart.Leg;
    case 5:
      return TargetedBodyPart.Shoulder;
    case 6:
      return TargetedBodyPart.FullBody;
    case 7:
      return TargetedBodyPart.Tricep;
    case 8:
      return TargetedBodyPart.Bicep;
    default:
      throw Exception(
          "Inside intToTargetedBodyPartConverter, i is ${i.toString()}");
  }
}

int targetedBodyPartToIntConverter(TargetedBodyPart tb) {
  switch (tb) {
    case TargetedBodyPart.Abs:
      return 0;
    case TargetedBodyPart.Arm:
      return 1;
    case TargetedBodyPart.Back:
      return 2;
    case TargetedBodyPart.Chest:
      return 3;
    case TargetedBodyPart.Leg:
      return 4;
    case TargetedBodyPart.Shoulder:
      return 5;
    case TargetedBodyPart.FullBody:
      return 6;
    case TargetedBodyPart.Tricep:
      return 7;
    case TargetedBodyPart.Bicep:
      return 8;
    default:
      throw Exception(
          "Inside targetedBodyPartToIntConverter, tb is ${tb.toString()}");
  }
}
