import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:workout_planner/main.dart';

import 'package:workout_planner/models/routine.dart';

class FirestoreHelper {
  static String generateId([int digit = 10]) {
    String id = "";
    int num = Random(DateTime.now().microsecond).nextInt(10);
    for (int i = 0; i < digit; i++) {
      if (num < 5) {
        num = Random(DateTime.now().microsecond).nextInt(10);
        id += String.fromCharCode(48+num);
      } else {
        num = Random(DateTime.now().microsecond).nextInt(26);
        id += String.fromCharCode(65+num);
      }
    }
    return id;
  }

  Future<void> handleUpload(List<Routine> routines,
      {failCallback: VoidCallback}) async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        failCallback();
      } else {
        var db = Firestore.instance;
        var snapshot =
        await db.collection("users").document(currentUser.id).get();

        if (snapshot.exists) {
          snapshot.reference.updateData({
            //"routines":"test routines"
            "routines":
            json.encode(routines.map((routine) => routine.toMap()).toList())
          });
        } else {
          await db.collection("users").document(currentUser.id).setData({
            "registerDate": firstRunDate,
            "email": currentUser.email,
            "routines":
            json.encode(routines.map((routine) => routine.toMap()).toList())
          });
        }
      }
    });
  }

  Future<int> getDailyData({failCallback: VoidCallback}) async {
    final String tempDateStr = dateTimeToStringConverter(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return -1;
    } else {
      var db = Firestore.instance;
      var snapshot =
      await db.collection("dailyData").document(tempDateStr).get();

      if (snapshot.exists) {
        return snapshot["totalCount"];
      } else {
        await db
            .collection("dailyData")
            .document(tempDateStr)
            .setData({"totalCount": 0});
        return 0;
      }
    }
  }
}
