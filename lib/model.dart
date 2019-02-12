import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'database/database.dart';

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
enum MainTargetedBodyPart { Abs, Arm, Back, Chest, Leg, Shoulder, FullBody }
enum SetType { Regular, Drop, Super, Tri, Giant }
enum AddOrEdit { Add, Edit }
enum WorkoutType { Cardio, Weight }

class Exercise {
  String name;
  double weight;
  int sets;
  String reps;

  //Map<DateTime, List<double>> exHistory;
  Map exHistory;

  Exercise(
      {@required this.name,
      @required this.weight,
      @required this.sets,
        @required this.reps,
        this.exHistory}) {
    if (name == null) name = '';
    if (weight == null) weight = 0;
    if (sets == null) sets = 0;
    if (reps == null) reps = '';
    if (exHistory == null) {
      exHistory = {};
    }
  }

  Exercise.fromJson(Map<String, dynamic> myJson) {
    exHistory = Map();
    name = myJson["name"];
    weight = double.parse(myJson["weight"] == '' ? '0' : myJson["weight"]);
    sets = int.parse(myJson["sets"].toString());
    reps = myJson["reps"];
    exHistory.addAll(myJson["history"] == null
        ? {}
        : jsonDecode(myJson['history']));
  }

//      : name = json["name"],
//        weight = json["weight"],
//        sets = int.parse(json["sets"]),
//        reps = json["reps"],
//        exHistory = json["history"] == null
//            ? {DateTime.now():[12]}
//            : jsonDecode(json["history"]);

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'weight': weight.toStringAsFixed(1),
        'sets': sets,
        'reps': reps,
        'history': jsonEncode(exHistory)
      };

  Exercise.copyFromExercise(Exercise ex) {
    name = ex.name;
    weight = ex.weight;
    sets = ex.sets;
    reps = ex.reps;
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
    //exHistory = ex.exHistory; this seems to be shallow copy?
    exHistory = {};
  }
}

class Part {
  bool defaultName;
  WorkoutType workoutType;
  SetType setType;
  TargetedBodyPart targetedBodyPart;
  String partName;
  List<Exercise> exercises;
  String additionalNotes;

  Part(
      {@required this.setType,
      @required this.targetedBodyPart,
      @required this.exercises,
        this.workoutType,
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
    if (workoutType == null) {
      workoutType = WorkoutType.Weight;
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

  Part.fromMap(Map<String, dynamic> json) {
    defaultName = json["isDefaultName"];
    //workoutType = intToWorkoutTypeConverter(json.containsKey('workoutType')?json['workoutType']:WorkoutType.Weight);//TODO: to be deleted
    workoutType = intToWorkoutTypeConverter(json['workoutType']);
    setType = intToSetTypeConverter(json['setType']);
    targetedBodyPart = intToTargetedBodyPartConverter(json['bodyPart']);
    additionalNotes = json['notes'];
    exercises =
        (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList();
    print("ok???");
  }

  Map<String, dynamic> toMap() {
    return {
      'isDefaultName': defaultName,
      'workoutType': workoutTypeToIntConverter(workoutType),
      'setType': setTypeToIntConverter(setType),
      'bodyPart': targetedBodyPartToIntConverter(targetedBodyPart),
      'notes': additionalNotes,
      'exercises': exercises.map((e) => e.toJson()).toList()
    };
  }

  Part.copyFromPart(Part part) {
    defaultName = part.defaultName;
    workoutType = part.workoutType;
    setType = part.setType;
    targetedBodyPart = part.targetedBodyPart;
    additionalNotes = part.additionalNotes;
    exercises =
        part.exercises.map((ex) => Exercise.copyFromExercise(ex)).toList();
  }

  Part.copyFromPartWithoutHistory(Part part) {
    defaultName = part.defaultName;
    workoutType = part.workoutType;
    setType = part.setType;
    targetedBodyPart = part.targetedBodyPart;
    additionalNotes = part.additionalNotes;
    exercises =
        part.exercises.map((ex) => Exercise.copyFromExercise(ex)).toList();
  }
}

class Routine {
  MainTargetedBodyPart mainTargetedBodyPart;
  String routineName;
  List<Part> parts;
  DateTime lastCompletedDate;
  DateTime createdDate;
  int completionCount;
  int id;

  Routine(
      {@required this.mainTargetedBodyPart,
      @required this.routineName,
      @required this.parts,
      @required this.createdDate,
      this.completionCount,
      this.lastCompletedDate}) {
    if (lastCompletedDate == null) {}
    if (completionCount == null) {
      completionCount = 0;
    }
    if (parts == null) {
      parts = new List<Part>();
    }
    if (createdDate == null) {
      createdDate = DateTime.now();
    }
    if (lastCompletedDate == null) {
      lastCompletedDate = DateTime.now();
    }
  }

  static Map<bool, String> checkIfAnyNull(Routine routine) {
    for (int i = 0; i < routine.parts.length; i++) {
      var map = Part.checkIfAnyNull(routine.parts[i]);
      if (!map.keys.first) {
        return map;
      }
    }
    if (routine.routineName == null || routine.routineName.trim() == '') {
      return {false: 'Please give your routine a name. '};
    }
    if (routine.mainTargetedBodyPart == null) {
      return {false: 'Please select a main targeted body part.'};
    }
    return {true: ''};
  }

  Routine.fromMap(Map<String, dynamic> map) {
    id = map["Id"];
    routineName = map['RoutineName'];
    mainTargetedBodyPart = intToMainTargetedBodyPartConverter(map['MainPart']);
    parts = map['Parts'] != null
        ? (jsonDecode(map['Parts']) as List)
        .map((partMap) => Part.fromMap(partMap))
        .toList()
        : null;
    lastCompletedDate = map['LastCompletedDate'] != null
        ? stringToDateTimeConverter(map['LastCompletedDate'])
        : DateTime.now();
    createdDate = map['CreatedDate'] != null
        ? stringToDateTimeConverter(map['CreatedDate'])
        : DateTime.now();
    completionCount = map['Count'];
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'RoutineName': routineName,
      'MainPart': mainTargetedBodyPartToIntConverter(mainTargetedBodyPart),
      'Parts': jsonEncode(parts.map((part) => part.toMap()).toList()),
      'LastCompletedDate': dateTimeToStringConverter(lastCompletedDate),
      'CreatedDate': dateTimeToStringConverter(createdDate),
      'Count': completionCount
    };
  }

  Routine.copyFromRoutine(Routine routine) {
    id = routine.id;
    routineName = routine.routineName;
    mainTargetedBodyPart = routine.mainTargetedBodyPart;
    parts = routine.parts.map((part) => Part.copyFromPart(part)).toList();
    lastCompletedDate = routine.lastCompletedDate;
    createdDate = routine.createdDate;
    completionCount = routine.completionCount;
  }

  Routine.copyFromRoutineWithoutHistory(Routine routine) {
    id = routine.id;
    routineName = routine.routineName;
    mainTargetedBodyPart = routine.mainTargetedBodyPart;
    parts = routine.parts.map((part) => Part.copyFromPart(part)).toList();
    lastCompletedDate = routine.lastCompletedDate;
    createdDate = routine.createdDate;
    completionCount = routine.completionCount;
  }
}

WorkoutType intToWorkoutTypeConverter(int i) {
  print('reached!!');
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

String dateTimeToStringConverter(DateTime date) {
//  return date.month.toString() +
//      '/' +
//      date.day.toString() +
//      '/' +
//      date.year.toString();
  return date
      .toString()
      .split(' ')
      .first;
}

DateTime stringToDateTimeConverter(String str) {
//  var strs = str.split('/');
//  DateTime date = new DateTime(int.tryParse(strs[2]) ?? 2019,
//      int.tryParse(strs[0]) ?? 1, int.tryParse(strs[1]) ?? 1);
  return DateTime.parse(str);
}

int mainTargetedBodyPartToIntConverter(MainTargetedBodyPart targetedBodyPart) {
  switch (targetedBodyPart) {
    case MainTargetedBodyPart.Abs:
      return 0;
    case MainTargetedBodyPart.Arm:
      return 1;
    case MainTargetedBodyPart.Back:
      return 2;
    case MainTargetedBodyPart.Chest:
      return 3;
    case MainTargetedBodyPart.Leg:
      return 4;
    case MainTargetedBodyPart.Shoulder:
      return 5;
    case MainTargetedBodyPart.FullBody:
      return 6;
    default:
      throw Exception;
  }
}

MainTargetedBodyPart intToMainTargetedBodyPartConverter(int i) {
  switch (i) {
    case 0:
      return MainTargetedBodyPart.Abs;
    case 1:
      return MainTargetedBodyPart.Arm;
    case 2:
      return MainTargetedBodyPart.Back;
    case 3:
      return MainTargetedBodyPart.Chest;
    case 4:
      return MainTargetedBodyPart.Leg;
    case 5:
      return MainTargetedBodyPart.Shoulder;
    case 6:
      return MainTargetedBodyPart.FullBody;
    default:
      throw Exception;
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

String mainTargetedBodyPartToStringConverter(
    MainTargetedBodyPart targetedBodyPart) {
  switch (targetedBodyPart) {
    case MainTargetedBodyPart.Abs:
      return 'Abs';
    case MainTargetedBodyPart.Arm:
      return 'Arms';
    case MainTargetedBodyPart.Back:
      return 'Back';
    case MainTargetedBodyPart.Chest:
      return 'Chest';
    case MainTargetedBodyPart.Leg:
      return 'Legs';
    case MainTargetedBodyPart.Shoulder:
      return 'Shoulders';
    case MainTargetedBodyPart.FullBody:
      return 'Full Body';
    default:
      throw Exception;
  }
}

Color setTypeToColorConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return Colors.lightBlue;
    case SetType.Drop:
      return Colors.grey;
    case SetType.Super:
      return Colors.teal;
    case SetType.Tri:
      return Colors.pink;
    case SetType.Giant:
      return Colors.red;
    default:
      return Colors.lightBlue;
  }
}

String targetedBodyPartToStringConverter(TargetedBodyPart targetedBodyPart) {
  switch (targetedBodyPart) {
    case TargetedBodyPart.Abs:
      return 'Abs';
    case TargetedBodyPart.Arm:
      return 'Arms';
    case TargetedBodyPart.Back:
      return 'Back';
    case TargetedBodyPart.Chest:
      return 'Chest';
    case TargetedBodyPart.Leg:
      return 'Legs';
    case TargetedBodyPart.Shoulder:
      return 'Shoulders';
    case TargetedBodyPart.Tricep:
      return 'Triceps';
    case TargetedBodyPart.Bicep:
      return 'Biceps';
    case TargetedBodyPart.FullBody:
      return 'Full Body';
    default:
      throw Exception;
  }
}

String setTypeToStringConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return 'Regular Sets';
    case SetType.Drop:
      return 'Drop Sets';
    case SetType.Super:
      return 'Supersets';
    case SetType.Tri:
      return 'Tri-sets';
    case SetType.Giant:
      return 'Giant sets';
    default:
      throw Exception;
  }
}

int setTypeToExerciseCountConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return 1;
    case SetType.Drop:
      return 1;
    case SetType.Super:
      return 2;
    case SetType.Tri:
      return 3;
    case SetType.Giant:
      return 4;
    default:
      throw Exception('setTypeToExerciseCountConverter(), setType is ' +
          setType.toString());
  }
}

Widget targetedBodyPartToImageConverter(TargetedBodyPart targetedBodyPart) {
  double scale = 30;
  switch (targetedBodyPart) {
    case TargetedBodyPart.Abs:
      return Image.asset(
        'assets/abs-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Arm:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Back:
      return Image.asset(
        'assets/back-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Chest:
      return Image.asset(
        'assets/chest-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Leg:
      return Image.asset(
        'assets/leg-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Shoulder:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
    default:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
  }
}

class RoutinesContext extends InheritedWidget {
  List<Routine> _routines;

  List<Routine> get routines => _routines;

  set routines(List<Routine> routines) {
    _routines = routines;
  }

  List<Routine> _recRoutines;

  List<Routine> get recRoutines => _recRoutines;

  set recRoutines(List<Routine> routines) {
    _recRoutines = routines;
  }

  Routine _curRoutine;
  Routine get curRoutine => _curRoutine;

  set curRoutine(Routine routine) {
    _curRoutine = routine;
  }

  Future<List<Routine>> getAllRoutines() async {
    return DBProvider.db.getAllRoutines();
  }

  Future<List<Routine>> getAllRecRoutines() async {
    return DBProvider.db.getAllRecRoutines();
  }

  RoutinesContext._({
    //@required this.routines,
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  static Widget around(Widget child, {Key key}) {
    return _RoutinesContextWrapper(
      child: child,
      key: key,
    );
  }

  static RoutinesContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RoutinesContext);
  }

  @override
  bool updateShouldNotify(RoutinesContext oldWidget) {
    return true;
  }
}

class _RoutinesContextWrapper extends StatefulWidget {
  final Widget child;

  _RoutinesContextWrapper({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutinesContextWrapperState();
}

class _RoutinesContextWrapperState extends State<_RoutinesContextWrapper> {
  List<Routine> routines = new List<Routine>();
  String _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RoutinesContext._(
      //routines: routines,
      child: widget.child,
    );
  }
}

class StringHelper {
  static String weightToString(double weight) {
    if (weight - weight.truncate() != 0)
      return weight.toStringAsFixed(1);
    else
      return weight.toStringAsFixed(0);
  }
}
