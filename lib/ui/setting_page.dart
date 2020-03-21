import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'components//custom_snack_bars.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/resource/firebase_provider.dart';

class SettingPage extends StatefulWidget {
  final VoidCallback signInCallback;

  SettingPage({this.signInCallback});

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedRadioValue;

  Future<void> _handleRestore() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
      } else {
        if (await firebaseProvider.checkUserExists()) {
          routinesBloc.restoreRoutines();
        } else {
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
                  "No data in the cloud",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ));
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
    super.initState();

    selectedRadioValue = firebaseProvider.weeklyAmount;
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
            leading: Icon(Icons.cloud_upload),
            title: Text("Back up my data"),
            onTap: onBackUpTapped,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.cloud_download),
            title: Text("Restore my data"),
            onTap: () {
              scaffoldKey.currentState.removeCurrentSnackBar();
              firebaseProvider.firebaseUser == null
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
                            //Navigator.pop(context);
                            widget.signInCallback();
                          }),
                    ))
                  : _handleRestore().whenComplete(() => _showSuccessSnackBar("RESTORED SUCCESSFULLY!"));
            },
          )
        ],
      ),
    );
  }

  void onBackUpTapped() {
    scaffoldKey.currentState.removeCurrentSnackBar();
    if (firebaseProvider.firebaseUser == null) {
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
              "You should sign in first",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        action: SnackBarAction(
            label: "SIGN IN",
            onPressed: () {
              widget.signInCallback();
            }),
      ));
    } else {
      uploadRoutines().whenComplete(() {
        _showSuccessSnackBar("BACKED UP SUCCESSFULLY!");
      });
    }
  }

  Future uploadRoutines() async {
    return Connectivity().checkConnectivity().then((connectivity) {
      if (connectivity == ConnectivityResult.none) {
        scaffoldKey.currentState.removeCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
        throw ("No internet connections.");
      } else {
        return routinesBloc.allRoutines.first.then((routines) {
          print("uploading");
          return firebaseProvider.uploadRoutines(routines);
        });
      }
    });
  }
}
