import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';

import 'package:workout_planner/models/routine.dart';

typedef void PartTapCallback(Part part);
typedef void StringCallback(String val);

class PartCard extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onPartTap;
  final StringCallback onTextEdited;
  final bool isEmptyMove = true;
  final Part part;

  @override
  PartCardState createState() => new PartCardState();

  PartCard(
      {Key key, @required this.onDelete, this.onPartTap, this.onTextEdited, @required this.part})
      : assert(onDelete != null),
        super(key: key);
}

class PartCardState extends State<PartCard> {
  final defaultTextStyle = TextStyle(fontFamily: 'Staa');
  final textController = TextEditingController();
  final textSetController = TextEditingController();
  final textRepController = TextEditingController();
  Part _part;

  @override
  void initState() {
    _part = widget.part;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _part = widget.part;
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          elevation: 12,
          color: Theme.of(context).primaryColor,
          child: InkWell(
            onTap: widget.onPartTap,
            splashColor: Colors.grey,
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
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    subtitle: Text(
                      _part.targetedBodyPart == null ? 'To be edited' : targetedBodyPartToStringConverter(_part.targetedBodyPart),
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 4),
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
    var children = <Widget>[];

    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 22,
          child: Text(
            "",
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
            flex: 5,
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: defaultTextStyle, children: [
                  TextSpan(text: 'sets', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ]))),
        Expanded(
            flex: 1,
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: defaultTextStyle, children: [
                  TextSpan(text: ' ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ]))),
        Expanded(
            flex: 5,
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: defaultTextStyle, children: [
                  TextSpan(text: 'reps', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ]))),
      ],
    ));

    for (var ex in part.exercises) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 22,
            child: Text(
              ex.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
              flex: 5,
              child: RichText(
                textAlign: TextAlign.center,
                  text: TextSpan(style: defaultTextStyle, children: [
                TextSpan(text: ex.sets.toString(), style: TextStyle(color: Colors.white, fontSize: 18)),
                //TextSpan(text: ' sets', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ]))),
          Expanded(
              flex: 1,
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(style: defaultTextStyle, children: [
                    TextSpan(text: 'x', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    //TextSpan(text: ' sets', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  ]))),
          Expanded(
              flex: 5,
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(style: defaultTextStyle, children: [
                TextSpan(text: ex.reps, style: TextStyle(color: Colors.white, fontSize: 18)),
                //TextSpan(text: (ex.workoutType == WorkoutType.Weight ? ' reps' : ' secs'), style: TextStyle(color: Colors.white54, fontSize: 14)),
              ]))),
        ],
      ));
      children.add(Divider(color: Colors.white38));
    }
    //children.removeLast();
    return Column(children: children);
  }
}
