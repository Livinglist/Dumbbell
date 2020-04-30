import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/components/part_edit_card.dart';
import 'package:workout_planner/ui/part_edit_page.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class RoutineEditPage extends StatefulWidget {
  final AddOrEdit addOrEdit;
  final MainTargetedBodyPart mainTargetedBodyPart;

  RoutineEditPage({@required this.addOrEdit, this.mainTargetedBodyPart})
      : assert((addOrEdit == AddOrEdit.add && mainTargetedBodyPart != null) || addOrEdit == AddOrEdit.edit);

  @override
  _RoutineEditPageState createState() => _RoutineEditPageState();
}

class _RoutineEditPageState extends State<RoutineEditPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool _initialized = false;

  MainTargetedBodyPart mTB;

  Routine routineCopy;
  Routine routine;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder(
          stream: routinesBloc.currentRoutine,
          builder: (_, AsyncSnapshot<Routine> snapshot) {
            if (snapshot.hasData) {
              routine = snapshot.data;

              if (!_initialized) {
                routineCopy = Routine.copyFromRoutine(routine);
                _initialized = true;
              }

              if (widget.addOrEdit == AddOrEdit.edit) {
                textEditingController.text = routineCopy.routineName;
              } else if (widget.addOrEdit == AddOrEdit.add) {}

              return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                      middle: Text(
                        'Edit Your ${mainTargetedBodyPartToStringConverter(widget.mainTargetedBodyPart)} Routine',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          widget.addOrEdit == AddOrEdit.edit
                              ? Transform.translate(
                                  offset: Offset(24, -6),
                                  child: CupertinoButton(
                                    child: Icon(Icons.delete_forever),
                                    onPressed: () {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
                                          title: Text('Delete this routine'),
                                          content: Text("Are you sure? You cannot undo this."),
                                          actions: <Widget>[
                                            CupertinoDialogAction(isDefaultAction: true, onPressed: () => Navigator.pop(_), child: Text('No')),
                                            CupertinoDialogAction(
                                              isDestructiveAction: true,
                                              onPressed: () {
                                                Navigator.pop(_);
                                                Navigator.popUntil(context, (Route r) {
                                                  print(r);
                                                  return r.settings.name == '/';
                                                });
                                                if (widget.addOrEdit == AddOrEdit.edit) {
                                                  routinesBloc.deleteRoutine(routine: routineCopy);
                                                }
                                              },
                                              child: Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ))
                              : Container(),
                          Transform.translate(
                              offset: Offset(12, -6),
                              child: Builder(
                                builder: (context) => CupertinoButton(child: Icon(Icons.done), onPressed: onDonePressed),
                              ))
                        ],
                      )),
                  child: CustomScrollView(slivers: [
                    SliverSafeArea(
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(buildExerciseDetails()),
                      ),
                    )
                  ])
//                backgroundColor: Colors.white,
//                body: buildExerciseDetails(),
//                floatingActionButton: FloatingActionButton.extended(
//                    backgroundColor: Colors.blueGrey[700], icon: Icon(Icons.add), label: Text('Add an exercise'), onPressed: onAddExercisePressed),
                  );
            } else {
              return Container();
            }
          },
        ));
  }

  void onDonePressed() {
    formKey.currentState.save();

    if (widget.addOrEdit == AddOrEdit.add) {
      routineCopy.mainTargetedBodyPart = widget.mainTargetedBodyPart;
      routinesBloc.addRoutine(routineCopy);
    } else {
      routinesBloc.updateRoutine(routineCopy);
    }

    Navigator.pop(context);
  }

  void onAddExercisePressed() {
    setState(() {
      routineCopy.parts.add(Part(setType: null, targetedBodyPart: null, exercises: null));
      //scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _startTimeout(300);
    });
  }

  List<Widget> buildExerciseDetails() {
    var children = <Widget>[Form(key: formKey, child: _routineDescriptionEditCard())];

    print('the length of parts:: ' + routineCopy.parts.length.toString());

    if (routineCopy.parts.isNotEmpty) {
      children.addAll(routineCopy.parts.map((part) {
        //print(part.exercises.first.name);
        return PartEditCard(
          key: UniqueKey(),
          onDelete: () {
            print("called ${part.exercises.first.name}");
            setState(() {
              routineCopy.parts.remove(part);
            });
          },
          part: part,
        );
      }));
    }

    children.add(Container(
      key: UniqueKey(),
      color: Colors.transparent,
      height: 60,
    ));

    children.add(Padding(
      padding: EdgeInsets.all(12),
      child: CupertinoButton.filled(child: Icon(CupertinoIcons.add), onPressed: onAddExercisePressed),
    ));

    return children;
  }

  Widget _routineDescriptionEditCard() {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          elevation: 12,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: textEditingController,
                    //style: TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                      labelText: 'Name this routine',
                      //labelStyle: TextStyle(color: Colors.white, fontSize: 18)
                    ),
                    onSaved: (str) {
                      if (str.isEmpty) {
                        routineCopy.routineName = mainTargetedBodyPartToStringConverter(routineCopy.mainTargetedBodyPart) + ' Workout';
                      } else {
                        routineCopy.routineName = str;
                      }
                    }),
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    return showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Are you sure?'),
            content: Text('Your editing will not be saved.'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  var timeout = const Duration(seconds: 1);
  var ms = const Duration(milliseconds: 1);

  _startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PartEditPage(
                    addOrEdit: AddOrEdit.add,
                    part: routineCopy.parts.last,
                    curRoutine: routineCopy,
                  ))).then((value) {
        if (value != null) {
          setState(() {
            routineCopy.parts.last = value;
          });
        }
      });
    });
  }
}
