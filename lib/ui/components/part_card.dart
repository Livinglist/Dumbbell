import 'package:flutter/material.dart';

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
  final _defaultTextStyle = TextStyle(fontFamily: 'Staa');
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          elevation: 12,
          color: setTypeToColorConverter(_part.setType),
          child: InkWell(
            onTap: widget.onPartTap,
            onLongPress: widget.onPartLongPressed,
            splashColor: Colors.deepOrange,
            borderRadius: BorderRadius.all(Radius.circular(4)),
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
                    child: _buildExerciseListView(_part),
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

  Widget _buildExerciseListView(Part part) {
    print('length' + part.exercises.length.toString());
    List<Widget> children = List<Widget>();

    for (var ex in part.exercises) {
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
              flex: 2,
              child: RichText(
                  text: TextSpan(style: _defaultTextStyle, children: [
                TextSpan(text: ex.sets.toString(), style: TextStyle(color: Colors.black, fontSize: 16)),
                TextSpan(text: ' sets', style: TextStyle(color: Colors.black54, fontSize: 12)),
              ]))),
          Expanded(
              flex: 2,
              child: RichText(
                  text: TextSpan(style: _defaultTextStyle, children: [
                TextSpan(text: ex.reps, style: TextStyle(color: Colors.black, fontSize: 16)),
                TextSpan(text: (ex.workoutType == WorkoutType.Weight ? ' reps' : ' secs'), style: TextStyle(color: Colors.black54, fontSize: 12)),
              ]))),
        ],
      ));
      children.add(Divider());
    }
    children.removeLast();
    return ListView(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), children: children);
  }
}
