import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/models/routine.dart';
import 'package:workout_planner/resource/shared_prefs_provider.dart';

class SettingPage extends StatefulWidget {
  final VoidCallback signInCallback;

  SettingPage({this.signInCallback});

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedRadioValue;

  Future<void> handleRestore() async {
    await Connectivity().checkConnectivity().then((connectivity) async {
      if (connectivity == ConnectivityResult.none) {
        showMsg("No Internet Connections");
      } else {
        if (await firebaseProvider.checkUserExists()) {
          routinesBloc.restoreRoutines();
        } else {
          showMsg("No Data Found");
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    selectedRadioValue = firebaseProvider.weeklyAmount;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        key: scaffoldKey,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder(
              stream: routinesBloc.allRecRoutines,
              builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
                if (snapshot.hasData) {
                  var routines = snapshot.data;
                  return StreamBuilder(
                    stream: firebaseProvider.firebaseAuth.onAuthStateChanged,
                    builder: (_, sp) {
                      var firebaseUser = sp.data;
                      if (firebaseUser != null) firebaseProvider.firebaseUser = firebaseUser;
                      return CustomScrollView(
                        slivers: <Widget>[
                          CupertinoSliverNavigationBar(
                            largeTitle: Text("Settings"),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              ListTile(
                                leading: Icon(Icons.cloud_upload, color: CupertinoColors.systemGrey),
                                title: Text(
                                  "Back up my data",
                                  style: TextStyle(
                                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                          ? CupertinoColors.white
                                          : CupertinoColors.black),
                                ),
                                onTap: onBackUpTapped,
                              ),
                              Padding(padding: EdgeInsets.only(left: 56), child: Divider(height: 0)),
                              ListTile(
                                leading: Icon(Icons.cloud_download, color: CupertinoColors.systemGrey),
                                title: Text("Restore my data",
                                    style: TextStyle(
                                        color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                            ? CupertinoColors.white
                                            : CupertinoColors.black)),
                                onTap: () {
                                  if (firebaseUser == null) {
                                    showMsg("You should sign in first");
                                    return;
                                  }
                                  handleRestore().whenComplete(() => showMsg("Restored Successfully"));
                                },
                              ),
                              Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: <Widget>[
                                      firebaseUser == null
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Text(
                                                firebaseUser == null ? "null" : firebaseUser.displayName ?? "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.black,
                                                    fontSize: 18),
                                              ),
                                            ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            firebaseUser == null
                                                ? CupertinoButton.filled(
                                                    child: Text('SIGN IN', style: TextStyle(fontSize: 18)),
                                                    onPressed: showSignInModalSheet,
                                                  )
                                                : CupertinoButton.filled(
                                                    child: Text('SIGN OUT', style: TextStyle(fontSize: 18)),
                                                    onPressed: signOut,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ]),
                          ),
                        ],
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }

  void showMsg(String msg) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(msg),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.pop(_);
                },
              )
            ],
          );
        });
  }

  void onBackUpTapped() {
    uploadRoutines().whenComplete(() {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('Uploaded'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Nice'),
                  onPressed: () {
                    Navigator.pop(_);
                  },
                )
              ],
            );
          });
    });
  }

  Future uploadRoutines() async {
    return Connectivity().checkConnectivity().then((connectivity) {
      if (connectivity == ConnectivityResult.none) {
        showCupertinoDialog(
            context: context,
            builder: (_) {
              return CupertinoAlertDialog(
                title: Text('No Internet Connections'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.pop(_);
                    },
                  )
                ],
              );
            });
        throw ("No internet connections.");
      } else {
        return routinesBloc.allRoutines.first.then((routines) {
          print("uploading");
          return firebaseProvider.uploadRoutines(routines);
        });
      }
    });
  }

  void signInAndRestore(SignInMethod signInMethod) {
    if (signInMethod == SignInMethod.apple) {
      firebaseProvider.signInApple().then((firebaseUser) {
        if (firebaseUser != null) {
          firebaseProvider.checkUserExists().then((userExists) {
            if (userExists) showRestoreDialog();
          });
        }
      });
    } else if (signInMethod == SignInMethod.google) {
      firebaseProvider.signInGoogle().then((firebaseUser) {
        if (firebaseUser != null) {
          firebaseProvider.checkUserExists().then((userExists) {
            if (userExists) showRestoreDialog();
          });
        }
      });
    }
  }

  void showRestoreDialog() => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('Restore your data?'),
          content: Text('Looks like you have your data on the cloud, do you want to restore them to this device?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('No'),
              textStyle: TextStyle(color: Colors.red),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Yes'),
              textStyle: TextStyle(color: Colors.blue),
              onPressed: () {
                routinesBloc.restoreRoutines();
                Navigator.pop(context);
              },
            )
          ],
        );
      });

  void signOut() {
    firebaseProvider.signOut();
    sharedPrefsProvider.signOut();
  }

  void showSignInModalSheet() {
    showCupertinoModalPopup<SignInMethod>(
        context: context,
        builder: (_) {
          return Container(
            height: 200,
            child: Column(
              children: <Widget>[
                Transform.scale(
                    scale: 1.2,
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: () {
                        Navigator.pop(_, SignInMethod.google);
                      },
                    )),
                SizedBox(
                  height: 12,
                ),
                Transform.scale(
                    scale: 1.2,
                    child: SignInButton(
                      Buttons.Apple,
                      onPressed: () {
                        Navigator.pop(_, SignInMethod.apple);
                      },
                    ))
              ],
            ),
          );
        }).then((val) {
      if (val != null) signInAndRestore(val);
    });
  }
}
