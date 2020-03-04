import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'components//custom_snack_bars.dart';
import 'package:workout_planner/main.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class SettingPage extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final VoidCallback signInCallback;

  SettingPage({this.currentUser, this.signInCallback});

  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedRadioValue;

  Future<void> _handleUpload() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
      } else {
        var db = Firestore.instance;
        var snapshot = await db.collection("users").document(widget.currentUser.id).get();

        if (snapshot.exists) {
          routinesBloc.allRoutines.listen((routines) {
            snapshot.reference.updateData({"routines": json.encode(routines.map((routine) => routine.toMap()).toList())}).whenComplete(() {
              _showSuccessSnackBar("UPLOADED SUCCESSFULLY!");
            });
          });
        } else {
          routinesBloc.allRoutines.first.then((routines) async {
            await db.collection("users").document(widget.currentUser.id).setData({
              "registerDate": firstRunDate,
              "email": currentUser.email,
              "routines": json.encode(routines.map((routine) => routine.toMap()).toList())
            }).whenComplete(() {
              _showSuccessSnackBar("UPLOADED SUCCESSFULLY!");
            });
          });
        }
      }
    });
  }

  Future<void> _handleRestore() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
      } else {
        var db = Firestore.instance;
        var snapshot = await db.collection("users").document(widget.currentUser.id).get();

        if (snapshot.exists) {
          firstRunDate = snapshot.data["registerDate"];
          var routines = (json.decode(snapshot.data["routines"]) as List).map((map) => Routine.fromMap(map)).toList();
//          DBProvider.db.deleteAllRoutines();
//          DBProvider.db.addAllRoutines(RoutinesContext.of(context).routines);
          routinesBloc.restoreRoutines(routines);
          _showSuccessSnackBar("RESTORED SUCCESSFULLY!");
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
              content: SnackBar(
            backgroundColor: Colors.yellow,
            content: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.report,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "No data in the cloud",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          )));
        }
      }
    });
  }

  void _showSuccessSnackBar(String msg) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          Text(
            msg,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));
  }

  @override
  void initState() {
    selectedRadioValue = weeklyAmount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
//          ListTile(
//            leading: Icon(Icons.alarm),
//            title: Text('Workout Frequency', textScaleFactor: 1.5),
//            subtitle: Text('Per week'),
//            dense: true,
//          ),
//          // Section Content
//          RadioListTile(
//            value: 3,
//            groupValue: selectedRadioValue,
//            onChanged: _handleChange,
//            title: Text('Third times'),
//            subtitle: Text('Gotta try harder'),
//            dense: true,
//          ),
//          RadioListTile(
//            value: 4,
//            groupValue: selectedRadioValue,
//            onChanged: _handleChange,
//            title: Text('Four times'),
//            subtitle: Text('Average'),
//            dense: true,
//          ),
//          RadioListTile(
//            value: 5,
//            groupValue: selectedRadioValue,
//            onChanged: _handleChange,
//            title: Text('Five times'),
//            subtitle: Text('Nice'),
//            dense: true,
//          ),
//          RadioListTile(
//            value: 6,
//            groupValue: selectedRadioValue,
//            onChanged: _handleChange,
//            title: Text('Six times'),
//            subtitle: Text('💪'),
//            dense: true,
//          ),
//          RadioListTile(
//            value: 7,
//            groupValue: selectedRadioValue,
//            onChanged: _handleChange,
//            title: Text('Seven times'),
//            subtitle: Text('🏋🏋️‍♀️'),
//            dense: true,
//          ),
//          Divider(),
          ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text("Back up my data"),
            onTap: () {
              scaffoldKey.currentState.removeCurrentSnackBar();
              widget.currentUser == null
                  ? scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor: Colors.yellow,
                      content: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.report,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "You should sign in first",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      action: SnackBarAction(
                          label: "SIGN IN",
                          onPressed: () {
                            Navigator.pop(context);
                            widget.signInCallback();
                          }),
                    ))
                  : _handleUpload();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.cloud_download),
            title: Text("Restore my data"),
            onTap: () {
              scaffoldKey.currentState.removeCurrentSnackBar();
              widget.currentUser == null
                  ? scaffoldKey.currentState.showSnackBar(SnackBar(
                      backgroundColor: Colors.yellow,
                      content: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.report,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "You should sign in first",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      action: SnackBarAction(
                          label: "SIGN IN",
                          onPressed: () {
                            Navigator.pop(context);
                            widget.signInCallback();
                          }),
                    ))
                  : _handleRestore();
            },
          )
        ],
      ),
    );
  }
}
