import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/ui/recommend_page.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';
import 'package:workout_planner/utils/routine_helpers.dart';

import 'components/routine_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final scrollController = ScrollController();
  bool showShadow = false;

  @override
  void initState() {
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(

                  child: Column(
                    children: [
                      ...MainTargetedBodyPart.values.map((val) {
                        var title = mainTargetedBodyPartToStringConverter(val);
                        return ListTile(
                          title: Text(title),
                          onTap: () {
                            Navigator.pop(context);
                            var tempRoutine =
                                Routine(mainTargetedBodyPart: val, routineName: null, parts: new List<Part>(), createdDate: null);
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
                      ListTile(
                        title: Text(
                          'Template',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecommendPage(
                                )))
                      )
                    ],
                  ),
                );
              });
        },
      ),
    );
  }

  List<Widget> buildChildren(List<Routine> routines) {
    var map = <MainTargetedBodyPart, List<Routine>>{};
    var todayRoutines = List<Routine>();
    int weekday = DateTime.now().weekday;
    var children = <Widget>[];

    var textColor = Colors.black;
    var todayTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.orangeAccent);
    var routineTitleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor);

    for (var routine in routines) {
      if (routine.weekdays.contains(weekday)) {
        todayRoutines.add(routine);
      }
    }

    children.add(Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          children: <Widget>[
            Text(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][weekday - 1], style: todayTextStyle),
          ],
        )));
    children.addAll(todayRoutines.map((routine) => RoutineCard(isActive: true, routine: routine)));

    routines.forEach((routine) {
      if (map.containsKey(routine.mainTargetedBodyPart) == false) map[routine.mainTargetedBodyPart] = [];
      map[routine.mainTargetedBodyPart].add(routine);
    });

    map.keys.forEach((bodyPart) {
      children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
