// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// To keep your imports tidy, follow the ordering guidelines at
// https://www.dartlang.org/guides/language/effective-dart/style#ordering
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'model.dart';
import 'routineDetailPage.dart';
// @required is defined in the meta.dart package


// We use an underscore to indicate that these variables are private.
// See https://www.dartlang.org/guides/language/effective-dart/design#libraries
final _rowHeight = 300.0;
//final _borderRadius = BorderRadius.circular(_rowHeight / 10);
final _borderRadius = BorderRadius.circular(10);

/// A custom [RoutineOverview] widget.
///
/// The widget is composed on an [Icon] and [Text]. Tapping on the widget shows
/// a colored [InkWell] animation.
class RoutineOverview extends StatelessWidget {
  final Routine routine;
   bool isRecRoutine = false;

  /// Creates a [RoutineOverview].
  ///
  /// A [RoutineOverview] saves the name of the Category (e.g. 'Length'), its color for
  /// the UI, and the icon that represents it (e.g. a ruler).
  // While the @required checks for whether a named parameter is passed in,
  // it doesn't check whether the object passed in is null. We check that
  // in the assert statement.
  RoutineOverview({
    Key key,
    @required this.routine,
    this.isRecRoutine
  })  : assert(routine != null),
        super(key: key);

  /// Builds a custom widget that shows [RoutineOverview] information.
  ///
  /// This information includes the icon, name, and color for the [RoutineOverview].
  @override
  // This `context` parameter describes the location of this widget in the
  // widget tree. It can be used for obtaining Theme data from the nearest
  // Theme ancestor in the tree. Below, we obtain the display1 text theme.
  // See https://docs.flutter.io/flutter/material/Theme-class.html
  Widget build(BuildContext context) {
    print('Inside of RoutineOverView, the length of routines.length: '+RoutinesContext.of(context).routines.length.toString());
    return _mainLayout(context);
  }

  Widget _mainLayout(BuildContext context){
    final Routine curRoutine = RoutinesContext.of(context).curRoutine;
    return Padding(
      padding: EdgeInsets.all(8),
      child: Material(
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.transparent),
            borderRadius: new BorderRadius.circular(12)),
        color: _mainTargetedBodyPartToColorConverter(routine.mainTargetedBodyPart)[1], //---The color of the background of RoutineOverview Card---
        elevation: 3,
        child: Ink(
          color: Colors.transparent,
          height: _rowHeight,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              borderRadius: new BorderRadius.circular(10),
              highlightColor: Colors.lightBlueAccent,
              splashColor: Colors.lightBlueAccent,
              // We can use either the () => function() or the () { function(); }
              // syntax.
              onTap: () {
                RoutinesContext.of(context).curRoutine = routine;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RoutineDetailPage(isRecRoutine: isRecRoutine,)));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Material(
                    elevation: 30,
                    color: _mainTargetedBodyPartToColorConverter(routine.mainTargetedBodyPart)[0], //----The color of the title bar of RoutineOverview Card----
                    shape: new RoundedRectangleBorder(
                        side: BorderSide(color: Colors.transparent),
                        borderRadius: new BorderRadius.only(
                            topLeft: new Radius.circular(10),
                            topRight: new Radius.circular(10))),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 20,top: 16, right:0,bottom: 0),
                          child: Text(
                            mainTargetedBodyPartToStringConverter(routine.mainTargetedBodyPart),
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 20, top: 8, right: 0, bottom: 16),
                            child: Text(routine.routineName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getFontSize(routine.routineName),
                                )
                              /*DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: 2, color: Colors.white),*/
                            )),
                      ],
                    )
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      //direction: Axis.horizontal,
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: new Image(
                            image: AssetImage(_getIconPath(routine.mainTargetedBodyPart)),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              //direction: Axis.vertical,
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 24),
                                          child: Material(
                                            shape: RoundedRectangleBorder(
                                                side: new BorderSide(
                                                    color: Colors.transparent),
                                                borderRadius: new BorderRadius.only(
                                                    bottomRight: Radius.circular(10))),
                                            color: Colors.transparent,
                                            child: ExerciseNameListView(exNames:_getFirstThreeExerciseName(routine.parts)),
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
  
  double _getFontSize(String str){
    if(str.length>56){
      return 18;
    }else if(str.length>17){
      return 24;
    }else{
      return 32;
    }
  }


  List<Color> _mainTargetedBodyPartToColorConverter(MainTargetedBodyPart mainTB){
    switch(mainTB){
      case MainTargetedBodyPart.Abs:
        return <Color>[Color(0xff8E24AA), Color(0xffE040FB)];
      case MainTargetedBodyPart.Arm:
        return <Color>[Color(0xff2196F3), Color(0xff64B5F6)];
      case MainTargetedBodyPart.Back:
        return <Color>[Color(0xff0288D1), Color(0xff29B6F6)];
      case MainTargetedBodyPart.Chest:
        return <Color>[Color(0xff006064), Color(0xff0097A7)];
      case MainTargetedBodyPart.Leg:
        return <Color>[Color(0xff00695C), Color(0xff00BFA5)];
      case MainTargetedBodyPart.Shoulder:
        return <Color>[Color(0xff2E7D32), Color(0xff00C853)];
      case MainTargetedBodyPart.FullBody:
        return <Color>[Color(0xffBF360C), Color(0xffD84315)];
      default:
        throw Exception('Inside of _mainTargetedBodyPartToColorConverter '+mainTB.toString());
    }
    //return <Color>[Colors.grey[600], Colors.grey[700]];
  }



  String _getIconPath(MainTargetedBodyPart mainTB) {
    switch(mainTB){
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

  List<String> _getFirstThreeExerciseName(List<Part> parts){
    int exCount = 0;
    List<String> exNames = new List<String>();

    print('Length of parts: '+parts.length.toString());

    for(int i = 0; i < parts.length; i++){
      if(parts[i].exercises == null) print("if you see this, the exs is null");
      print('Length of exercises: '+parts[i].exercises.length.toString());
      for(int j = 0; j<parts[i].exercises.length;j++){
        exNames.add(parts[i].exercises[j].name);
        if(exNames.length == 3){
          i = parts.length;
          break;
        }
      }
    }
    return exNames;
  }
}

class ExerciseNameListViewState extends State<ExerciseNameListView> {
  //final List<String> _moves = <String>['push up', 'list up for jesus', 'pull over','Wide grip bench pressssss','jghjgjhgjghjghjgj'];

  @override
  Widget build(BuildContext context) {
    return _buildMoves();
  }

  Widget _buildMoves() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, i){
        return Divider(
          color: Colors.white70,
        );
      },
      itemCount: widget.exNames.length,
      itemBuilder: (context, i) {
          return _buildRow(widget.exNames[i], i % 2 == 0 ? Colors.white : Colors.white);

      },
    );
  }

  Widget _buildRow(String move, Color fontColor) {
    return new RichText(
        maxLines: 2,
        overflow: TextOverflow.clip,
        text: new TextSpan(
            style: new TextStyle(
              color: fontColor,
              fontSize: 18,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 24,
                  color: Colors.black,
                ),
              ],
            ),
            children: <TextSpan>[
          new TextSpan(text: move),
        ]));
  }
}

class ExerciseNameListView extends StatefulWidget {
  List<String> exNames;

  ExerciseNameListView({this.exNames}):assert(exNames != null);

  @override
  ExerciseNameListViewState createState() => new ExerciseNameListViewState();
}
