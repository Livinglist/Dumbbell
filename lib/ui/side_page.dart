import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/models/routine.dart';
import 'package:workout_planner/resource/shared_prefs_provider.dart';
import 'package:workout_planner/ui/routine_detail_page.dart';
import 'setting_page.dart';
import 'calender_page.dart';
import 'statistics_page.dart';
import 'recommend_page.dart';

///This is the page that is displayed on the leftmost side of the main page.
class SidePage extends StatefulWidget {
  final List<Routine> routines;

  SidePage({this.routines}) : assert(routines != null);

  @override
  _SidePageState createState() => _SidePageState();
}

class _SidePageState extends State<SidePage> {
  //GoogleSignInAccount currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: StreamBuilder(
            stream: firebaseProvider.firebaseAuth.onAuthStateChanged,
            builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
              var firebaseUser = snapshot.data;
              return Column(
                children: <Widget>[
                  SizedBox(height: 48),
//          firebaseUser == null
//              ? Container()
//              : ClipRRect(
//                  borderRadius: BorderRadius.circular(30),
//                  child: Text(firebaseProvider.appleIdCredential.fullName.givenName == null
//                      ? ''
//                      : firebaseProvider.appleIdCredential.fullName.givenName[0] + firebaseProvider.appleIdCredential.fullName.familyName == null
//                          ? ''
//                          : firebaseProvider.appleIdCredential.fullName.familyName[0])),
                  firebaseUser == null
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            firebaseUser == null ? "null" : firebaseUser.displayName ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      firebaseUser == null ? "Sign in to sync your data" : firebaseUser.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        firebaseUser == null
                            ? RaisedButton(
                                child: Text('SIGN IN', style: TextStyle(fontSize: 18)),
                                onPressed: showSignInModalSheet,
                              )
                            : RaisedButton(
                                child: Text('SIGN OUT', style: TextStyle(fontSize: 18)),
                                onPressed: signOut,
                              ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Settings',
                      style: TextStyle(fontFamily: 'Staa', fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingPage(signInCallback: showSignInModalSheet))),
                  ),
                  ListTile(
                    title: Text(
                      'Statistics',
                      style: TextStyle(fontFamily: 'Staa', fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StatisticsPage())),
                  ),
                  ListTile(
                    title: Text(
                      "Dev's favorite",
                      style: TextStyle(fontFamily: 'Staa', fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecommendPage())),
                  ),
                  ListTile(
                    title: Text(
                      "Calender",
                      style: TextStyle(fontFamily: 'Staa', fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CalenderPage(routines: widget.routines))),
                  ),
                ],
              );
            }));
  }

  void showSignInModalSheet() {
    showModalBottomSheet(
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
                        Navigator.pop(context);
                        signInAndRestore(SignInMethod.google);
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
                        Navigator.pop(context);
                        signInAndRestore(SignInMethod.apple);
                      },
                    ))
              ],
            ),
          );
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
}
