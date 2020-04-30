import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_planner/models/routine.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future initDB({bool refresh = false}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = join(appDocDir.path, "data.db");

    if (await File(path).exists() && !refresh) {
      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));
        },
      );
    } else {
      ByteData data = await rootBundle.load("database/data.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));
        },
      );
    }
  }

  Future<int> getLastId() async {
    final db = await database;
    var table = await db.rawQuery('SELECT MAX(Id)+1 as Id FROM Routines');
    int id = table.first['Id'];
    return id;
  }

  Future<int> newRoutine(Routine routine) async {
    final db = await database;
    var table = await db.rawQuery('SELECT MAX(Id)+1 as Id FROM Routines');
    int id = table.first['Id'];
    var map = routine.toMap();
    await db.rawInsert(
        'INSERT Into Routines (Id, RoutineName, MainPart, Parts, LastCompletedDate, CreatedDate, Count, RoutineHistory, Weekdays) VALUES (?,?,?,?,?,?,?,?,?)',
        [
          id,
          map['RoutineName'],
          map['MainPart'],
          map['Parts'],
          map['LastCompletedDate'],
          map['CreatedDate'],
          map['Count'],
          map['RoutineHistory'],
          map['Weekdays'],
        ]);
    return id;
  }

  updateRoutine(Routine routine) async {
    final db = await database;
    var res = await db.update("Routines", routine.toMap(), where: "id = ?", whereArgs: [routine.id]);
    return res;
  }

  deleteRoutine(Routine routine) async {
    final db = await database;
    var res = await db.delete("Routines", where: "id = ?", whereArgs: [routine.id]);
    return res;
  }

  deleteAllRoutines() async {
    final db = await database;
    var res = await db.delete("Routines");
    return res;
  }

  addAllRoutines(List<Routine> routines) async {
    final db = await database;

    for (var routine in routines) {
      var table = await db.rawQuery('SELECT MAX(Id)+1 as Id FROM Routines');
      int id = table.first['Id'];
      var map = routine.toMap();
      await db.rawInsert(
          'INSERT Into Routines (Id, RoutineName, MainPart, Parts, LastCompletedDate, CreatedDate, Count, RoutineHistory, Weekdays) VALUES (?,?,?,?,?,?,?,?,?)',
          [
            id,

            ///changed from [map['id']] to [id]
            map['RoutineName'],
            map['MainPart'],
            map['Parts'],
            map['LastCompletedDate'],
            map['CreatedDate'],
            map['Count'],
            map['RoutineHistory'],
            map['Weekdays'],
          ]);
    }
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    List<Map> res;
    res = await db.query('Routines');

    print("aaaaaaaa");

    var a = res.map((r) {
      return Routine.fromMap(r);
    }).toList();

    print(a.length);

    print("bbbbbbbb");

    return res.isNotEmpty
        ? res.map((r) {
            return Routine.fromMap(r);
          }).toList()
        : [];
  }

  Future<List<Routine>> getAllRecRoutines() async {
    final db = await database;
    var res = await db.query('RecommendedRoutines');

    return res.isNotEmpty
        ? res.map((r) {
            return Routine.fromMap(r);
          }).toList()
        : [];
  }
}
