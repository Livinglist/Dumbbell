import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:workout_planner/main.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/components/part_detail_edit_page_widgets.dart';
import 'package:workout_planner/ui/part_edit_page.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class RoutineEditPage extends StatefulWidget {
  final AddOrEdit addOrEdit;
  final MainTargetedBodyPart mainTargetedBodyPart;

  RoutineEditPage({@required this.addOrEdit, this.mainTargetedBodyPart}): assert((addOrEdit == AddOrEdit.add && mainTargetedBodyPart != null)||addOrEdit == AddOrEdit.edit);

  @override
  RoutineEditPageState createState() => new RoutineEditPageState();
}

class RoutineEditPageState extends State<RoutineEditPage> {
  //PlanEditPage({Key key}):super(key:key);
  final formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = new TextEditingController();
  bool _initialized = false;
  //Routine curRoutineCopy;
  ScrollController _scrollController = new ScrollController();

  MainTargetedBodyPart mTB;

  Routine routineCopy;
  Routine routine;


  @override
  void initState() {
    super.initState();
  }

  _handleUpload() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {

    } else {
      ///update user data if signed in
      if (firebaseProvider.currentUser != null) {
        routinesBloc.allRoutines.first.then((routines) async {
          await firebaseProvider.handleUpload(routines, failCallback: () {});
        });}
    }
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
              if(!_initialized) {
                routineCopy = Routine.copyFromRoutine(routine);
                _initialized = true;
              }
              if (widget.addOrEdit == AddOrEdit.edit) {
                textEditingController.text = routineCopy.routineName;
              } else if (widget.addOrEdit == AddOrEdit.add) {}
              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(color: Colors.black),
                  title: Text('Design Your ${mainTargetedBodyPartToStringConverter(widget.mainTargetedBodyPart)} Routine', style: TextStyle(fontFamily: 'Staa'),),
                  actions: <Widget>[
                    widget.addOrEdit == AddOrEdit.edit
                        ? IconButton(
                            icon: Icon(Icons.delete_forever),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Delete this routine'),
                                      content: Text("Are you sure? You cannot undo this."),
                                      actions: <Widget>[
                                        FlatButton(onPressed: () => Navigator.pop(context), child: Text('No')),
                                        FlatButton(
                                          onPressed: () {
                                            //routines.remove(curRoutineCopy);
                                            if (widget.addOrEdit == AddOrEdit.edit) {
                                              //DBProvider.db.deleteRoutine(curRoutineCopy);
                                              routinesBloc.deleteRoutine(routine: routineCopy);
                                              _handleUpload();
                                            }
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          )
                        : Container(),
                    Builder(
                      builder: (context) => IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              setState(() {
                                formKey.currentState.validate();
                                if (widget.addOrEdit == AddOrEdit.add) {
                                  routineCopy.mainTargetedBodyPart = widget.mainTargetedBodyPart;
                                  routinesBloc.addRoutine(routineCopy);
                                } else {
                                  routinesBloc.updateRoutine(routineCopy);
                                }
                                Navigator.pop(context);
                                _handleUpload();
                              });
                            },
                          ),
                    )
                  ],
                ),
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  controller: _scrollController,
                  child: _buildChildren(),
                ),
                floatingActionButton: new FloatingActionButton.extended(
                    backgroundColor: Colors.blueGrey[700],
                    icon: Icon(Icons.add),
                    label: Text('Add an exercise'),
                    onPressed: () {
                      setState(() {
                        routineCopy.parts.add(Part(setType: null, targetedBodyPart: null, exercises: null));
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        _startTimeout(300);
                      });
                    }),
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget _buildChildren() {
    List<Widget> exerciseDetails = <Widget>[];

    print('the length of parts:: ' + routineCopy.parts.length.toString());

    exerciseDetails.add(Form(key: formKey, child: _routineDescriptionEditCard()));
    if (routineCopy.parts.length != 0) {
      exerciseDetails.addAll(routineCopy.parts.map((part) => PartEditCard(
            onDelete: () {
              setState(() {
                routineCopy.parts.remove(part);
              });
            },
            part: part,
          )));
    }
    exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));
//    exerciseDetails.add(Container(
//      color: Colors.transparent,
//      height: 60,
//    ));

    return Column(
      children: exerciseDetails,
    );
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
                    validator: (str) {
                      if (str.isEmpty) {
                        routineCopy.routineName = mainTargetedBodyPartToStringConverter(routineCopy.mainTargetedBodyPart) + ' Workout';
                      } else {
                        routineCopy.routineName = str;
                      }

                      return '';
                    }),
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Your editing will not be saved.'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes'),
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
    return new Timer(duration, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PartEditPage(
                    addOrEdit: AddOrEdit.add,
                    part: routineCopy.parts.last,
                    curRoutine: routineCopy,
                  )));
    });
  }
}
