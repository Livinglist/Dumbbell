import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:workout_planner/ui/components//custom_snack_bars.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

typedef int Operation(int);

class RoutineStepPage extends StatefulWidget {
  final Routine routine;
  final VoidCallback celebrateCallback;
  final VoidCallback onBackPressed;

  RoutineStepPage({@required this.routine, this.celebrateCallback, this.onBackPressed});

  @override
  State<StatefulWidget> createState() => _RoutineStepPageState();
}

const LabelTextStyle = TextStyle(color: Colors.white70);
const SmallBoldTextStyle = TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold);

class _RoutineStepPageState extends State<RoutineStepPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _duration = Duration(milliseconds: 50);
  var stepperKey = GlobalKey();

  AnimationController opacityController;
  Animation<double> opacity;

  bool finished = false;

  double maxOffset;
  Routine routine;
  Routine routineCopy;
  MediaQueryData queryData;
  bool upEnabled = true;
  bool downEnabled = true;
  Color appBarColors = Colors.grey[800];
  int curExIndex = 0;
  String title;
  List<int> currentSteps;
  bool initialized = false;
  List<int> setsLeft;
  bool fabEnabled = false;

  //List<Part> _partsCopy;
  int totalLength = 0;
  int position = 0;

  Timer incrementTimer;
  Timer decrementTimer;

  var timeout = const Duration(seconds: 1);
  var ms = const Duration(milliseconds: 1);

  startDownTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return new Timer(duration, () {
      downEnabled = true;
    });
  }

  startUpTimeout([int milliseconds]) {
    var duration = milliseconds == null ? Duration(seconds: 1) : ms * milliseconds;
    return new Timer(duration, () {
      upEnabled = true;
    });
  }

  keepDecre(Exercise ex) {
    decrementTimer = Timer.periodic(_duration, (Timer t) {
      setState(() {
        ex.weight = decrementWeight(ex.weight);
      });
    });
  }

  keepIncre(Exercise ex) {
    incrementTimer = Timer.periodic(_duration, (Timer t) {
      setState(() {
        ex.weight = incrementWeight(ex.weight);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    opacityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    opacity = CurvedAnimation(parent: opacityController, curve: Curves.easeInOut)
      ..addStatusListener((status) {
//      if (status == AnimationStatus.completed) {
//        _opacityController.reverse();
//      } else if (status == AnimationStatus.dismissed) {
//        _opacityController.forward();
//      }
        if (status == AnimationStatus.dismissed) {
          opacityController.forward();
        }
      });
    opacityController.forward();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    //routine = RoutinesContext.of(context).curRoutine;
    routine = widget.routine;
    maxOffset = routine.parts.length * queryData.size.height;
    appBarColors = curExIndex == routine.parts.length ? Colors.orange : setTypeToColorConverter(routine.parts[curExIndex].setType);
    title = curExIndex < routine.parts.length
        ? targetedBodyPartToStringConverter(routine.parts[curExIndex].targetedBodyPart) +
            ' - ' +
            setTypeToStringConverter(routine.parts[curExIndex].setType)
        : 'Finished!';

    if (!initialized) {
      currentSteps = routine.parts.map((p) => 0).toList();
      setsLeft = routine.parts.map((p) => p.exercises.first.sets - 1).toList();

      routineCopy = Routine.copyFromRoutine(routine);

      String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
      for (var part in routineCopy.parts) {
        totalLength += part.exercises.length * part.exercises.first.sets;

        for (var ex in part.exercises) {
          if (ex.exHistory.containsKey(tempDateStr)) {
            ex.exHistory.remove(tempDateStr);
          }
        }
      }
      opacityController.reverse();
      initialized = true;
    }

    return WillPopScope(
        onWillPop: onWillPop,
        child: FadeTransition(
          opacity: opacity,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              //iconTheme: IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                title,
                style: TextStyle(color: Colors.white54),
              ),
              bottom: PreferredSize(
                  child: LinearProgressIndicator(
                    value: position / totalLength,
                  ),
                  preferredSize: null),
              backgroundColor: appBarColors,
            ),
            body: buildMainLayout(),
          ),
        ));
  }

  Widget buildMainLayout() {
    if (curExIndex < routine.parts.length) {
      return buildRow();
    } else {}

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
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  Widget buildRow() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      alignment: Alignment.topCenter,
      height: queryData.size.height,
      width: queryData.size.width,
      color: setTypeToColorConverter(routine.parts[curExIndex].setType),
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
                      child: buildExerciseDetailRow(curExIndex, routineCopy.parts[curExIndex].exercises, routineCopy.parts[curExIndex].setType),
                    ))
              ],
            ),
          )),
    );
  }

  void updateExHistory(int curEx, int setLeft) {
    String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    if (routineCopy.parts[curExIndex].exercises[curEx].exHistory.containsKey(tempDateStr)) {
      routineCopy.parts[curExIndex].exercises[curEx].exHistory[tempDateStr] += '/' + routineCopy.parts[curExIndex].exercises[curEx].weight.toString();
    } else {
      routineCopy.parts[curExIndex].exercises[curEx].exHistory[tempDateStr] = routineCopy.parts[curExIndex].exercises[curEx].weight.toString();
    }
  }

  Widget buildExerciseDetailRow(int i, List<Exercise> exs, SetType setType) {
    return Stepper(
      key: stepperKey,
      physics: NeverScrollableScrollPhysics(),
      controlsBuilder: (context, {onStepContinue, onStepCancel}) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              onPressed: onStepContinue,
            )
          ],
        );
      },
      currentStep: currentSteps[i],
      onStepContinue: () {
        updateExHistory(currentSteps[i], setsLeft[i]);
        position++;
        if (currentSteps[i] == exs.length - 1 && setsLeft[i] == 0) {
          opacityController.reverse();
          if (curExIndex + 1 == routine.parts.length && finished == false) {
            finished = true;
            routineCopy.completionCount++;

            if (!routineCopy.routineHistory.contains(getTimestampNow())) {
              routineCopy.routineHistory.add(getTimestampNow());
            }

            routinesBloc.updateRoutine(routineCopy);
          }

          Timer(Duration(milliseconds: 500), () {
            setState(() {
              if (curExIndex < routine.parts.length) curExIndex++;
              stepperKey = GlobalKey();
            });
          });
        } else {
          setState(() {
            if (currentSteps[i] < exs.length - 1) {
              currentSteps[i]++;
            } else {
              if (setsLeft[i] == 0) {
                opacityController.reverse();
                Timer(Duration(milliseconds: 500), () {
                  curExIndex++;
                  stepperKey = GlobalKey();
                });
              } else {
                currentSteps[i] = 0;
                setsLeft[i]--;
              }
            }
          });
        }
      },
      steps: exs
          .map((ex) => Step(
                title: Text(
                  ex.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                content: buildStepContent(i, ex, setType),
              ))
          .toList(),
    );
  }

  Widget buildStepContent(int i, Exercise ex, SetType setType) {
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
                launchURL(ex.name); //TODO: detect the internet availability
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
                    decrementTimer.cancel();
                  },
                  child: RaisedButton(
                      child: Text(
                        '-',
                        style: TextStyle(fontSize: 28),
                      ),
                      shape: CircleBorder(),
                      onPressed: () {
                        setState(() {
                          ex.weight = decrementWeight(ex.weight);
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
                        style: TextStyle(color: Colors.white, fontSize: getWeightFontSize(setType), fontWeight: FontWeight.bold)),
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
                    incrementTimer.cancel();
                  },
                  child: RaisedButton(
                      child: Text(
                        '+',
                        style: TextStyle(fontSize: 24),
                      ),
                      shape: CircleBorder(),
                      onPressed: () {
                        setState(() {
                          ex.weight = incrementWeight(ex.weight);
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
                    TextSpan(text: ex.workoutType == WorkoutType.Weight ? 'Reps: ' : 'Seconds: ', style: LabelTextStyle),
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
                          text: setsLeft[i].toString(),
                          style: TextStyle(color: Colors.white, fontSize: getSetRepFontSize(setType), fontWeight: FontWeight.bold))
                    ]),
                  ),
                ),
              ),
              Expanded(
                  child: Center(
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(text: ex.reps, style: TextStyle(color: Colors.white, fontSize: getSetRepFontSize(setType), fontWeight: FontWeight.bold))
                  ]),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  Future<bool> onWillPop() {
    return showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: Colors.white,
              elevation: 4,
              child: Container(
                height: 200,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Flexible(
                        flex: 7,
                        child: Container(
                          width: double.infinity,
                          color: Theme.of(context).primaryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'Too soon to quit.😑',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Your progress will not be saved.',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        )),
                    Flexible(
                        flex: 3,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Stay',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                ),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text(
                                  'Quit',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ));
  }

  double getWeightFontSize(SetType st) {
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

  double getSetRepFontSize(SetType st) {
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

//  Future launchURL(String ex) async {
//    var connectivity = await Connectivity().checkConnectivity();
//
//    if (connectivity == ConnectivityResult.none) {
//      _scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
//    } else {
//      String url = 'https://www.bodybuilding.com/exercises/search?query=' + ex;
//      if (await canLaunch(url)) {
//        print("can launch");
//        return launch(url, forceWebView: true);
//      } else {
//        throw 'Could not launch $url';
//      }
//    }
//  }

  Future launchURL(String ex) async {
    var connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
    } else {
      final url = Uri.encodeFull('https://www.bodybuilding.com/exercises/search?query=' + ex);
      if (await canLaunch(url)) {
        await launch(url, forceSafariVC: true, forceWebView: true);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  double incrementWeight(double weight) {
    if (weight < 1000) {
      if (weight < 20) {
        weight += 0.5;
      } else {
        weight += 1;
      }
    }
    return weight;
  }

  double decrementWeight(double weight) {
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
