// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// To keep your imports tidy, follow the ordering guidelines at
// https://www.dartlang.org/guides/language/effective-dart/style#ordering
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/routine_detail_page.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';
// @required is defined in the meta.dart package

// We use an underscore to indicate that these variables are private.
// See https://www.dartlang.org/guides/language/effective-dart/design#libraries
final _rowHeight = 300.0;
//final _borderRadius = BorderRadius.circular(_rowHeight / 10);
//final _borderRadius = BorderRadius.circular(10);

/// A custom [RoutineOverview] widget.
///
/// The widget is composed on an [Icon] and [Text]. Tapping on the widget shows
/// a colored [InkWell] animation.
class RoutineOverview extends StatelessWidget {
  final Routine routine;
  final bool isRecRoutine;

  /// Creates a [RoutineOverview].
  ///
  /// A [RoutineOverview] saves the name of the Category (e.g. 'Length'), its color for
  /// the UI, and the icon that represents it (e.g. a ruler).
  // While the @required checks for whether a named parameter is passed in,
  // it doesn't check whether the object passed in is null. We check that
  // in the assert statement.
  RoutineOverview({Key key, @required this.routine, this.isRecRoutine = false})
      : assert(routine != null),
        super(key: key);

  /// Builds a custom widget that shows [RoutineOverview] information.
  /// This information includes the icon, name, and color for the [RoutineOverview].
  @override
  Widget build(BuildContext context) {
    return _mainLayout(context);
  }

  Widget _mainLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Material(
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(24)),
        color: Colors.orangeAccent,
        elevation: 3,
        child: Ink(
          color: Colors.transparent,
          height: _rowHeight,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              highlightColor: Colors.orange,
              splashColor: Colors.orange,
              // We can use either the () => function() or the () { function(); }
              // syntax.
              onTap: () {
                //RoutinesContext.of(context).curRoutine = routine;
                routinesBloc.setCurrentRoutine(routine);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RoutineDetailPage(
                              isRecRoutine: isRecRoutine,
                            )));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, top: 16),
                      child: Text(
                        mainTargetedBodyPartToStringConverter(routine.mainTargetedBodyPart),
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 20, top: 8, bottom: 16),
                      child: Text(routine.routineName,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Staa',
                            fontSize: _getFontSize(routine.routineName),
                          )
                          )),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      //direction: Axis.horizontal,
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Image(
                            image: AssetImage(_getIconPath(routine.mainTargetedBodyPart)),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          //direction: Axis.vertical,
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                    child: Padding(
                              padding: EdgeInsets.only(top: 24, right: 8),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    side: new BorderSide(color: Colors.transparent),
                                    borderRadius: new BorderRadius.only(bottomRight: Radius.circular(10))),
                                color: Colors.transparent,
                                child: ExerciseNameListView(exNames: _getFirstThreeExerciseName(routine.parts)),
                              ),
                            )))
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize(String str) {
    if (str.length > 56) {
      return 18;
    } else if (str.length > 17) {
      return 24;
    } else {
      return 32;
    }
  }

  String _getIconPath(MainTargetedBodyPart mainTB) {
    switch (mainTB) {
      case MainTargetedBodyPart.Abs:
        return 'assets/abs-96.png';
      case MainTargetedBodyPart.Arm:
        return 'assets/muscle-96.png';
      case MainTargetedBodyPart.Back:
        return 'assets/back-96.png';
      case MainTargetedBodyPart.Chest:
        return 'assets/chest-96.png';
      case MainTargetedBodyPart.Leg:
        return 'assets/leg-96.png';
      case MainTargetedBodyPart.Shoulder:
        return 'assets/muscle-96.png';
      case MainTargetedBodyPart.FullBody:
        return 'assets/muscle-96.png';
      default:
        throw Exception('Inside of _getIconPath');
    }
  }

  List<String> _getFirstThreeExerciseName(List<Part> parts) {
    List<String> exNames = <String>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].exercises == null) print("if you see this, the exs is null");
      for (int j = 0; j < parts[i].exercises.length; j++) {
        exNames.add(parts[i].exercises[j].name);
        if (exNames.length == 3) {
          i = parts.length;
          break;
        }
      }
    }
    return exNames;
  }
}

class ExerciseNameListViewState extends State<ExerciseNameListView> {
  @override
  Widget build(BuildContext context) {
    return _buildMoves();
  }

  Widget _buildMoves() {
    List<Widget> children = [];

    if (widget.exNames.isNotEmpty) {
      for (var exName in widget.exNames) {
        children..add(_buildRow(exName))..add(Divider());
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
        maxLines: 2,
        overflow: TextOverflow.clip,
        text: TextSpan(
            style: TextStyle(
              fontFamily: 'Staa',
              color: Colors.black,
              fontSize: 18,
              shadows: Platform.isAndroid
                  ? <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 24,
                        color: Colors.black,
                      ),
                    ]
                  : null,
            ),
            children: <TextSpan>[
              TextSpan(text: move),
            ]));
  }
}

class ExerciseNameListView extends StatefulWidget {
  final List<String> exNames;

  ExerciseNameListView({this.exNames}) : assert(exNames != null);

  @override
  ExerciseNameListViewState createState() => new ExerciseNameListViewState();
}
