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

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder(
        stream: routinesBloc.allRoutines,
        builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
          print(snapshot.hasData);
          if (snapshot.hasData) {
            var routines = snapshot.data;
            print(routines);
            routines.forEach((r)=>print(r.parts));
            return CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  largeTitle: Text('My Routines'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Transform.translate(
                        offset: Offset(24, -6),
                        child: CupertinoButton(
                          child: Icon(Icons.star),
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => RecommendPage()));
                          },
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(12, -6),
                        child: CupertinoButton(
                          child: Icon(CupertinoIcons.add),
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
                                          var tempRoutine =
                                          Routine(mainTargetedBodyPart: val, routineName: null, parts: new List<Part>(), createdDate: null);
                                          routinesBloc.setCurrentRoutine(tempRoutine);
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
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
                      ),
                    ],
                  )
                ),
                SliverSafeArea(
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(buildChildren(routines)),
                  ),
                )
              ],
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

    var textColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black;
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
          Text('Today ', style:routineTitleTextStyle),
          Text(['Monday', 'Tuesday', 'Wednesday', 'Thusrday', 'Friday', 'Saturday', 'Sunday'][weekday - 1], style: todaysRoutineTitleTextStyle),
        ],
      )
    ));
    children.addAll(todaysRoutines.map((routine) => RoutineCard(isActive: true, routine: routine)));

    routines.forEach((routine) {
      if (map.containsKey(routine.mainTargetedBodyPart) == false) map[routine.mainTargetedBodyPart] = [];
      map[routine.mainTargetedBodyPart].add(routine);
    });

    map.keys.forEach((bodyPart) {
      children.add(Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(mainTargetedBodyPartToStringConverter(bodyPart), style: routineTitleTextStyle),
      ));
      children.addAll(map[bodyPart].map((routine) => RoutineCard(routine: routine)));
    });

    return children;
  }
}
