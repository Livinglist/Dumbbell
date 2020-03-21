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
  final defaultTextStyle = TextStyle(color: Colors.white);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          elevation: 12,
          color: _getColor(part.setType),
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: targetedBodyPartToImageConverter(part.targetedBodyPart ?? TargetedBodyPart.Arm),
                  title: Text(
                    part.setType == null ? 'To be edited' : setTypeToStringConverter(part.setType),
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    part.targetedBodyPart == null ? 'To be edited' : targetedBodyPartToStringConverter(part.targetedBodyPart),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                    child: Container(
                      height: _getHeight(part.setType),
                      child: _buildExerciseListView(part),
                    ) //_buildExerciseListView(_part)
                    ),
                ButtonBar(
                  children: <Widget>[
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
                                      ))).then((value){
                                        setState(() {
                                          this.part = value;
                                        });
                          });
                        }),
                    FlatButton(
                        child: Text(
                          'DELETE',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
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
                        }
                        //widget.onDelete()
                        ),
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
        return 40;
      case SetType.Drop:
        return 40;
      case SetType.Super:
        return 60;
      case SetType.Tri:
        return 70;
      case SetType.Giant:
        return 100;
      default:
        throw Exception('Unmatched SetType in _getHight');
    }
  }

  Widget _buildExerciseListView(Part part) {
    if (part.exercises.length != 0) {
      return ListView.builder(
        controller: ScrollController(),
        physics: NeverScrollableScrollPhysics(),
        itemCount: part.exercises.length,
        itemBuilder: (context, i) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Text(
                  part.exercises[i].name,
                  style: defaultTextStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Sets: ' + part.exercises[i].sets.toString(),
                  style: defaultTextStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  (part.exercises[i].workoutType == WorkoutType.Weight ? 'Reps: ' : 'Seconds: ') + part.exercises[i].reps,
                  style: defaultTextStyle,
                ),
              )
            ],
          );
        },
      );
    } else {
      return null;
    }
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
}
