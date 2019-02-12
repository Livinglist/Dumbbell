import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database/database.dart';
import 'main.dart';
import 'model.dart';

class SettingPage extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final VoidCallback signInCallback;

  SettingPage({this.currentUser, this.signInCallback});

  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  int selectedRadioValue;

  Future<void> _handleUpload() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(SnackBar(
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
                "NO NETWORK CONNECTION",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ));
      } else {
        var db = Firestore.instance;
        var snapshot =
            await db.collection("users").document(widget.currentUser.id).get();

        if (snapshot.exists) {
          var res = snapshot.reference.updateData({
            "registerDate": firstRunDate,
            //"routines":"test routines"
            "routines": json.encode(RoutinesContext.of(context)
                .routines
                .map((routine) => routine.toMap())
                .toList())
          });
        } else {
          var res = await db
              .collection("users")
              .document(widget.currentUser.id)
              .setData({
            "registerDate": firstRunDate,
            "routines": json.encode(RoutinesContext.of(context)
                .routines
                .map((routine) => routine.toMap())
                .toList())
          });
        }
      }
    });
  }

  Future<void> _handleRestore() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(SnackBar(
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
                "NO NETWORK CONNECTION",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ));
      } else {
        var db = Firestore.instance;
        var snapshot =
            await db.collection("users").document(widget.currentUser.id).get();

        if (snapshot.exists) {
          firstRunDate = snapshot.data["registerDate"];
          RoutinesContext.of(context).routines =
              (json.decode(snapshot.data["routines"]) as List)
                  .map((map) => Routine.fromMap(map))
                  .toList();
          DBProvider.db.deleteAllRoutines();
          DBProvider.db.addAllRoutines(RoutinesContext.of(context).routines);
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

  void _handleChange(int val) {
    setWeeklyAmount(val);
    setState(() {
      selectedRadioValue = val;
    });
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
        title: Text("Settings"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.alarm),
            title: Text('Workout Frequency', textScaleFactor: 1.5),
            subtitle: Text('Per week'),
            dense: true,
          ),
          // Section Content
          RadioListTile(
            value: 3,
            groupValue: selectedRadioValue,
            onChanged: _handleChange,
            title: Text('Third times'),
            subtitle: Text('Gotta try harder'),
            dense: true,
          ),
          RadioListTile(
            value: 4,
            groupValue: selectedRadioValue,
            onChanged: _handleChange,
            title: Text('Four times'),
            subtitle: Text('Average'),
            dense: true,
          ),
          RadioListTile(
            value: 5,
            groupValue: selectedRadioValue,
            onChanged: _handleChange,
            title: Text('Five times'),
            subtitle: Text('Nice'),
            dense: true,
          ),
          RadioListTile(
            value: 6,
            groupValue: selectedRadioValue,
            onChanged: _handleChange,
            title: Text('Six times'),
            subtitle: Text('💪'),
            dense: true,
          ),
          RadioListTile(
            value: 7,
            groupValue: selectedRadioValue,
            onChanged: _handleChange,
            title: Text('Seven times'),
            subtitle: Text('🏋🏋️‍♀️'),
            dense: true,
          ),
          Divider(),
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
