import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
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

    if(await File(path).exists()) {
      return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
      );
    }else{
      ByteData data = await rootBundle.load("database/test.db");
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);


      await File(path).writeAsBytes(bytes);
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

  String dateTimeToStringConverter(DateTime date) {
    return date.month.toString() +
        '/' +
        date.day.toString() +
        '/' +
        date.year.toString();
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    var res = await db.query('Routines');
    //return res.isNotEmpty? res.map((c)=> Routine.fromMap(c)).toList():[];
    print(res.toString());
    return res.isNotEmpty
        ? res.map((r) {
      return Routine.fromMap(r);
    }).toList()
        : [];
  }

  Future<List<Routine>> getAllRecRoutines() async {
    final db = await database;
    var res = await db.query('RecommendedRoutines');
    //return res.isNotEmpty? res.map((c)=> Routine.fromMap(c)).toList():[];
    print(res.toString());
    return res.isNotEmpty
        ? res.map((r) {
      return Routine.fromMap(r);
    }).toList()
        : [];
  }
}
