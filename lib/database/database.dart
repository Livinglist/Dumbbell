import 'dart:async';
import 'dart:convert';
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
    String path = join(appDocDir.path, "test.db");


    if (await File(path).exists() && await getDatabaseStatus()) {
      return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},);
//      ).then((database) async {
//        if(await database.getVersion() == 1){
//
//          ///copy the test2 in assets folder to appDir folder for reading
//          ByteData data = await rootBundle.load("database/test2.db");
//          List<int> bytes =
//          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//          await File(join(appDocDir.path, "test2.db")).writeAsBytes(bytes);
//
//          ///open the test2 database
//          Database srcDatabase = await openReadOnlyDatabase(join(appDocDir.path, "test2.db"));
//          var srcData = await srcDatabase.query('RecommendedRoutines');
//
//          ///delete all rows in RecRoutin table from database already in the appDir folder
//          database.delete("RecommendedRoutines");
//
//          ///add rows from test2 to test
//          for(var row in srcData){
//            database.insert("RecommendedRoutines", row);
//          }
//
//          ///update version
//          database.setVersion(2);
//        }
//      });
    }else{
      ByteData data = await rootBundle.load("database/test.db");
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
    var raw = await db.rawInsert(
        'INSERT Into Routines (Id, RoutineName, MainPart, Parts, LastCompletedDate, CreatedDate, Count) VALUES (?,?,?,?,?,?,?)',
        [
          id,
          routine.routineName,
          mainTargetedBodyPartToIntConverter(routine.mainTargetedBodyPart),
          jsonEncode(routine.parts.map((part)=>part.toMap()).toList()),
          dateTimeToStringConverter(routine.lastCompletedDate),
          dateTimeToStringConverter(routine.createdDate),
          routine.completionCount
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
      var raw = await db.rawInsert(
          'INSERT Into Routines (Id, RoutineName, MainPart, Parts, LastCompletedDate, CreatedDate, Count) VALUES (?,?,?,?,?,?,?)',
          [
            id,
            routine.routineName,
            mainTargetedBodyPartToIntConverter(routine.mainTargetedBodyPart),
            jsonEncode(routine.parts.map((part) => part.toMap()).toList()),
            dateTimeToStringConverter(routine.lastCompletedDate),
            dateTimeToStringConverter(routine.createdDate),
            routine.completionCount
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
