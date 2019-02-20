import 'package:flutter/material.dart';

import 'main.dart';
import 'model.dart';
import 'partEditPage.dart';

//class PartEditCard extends StatefulWidget {
//  AddOrEdit addOrEdit;
//  VoidCallback onDelete;
//  StringCallback onTextEdited;
//  bool isEmptyMove = true;
//  Part part;
//
//  @override
//  PartEditCardState createState() => new PartEditCardState();
//
//  PartEditCard(
//      {Key key,
//      @required this.onDelete,
//      this.onTextEdited,
//      @required this.part})
//      : assert(onDelete != null),
//        super(key: key);
//}

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class PartEditCard extends StatelessWidget {
  final _defaultTextStyle = TextStyle(color: Colors.white);

  //bool _visibility = true;
  final textController = TextEditingController();
  final textSetController = TextEditingController();
  final textRepController = TextEditingController();
  Part part;

  AddOrEdit addOrEdit;
  VoidCallback onDelete;
  StringCallback onTextEdited;

  //Part part;

  PartEditCard(
      {Key key,
        @required this.onDelete,
        this.onTextEdited,
        @required this.part})
      : assert(onDelete != null),
        super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
            padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                elevation: 12,
                color: _getColor(part.setType),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: targetedBodyPartToImageConverter(
                            part.targetedBodyPart ?? TargetedBodyPart.Arm),
                        title: Text(
                          part.setType == null
                              ? 'To be edited'
                              : setTypeToStringConverter(part.setType),
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          part.targetedBodyPart == null
                              ? 'To be edited'
                              : targetedBodyPartToStringConverter(
                              part.targetedBodyPart),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 12, right: 12, top: 4, bottom: 4),
                          child: Container(
                            height: _getHeight(part.setType),
                            child: _buildExerciseListView(part),
                          ) //_buildExerciseListView(_part)
                          ),
                      ButtonTheme.bar(
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                                child: const Text(
                                  'EDIT',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  //_navigateAndDisplaySelection(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PartEditPage(
                                                addOrEdit: AddOrEdit.Edit,
                                            part: part,
                                              )));
                                }),
                            FlatButton(
                                child: const Text(
                                  'DELETE',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                          title: new Text(
                                              'Delete this part of routine?'),
                                          content:
                                              new Text('You cannot undo this.'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: new Text('No'),
                                            ),
                                            new FlatButton(
                                              onPressed: () {
                                                onDelete();
                                                Navigator.of(context).pop(true);
                                              },
                                              child: new Text('Yes'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                                //widget.onDelete()
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
  }

  double _getHeight(SetType setType) {
    print('in get height');
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
    }
  }

  ListView _buildExerciseListView(Part part) {
    if (part.exercises.length != 0) {
      return ListView.builder(
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
                  style: _defaultTextStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Sets: ' + part.exercises[i].sets.toString(),
                  style: _defaultTextStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  (part.exercises[i].workoutType == WorkoutType.Weight
                      ? 'Reps: '
                      : 'Seconds: ') + part.exercises[i].reps,
                  style: _defaultTextStyle,
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

//  _navigateAndDisplaySelection(BuildContext context) async {
//    // Navigator.push returns a Future that will complete after we call
//    // Navigator.pop on the Selection Screen!
//    final result = await Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => PartEditPage(part: part)),
//    );
//
//    if (result != null) {
//      setState(() {
//        part = result;
//      });
//    }
//
//    // After the Selection Screen returns a result, hide any previous snackbars
//    // and show the new result!
////    Scaffold.of(context)
////      ..repartCurrentSnackBar()
////      ..showSnackBar(SnackBar(content: Text("$result")));
//  }

  Color _getColor(SetType setType) {
    print('reached _getColor');
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
