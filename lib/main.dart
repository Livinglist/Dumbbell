import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'resource/db_provider.dart';
import 'resource/firebase_provider.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';
import 'package:workout_planner/ui/setting_page.dart';
import 'package:workout_planner/ui/statistics_page.dart';
import 'bloc/routines_bloc.dart';
import 'resource/shared_prefs_provider.dart';

import 'ui/home_page.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.orange,
          primarySwatch: Colors.deepOrange,
          fontFamily: 'Staa',
          textTheme: TextTheme(
            bodyText2: TextStyle(
              fontSize: 16
            ),
          )
        ),
        debugShowCheckedModeBanner: false,
        title: 'Dumbbell',
        routes: {
          '/routine_edit_page': (context) => RoutineEditPage(),
          '/home_page': (context) => HomePage(),
        },
        home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return Container();

            return MainPage();
          },
        ));
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final pageController = PageController(initialPage: 0, keepPage: true);
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  var tabs = [HomePage(), StatisticsPage(), SettingPage()];
  int selectedIndex = 0;

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
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.wrap_text,
            ),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            if ((selectedIndex - index).abs() > 1) {
              selectedIndex = index;
              pageController.jumpToPage(index);
            } else {
              selectedIndex = index;
              pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
            }
          });
        },
      ),
    );
  }
}
