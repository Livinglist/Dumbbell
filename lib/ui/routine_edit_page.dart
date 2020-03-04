import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:workout_planner/main.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/ui/model.dart';
import 'package:workout_planner/ui/components/part_detail_edit_page_widgets.dart';
import 'package:workout_planner/ui/part_edit_page.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class RoutineEditPage extends StatefulWidget {
  final AddOrEdit addOrEdit;

  RoutineEditPage({@required this.addOrEdit});

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
  MainTargetedBodyPart selectedTB;

  MainTargetedBodyPart mTB;

  Routine routineCopy;
  Routine routine;
  

  @override
  void initState() {
    super.initState();
  }

  _handleUpload() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      //no internet connection
    } else {
      ///update user data if signed in
      print("inside the shit!");
      if (currentUser != null) {
        routinesBloc.allRoutines.first.then((routines) async {
          await FirestoreHelper().handleUpload(routines, failCallback: () {});
        });}
    }
  }

  @override
  Widget build(BuildContext context) {
    //final RoutinesContext roc = RoutinesContext.of(context);
    //final List<Routine> routines = RoutinesContext.of(context).routines;
//    if (!_initialized) {
//      //curRoutineCopy = Routine.copyFromRoutine(RoutinesContext.of(context).curRoutine);
////      if (widget.addOrEdit == AddOrEdit.Edit) {
////        selectedTB = routine.mainTargetedBodyPart;
////        textEditingController.text = routine.routineName;
////      } else if (widget.addOrEdit == AddOrEdit.Add) {
////      }
//      _initialized = true;
//    }

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
              if (widget.addOrEdit == AddOrEdit.Edit) {
                selectedTB = routineCopy.mainTargetedBodyPart;
                textEditingController.text = routineCopy.routineName;
              } else if (widget.addOrEdit == AddOrEdit.Add) {}
              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(color: Colors.white),
                  title: Text('Design Your Rouitne'),
                  actions: <Widget>[
                    widget.addOrEdit == AddOrEdit.Edit
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
                                            if (widget.addOrEdit == AddOrEdit.Edit) {
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
                                if (selectedTB == null) {
                                  //Newly created routine
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('Oops'),
                                          content: Text('Please choose a main targeted body part for this routine'),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Okay'),
                                            ),
                                          ],
                                        ),
                                  );
                                } else {
                                  formKey.currentState.validate();
                                  if (widget.addOrEdit == AddOrEdit.Add) {
//                            roc.curRoutine = curRoutineCopy;
//                            curRoutineCopy.createdDate = DateTime.now();
//                            routines.add(curRoutineCopy);
//                            DBProvider.db.newRoutine(curRoutineCopy);
                                    routinesBloc.addRoutine(routineCopy);
                                    Navigator.pop(context);
                                  } else {
//                            roc.curRoutine = curRoutineCopy;
//                            int indexOfRoutine = roc.routines.indexWhere((r) => r.id == curRoutineCopy.id);
//                            roc.routines[indexOfRoutine] = Routine.copyFromRoutine(curRoutineCopy);
//                            DBProvider.db.updateRoutine(curRoutineCopy);
                                    routinesBloc.updateRoutine(routineCopy);
                                    Navigator.pop(context);
                                  }
                                  _handleUpload();
                                }
                              });
                            },
                          ),
                    )
                  ],
                ),
                backgroundColor: Colors.white,
//        body: ReorderableListView(
//            children: curRoutineCopy.parts.isNotEmpty?curRoutineCopy.parts.map((part) => PartEditCard(
//              key: GlobalKey(),
//              onDelete: () {
//                setState(() {
//                  curRoutineCopy.parts.remove(part);
//                });
//              },
//              part: part,
//            )
//            ).toList():[],
//            onReorder: (oldIndex, newIndex) {
//              setState(() {
//                if (oldIndex < newIndex) newIndex -= 1;
//                var ele = curRoutineCopy.parts[oldIndex];
//                curRoutineCopy.parts.removeAt(oldIndex);
//                curRoutineCopy.parts.insert(newIndex, ele);
//              });
//            }),
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
                    }),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Main targeted body part:',
                      //style: TextStyle(color: Colors.white),
                    ),
                    PopupMenuButton<MainTargetedBodyPart>(
                      onSelected: (MainTargetedBodyPart res) {
                        selectedTB = res;
                        routineCopy.mainTargetedBodyPart = res;
                        setState(() {});
                      },
                      icon: Icon(Icons.list),
                      //onSelected: (WhyFarther result) { setState(() { _selection = result; }); },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<MainTargetedBodyPart>>[
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Abs,
                              child: Text('Abs'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Abs, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Arm,
                              child: Text('Arms'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Arm, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Back,
                              child: Text('Back'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Back, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Chest,
                              child: Text('Chest'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Chest, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Leg,
                              child: Text('Legs'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Leg, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.Shoulder,
                              child: Text('Shoulder'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.Shoulder, selectedTB),
                            ),
                            CheckedPopupMenuItem<MainTargetedBodyPart>(
                              value: MainTargetedBodyPart.FullBody,
                              child: Text('Full Body'),
                              checked: _shouldBeChecked(MainTargetedBodyPart.FullBody, selectedTB),
                            )
                          ],
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  bool _shouldBeChecked(MainTargetedBodyPart mainTB, MainTargetedBodyPart selectedTB) {
    if (selectedTB != null && mainTB == selectedTB) {
      return true;
    }
    return false;
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
                    addOrEdit: AddOrEdit.Add,
                    part: routineCopy.parts.last,
                    curRoutine: routineCopy,
                  )));
    });
  }
}
