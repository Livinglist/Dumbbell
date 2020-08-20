import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

import 'package:workout_planner/models/routine.dart';
import 'package:workout_planner/ui/routine_detail_page.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/utils/date_time_extension.dart';

class RoutineCard extends StatefulWidget {
  final bool isActive;
  final Routine routine;
  final bool isRecRoutine;
  final Key key;

  RoutineCard({this.isActive = false, this.routine, this.isRecRoutine = false, Key key})
      : key = key ?? UniqueKey(),
        super(key: key);

  @override
  _RoutineCardState createState() => _RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard> {
  @override
  Widget build(BuildContext context) {
    var routine = widget.routine;

    var exList = <Widget>[];
    var exInfoList = <Widget>[];

    List<Exercise> exes = [];
    routine.parts.forEach((part) {
      exes.addAll(part.exercises);
    });

    for (var ex in exes.sublist(0, min(5, exes.length))) {
      exList.add(Text(ex.name.toUpperCase()));
      exList.add(Padding(padding: EdgeInsets.symmetric(horizontal: 0), child: Divider()));

      exInfoList.add(RichText(
          text: TextSpan(style: TextStyle(fontFamily: 'Staa'), children: [
        TextSpan(text: ex.reps, style: TextStyle(color: Colors.black)),
        TextSpan(text: (ex.workoutType == WorkoutType.Weight ? ' reps' : ' secs'), style: TextStyle(color: Colors.black54)),
        TextSpan(text: ' x ${ex.sets} ', style: TextStyle(color: Colors.black)),
        TextSpan(text: 'sets', style: TextStyle(color: Colors.black54)),
      ])));
      exInfoList.add(Divider(
        color: Colors.transparent,
      ));
    }

    exList.removeLast();
    exInfoList.removeLast();

    return Card(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          splashColor: Colors.deepOrange,
          onTap: () {
            routinesBloc.setCurrentRoutine(routine);
            Navigator.push(context, CupertinoPageRoute(builder: (_) => RoutineDetailPage(isRecRoutine: widget.isRecRoutine)));
          },
          child: Container(
              height: 240,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.white60,
                      child: Container(
                          height: 64,
                          child: Padding(
                              padding: EdgeInsets.only(left: 12, top: 12),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Text(
                                  routine.routineName,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(fontSize: getFontSize(routine.routineName), fontFamily: 'Staa'),
                                ),
                              ]))),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                        children: [1, 2, 3, 4, 5, 6, 7].map((weekday) {
                      Color color, textColor;
                      if (routine.weekdays.contains(weekday)) {
                        color = Colors.deepOrange;
                        textColor = Colors.white;
                      } else {
                        color = Colors.transparent;
                        textColor = Colors.black;
                      }
                      return Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6)), color: color),
                          child: Center(
                            child: Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1],
                              style: TextStyle(color: textColor, fontSize: 6, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ),
                  Positioned(
                      top: 72,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: exList,
                      )),
                  Positioned(
                      top: 72,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: exInfoList,
                      )),
                ],
              )),
        ));

    return CupertinoButton(
        child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), //color: Theme.of(context).primaryColorDark
                color: CupertinoColors.secondarySystemBackground),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Text(mainTargetedBodyPartToStringConverter(routine.mainTargetedBodyPart),
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                ),
                Positioned(
                  top: 64,
                  left: 16,
                  right: 16,
                  child: ExerciseNameListView(parts: routine.parts),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        height: 48,
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                height: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            )))),
                if (widget.isActive)
                  Positioned(
                      top: 16,
                      right: 16,
                      child: Icon(
                          widget.routine.lastCompletedDate.isSameDay(DateTime.now()) ? Icons.check_circle_outline : Icons.radio_button_unchecked)),
                Positioned(
                  top: 16,
                  left: 16,
                  width: MediaQuery.of(context).size.width - 64,
                  child: Text(
                      widget.routine.routineName.substring(0, min(widget.routine.routineName.length, 28)) +
                          (widget.routine.routineName.length > 28 ? '...' : ''),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.orange,
                        fontFamily: 'Staa',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 16,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ),
                      maxLines: 1),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                      children: routine.parts
                          .map((set) => Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6)), color: setTypeToColorConverter(set.setType)),
                                ),
                              ))
                          .toList()),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Row(
                      children: [1, 2, 3, 4, 5, 6, 7].map((weekday) {
                    Color color, textColor;
                    if (routine.weekdays.contains(weekday)) {
                      color = Colors.deepOrange;
                      textColor = Colors.white;
                    } else {
                      color = Colors.transparent;
                      textColor = Colors.black;
                    }
                    return Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6)), color: color),
                        child: Center(
                          child: Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1],
                            style: TextStyle(color: textColor, fontSize: 6, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                ),
              ],
            )),
        onPressed: () {
          routinesBloc.setCurrentRoutine(routine);
          Navigator.push(context, CupertinoPageRoute(builder: (_) => RoutineDetailPage(isRecRoutine: widget.isRecRoutine)));
        });
  }

  double getFontSize(String str) {
    if (str.length > 56) {
      return 14;
    } else if (str.length > 17) {
      return 24;
    } else {
      return 36;
    }
  }
}

class _ExerciseNameListViewState extends State<ExerciseNameListView> with SingleTickerProviderStateMixin {
  final List<String> exNames;
  final bool isStatic;

  _ExerciseNameListViewState({this.exNames, this.isStatic});

  AnimationController animationController;
  Animation<double> curvedAnimation;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, lowerBound: 0.2, upperBound: 1, duration: Duration(seconds: 1, milliseconds: 500)); //..repeat(reverse: true);

    if (isStatic) {
      animationController.value = 1;
    } else {
      animationController.repeat(reverse: true);
    }

    curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
      //reverseCurve: Curves.elasticOut,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (_, __) {
        return Transform.scale(
          alignment: Alignment.centerLeft,
          scale: 0.95 + 0.05 * curvedAnimation.value,
          child: _buildMoves(),
        );
      },
    );
  }

  Widget _buildMoves() {
    List<Widget> children = [];

    if (exNames.isNotEmpty) {
      for (var exName in exNames) {
        children
          ..add(_buildRow(exName))
          ..add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              color: Colors.white,
            ),
          ));
      }

      children.removeLast();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRow(String move) {
    return RichText(
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.clip,
        text: TextSpan(
            style: TextStyle(
              fontFamily: 'Staa',
              color: Colors.black,
              fontSize: 16,
//              shadows: <Shadow>[
//                Shadow(
//                  offset: Offset(0, 1 * curvedAnimation.value),
//                  blurRadius: 4 + 12 * curvedAnimation.value,
//                  color: Colors.black,
//                ),
//              ],
            ),
            children: <TextSpan>[
              TextSpan(text: move),
            ]));
  }
}

class ExerciseNameListView extends StatefulWidget {
  final List<Part> parts;
  final List<String> exNames;
  final bool isStatic;

  ExerciseNameListView({this.parts, this.isStatic = true})
      : assert(parts != null),
        exNames = getFirstThreeExerciseName(parts);

  @override
  _ExerciseNameListViewState createState() => _ExerciseNameListViewState(exNames: exNames, isStatic: isStatic);

  static List<String> getFirstThreeExerciseName(List<Part> parts) {
    List<String> exNames = new List<String>();

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].exercises == null) print("if you see this, the exs is null");
      for (int j = 0; j < parts[i].exercises.length; j++) {
        exNames.add(parts[i].exercises[j].name);
//        if (exNames.length == 6) {
//          i = parts.length;
//          break;
//        }
      }
    }
    return exNames;
  }
}
