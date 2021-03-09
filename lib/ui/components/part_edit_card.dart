import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/part_edit_page.dart';

import 'package:workout_planner/models/routine.dart';

typedef void StringCallback(String val);

class PartEditCard extends StatefulWidget {
  final VoidCallback onDelete;
  final StringCallback onTextEdited;
  final Part part;

  PartEditCard({Key key, @required this.onDelete, this.onTextEdited, @required this.part})
      : assert(onDelete != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PartEditCardState();
}

class PartEditCardState extends State<PartEditCard> {
  final defaultTextStyle = TextStyle(fontFamily: 'Staa');
  final textController = TextEditingController();
  final textSetController = TextEditingController();
  final textRepController = TextEditingController();
  Part part;

  @override
  void initState() {
    super.initState();

    part = widget.part;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          elevation: 12,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: targetedBodyPartToImageConverter(part.targetedBodyPart ?? TargetedBodyPart.Arm),
                  title: Text(
                    part.setType == null ? 'To be edited' : setTypeToStringConverter(part.setType),
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    part.targetedBodyPart == null ? 'To be edited' : targetedBodyPartToStringConverter(part.targetedBodyPart),
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 0),
                    child: _buildExerciseListView(part),
                    ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text(
                          'EDIT',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PartEditPage(
                                    addOrEdit: AddOrEdit.edit,
                                    part: part,
                                  ))).then((value) {
                            setState(() {
                              if (value != null) this.part = value;
                            });
                          });
                        }),
                    FlatButton(
                        child: Text(
                          'DELETE',style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('Delete this part of routine?'),
                              content: Text('You cannot undo this.'),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('No'),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    widget.onDelete();
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Yes'),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildExerciseListView(Part part) {
    var children = List<Widget>();

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
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
              flex: 2,
              child: RichText(
                  text: TextSpan(style: defaultTextStyle, children: [
                    TextSpan(text: ex.sets.toString(), style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextSpan(text: ' sets', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ]))),
          Expanded(
              flex: 2,
              child: RichText(
                  text: TextSpan(style: defaultTextStyle, children: [
                    TextSpan(text: ex.reps, style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextSpan(text: (ex.workoutType == WorkoutType.Weight ? ' reps' : ' secs'), style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ]))),
        ],
      ));
      children.add(Divider());
    }
    return Column(children: children);
  }
}
