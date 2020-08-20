import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';
import 'package:workout_planner/utils/routine_helpers.dart';

import 'components/routine_card.dart';

class RecommendPage extends StatefulWidget {
  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Dev's Favorite"),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder(
            stream: routinesBloc.allRecRoutines,
            builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
              if (snapshot.hasData) {
                var routines = snapshot.data;
                return ListView(
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
    var children = <Widget>[];

    var textColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black;
    var style = TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor);

    routines.forEach((routine) {
      if (map.containsKey(routine.mainTargetedBodyPart) == false) map[routine.mainTargetedBodyPart] = [];
      map[routine.mainTargetedBodyPart].add(routine);
    });

    map.keys.forEach((bodyPart) {
      children.add(Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(mainTargetedBodyPartToStringConverter(bodyPart), style: style),
      ));
      children.addAll(map[bodyPart].map((routine) => RoutineCard(routine: routine, isRecRoutine: true)));
      children.add(Divider());
    });

    return children;
  }
}
