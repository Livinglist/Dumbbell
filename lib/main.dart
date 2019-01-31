// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// You can read about packages here: https://flutter.io/using-packages/

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'category.dart';
import 'model.dart';
import 'routineEditPage.dart';
import 'database/database.dart';
import 'statisticsPage.dart';
import 'recommendPage.dart';
import 'scanPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/firebase.dart';

typedef void StringCallback(String val);
const String FirstRunDateKey = "firstRunDate";
String firstRunDate;

void main() async {
  //UploadKeyAndValue();
  //UploadToFirestore();
  ///get user preferences on startup of the app
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString(FirstRunDateKey) == null) {
    prefs.setString(FirstRunDateKey, dateTimeToStringConverter(DateTime.now()));
  }
  firstRunDate = prefs.getString(FirstRunDateKey);
  runApp(App());
}

/// This widget is the root of our application.
/// Currently, we just show one widget in our app.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoutinesContext.around(MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    final RoutinesContext roc = RoutinesContext.of(context);
    final List<Routine> routines = RoutinesContext.of(context).routines;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'A hardworker since $firstRunDate',
                style: TextStyle(color: Colors.white70),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.assessment,
                color: Colors.black,
              ),
              title: Text('Statistics'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StatisticsPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: Text("Dev's recommendations"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RecommendPage()));
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
                    ), //TODO:
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
        backgroundColor: Colors.grey[800],
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ScanPage()));
                  },
                ),
          ),
          Builder(
            builder: (context) => IconButton(
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
                            builder: (context) => RoutineEditPage(
                                  addOrEdit: AddOrEdit.Add,
                                )));
                  },
                ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _buildCategories(),
    );
  }

  Widget _buildCategories() {
    final RoutinesContext roc = RoutinesContext.of(context);
    List<Routine> routines = RoutinesContext.of(context).routines;

    return FutureBuilder<List<Routine>>(
      future: RoutinesContext.of(context).getAllRoutines(),
      builder: (BuildContext context, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.hasData) {
          RoutinesContext.of(context).routines = snapshot.data;
          routines = RoutinesContext.of(context).routines;
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
}

//---------------------------------Abandoned

class RoutineOverviewListViewState extends State<RoutineOverviewListView> {
  @override
  Widget build(BuildContext context) {
    final RoutinesContext roc = RoutinesContext.of(context);
    final List<Routine> routines = RoutinesContext.of(context).routines;
    return Scaffold(
      body: _buildCategories(),
    );
  }

  Widget _buildCategories() {
    final RoutinesContext roc = RoutinesContext.of(context);
    List<Routine> routines = RoutinesContext.of(context).routines;

    return FutureBuilder<List<Routine>>(
      future: RoutinesContext.of(context).getAllRoutines(),
      builder: (BuildContext context, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.hasData) {
          RoutinesContext.of(context).routines = snapshot.data;
          routines = RoutinesContext.of(context).routines;
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
}

class RoutineOverviewListView extends StatefulWidget {
  @override
  RoutineOverviewListViewState createState() =>
      new RoutineOverviewListViewState();
}
