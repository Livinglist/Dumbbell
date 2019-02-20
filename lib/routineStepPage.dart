import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'customWidgets/customSnackBars.dart';
import 'database/database.dart';
import 'model.dart';

typedef int Operation(int);

class RoutineStepPage extends StatefulWidget {
  VoidCallback celebrateCallback;

  RoutineStepPage({this.celebrateCallback});

  @override
  State<StatefulWidget> createState() {
    return _RoutineStepPageState();
  }
}

const LabelTextStyle = TextStyle(color: Colors.white70);
const SmallBoldTextStyle =
    TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold);

class _RoutineStepPageState extends State<RoutineStepPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = new ScrollController();
  final _duration = Duration(milliseconds: 50);
  var _stepperKey = GlobalKey();
  var _bottomSheetContainerKey = GlobalKey();
  AnimationController _opacityController;
  Animation<double> _opacity;

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

  Timer _increTimer;
  Timer _decreTimer;

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

  keepDecre(Exercise ex) {
    _decreTimer = Timer.periodic(_duration, (Timer t) {
      setState(() {
        ex.weight = _decreWeight(ex.weight);
      });
    });
  }

  keepIncre(Exercise ex) {
    _increTimer = Timer.periodic(_duration, (Timer t) {
      setState(() {
        ex.weight = _increWeight(ex.weight);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _opacityController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _opacity =
    CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut)
      ..addStatusListener((status) {
//      if (status == AnimationStatus.completed) {
//        _opacityController.reverse();
//      } else if (status == AnimationStatus.dismissed) {
//        _opacityController.forward();
//      }
        if (status == AnimationStatus.dismissed) {
          _opacityController.forward();
        }
      });
    _opacityController.forward();
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
      _opacityController.reverse();
      _initialized = true;
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: FadeTransition(
          opacity: _opacity,
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
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.assignment),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context, builder: (buildContext) {
                      return Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(routineCopy
                              .parts[_curExIndex].additionalNotes.isEmpty
                              ? "No additional notes"
                              : routineCopy.parts[_curExIndex].additionalNotes,
                            textAlign: TextAlign.center,),
                        ),
                      );
                    });
//                    _scaffoldKey.currentState.showBottomSheet((buildContext) {
//                      return Container(
//                        key: _bottomSheetContainerKey,
//                        height: 200,
//                        width: double.infinity,
//                        color: Colors.white,
//                        child: Padding(
//                          padding: EdgeInsets.all(8),
//                          child: Text(routineCopy
//                                  .parts[_curExIndex].additionalNotes.isEmpty
//                              ? "No additional notes"
//                              : routineCopy.parts[_curExIndex].additionalNotes),
//                        ),
//                      );
//                    });
                  },
                )
              ],
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
                          content:
                          Text('Add one to the completion counter?'),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: Text("Nah"),
                            ),
                            FlatButton(
                              onPressed: () async {
                                Navigator.of(context).pop(true);

                                routineCopy.completionCount++;
                                if (!routineCopy.routineHistory
                                    .contains(getTodayDate())) {
                                  routineCopy.routineHistory
                                      .add(getTodayDate());
                                }

                                RoutinesContext
                                    .of(context)
                                    .routines
                                    .removeWhere(
                                        (r) => r.id == routineCopy.id);
                                RoutinesContext
                                    .of(context)
                                    .routines
                                    .add(
                                    Routine.copyFromRoutine(routineCopy));
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

                                widget.celebrateCallback();

                                Navigator.pop(context);
                              },
                              child: Text(
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
        ));
  }

  Widget _mainLayout() {
    if (_curExIndex < routine.parts.length)
      return _buildRow();
    else
      _fabEnabled = true;
    return Container(
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
    );
  }

  ///new
  Widget _buildRow() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      alignment: Alignment.topCenter,
      height: queryData.size.height,
      width: queryData.size.width,
      color: setTypeToColorConverter(routine.parts[_curExIndex].setType),
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
                      child: _buildExerciseDetailRow(
                          _curExIndex,
                          routineCopy.parts[_curExIndex].exercises,
                          routineCopy.parts[_curExIndex].setType),
                    ))
              ],
            ),
          )),
    );
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
      routineCopy.parts[_curExIndex].exercises[curEx].exHistory[tempDateStr] +=
          '/' +
              routineCopy.parts[_curExIndex].exercises[curEx].weight.toString();
    } else {
      routineCopy.parts[_curExIndex].exercises[curEx].exHistory[tempDateStr] =
          routineCopy.parts[_curExIndex].exercises[curEx].weight.toString();
    }
  }

  Widget _buildExerciseDetailRow(int i, List<Exercise> exs, SetType setType) {
    return Stepper(
      key: _stepperKey,
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
        //TODO: organize
        if (_currentSteps[i] == exs.length - 1 && _setsLeft[i] == 0) {
          _opacityController.reverse();
          Timer(Duration(milliseconds: 800), () {
            setState(() {
              _curExIndex++;
              _stepperKey = GlobalKey();
            });
          });
        } else {
          setState(() {
            if (_currentSteps[i] < exs.length - 1) {
              _currentSteps[i]++;
            } else {
              if (_setsLeft[i] == 0) {
                _opacityController.reverse();
                Timer(Duration(milliseconds: 800), () {
                  _curExIndex++;
                  _stepperKey = GlobalKey();
                });
              } else {
                _currentSteps[i] = 0;
                _setsLeft[i]--;
              }
            }
          });
        }
      },
      steps: exs
          .map((ex) =>
          Step(
            title: Text(ex.name),
            content: _buildStepContent(i, ex, setType),
          ))
          .toList(),
    );
  }

  Widget _buildStepContent(int i, Exercise ex, SetType setType) {
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
                    keepDecre(ex);
                  },
                  onLongPressUp: () {
                    _decreTimer.cancel();
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
                    keepIncre(ex);
                  },
                  onLongPressUp: () {
                    _increTimer.cancel();
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
                        text: ex.workoutType == WorkoutType.Weight
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
    var connectivity = Connectivity();
    if (connectivity.checkConnectivity == ConnectionState.none) {
      _scaffoldKey.currentState.showSnackBar(NoNetworkSnackBar());
    } else {
      String url = 'https://www.bodybuilding.com/exercises/search?query=' + ex;
      if (await canLaunch(url)) {
        await launch(url, forceWebView: true);
      } else {
        throw 'Could not launch $url';
      }
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
