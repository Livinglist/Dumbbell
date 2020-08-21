import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/ui/recommend_page.dart';
import 'package:workout_planner/utils/routine_helpers.dart';

import 'components/routine_card.dart';
import 'routine_edit_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  AnimationController animationController;
  bool showShadow = false;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, value: 0);

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 30) {
          animationController.value = 1 - (30 - scrollController.offset) / 30;
        } else {
          animationController.value = 1;
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: animationController,
            child: Text(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][DateTime.now().weekday - 1],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orangeAccent)),
            builder: (_, child) {
              return Opacity(
                child: child,
                opacity: animationController.value,
              );
            },
          ),
          elevation: showShadow ? 8 : 0,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          actions: [
            IconButton(
              icon: Icon(Icons.star),
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => RecommendPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return CupertinoActionSheet(
                        title: Text('Choose a targeted muscle group for this routine'),
                        actions: MainTargetedBodyPart.values.map((val) {
                          var title = mainTargetedBodyPartToStringConverter(val);

                          return CupertinoActionSheetAction(
                            child: Text(title),
                            onPressed: () {
                              Navigator.pop(context);
                              var tempRoutine = Routine(mainTargetedBodyPart: val, routineName: null, parts: new List<Part>(), createdDate: null);
                              routinesBloc.setCurrentRoutine(tempRoutine);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RoutineEditPage(
                                            addOrEdit: AddOrEdit.add,
                                            mainTargetedBodyPart: val,
                                          )));
                            },
                          );
                        }).toList(),
                        cancelButton: CupertinoActionSheetAction(
                          isDefaultAction: true,
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    });
              },
            ),
          ],
          //title: Text('My Routines'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder(
            stream: routinesBloc.allRoutines,
            builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
              if (snapshot.hasData) {
                var routines = snapshot.data;

                return ListView(
                  controller: scrollController,
                  children: buildChildren(routines),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }

  List<Widget> buildChildren(List<Routine> routines) {
    var map = <MainTargetedBodyPart, List<Routine>>{};
    var todaysRoutines = List<Routine>();
    int weekday = DateTime.now().weekday;
    var children = <Widget>[];

    var textColor = Colors.black;
    var todaysRoutineTitleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orangeAccent);
    var routineTitleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor);

    for (var routine in routines) {
      if (routine.weekdays.contains(weekday)) {
        todaysRoutines.add(routine);
      }
    }

    children.add(Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          children: <Widget>[
            Text('Today ', style: routineTitleTextStyle),
            Text(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][weekday - 1], style: todaysRoutineTitleTextStyle),
          ],
        )));
    children.addAll(todaysRoutines.map((routine) => RoutineCard(isActive: true, routine: routine)));

    routines.forEach((routine) {
      if (map.containsKey(routine.mainTargetedBodyPart) == false) map[routine.mainTargetedBodyPart] = [];
      map[routine.mainTargetedBodyPart].add(routine);
    });

    map.keys.forEach((bodyPart) {
      children.add(Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Text(mainTargetedBodyPartToStringConverter(bodyPart), style: routineTitleTextStyle),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Divider(),
                )
              ],
            ),
          )));
      children.addAll(map[bodyPart].map((routine) => RoutineCard(routine: routine)));
    });

    return children;
  }
}
