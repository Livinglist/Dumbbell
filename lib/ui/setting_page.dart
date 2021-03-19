import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
        key: scaffoldKey,
        body: Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder(
              stream: routinesBloc.allRecRoutines,
              builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
                if (snapshot.hasData) {
                  return StreamBuilder(
                    stream: firebaseProvider.firebaseAuth.authStateChanges(),
                    builder: (_, sp) {
                      var firebaseUser = sp.data;
                      if (firebaseUser != null) firebaseProvider.firebaseUser = firebaseUser;
                      return ListView(
                        children: [
                          ListTile(
                            leading: Icon(Icons.cloud_upload),
                            title: Text("Back up my data"),
                            onTap: onBackUpTapped,
                          ),
                          Padding(padding: EdgeInsets.only(left: 56), child: Divider(height: 0)),
                          ListTile(
                            leading: Icon(Icons.cloud_download),
                            title: Text("Restore my data"),
                            onTap: () {
                              if (firebaseUser == null) {
                                showMsg("You should sign in first");
                                return;
                              }
                              handleRestore().whenComplete(() => showMsg("Restored Successfully"));
                            },
                          ),
                          Padding(padding: EdgeInsets.only(left: 56), child: Divider(height: 0)),
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(firebaseUser == null ? 'Sign In' : 'Sign out'),
                            subtitle: firebaseUser == null ? null : Text(firebaseUser.displayName ?? ""),
                            onTap: () {
                              if (firebaseUser == null)
                                showSignInModalSheet();
                              else
                                signOut();
                            },
                          ),
                          Padding(padding: EdgeInsets.only(left: 56), child: Divider(height: 0)),
                          AboutListTile(
                            applicationIcon: Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                'assets/app_icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            applicationVersion: 'v1.1.5',
                            aboutBoxChildren: [
                              ElevatedButton(
                                onPressed: () {
                                  launch("https://livinglist.github.io");
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.addressCard),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text("Developer"),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  launch("https://github.com/Livinglist/Dumbbell");
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.github),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text("Source Code"),
                                  ],
                                ),
                              ),
                            ],
                            icon: Icon(Icons.info),
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
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(msg),
            actions: <Widget>[
              TextButton(
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
    if (firebaseProvider.firebaseUser == null)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No User Signed In'),
        action: SnackBarAction(label: 'Okay', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      ));
    else
      uploadRoutines().whenComplete(() {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Data uploaded'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Okay'),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No Internet Connections'),
          action: SnackBarAction(label: 'Okay', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
        ));
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
        return AlertDialog(
          title: Text('Restore your data?'),
          content: Text('Looks like you have your data on the cloud, do you want to restore them to this device?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Yes'),
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
                    child: SignInButtonBuilder(
                      backgroundColor: Colors.blue,
                      text: 'Sign in with Google',
                      icon: FontAwesomeIcons.google,
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
