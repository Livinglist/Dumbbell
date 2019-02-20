import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_planner/main.dart';
import 'package:workout_planner/model.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    //Directory docDirectory = await getApplicationDocumentsDirectory();
    //String path = join(docDirectory.path,'test.db');
    //String fromPath = 'database/test.db';
    //
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = join(appDocDir.path, "data.db");


    if (await File(path).exists() && await getDatabaseStatus()) {
      //return await openDatabase(path);
      return await openDatabase(
        path,
        version: 1,
        onUpgrade: (db, _, __) async {
          ByteData data = await rootBundle.load("database/data.db");
          List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          File(join(appDocDir.path, "updateData.db")).writeAsBytes(bytes);
          await openDatabase(
            join(appDocDir.path, "updateData.db"),
            version: 1,
            onOpen: (db2) async {
              var res = await db2.query('RecommendedRoutines');

              db.delete("RecommendedRoutines");

              for (var map in res) {
                db.insert("RecommendedRoutines", map);
              }
              //db.close();
              db2.close();
            },
          );
        },
        onOpen: (db) {},);
    }else{
      ByteData data = await rootBundle.load("database/data.db");
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      //File(path).delete();
      File(path).writeAsBytes(bytes);
      return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
      );
    }
  }

  Future<int> getLastId() async{
    final db = await database;
    var table = await db.rawQuery('SELECT MAX(Id)+1 as Id FROM Routines');
    int id = table.first['Id'];
    return id;
  }

  newRoutine(Routine routine) async {
    final db = await database;
    var table = await db.rawQuery('SELECT MAX(Id)+1 as Id FROM Routines');
    int id = table.first['Id'];
    var map = routine.toMap();
    var raw = await db.rawInsert(
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
    return raw;
  }

  updateRoutine(Routine routine) async{
    final db = await database;
    var res = await db.update("Routines", routine.toMap(),where: "id = ?", whereArgs: [routine.id]);
    return res;
  }

  deleteRoutine(Routine routine) async{
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
      var raw = await db.rawInsert(
          'INSERT Into Routines (Id, RoutineName, MainPart, Parts, LastCompletedDate, CreatedDate, Count, RoutineHistory, Weekdays) VALUES (?,?,?,?,?,?,?,?,?)',
          [
            map['Id'],
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

//  String dateTimeToStringConverter(DateTime date) {
//    return date.month.toString() +
//        '/' +
//        date.day.toString() +
//        '/' +
//        date.year.toString();
//  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    var res = await db.query('Routines');

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
