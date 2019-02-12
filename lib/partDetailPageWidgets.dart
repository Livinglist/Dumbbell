import 'package:flutter/material.dart';

import 'main.dart';
import 'model.dart';
import 'partEditPage.dart';

typedef void PartTapCallback(Part part);

class PartCard extends StatefulWidget {
  VoidCallback onDelete;
  VoidCallback onPartLongPressed;
  VoidCallback onPartLongPressedUp;
  VoidCallback onPartTap;
  StringCallback onTextEdited;
  bool isEmptyMove = true;
  Part part;

  @override
  PartCardState createState() => new PartCardState();

  PartCard(
      {Key key,
      @required this.onDelete,
        this.onPartLongPressed,
        this.onPartLongPressedUp,
        this.onPartTap,
      this.onTextEdited,
      @required this.part})
      : assert(onDelete != null),
        super(key: key);
}


class PartCardState extends State<PartCard> {
  final _defaultTextStyle = TextStyle(color: Colors.white);
  bool _visibility = true;
  final textController = TextEditingController();
  final textSetController = TextEditingController();
  final textRepController = TextEditingController();
  Part _part;

  @override
  void initState() {
    // TODO: implement initState
    _part = widget.part;
    super.initState();
  }

  //final Workout workout;
  //bool visible = true;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //if(MoveDetail.part != null) print('hello'+MoveDetail.part.partName);
    //else print('is null!!');
    _part = widget.part;
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
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
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: targetedBodyPartToImageConverter(
                          _part.targetedBodyPart ?? TargetedBodyPart.Arm),
                      title: Text(
                        _part.setType == null
                            ? 'To be edited'
                            : setTypeToStringConverter(_part.setType),
                        style: _defaultTextStyle,
                      ),
                      subtitle: Text(
                        _part.targetedBodyPart == null
                            ? 'To be edited'
                            : targetedBodyPartToStringConverter(
                            _part.targetedBodyPart),
                        style: _defaultTextStyle,
                      ),
                    ),
                    Padding(
                        padding:
                        EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                        child: Container(
                          height: _getHeight(_part.setType),
                          child: _buildExerciseListView(_part),
                        ) //_buildExerciseListView(_part)
                    ),
                  ],
                ),
              ),
            )),
    );
  }

  double _getHeight(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return 60;
      case SetType.Drop:
        return 60;
      case SetType.Super:
        return 100;
      case SetType.Tri:
        return 120;
      case SetType.Giant:
        return 160;
    }
  }

  ListView _buildExerciseListView(Part part) {
    print('length' + part.exercises.length.toString());
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, i) => Divider(
            color: Colors.white,
          ),
      itemCount: part.exercises.length,
      itemBuilder: (context, i) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Text(
                part.exercises[i].name,
                maxLines: 1,
                overflow: TextOverflow.clip,
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
                (part.workoutType== WorkoutType.Weight?'Reps: ':'Seconds: ') + part.exercises[i].reps,
                style: _defaultTextStyle,
              ),
            )
          ],
        );
      },
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PartEditPage(part: _part)),
    );

    if (result != null) {
      setState(() {
        _part = result;
      });
    }

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result!
//    Scaffold.of(context)
//      ..repartCurrentSnackBar()
//      ..showSnackBar(SnackBar(content: Text("$result")));
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
  RoutineDescriptionCardState createState() =>
      new RoutineDescriptionCardState();
}

class RoutineDescriptionCardState extends State<RoutineDescriptionCard> {
  @override
  Widget build(BuildContext context) {
    final Routine routine = widget.routine;
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
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
