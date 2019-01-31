import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'database/database.dart';

typedef int Operation(int);

class RoutineStepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RoutineStepPageState();
  }
}

const LabelTextStyle = TextStyle(color: Colors.white70);
const SmallBoldTextStyle =
    TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold);

class RoutineStepPageState extends State<RoutineStepPage> {
  final ScrollController _scrollController = new ScrollController();
  double maxOffset;
  Routine routine;
  MediaQueryData queryData;
  bool upEnabled = true;
  bool downEnabled = true;
  Color _appBarColors = Colors.grey[800];
  int _curExIndex = 0;
  Widget _fabIcon;
  String _title;
  int _currentStep = 0;
  List<int> _currentSteps;
  bool _initialized = false;
  List<int> _setsLeft;
  bool _fabEnabled = false;

  var timeout = const Duration(seconds: 1);
  var ms = const Duration(milliseconds: 1);

  startDownTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return new Timer(duration, () {
      downEnabled = true;
    });
  }

  startUpTimeout([int milliseconds]) {
    var duration =
        milliseconds == null ? Duration(seconds: 1) : ms * milliseconds;
    return new Timer(duration, () {
      upEnabled = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    routine = RoutinesContext.of(context).curRoutine;
    maxOffset = routine.parts.length * queryData.size.height;
    _appBarColors = _curExIndex == routine.parts.length
        ? Colors.orange
        : setTypeToColorConverter(routine.parts[_curExIndex].setType);
    _fabIcon = _curExIndex == routine.parts.length
        ? Text('+1')
        : Icon(Icons.arrow_downward);
    _title = _curExIndex < routine.parts.length
        ? targetedBodyPartToStringConverter(
                routine.parts[_curExIndex].targetedBodyPart) +
            ' - ' +
            setTypeToStringConverter(routine.parts[_curExIndex].setType)
        : 'Finished!';

    if (!_initialized) {
      _currentSteps = routine.parts.map((p) => 0).toList();
      _setsLeft =
          routine.parts.map((p) => int.parse(p.exercises.first.sets)-1).toList();
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(color: Colors.white54),
        ),
        backgroundColor: _appBarColors,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: () {
              //if(_scrollController.offset != 0)
              if (upEnabled) {
                _scrollController.animateTo(
                    _scrollController.offset - queryData.size.height,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
                upEnabled = false;
                setState(() {
                  if (_curExIndex != 0) _curExIndex--;
                });
                startUpTimeout(350);
                _fabEnabled = true;
              } else {}
            },
          )
        ],
      ),
      body: _mainLayout(),
      floatingActionButton: _fabEnabled?FloatingActionButton(
          child: Text('+1'),
          onPressed: () {
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                      title: new Text('Congrats! You finished it!'),
                      content: new Text('Add one to the completion counter?'),
                      actions: <Widget>[
                        new FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: new Text("Nah"),
                        ),
                        new FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            routine.completionCount++;
                            DBProvider.db.updateRoutine(routine);
                            Navigator.pop(context);
                          },
                          child: new Text(
                            'Sure',
                            style: TextStyle(fontSize: 36),
                          ),
                        ),
                      ],
                    ),
              );
          }):Container(),
    );
  }

  Widget _mainLayout() {
    return _buildRows();
  }

  Widget _buildRows() {
    List<Widget> widgets = new List<Widget>();
    for (int i = 0; i < routine.parts.length; i++) {
      widgets.add(Container(
        alignment: Alignment.topCenter,
        height: queryData.size.height,
        width: queryData.size.width,
        color: setTypeToColorConverter(routine.parts[i].setType),
        child: Container(
            alignment: Alignment.topCenter,
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(top: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: queryData.size.height * 0.8,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: _buildExerciseDetailRows(
                            i,
                            routine.parts[i].exercises,
                            routine.parts[i].setType,
                            routine.parts[i].workoutType),
                      ))
                ],
              ),
            )),
      ));
    }
    widgets.add(Container(
      alignment: Alignment.center,
      height: queryData.size.height,
      width: queryData.size.width,
      color: Colors.orange,
      child: Container(
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          'You finished it!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ));

    return ListView(
      controller: _scrollController,
      physics: NeverScrollableScrollPhysics(),
      children: widgets,
    );
  }

  void _scrollDown() {
    if (_scrollController.offset + queryData.size.height <= maxOffset) {
      _scrollController.animateTo(
          _scrollController.offset + queryData.size.height,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      setState(() {
        if (_curExIndex < routine.parts.length) {
          _curExIndex++;
          if(_curExIndex == routine.parts.length){
            _fabEnabled = true;
          }
//          if (_curExIndex != routine.parts.length &&
//              _setsLeft[_curExIndex] != 0) _fabEnabled = true;
        }
      });
    }else{
      _scrollController.animateTo(
          _scrollController.offset + queryData.size.height,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      setState(() {
        _fabEnabled = true;
      });
      routine.lastCompletedDate = DateTime.now();
      DBProvider.db.updateRoutine(routine);
    }
  }

  Widget _buildExerciseDetailRows(
      int i, List<Exercise> exs, SetType setType, WorkoutType workoutType) {
    List<Widget> _widgets = new List<Widget>();
    if (true) {
      _widgets.add(Stepper(
        currentStep: _currentSteps[i],
        onStepContinue: () {
          setState(() {
            if (_currentSteps[i] < exs.length - 1) {
              _currentSteps[i] += 1;
            } else {
              if(_setsLeft[i]==0){
                _scrollDown();
                //_fabEnabled = true;
              }else {
                _currentSteps[i] = 0;
                _setsLeft[i]--;
              }
            }
          });
        },
        steps: exs
            .map((ex) => Step(
                  title: Text(ex.name),
                  content: _buildStepContent(i, ex, setType, workoutType),
                ))
            .toList(),
      ));
    } else {
      for (int i = 0; i < exs.length; i++) {
        _widgets.add(Expanded(
            child: Padding(
          padding: EdgeInsets.only(top: 12, bottom: 12),
          child: ListTile(
            title: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.info,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _launchURL(exs[i].name);
                    },
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    exs[i].name,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              children: <Widget>[
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(text: 'Weight: ', style: LabelTextStyle),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                Row(children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 24),
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            String tempWeight =
                                _tryParse(exs[i].weight, (d) => --d);
                            if (tempWeight != null) {
                              setState(() {
                                exs[i].weight = tempWeight;
                              });
                            }
                            DBProvider.db.updateRoutine(routine);
                          })),
                  Expanded(
                    child: Center(
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: exs[i].weight,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getWeightFontSize(setType),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                  Expanded(
                      child: RaisedButton(
                          child: Text(
                            '+',
                            style: TextStyle(fontSize: 24),
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            String tempWeight =
                                _tryParse(exs[i].weight, (d) => ++d);
                            if (tempWeight != null) {
                              setState(() {
                                exs[i].weight = tempWeight;
                              });
                            }
                            DBProvider.db.updateRoutine(routine);
                          })),
                ]),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(text: 'Sets: ', style: LabelTextStyle),
                          ]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                          child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: workoutType == WorkoutType.Weight
                                  ? 'Reps: '
                                  : 'Seconds: ',
                              style: LabelTextStyle),
                        ]),
                      )),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: exs[i].sets,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getSetRepFontSize(setType),
                                    fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Center(
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: exs[i].reps,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getSetRepFontSize(setType),
                                  fontWeight: FontWeight.bold))
                        ]),
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
        )));
      }
    }

    return Column(children: _widgets);
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView.separated(
          physics: ScrollPhysics(),
          separatorBuilder: (context, i) {
            return Divider();
          },
          itemCount: exs.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: EdgeInsets.only(top: 12, bottom: 12),
              child: ListTile(
                title: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _launchURL(exs[i].name);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Text(
                        exs[i].name,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  children: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: 'Weight: ', style: LabelTextStyle),
                                ]),
                              ),
                            ),
                          ),
                        ]),
                    Row(children: <Widget>[
                      Expanded(
                          child: RaisedButton(
                              child: Text(
                                '-',
                                style: TextStyle(fontSize: 24),
                              ),
                              shape: CircleBorder(),
                              onPressed: () {
                                String tempWeight =
                                    _tryParse(exs[i].weight, (d) => --d);
                                if (tempWeight != null) {
                                  setState(() {
                                    exs[i].weight = tempWeight;
                                  });
                                }
                                DBProvider.db.updateRoutine(routine);
                              })),
                      Expanded(
                        child: Center(
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: exs[i].weight,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ),
                      ),
                      Expanded(
                          child: RaisedButton(
                              child: Text(
                                '+',
                                style: TextStyle(fontSize: 24),
                              ),
                              shape: CircleBorder(),
                              onPressed: () {
                                String tempWeight =
                                    _tryParse(exs[i].weight, (d) => ++d);
                                if (tempWeight != null) {
                                  setState(() {
                                    exs[i].weight = tempWeight;
                                  });
                                }
                                DBProvider.db.updateRoutine(routine);
                              })),
                    ]),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: RichText(
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(text: 'Sets: ', style: LabelTextStyle),
                              ]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                              child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: workoutType == WorkoutType.Weight
                                      ? 'Reps: '
                                      : 'Seconds: ',
                                  style: LabelTextStyle),
                            ]),
                          )),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: RichText(
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: exs[i].sets,
                                    style: SmallBoldTextStyle)
                              ]),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Center(
                          child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: exs[i].reps, style: SmallBoldTextStyle)
                            ]),
                          ),
                        )),
                      ],
                    )
                  ],
                ),
//              subtitle: RichText(
//                text: TextSpan(
//                    style: TextStyle(color: Colors.white),
//                    children: <TextSpan>[
//                      TextSpan(text: ),
//                    ]
//                ),
//              )
              ),
            );
          }),
    );
  }

  Widget _buildStepContent(
      int i, Exercise ex, SetType setType, WorkoutType workoutType) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                _launchURL(ex.name);
              },
            ),
          ),
        ],
      ),
      subtitle: Column(
        children: <Widget>[
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(text: 'Weight: ', style: LabelTextStyle),
                      ]),
                    ),
                  ),
                ),
              ]),
          Row(children: <Widget>[
            Expanded(
                flex: 2,
                child: RaisedButton(
                    child: Text(
                      '-',
                      style: TextStyle(fontSize: 24),
                    ),
                    shape: CircleBorder(),
                    onPressed: () {
                      String tempWeight = _tryParse(ex.weight, (d) => --d);
                      if (tempWeight != null) {
                        setState(() {
                          ex.weight = tempWeight;
                        });
                      }
                      DBProvider.db.updateRoutine(routine);
                    })),
            Expanded(
              flex: 6,
              child: Center(
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: ex.weight,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _getWeightFontSize(setType),
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
            Expanded(
              flex: 2,
                child: RaisedButton(
                    child: Text(
                      '+',
                      style: TextStyle(fontSize: 24),
                    ),
                    shape: CircleBorder(),
                    onPressed: () {
                      String tempWeight = _tryParse(ex.weight, (d) => ++d);
                      if (tempWeight != null) {
                        setState(() {
                          ex.weight = tempWeight;
                        });
                      }
                      DBProvider.db.updateRoutine(routine);
                    })),
          ]),
          Row(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(text: 'Sets left: ', style: LabelTextStyle),
                    ]),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                    child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: workoutType == WorkoutType.Weight
                            ? 'Reps: '
                            : 'Seconds: ',
                        style: LabelTextStyle),
                  ]),
                )),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: _setsLeft[i].toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: _getSetRepFontSize(setType),
                              fontWeight: FontWeight.bold))
                    ]),
                  ),
                ),
              ),
              Expanded(
                  child: Center(
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: ex.reps,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _getSetRepFontSize(setType),
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  double _getWeightFontSize(SetType st) {
    switch (st) {
      case SetType.Regular:
        return 72;
      case SetType.Drop:
        return 72;
      case SetType.Super:
        return 72;
      case SetType.Tri:
        return 64;
      case SetType.Giant:
        return 72;
    }
  }

  double _getSetRepFontSize(SetType st) {
    switch (st) {
      case SetType.Regular:
        return 36;
      case SetType.Drop:
        return 36;
      case SetType.Super:
        return 36;
      case SetType.Tri:
        return 28;
      case SetType.Giant:
        return 36;
    }
  }

  _launchURL(String ex) async {
    String url = 'https://www.bodybuilding.com/exercises/search?query=' + ex;
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _tryParse(String str, Operation operation) {
    var num = int.tryParse(str.trim());
    if (num != null) {
      print('heloooo');
      return operation(num) <= 0
          ? 0.toString()
          : operation(num).toString(); //weight cannot be below 0
    } else if (str.contains('-')) {
      List<String> list = str.split('-');
      for (var i in list) {
        var tempNum = int.tryParse(i.trim());
        if (tempNum != null) {
          i = operation(tempNum).toString();
        } else {
          return null;
        }
      }
      return list[0] + '-' + list[1];
    }
    return null;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
