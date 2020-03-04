import 'package:flutter/material.dart';

import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/ui/model.dart';
import 'package:workout_planner/ui/routine_detail_page.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController pageController;
  Animatable<Color> background;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    pageController = PageController();
    background = TweenSequence<Color>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.orange[600],
          end: Colors.deepPurple[400],
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.deepPurple[400],
          end: Colors.yellow[300],
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.yellow[300],
          end: Colors.cyan,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.cyan,
          end: Colors.amber,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.amber,
          end: Colors.blueGrey,
        ),
      ),
//      TweenSequenceItem(
//        weight: 1.0,
//        tween: ColorTween(
//          begin: Colors.blueGrey,
//          end: Colors.limeAccent,
//        ),
//      ),
    ]);
  }

//  @override
//  void reassemble() {
//    pageController.dispose();
//    _initialize();
//    super.reassemble();
//  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: routinesBloc.allRoutines,
      builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.hasData) {
          var routines = snapshot.data;

          return Scaffold(
            floatingActionButton: AnimatedBuilder(
              animation: pageController,
              builder: (_, child) {
                final color = pageController.hasClients ? pageController.page / 6 : .0;

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
                                  addOrEdit: AddOrEdit.Add,
                                )));
                  },
                );
              },
              child: Container(),
            ),
            body: AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                final color = pageController.hasClients ? pageController.page / 6 : .0;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: background.evaluate(AlwaysStoppedAnimation(color)),
                  ),
                  child: child,
                );
              },
              child: PageView(controller: pageController, children: buildPageviewChildren(routines)),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  List<Widget> buildPageviewChildren(List<Routine> routines) {
    Map<MainTargetedBodyPart, List<Routine>> rs = {};
    rs[MainTargetedBodyPart.Arm] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Arm).toList();
    rs[MainTargetedBodyPart.Chest] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Chest).toList();
    rs[MainTargetedBodyPart.Back] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Back).toList();
    rs[MainTargetedBodyPart.Leg] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Leg).toList();
    rs[MainTargetedBodyPart.FullBody] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.FullBody).toList();
    //rs[MainTargetedBodyPart.Shoulder] = routines.where((r) => r.mainTargetedBodyPart == MainTargetedBodyPart.Shoulder).toList();
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
            children: routines.map((r) => routineToRoutineCard(r)).toList(),
          ),
        )
      ],
    );
  }

  Widget routineToRoutineCard(Routine routine) {
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
