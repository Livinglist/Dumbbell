import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:uuid/uuid.dart';

import 'package:workout_planner/main.dart';
import 'package:workout_planner/models/routine.dart';

const String FirstRunDateKey = "firstRunDate";
const String AppVersionKey = "appVersion";
const String DailyRankKey = "dailyRank";
const String DatabaseStatusKey = "databaseStatus";
const String WeeklyAmountKey = "weeklyAmount";

///format: {"2019-01-01":50} (use UTC time)
//String firstRunDate;
//bool isFirstRun;
//String dailyRankInfo;
//int dailyRank;
//int weeklyAmount;

class FirebaseProvider {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  GoogleSignInAccount currentUser;
  String firstRunDate;
  bool isFirstRun;
  String dailyRankInfo;
  int dailyRank;
  int weeklyAmount;

  static String generateId() {
    var id = Uuid().v4();
    return id;
  }

  Future<void> handleUpload(List<Routine> routines, {failCallback: VoidCallback}) async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        failCallback();
      } else {
        var db = Firestore.instance;
        var snapshot = await db.collection("users").document(currentUser.id).get();

        if (snapshot.exists) {
          snapshot.reference.updateData({
            //"routines":"test routines"
            "routines": json.encode(routines.map((routine) => routine.toMap()).toList())
          });
        } else {
          await db.collection("users").document(currentUser.id).setData({
            "registerDate": firstRunDate,
            "email": currentUser.email,
            "routines": json.encode(routines.map((routine) => routine.toMap()).toList())
          });
        }
      }
    });
  }

  Future<int> getDailyData({failCallback: VoidCallback}) async {
    final String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return -1;
    } else {
      var db = Firestore.instance;
      var snapshot = await db.collection("dailyData").document(tempDateStr).get();

      if (snapshot.exists) {
        return snapshot["totalCount"];
      } else {
        await db.collection("dailyData").document(tempDateStr).setData({"totalCount": 0});
        return 0;
      }
    }
  }

  Future<DocumentSnapshot> handleRestore() async {
    var db = Firestore.instance;
    var snapshot = await db.collection("users").document(currentUser.id).get();

    if (snapshot.exists) {
      firstRunDate = snapshot.data["registerDate"];
      //var routines = (json.decode(snapshot.data["routines"]) as List).map((map) => Routine.fromMap(map)).toList();
    }

    return snapshot;
  }

  Future<bool> checkUserExists() => Firestore.instance.collection('users').document(currentUser.id).get().then((snapshot) => snapshot.exists);

  Future<List<Routine>> restoreRoutines() async {
    var db = Firestore.instance;
    return db.collection("users").document(currentUser.id).get().then((snapshot) {
      var routines = (json.decode(snapshot.data["routines"]) as List).map((map) => Routine.fromMap(map)).toList();
      return routines;
    });
  }

  Future<bool> isSignedIn() => googleSignIn.isSignedIn();

  Future<GoogleSignInAccount> signInSilently() => googleSignIn.signInSilently().then((value){
    this.currentUser = value;
    print("current user: $currentUser");
    return value;
  });

  Future<GoogleSignInAccount> signIn() => googleSignIn.signIn().then((value){
    this.currentUser = value;
    return value;
  });

  Future<GoogleSignInAccount> signOut() => googleSignIn.signOut().whenComplete(() => this.currentUser = null);
}

final firebaseProvider = FirebaseProvider();
