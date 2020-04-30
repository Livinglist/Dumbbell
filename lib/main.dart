import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'resource/db_provider.dart';
import 'resource/firebase_provider.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';
import 'package:workout_planner/ui/setting_page.dart';
import 'package:workout_planner/ui/statistics_page.dart';
import 'bloc/routines_bloc.dart';
import 'resource/shared_prefs_provider.dart';

import 'ui/home_page.dart';

//typedef void StringCallback(String val);
//const String FirstRunDateKey = "firstRunDate";
//const String AppVersionKey = "appVersion";
//const String DailyRankKey = "dailyRank";
//const String DatabaseStatusKey = "databaseStatus";
//const String WeeklyAmountKey = "weeklyAmount";
//
/////format: {"2019-01-01":50} (use UTC time)
//String firstRunDate;
//bool isFirstRun;
//String dailyRankInfo;
//int dailyRank;
//int weeklyAmount;
//
//GoogleSignIn _googleSignIn = GoogleSignIn(
//  scopes: <String>[
//    'email',
//  ],
//);
//
//GoogleSignInAccount currentUser;

void main() {
  runApp(App());
}

/// This widget is the root of our application.
/// Currently, we just show one widget in our app.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        theme: CupertinoThemeData(
          //fontFamily: 'Staa',
          primaryColor: Colors.orange,
          //buttonColor: Colors.orange[300],
          //toggleableActiveColor: Colors.orangeAccent,
          //indicatorColor: Colors.orangeAccent,
          //bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent)
        ),
        debugShowCheckedModeBanner: false,
        title: 'Workout Planner',
        routes: {
          '/routine_edit_page': (context) => RoutineEditPage(),
          '/home_page': (context) => HomePage(),
        },
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    DBProvider.db.initDB().whenComplete(() {
      routinesBloc.fetchAllRoutines();
      routinesBloc.fetchAllRecRoutines();
    });

    firebaseProvider.signInSilently().then((_) {
      print("Sign in silently end. :$_");
    });

    sharedPrefsProvider.prepareData();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.dumbbell, size: 24),
              title: Center(
                child: Text(
                  '  My Routines',
                  textAlign: TextAlign.center,
                ),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              title: Center(
                child: Text(
                  'Progress',
                  textAlign: TextAlign.center,
                ),
              )),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 28,
            ),
            title: Text(
              'Settings',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return HomePage();
              case 1:
                return StatisticsPage();
              case 2:
                return SettingPage();
              default:
                throw Exception("Unmatched index: $index");
            }
          },
        );
      },
    );
  }
}
