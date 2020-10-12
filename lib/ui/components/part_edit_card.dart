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
  final defaultTextStyle = TextStyle();
  final subTextStyle = TextStyle(color: Colors.black54);
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
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          elevation: 12,
          color: setTypeToColorConverter(part.setType),
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: targetedBodyPartToImageConverter(part.targetedBodyPart ?? TargetedBodyPart.Arm),
                  title: Text(
                    part.setType == null ? 'To be edited' : setTypeToStringConverter(part.setType),
                  ),
                  subtitle: Text(
                    part.targetedBodyPart == null ? 'To be edited' : targetedBodyPartToStringConverter(part.targetedBodyPart),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                    child: _buildExerciseListView(part),
                    ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                        child: Text(
                          'EDIT',
                          style: TextStyle(color: Colors.black),
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
                          'DELETE',style: TextStyle(color: Colors.black),
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

  double _getHeight(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return 20;
      case SetType.Drop:
        return 20;
      case SetType.Super:
        return 50;
      case SetType.Tri:
        return 80;
      case SetType.Giant:
        return 120;
      default:
        throw Exception('Unmatched SetType in _getHight');
    }
  }

  Widget _buildExerciseListView(Part part) {
    if (part.exercises.length != 0) {
      var children = <Widget>[];

      for (var ex in part.exercises) {
        children.add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Text(
                ex.name,
                maxLines: 1,
                style: defaultTextStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                ex.sets.toString() + ' Set${ex.sets == 1 ? '' : 's'}',
                style: defaultTextStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                ex.reps + (ex.workoutType == WorkoutType.Weight ? ' Reps' : ' Sec'),
                style: defaultTextStyle,
              ),
            )
          ],
        ));
        children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ));
      }
      children.removeLast();

      return ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        physics: NeverScrollableScrollPhysics(),
        children: children,
      );
    } else {
      return null;
    }
  }
}
