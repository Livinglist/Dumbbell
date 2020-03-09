import 'package:flutter/material.dart';

import 'package:workout_planner/main.dart';
import 'package:workout_planner/utils/routine_helpers.dart';

import 'package:workout_planner/models/routine.dart';

typedef void PartTapCallback(Part part);
typedef void StringCallback(String val);


class PartCard extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onPartLongPressed;
  final VoidCallback onPartLongPressedUp;
  final VoidCallback onPartTap;
  final StringCallback onTextEdited;
  final bool isEmptyMove = true;
  final Part part;

  @override
  PartCardState createState() => new PartCardState();

  PartCard(
      {Key key, @required this.onDelete, this.onPartLongPressed, this.onPartLongPressedUp, this.onPartTap, this.onTextEdited, @required this.part})
      : assert(onDelete != null),
        super(key: key);
}

class PartCardState extends State<PartCard> {
  final _defaultTextStyle = TextStyle(color: Colors.white);
  final textController = TextEditingController();
  final textSetController = TextEditingController();
  final textRepController = TextEditingController();
  Part _part;

  @override
  void initState() {
    _part = widget.part;
    super.initState();
  }

  //final Workout workout;
  //bool visible = true;
  @override
  Widget build(BuildContext context) {
    //if(MoveDetail.part != null) print('hello'+MoveDetail.part.partName);
    //else print('is null!!');
    _part = widget.part;
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          elevation: 12,
          color: _getColor(_part.setType),
          child: InkWell(
            onTap: widget.onPartTap,
            onLongPress: widget.onPartLongPressed,
            splashColor: _getSplashColor(_part.setType),
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    leading: targetedBodyPartToImageConverter(_part.targetedBodyPart ?? TargetedBodyPart.Arm),
                    title: Text(
                      _part.setType == null ? 'To be edited' : setTypeToStringConverter(_part.setType),
                      style: _defaultTextStyle,
                    ),
                    subtitle: Text(
                      _part.targetedBodyPart == null ? 'To be edited' : targetedBodyPartToStringConverter(_part.targetedBodyPart),
                      style: _defaultTextStyle,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                      child: Container(
                        height: _getHeight(_part.setType),
                        child: _buildExerciseListView(_part),
                      ) //_buildExerciseListView(_part)
                      ),
                  SizedBox(
                    height: 12,
                  )
                ],
              ),
            ),
          )),
    );
  }

  double _getHeight(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return 40;
      case SetType.Drop:
        return 40;
      case SetType.Super:
        return 60;
      case SetType.Tri:
        return 90;
      case SetType.Giant:
        return 125;
      default:
        throw Exception('Unmatched SetType in _getHight');
    }
  }

  Widget _buildExerciseListView(Part part) {
    print('length' + part.exercises.length.toString());
    List<Widget> children = List<Widget>();

    for(var ex in part.exercises){
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Text(
              ex.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: _defaultTextStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              ex.sets.toString() + ' sets',
              style: _defaultTextStyle,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              ex.reps + (ex.workoutType == WorkoutType.Weight ? ' reps' : ' seconds'),
              style: _defaultTextStyle,
            ),
          )
        ],
      ));
      children.add(Divider());
    }
    children.removeLast();
    return Column(
      children: children
    );
  }


  Color _getColor(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return Colors.lightBlue;
      case SetType.Drop:
        return Colors.grey;
      case SetType.Super:
        return Colors.teal;
      case SetType.Tri:
        return Colors.pink;
      case SetType.Giant:
        return Colors.red;
      default:
        return Colors.lightBlue;
    }
  }

  Color _getSplashColor(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return Colors.lightBlueAccent;
      case SetType.Drop:
        return Colors.greenAccent;
      case SetType.Super:
        return Colors.tealAccent;
      case SetType.Tri:
        return Colors.pinkAccent;
      case SetType.Giant:
        return Colors.redAccent;
      default:
        return Colors.lightBlueAccent;
    }
  }
}

class RoutineDescriptionCard extends StatefulWidget {
  final Routine routine;

  RoutineDescriptionCard({@required this.routine});

  @override
  RoutineDescriptionCardState createState() => new RoutineDescriptionCardState();
}

class RoutineDescriptionCardState extends State<RoutineDescriptionCard> {
  @override
  Widget build(BuildContext context) {
    final Routine routine = widget.routine;
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          elevation: 12,
          color: Colors.grey[700],
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  routine.routineName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                Text(
                  'You have done this workout',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  routine.completionCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, color: Colors.white),
                ),
                Text(
                  'times',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  'since',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  '${routine.createdDate.month}/${routine.createdDate.day}/${routine.createdDate.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
