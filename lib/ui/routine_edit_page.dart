import 'dart:async';
import 'dart:math';

import 'package:app_review/app_review.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/components/part_edit_card.dart';
import 'package:workout_planner/ui/part_edit_page.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

import 'components/spring_curve.dart';

class RoutineEditPage extends StatefulWidget {
  final AddOrEdit addOrEdit;
  final MainTargetedBodyPart mainTargetedBodyPart;

  RoutineEditPage({@required this.addOrEdit, this.mainTargetedBodyPart})
      : assert((addOrEdit == AddOrEdit.add && mainTargetedBodyPart != null) || addOrEdit == AddOrEdit.edit);

  @override
  _RoutineEditPageState createState() => _RoutineEditPageState();
}

class _RoutineEditPageState extends State<RoutineEditPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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

    AppReview.isRequestReviewAvailable.then((value) {
      if (value) {
        AppReview.requestReview;
      }
    });

    Timer(Duration(milliseconds: 500), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500), curve: SpringCurve.underDamped);
      }
    });
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

              return Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  actions: <Widget>[
                    if (widget.addOrEdit == AddOrEdit.edit)
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Delete this routine'),
                              content: Text("Are you sure? You cannot undo this."),
                              actions: <Widget>[
                                TextButton(onPressed: () => Navigator.pop(_), child: Text('No')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(_);
                                    Navigator.popUntil(context, (Route r) {
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
                      ),
                    Builder(
                      builder: (context) => IconButton(icon: Icon(Icons.done), onPressed: onDonePressed),
                    )
                  ],
                ),
                body: ReorderableListView(
                  scrollController: scrollController,
                  children: buildExerciseDetails(),
                  onReorder: onReorder,
                  header: Form(key: formKey, child: _routineDescriptionEditCard()),
                  padding: EdgeInsets.only(bottom: 128),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    'ADD',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: onAddExercisePressed,
                  isExtended: true,
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }

  void onDonePressed() {
    if (widget.addOrEdit == AddOrEdit.add && routineCopy.parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routine is empty.')));
      return;
    }
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
      _startTimeout(300);
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    var temp = routineCopy.parts.removeAt(oldIndex);
    setState(() {
      routineCopy.parts.insert(min(newIndex, routineCopy.parts.length), temp);
    });
  }

  List<Widget> buildExerciseDetails() {
    var children = <Widget>[];

    if (routineCopy.parts.isNotEmpty) {
      children.addAll(routineCopy.parts.map((part) {
        return PartEditCard(
          key: UniqueKey(),
          onDelete: () {
            setState(() {
              routineCopy.parts.remove(part);
            });
          },
          part: part,
        );
      }));
    }

    return children;
  }

  Widget _routineDescriptionEditCard() {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          elevation: 12,
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: textEditingController,
                    style: TextStyle(color: Colors.black, fontSize: 22),
                    decoration: InputDecoration(
                      labelText: 'Routine Title',
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
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Your editing will not be saved.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
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
        setState(() {
          if (value != null) {
            routineCopy.parts.last = value;
          }
        });
      });
    });
  }
}
