import 'dart:convert';

import 'package:flutter/material.dart';

import 'part.dart';

export 'part.dart';

enum MainTargetedBodyPart { Abs, Arm, Back, Chest, Leg, Shoulder, FullBody }

class Routine {
  MainTargetedBodyPart mainTargetedBodyPart;
  List<int> routineHistory;
  List<int> weekdays;
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
      this.weekdays,
      this.routineHistory,
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
    if (routineHistory == null) {
      routineHistory = List<int>();
    }
    if (weekdays == null) {
      weekdays = List<int>();
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
    print("The name is : " + map['RoutineName']);
    id = map["Id"];
    routineName = map['RoutineName'];
    mainTargetedBodyPart = intToMainTargetedBodyPartConverter(map['MainPart']);
    parts = map['Parts'] != null ? (jsonDecode(map['Parts']) as List).map((partMap) => Part.fromMap(partMap)).toList() : null;
    lastCompletedDate = map['LastCompletedDate'] != null ? stringToDateTimeConverter(map['LastCompletedDate']) : DateTime.now();
    createdDate = map['CreatedDate'] != null ? stringToDateTimeConverter(map['CreatedDate']) : DateTime.now();
    completionCount = map['Count'];
    print("ISUAHLFIDSufghklahfdklashlkdhlakhdfiouAHSIDHUIA======");
    try {
      routineHistory = (map["RoutineHistory"] == null ? <int>[] : (jsonDecode(map['RoutineHistory']) as List).cast<int>());
    } catch (_) {
      routineHistory = [];

      var dateStrings = (jsonDecode(map['RoutineHistory']) as List).cast<String>();
      for (var str in dateStrings) {
        var d = DateTime.parse(str);

        routineHistory.add(d.millisecondsSinceEpoch);
      }
    }
    weekdays = (map["Weekdays"] == null ? <int>[] : (jsonDecode(map["Weekdays"]) as List).cast<int>());
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'RoutineName': routineName,
      'RoutineHistory': jsonEncode(routineHistory ?? []),
      'Weekdays': jsonEncode(weekdays ?? []),
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
    routineHistory = routine.routineHistory.map((str) => str).toList();
    weekdays = routine.weekdays.map((i) => i).toList();
    mainTargetedBodyPart = routine.mainTargetedBodyPart;
    parts = routine.parts.map((part) => Part.copyFromPart(part)).toList();
    lastCompletedDate = routine.lastCompletedDate;
    createdDate = routine.createdDate;
    completionCount = routine.completionCount;
  }

  Routine.copyFromRoutineWithoutHistory(Routine routine) {
    id = routine.id;
    routineName = routine.routineName;
    routineHistory = List<int>();
    weekdays = List<int>();
    mainTargetedBodyPart = routine.mainTargetedBodyPart;
    parts = routine.parts.map((part) => Part.copyFromPart(part)).toList();
    lastCompletedDate = routine.lastCompletedDate;
    createdDate = routine.createdDate;
    completionCount = routine.completionCount;
  }

  String toString() {
    return "Instance of Routine id:${this.id} name: ${this.routineName}";
  }
}

String dateTimeToStringConverter(DateTime date) {
  return date.toString().split(' ').first;
}

DateTime stringToDateTimeConverter(String str) {
  return DateTime.parse(str);
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
