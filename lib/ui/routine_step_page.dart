import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:workout_planner/ui/components//custom_snack_bars.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

/// Note:
/// Some really bad design decision made in the early stage of this project has led to this incredibly messy code.

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
  final ConfettiController confettiController = ConfettiController(duration: Duration(seconds: 10));
  final timerDuration = Duration(milliseconds: 50);
  var stepperKey = GlobalKey();

  List<Exercise> exercises;
  bool finished = false,initialized = false;
  
  Routine routine;
  String title;
  
  Timer incrementTimer;
  Timer decrementTimer;

  List<int> setsLeft = [];
  List<int> currentPartIndexes = [];
  List<int> stepperIndexes = [];
  int currentStep = 0;

  var timeout = const Duration(seconds: 1);
  var ms = const Duration(milliseconds: 1);

  @override
  void initState() {
    super.initState();
    routine = Routine.copyFromRoutine(widget.routine);

    String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    for (var part in routine.parts) {

      for (var ex in part.exercises) {
        if (ex.exHistory.containsKey(tempDateStr)) {
          ex.exHistory.remove(tempDateStr);
        }
      }
    }

    exercises = widget.routine.parts.expand((p) => p.exercises).toList();
    generateStepperIndexes();
  }

  @override
  Widget build(BuildContext context) {
    title = currentStep < stepperIndexes.length
        ? targetedBodyPartToStringConverter(routine.parts[currentPartIndexes[currentStep]].targetedBodyPart) +
            ' - ' +
            setTypeToStringConverter(routine.parts[currentPartIndexes[currentStep]].setType)
        : 'Finished!';


    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(color: Colors.white54),
            ),
            bottom: PreferredSize(
                child: LinearProgressIndicator(
                  value: currentStep / stepperIndexes.length,
                ),
                preferredSize: Size.fromHeight(12)),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          body: buildMainLayout(),
        ));
  }

  Widget buildMainLayout() {
    if (!finished) {
      return buildStepper(exercises);
    }

    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).primaryColor,
          child: Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Text(
              'You finished it!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
            false, // start again as soon as the animation is finished
            blastDirection: 3.14 / 2,
            maxBlastForce: 8, // set a lower max blast force
            minBlastForce: 4, // set a lower min blast force
            emissionFrequency: 0.05,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
             // define a custom shape/path.
          ),
        ),

      ],
    );
  }

  void generateStepperIndexes() {
    var parts = widget.routine.parts;
    var indexes = <int>[];

    for (int i = 0, k = 0; k < parts.length; k++) {
      var part = parts[k];
      var ex = exercises[i];
      var sets = ex.sets;
      switch (part.setType) {
        case SetType.Drop:
          for (var j = 0; j < sets; j++) {
            indexes.add(i);
            currentPartIndexes.add(k);
            setsLeft.add(sets - j);
          }
          i += 1;
          break;
        case SetType.Regular:
          for (var j = 0; j < ex.sets; j++) {
            indexes.add(i);
            currentPartIndexes.add(k);
            setsLeft.add(sets-j);
          }
          i += 1;
          break;
        case SetType.Super:
          for (var j = 0; j < ex.sets; j++) {
            indexes.add(i);
            indexes.add(i + 1);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
          }
          i += 2;
          break;
        case SetType.Tri:
          for (var j = 0; j < ex.sets; j++) {
            indexes.add(i);
            indexes.add(i + 1);
            indexes.add(i + 2);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
          }
          i += 3;
          break;
        case SetType.Giant:
          for (var j = 0; j < ex.sets; j++) {
            indexes.add(i);
            indexes.add(i + 1);
            indexes.add(i + 2);
            indexes.add(i + 3);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            currentPartIndexes.add(k);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
            setsLeft.add(sets-j);
          }
          i += 4;
          break;
      }
    }

    stepperIndexes = indexes;
  }

  void updateExHistory() {
    String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    var partIndex = currentPartIndexes[currentStep];
    var exIndex = routine.parts[partIndex].exercises.indexWhere((e) => e.name == exercises[stepperIndexes[currentStep]].name);

    if (routine.parts[partIndex].exercises[exIndex].exHistory.containsKey(tempDateStr)) {
      routine.parts[partIndex].exercises[exIndex].exHistory[tempDateStr] += '/' + routine.parts[partIndex].exercises[exIndex].weight.toString();
    } else {
      routine.parts[partIndex].exercises[exIndex].exHistory[tempDateStr] = routine.parts[partIndex].exercises[exIndex].weight.toString();
    }
  }

  Widget buildStepper(List<Exercise> exs) {
    return SingleChildScrollView(
      child: Stepper(
        key: stepperKey,
        physics: NeverScrollableScrollPhysics(),
        controlsBuilder: (context, {onStepContinue, onStepCancel}) {
          return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
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
        currentStep: stepperIndexes[currentStep],
        onStepContinue: () {
          if (!finished && currentStep < stepperIndexes.length - 1) {
            setState(() {
              currentStep += 1;
            });
            updateExHistory();
          }else{
            setState(() {
              finished = true;
              currentStep += 1;
            });
            confettiController.play();
            routine.completionCount++;
            if (!routine.routineHistory.contains(getTimestampNow())) {
                    routine.routineHistory.add(getTimestampNow());
            }

            routinesBloc.updateRoutine(routine);
          }
        },
        steps: List.generate(exs.length, (index) => index)
            .map((i){
              var isCurrent = i == stepperIndexes[currentStep];

              return Step(
                title: Text(
                  exs[i].name,
                  style: TextStyle(fontSize: isCurrent? 24:16, fontWeight: FontWeight.w300, color: isCurrent ? Colors.white: Colors.black),
                ),
                content: buildStep(exs[i]),
              );
        })
            .toList(),
        // steps: exs
        //     .map((ex) => Step(
        //   title: Text(
        //     ex.name,
        //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        //   ),
        //   content: buildStep(ex),
        // ))
        //     .toList(),
      ),
    );
  }

  Widget buildStep(Exercise ex) {
    var setType = widget.routine.parts[currentPartIndexes[currentStep]].setType;
    var partIndex = currentPartIndexes[currentStep];
    var exIndex = routine.parts[partIndex].exercises.indexWhere((e) => e.name == exercises[stepperIndexes[currentStep]].name);
    var ex = routine.parts[partIndex].exercises[exIndex];
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
                launchURL(ex.name);
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
                    decreaseWeight(ex);
                  },
                  onLongPressUp: () {
                    decrementTimer.cancel();
                  },
                  child: ElevatedButton(
                      child: Text(
                        '-',
                        style: TextStyle(fontSize: 28),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
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
                        style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: GestureDetector(
                  onLongPress: () {
                    increaseWeight(ex);
                  },
                  onLongPressUp: () {
                    incrementTimer.cancel();
                  },
                  child: ElevatedButton(
                      child: Text(
                        '+',
                        style: TextStyle(fontSize: 24),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
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
                          text: setsLeft[currentStep].toString(),
                          style: TextStyle(color: Colors.white, fontSize: getSetRepFontSize(setType), fontWeight: FontWeight.bold))
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
                        style: TextStyle(color: Colors.white, fontSize: getSetRepFontSize(setType), fontWeight: FontWeight.bold))
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
    if(finished) return Future.value(true);
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
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Stay',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                ),
                              ),
                              TextButton(
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

  void decreaseWeight(Exercise ex) {
    decrementTimer = Timer.periodic(timerDuration, (Timer t) {
      setState(() {
        ex.weight = decrementWeight(ex.weight);
      });
    });
  }

  void increaseWeight(Exercise ex) {
    incrementTimer = Timer.periodic(timerDuration, (Timer t) {
      setState(() {
        ex.weight = incrementWeight(ex.weight);
      });
    });
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

  Future launchURL(String ex) async {
    var connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(noNetworkSnackBar);
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
