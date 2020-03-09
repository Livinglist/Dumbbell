import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/models/routine.dart';
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
  GoogleSignInAccount currentUser;

  @override
  void initState() {
    super.initState();

    currentUser = firebaseProvider.currentUser;
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          SizedBox(height: 48),
          currentUser == null
              ? Container()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    firebaseProvider.currentUser.photoUrl,
                    width: 60,
                    height: 60,
                  ),
                ),
          currentUser == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    firebaseProvider.currentUser.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              firebaseProvider.currentUser == null ? "Sign in to sync your data" : firebaseProvider.currentUser.email,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                firebaseProvider.currentUser == null
                    ? RaisedButton(
                        child: const Text('SIGN IN'),
                        onPressed: signInAndRestore,
                      )
                    : RaisedButton(
                        child: const Text('SIGN OUT'),
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingPage())),
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
      ),
    );
  }

  Future<void> signInAndRestore() async {
    try {
      firebaseProvider.signIn().then((value){
        setState(() {
          currentUser = value;
        });
      }).then((value) async {
        if (value !=null && await firebaseProvider.checkUserExists()) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return CupertinoAlertDialog(
                  title: const Text('Restore your data?'),
                  content: const Text('Looks like you have your data on the cloud, do you want to restore them to this device?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('No'),
                      textStyle: TextStyle(color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('Yes'),
                      textStyle: TextStyle(color: Colors.blue),
                      onPressed: () {
                        routinesBloc.restoreRoutines();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
      });
    } catch (error) {
      print(error);
    }
  }

  void signOut() => firebaseProvider.signOut().whenComplete((){
    setState(() {
      this.currentUser = null;
    });
  });
}
