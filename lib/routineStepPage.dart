import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database/database.dart';
import 'model.dart';

typedef int Operation(int);

class RoutineStepPage extends StatefulWidget {
  VoidCallback celebrateCallback;

  RoutineStepPage({this.celebrateCallback});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _RoutineStepPageState();
  }
}

const LabelTextStyle = TextStyle(color: Colors.white70);
const SmallBoldTextStyle =
    TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold);

class _RoutineStepPageState extends State<RoutineStepPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = new ScrollController();
  double maxOffset;
  Routine routine;
  Routine routineCopy;
  MediaQueryData queryData;
  bool upEnabled = true;
  bool downEnabled = true;
  Color _appBarColors = Colors.grey[800];
  int _curExIndex = 0;
  Widget _fabIcon;
  String _title;
  List<int> _currentSteps;
  bool _initialized = false;
  List<int> _setsLeft;
  bool _fabEnabled = false;

  //List<Part> _partsCopy;
  int totalLength = 0;
  int postion = 0;
  bool shouldIncre = false;
  bool shouldDecre = false;
  bool shouldBreak = false;

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

  startIncTimeout(Exercise ex, int milliseconds) {
    var duration =
    milliseconds == null ? Duration(seconds: 1) : ms * milliseconds;
    return new Timer(duration, () {
      if (shouldIncre) {
        setState(() {
          ex.weight = _increWeight(ex.weight);
        });
        startIncTimeout(ex, milliseconds);
      } else {
        //DBProvider.db.updateRoutine(routine);
      }
    });
  }

  startDecTimeout(Exercise ex, int milliseconds) {
    var duration =
    milliseconds == null ? Duration(seconds: 1) : ms * milliseconds;
    return new Timer(duration, () {
      if (shouldDecre) {
        setState(() {
          ex.weight = _decreWeight(ex.weight);
        });
        startDecTimeout(ex, milliseconds);
      } else {
        //DBProvider.db.updateRoutine(routine);
      }
    });
  }

  @override
  void initState() {
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
      _setsLeft = routine.parts.map((p) => p.exercises.first.sets - 1).toList();

      routineCopy = Routine.copyFromRoutine(routine);

      String tempDateStr = dateTimeToStringConverter(DateTime(
          DateTime
              .now()
              .year, DateTime
          .now()
          .month, DateTime
          .now()
          .day));
      for (var part in routineCopy.parts) {
        totalLength += part.exercises.length * part.exercises.first.sets;

        for (var ex in part.exercises) {
          if (ex.exHistory.containsKey(tempDateStr)) {
            ex.exHistory.remove(tempDateStr);
          }
        }
      }

      _initialized = true;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(color: Colors.white54),
          ),
          bottom: PreferredSize(
              child: LinearProgressIndicator(
                value: postion / totalLength,
              ),
              preferredSize: null),
          backgroundColor: _appBarColors,
        ),
        body: _mainLayout(),
        floatingActionButton: _fabEnabled
            ? FloatingActionButton(
            child: Text('+1'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: Text('Congrats! You finished it!'),
                      content: Text('Add one to the completion counter?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text("Nah"),
                        ),
                        FlatButton(
                          onPressed: () async {
                            Navigator.of(context).pop(true);

                            routineCopy.completionCount++;
                            RoutinesContext
                                .of(context)
                                .routines
                                .removeWhere((r) => r.id == routineCopy.id);
                            RoutinesContext
                                .of(context)
                                .routines
                                .add(Routine.copyFromRoutine(routineCopy));
                            RoutinesContext
                                .of(context)
                                .curRoutine =
                                RoutinesContext
                                    .of(context)
                                    .routines
                                    .last;

                            DBProvider.db.updateRoutine(
                                RoutinesContext
                                    .of(context)
                                    .curRoutine);

//                                ///update the database if haven't yet
//                                if (dailyRank > -1) {//== 0
//                                  var docs = await Firestore.instance
//                                      .collection('dailyData')
//                                      .getDocuments();
//                                  var ref = docs.documents.first.reference;
//                                  Firestore.instance
//                                      .runTransaction((transaction) async {
//                                    DocumentSnapshot freshSnap =
//                                        await transaction.get(ref);
//                                    await transaction.update(
//                                        freshSnap.reference, {
//                                      "totalCount": freshSnap["totalCount"] + 1
//                                    }).whenComplete(() async {
//                                      dailyRank = await ref.get().then(
//                                              (docSnapshot) =>
//                                          docSnapshot["totalCount"]);
//                                    });
//
//
//
//                                    ///TODO: why can't it fetch the latest updated value??
//                                    print("dailyRan value is $dailyRank");
//                                    dailyRankInfo =
//                                        DateTime.now().toUtc().toString() +
//                                            '/' +
//                                            dailyRank.toString();
//                                    setDailyRankInfo(dailyRankInfo);
//                                  });
//                                }

                            widget.celebrateCallback();

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
            })
            : Container(),
      ),
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
                            routineCopy.parts[i].exercises,
                            routineCopy.parts[i].setType,
                            routineCopy.parts[i].workoutType),
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
          //TODO: delete this part
          _curExIndex++;
          if (_curExIndex == routine.parts.length) {
            _fabEnabled = true;
          }
        }
      });
    } else {
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

  void _updateExHistory(int curEx, int setLeft) {
    String tempDateStr = dateTimeToStringConverter(DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day));
    if (routineCopy.parts[_curExIndex].exercises[curEx].exHistory
        .containsKey(tempDateStr)) {
      routineCopy
          .parts[_curExIndex].exercises[curEx].exHistory[tempDateStr] +=
          '/' +
              routineCopy.parts[_curExIndex].exercises[curEx].weight.toString();
    } else {
      routineCopy.parts[_curExIndex].exercises[curEx].exHistory[tempDateStr] =
          routineCopy.parts[_curExIndex].exercises[curEx].weight.toString();
    }
  }

  Widget _buildExerciseDetailRows(
      int i, List<Exercise> exs, SetType setType, WorkoutType workoutType) {
    List<Widget> _widgets = new List<Widget>();
    if (true) {
      _widgets.add(Stepper(
        controlsBuilder: (context, {onStepContinue, onStepCancel}) {
          return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Next'),
                onPressed: onStepContinue,
              )
            ],
          );
        },
        currentStep: _currentSteps[i],
        onStepContinue: () {
          _updateExHistory(_currentSteps[i], _setsLeft[i]);
          postion++;
          setState(() {
            if (_currentSteps[i] < exs.length - 1) {
              _currentSteps[i]++;
            } else {
              if (_setsLeft[i] == 0) {
                _scrollDown();
                //_fabEnabled = true;
              } else {
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
    }

    return Column(children: _widgets);
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
                _launchURL(ex.name); //TODO: detect the internet availability
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
                child: GestureDetector(
                  onLongPress: () {
                    shouldDecre = true;

                    startDecTimeout(ex, 50);
                  },
                  onLongPressUp: () {
                    shouldDecre = false;
                  },
                  child: RaisedButton(
                      child: Text(
                        '-',
                        style: TextStyle(fontSize: 24),
                      ),
                      shape: CircleBorder(),
                      onPressed: () {
                        setState(() {
                          ex.weight = _decreWeight(ex.weight);
                        });
                        //DBProvider.db.updateRoutine(routine);
                      }),
                )),
            Expanded(
              flex: 6,
              child: Center(
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: StringHelper.weightToString(ex.weight),
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
                child: GestureDetector(
                  onLongPress: () {
                    shouldIncre = true;

                    startIncTimeout(ex, 50);
                  },
                  onLongPressUp: () {
                    shouldIncre = false;
                  },
                  child: RaisedButton(
                      child: Text(
                        '+',
                        style: TextStyle(fontSize: 24),
                      ),
                      shape: CircleBorder(),
                      onPressed: () {
                        setState(() {
                          ex.weight = _increWeight(ex.weight);
                        });
                        //DBProvider.db.updateRoutine(routine);
                      }),
                )),
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

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
        title: new Text('Too soon to quit.😑'),
        content: new Text('Your progress will not be saved.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Ok ok'),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: new Text('I quit'),
          ),
        ],
      ),
    ) ??
        false;
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
      default:
        throw Exception("Inside _getWeightFontSize()");
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
      default:
        throw Exception("Inside _getWeightFontSize()");
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

  double _increWeight(double weight) {
    if (weight < 1000) {
      if (weight < 20) {
        weight += 0.5;
      } else {
        weight += 1;
      }
    }
    return weight;
  }

  double _decreWeight(double weight) {
    if (weight > 0) {
      if (weight < 20) {
        weight -= 0.5;
      } else {
        weight -= 1;
      }
    }
    return weight;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
