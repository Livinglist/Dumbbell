// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// You can read about packages here: https://flutter.io/using-packages/

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calenderPage.dart';
import 'category.dart';
import 'database/database.dart';
import 'database/firestore.dart';
import 'model.dart';
import 'recommendPage.dart';
import 'routineEditPage.dart';
import 'scanPage.dart';
import 'settingPage.dart';
import 'statisticsPage.dart';

typedef void StringCallback(String val);
const String FirstRunDateKey = "firstRunDate";
const String AppVersionKey = "appVersion";
const String DailyRankKey = "dailyRank";
const String DatabaseStatusKey = "databaseStatus";
const String WeeklyAmountKey = "weeklyAmount";

///format: {"2019-01-01":50} (use UTC time)
String firstRunDate;
bool isFirstRun;
String dailyRankInfo;
int dailyRank;
int weeklyAmount;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

GoogleSignInAccount currentUser;

const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[
    "E218F2857258595DFA47993309CED406"
  ], // Android emulators are considered test devices
);

InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);

///return 0 if haven't workout today
Future<int> getDailyRank() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String dailyRankInfo = prefs.getString(DailyRankKey);
  if (dailyRankInfo == null ||
      DateTime
          .now()
          .day -
          DateTime
              .parse(dailyRankInfo
              .split('/')
              .first)
              .toLocal()
              .day ==
          1) {
    return 0;
  }
  return int.parse(dailyRankInfo.split('/')[1]);
}

void setWeeklyAmount(int amt) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(WeeklyAmountKey, amt);
  weeklyAmount = amt;
}

void setDailyRankInfo(String dailyRankInfo) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(DailyRankKey, dailyRankInfo);
}

void setDatabaseStatus(bool dbStatus) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(DatabaseStatusKey, dbStatus);
}

Future<bool> getDatabaseStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(DatabaseStatusKey);
}

void main() async {
  ///get user preferences on startup of the app
  SharedPreferences prefs = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  ///if true, this is the first time the app is run after installation
  if (prefs.getString(FirstRunDateKey) == null) {
    prefs.setString(FirstRunDateKey, dateTimeToStringConverter(DateTime.now()));

    prefs.setBool(DatabaseStatusKey, false);

    prefs.setInt(WeeklyAmountKey, 3);
  }

  ///if true, this is the first time the app is run after installation/update
  if (prefs.getString(AppVersionKey) == null ||
      prefs.getString(AppVersionKey) != packageInfo.version) {
    prefs.setString(AppVersionKey, packageInfo.version);
    isFirstRun = true;
  } else {
    isFirstRun = false;
  }
  firstRunDate = prefs.getString(FirstRunDateKey);
  dailyRankInfo = prefs.getString(DailyRankKey);
  dailyRank = await getDailyRank();
  weeklyAmount = prefs.getInt(WeeklyAmountKey);

//  ///initialize admob
//  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
//
//  ///load ad
//  myInterstitial.load();
//  RewardedVideoAd.instance.load(
//      adUnitId: RewardedVideoAd.testAdUnitId,
//      targetingInfo: targetingInfo);

  ///run app
  runApp(App());
}

/// This widget is the root of our application.
/// Currently, we just show one widget in our app.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoutinesContext.around(MaterialApp(
        theme: ThemeData(
          fontFamily: 'Roboto',
          primaryColor: Colors.blueGrey,
          buttonColor: Colors.blueGrey[300],
          toggleableActiveColor: Colors.blueGrey[400],
          indicatorColor: Colors.blueGrey[200],
        ),
        debugShowCheckedModeBanner: false,
        title: 'Workout Planner',
        home: MainPage()));
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  String _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        currentUser = account;
      });
      if (currentUser != null) {
        //_handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
    setState(() {});
  }

  Future<void> _handleSync() async {
    var docs = await Firestore.instance.collection('users').getDocuments();
    var ref = docs.documents.first.reference;
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(ref);
      await transaction.update(freshSnap.reference, {
        "id": currentUser.id,
        "registerDate": firstRunDate,
        //"routines":"test routines"
        "routines": json.encode(RoutinesContext
            .of(context)
            .routines
            .map((routine) => routine.toMap())
            .toList())
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final RoutinesContext roc = RoutinesContext.of(context);
    final List<Routine> routines = RoutinesContext.of(context).routines;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 300,
                    child: DrawerHeader(
                      child: Column(
                        children: <Widget>[
                          currentUser == null
                              ? Container()
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              currentUser.photoUrl,
                              width: 60,
                              height: 60,
                            ),
                          ),
                          currentUser == null
                              ? Container()
                              : Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              currentUser.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              currentUser == null
                                  ? "Sign in to sync your data"
                                  : currentUser.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                currentUser == null
                                    ? RaisedButton(
                                  child: const Text('SIGN IN'),
                                  onPressed: _handleSignIn,
                                )
                                    : RaisedButton(
                                  child: const Text('SIGN OUT'),
                                  onPressed: _handleSignOut,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: FutureBuilder(
                                      future: FirestoreHelper().getDailyData(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data as int == -1) {
                                            return Text(
                                              'NO DATA',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            );
                                          } else {
                                            return dailyRank == 0
                                                ? Text(
                                              "${snapshot
                                                  .data} people have worked out out today",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            )
                                                : Text(
                                              "${snapshot
                                                  .data} people have worked out today\nYou are in the ${dailyRank
                                                  .toString() +
                                                  _getNumberSuffix(
                                                      dailyRank)} place",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            );
                                          }
                                        } else {
                                          return Text(
                                            'NO DATA',
                                            textAlign: TextAlign.center,
                                            style:
                                            TextStyle(color: Colors.white),
                                          );
                                        }
                                      }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      decoration:
                      BoxDecoration(color: Theme
                          .of(context)
                          .primaryColor),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    title: Text('This Year'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CalenderPage(
                                      _getWorkoutDates(
                                          RoutinesContext
                                              .of(context)
                                              .routines))));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.assessment,
                      color: Colors.black,
                    ),
                    title: Text('Statistics'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StatisticsPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    title: Text("Dev's recommendations"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecommendPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Colors.black,
                    ),
                    title: Text("Settings"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SettingPage(
                                    currentUser: currentUser,
                                    signInCallback: _handleSignIn,
                                  )));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.gradient,
                      color: Colors.black,
                    ),
                    title: Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                          context: context,
                          applicationName: 'Workout Planner',
                          applicationVersion: '0.1 beta',
                          applicationIcon: Image.asset(
                            'assets/ic_launcher.png',
                            scale: 2,
                          ),
                          children: <Widget>[
                            Text(
                                'A simple app to plan out your workout routines, made by Jiaqi Feng, as a gift to those who sweat for a better self')
                          ]);
                    },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text('My Routines'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.android),
                  onPressed: () {
//              RewardedVideoAd.instance.show();
//              myInterstitial.show(anchorOffset: 0, anchorType: AnchorType.top);
                  },
                ),
                Builder(
                  builder: (context) =>
                      IconButton(
                        icon: Transform.rotate(
                          origin: Offset(0, 0),
                          angle: pi / 2,
                          child: Icon(Icons.flip),
                        ),
                        onPressed: () {
                          roc.curRoutine = Routine(
                              mainTargetedBodyPart: null,
                              routineName: null,
                              parts: null,
                              createdDate: null);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScanPage()));
                        },
                      ),
                ),
                Builder(
                  builder: (context) =>
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          roc.curRoutine = Routine(
                              mainTargetedBodyPart: null,
                              routineName: null,
                              parts: new List<Part>(),
                              createdDate: null);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RoutineEditPage(
                                        addOrEdit: AddOrEdit.Add,
                                      )));
                        },
                      ),
                ),
              ],
              bottom: TabBar(tabs: [
                Tab(
                  text: 'MY ROUTINES',
                ),
                Tab(
                  text: 'TODAY',
                )
              ]),
            ),
            backgroundColor: Colors.white,
            body: TabBarView(children: [
              _buildCategories(),
              FutureBuilder(
                future: RoutinesContext.of(context).getAllRoutines(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        child: ListView(
                          children: (snapshot.data as List<Routine>)
                              .where((routine) =>
                              routine.weekdays
                                  .contains(DateTime
                                  .now()
                                  .weekday))
                              .map((routine) =>
                              RoutineOverview(
                                routine: routine,
                              ))
                              .toList(),
                        ));
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ])));
  }

  Widget _buildCategories() {
    final RoutinesContext roc = RoutinesContext.of(context);
    List<Routine> routines = RoutinesContext.of(context).routines;

    return FutureBuilder<List<Routine>>(
      future: RoutinesContext.of(context).getAllRoutines(),
      builder:
          (BuildContext context, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Center(
              child: RaisedButton(
                child: Text("Refresh"),
                onPressed: () =>
                    setState(() {
                      DBProvider.db.initDB();
                    }),
              ));
        }
        if (snapshot.hasData) {
          setDatabaseStatus(true);
          RoutinesContext
              .of(context)
              .routines = snapshot.data;
          routines = RoutinesContext
              .of(context)
              .routines;
          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, i) {
              return LongPressDraggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                feedback: Text('Not implemented yet.'),
                child: _buildRow(routines[i]),
                childWhenDragging: _buildRow(routines[i]),
              );
            },
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildRow(Routine routine) {
    return RoutineOverview(
      routine: routine,
    );
  }

  String _getNumberSuffix(int num) {
    if (num > 3)
      return 'th';
    else if (num == 3)
      return 'rd';
    else if (num == 2)
      return 'nd';
    else
      return 'st';
  }

//  List<String> _getWorkoutDates(List<Routine> routines) {
//    List<String> dates = List<String>();
//
//    for (var routine in routines) {
//      if (routine.parts.isNotEmpty &&
//          routine.parts.first.exercises.first.exHistory.isNotEmpty) {
//        for (var date in routine.parts.first.exercises.first.exHistory.keys) {
//          dates.add(date);
//        }
//      }
//    }
//    return dates;
//  }

  Map<String, Routine> _getWorkoutDates(List<Routine> routines) {
    Map<String, Routine> dates = {};

    for (var routine in routines) {
      print(
          "${routine.routineName} has a length of history: ${routine
              .routineHistory.length}");
      if (routine.routineHistory.isNotEmpty) {
        for (var date in routine.routineHistory) {
          dates[date] = routine;
        }
      }
    }
    return dates;
  }
}
