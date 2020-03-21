import 'package:flutter/material.dart';

import 'package:app_review/app_review.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/ui/calender_page.dart';
import 'setting_page.dart';
import 'statistics_page.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'routine_detail_page.dart';
import 'routine_edit_page.dart';
import 'components/routine_overview_card.dart';
import 'recommend_page.dart';
import 'side_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  PageController pageController;
  AnimationController animationController;
  Animatable<Color> background;
  bool showFab = false;
  final pageNumberToMainPartMap = {
    2: MainTargetedBodyPart.Arm,
    3: MainTargetedBodyPart.Chest,
    4: MainTargetedBodyPart.Back,
    5: MainTargetedBodyPart.Leg,
    6: MainTargetedBodyPart.FullBody,
    7: MainTargetedBodyPart.Abs
  };

  @override
  void initState() {
    super.initState();

    _initialize();
    animationController = AnimationController(duration: Duration(seconds: 10), vsync: this)..repeat(reverse: true);

    AppReview.isRequestReviewAvailable.then((isAvailable) {
      if (isAvailable) {
        AppReview.requestReview;
      }
    });
  }

  void _initialize() {
    background = TweenSequence<Color>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.orange[700],
          end: Colors.orange[600],
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.orange[600],
          end: Colors.orange[500],
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.orange[500],
          end: Colors.deepOrange,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.deepOrange,
          end: Colors.orange[400],
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.orange[400],
          end: Colors.orange[300],
        ),
      ),
    ]);

    pageController = PageController(initialPage: 1)
      ..addListener(() {
        var page = pageController.page.toInt();
        if (page == 1 || page == 0) {
          setState(() {
            showFab = false;
          });
        } else {
          setState(() {
            showFab = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: routinesBloc.allRoutines,
      builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.hasData) {
          var routines = snapshot.data;

          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                            colors: [background.evaluate(AlwaysStoppedAnimation(animationController.value)), Colors.orange],
                            stops: [0.0, 1.0],
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            tileMode: TileMode.repeated)),
                    child: child,
                  ),
                  floatingActionButton: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: showFab ? 1 : 0,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      backgroundColor: Colors.white,
                      foregroundColor: background.evaluate(AlwaysStoppedAnimation(animationController.value)),
                      onPressed: () {
                        var tempRoutine = Routine(
                            mainTargetedBodyPart: pageNumberToMainPartMap[pageController.page.toInt()],
                            routineName: null,
                            parts: new List<Part>(),
                            createdDate: null);
                        routinesBloc.setCurrentRoutine(tempRoutine);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoutineEditPage(
                                      addOrEdit: AddOrEdit.add,
                                      mainTargetedBodyPart: pageNumberToMainPartMap[pageController.page.toInt()],
                                    )));
                      },
                    ),
                  ));
            },
            child: PageView(
                controller: pageController, children: [SidePage(routines: routines), buildTodayPage(routines), ...buildPageviewChildren(routines)]),
          );

          return Scaffold(
            floatingActionButton: AnimatedBuilder(
              animation: pageController,
              builder: (_, child) {
                final color = pageController.hasClients ? pageController.page / 7 : .0;

                return FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Colors.white,
                  foregroundColor: background.evaluate(AlwaysStoppedAnimation(color)),
                  onPressed: () {
                    var tempRoutine = Routine(mainTargetedBodyPart: null, routineName: null, parts: new List<Part>(), createdDate: null);
                    routinesBloc.setCurrentRoutine(tempRoutine);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoutineEditPage(
                                  addOrEdit: AddOrEdit.add,
                                  mainTargetedBodyPart: pageNumberToMainPartMap[pageController.page.toInt()],
                                )));
                  },
                );
              },
              child: Container(),
            ),
            body: AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                final color = pageController.hasClients ? pageController.page / 7 : .0;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: background.evaluate(AlwaysStoppedAnimation(color)),
                  ),
                  child: child,
                );
              },
              child: PageView(controller: pageController, children: [SidePage(routines: routines), ...buildPageviewChildren(routines)]),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildTodayPage(List<Routine> routines) {
    var todaysRoutines = List<Routine>();

    int weekday = DateTime.now().weekday;

    for (var routine in routines) {
      if (routine.weekdays.contains(weekday)) {
        todaysRoutines.add(routine);
      }
    }

    return buildPage(todaysRoutines, "Today");
  }

  List<Widget> buildPageviewChildren(List<Routine> routines) {
    Map<MainTargetedBodyPart, List<Routine>> rs = {};
    rs[MainTargetedBodyPart.Arm] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Arm).toList();
    rs[MainTargetedBodyPart.Chest] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Chest).toList();
    rs[MainTargetedBodyPart.Back] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Back).toList();
    rs[MainTargetedBodyPart.Leg] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Leg).toList();
    rs[MainTargetedBodyPart.FullBody] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.FullBody).toList();
    rs[MainTargetedBodyPart.Abs] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Abs).toList();

    return rs.keys.map((key) => buildPage(rs[key], mainTargetedBodyPartToStringConverter(key))).toList();
  }

  Widget buildPage(List<Routine> routines, String bodyPart) {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              bodyPart,
              style: TextStyle(fontSize: 92, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        Flexible(
          child: Column(
            children: routines.map((r) => RoutineOverview(routine: r)).toList(),
          ),
        )
      ],
    );
  }

  Widget buildRoutineOverviewCard(Routine routine) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              routinesBloc.setCurrentRoutine(routine);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RoutineDetailPage(
                            isRecRoutine: false,
                          )));
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Text(
                      routine.routineName,
                      style: TextStyle(fontSize: 36),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    for (var part in routine.parts.getRange(0, routine.parts.length))
                      Column(
                        children: <Widget>[
                          Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(part.exercises.first.name),
                              )
                            ],
                          ),
                          Divider()
                        ],
                      ),
                    Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(routine.parts.last.exercises.first.name),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
