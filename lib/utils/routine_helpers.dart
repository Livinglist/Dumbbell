import 'package:flutter/material.dart';

import 'package:workout_planner/models/routine.dart';

enum AddOrEdit { add, edit }

Color mainTargetedBodyPartToColorConverter(MainTargetedBodyPart mainTB) {
  switch (mainTB) {
    case MainTargetedBodyPart.Abs:
      return Color(0xff8E24AA);
    case MainTargetedBodyPart.Arm:
      return Color(0xff64B5F6);
    case MainTargetedBodyPart.Back:
      return Color(0xff29B6F6);
    case MainTargetedBodyPart.Chest:
      return Color(0xff0097A7);
    case MainTargetedBodyPart.Leg:
      return Color(0xff00BFA5);
    case MainTargetedBodyPart.Shoulder:
      return Color(0xff00C853);
    case MainTargetedBodyPart.FullBody:
      return Color(0xffD84315);
    default:
      throw Exception('Inside of mainTargetedBodyPartToColorConverter ' + mainTB.toString());
  }
  //return <Color>[Colors.grey[600], Colors.grey[700]];
}

String mainTargetedBodyPartToStringConverter(MainTargetedBodyPart targetedBodyPart) {
  switch (targetedBodyPart) {
    case MainTargetedBodyPart.Abs:
      return 'Abs';
    case MainTargetedBodyPart.Arm:
      return 'Arms';
    case MainTargetedBodyPart.Back:
      return 'Back';
    case MainTargetedBodyPart.Chest:
      return 'Chest';
    case MainTargetedBodyPart.Leg:
      return 'Legs';
    case MainTargetedBodyPart.Shoulder:
      return 'Shoulders';
    case MainTargetedBodyPart.FullBody:
      return 'Full Body';
    default:
      throw Exception;
  }
}

Color setTypeToColorConverter(SetType setType) {
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

String targetedBodyPartToStringConverter(TargetedBodyPart targetedBodyPart) {
  switch (targetedBodyPart) {
    case TargetedBodyPart.Abs:
      return 'Abs';
    case TargetedBodyPart.Arm:
      return 'Arms';
    case TargetedBodyPart.Back:
      return 'Back';
    case TargetedBodyPart.Chest:
      return 'Chest';
    case TargetedBodyPart.Leg:
      return 'Legs';
    case TargetedBodyPart.Shoulder:
      return 'Shoulders';
    case TargetedBodyPart.Tricep:
      return 'Triceps';
    case TargetedBodyPart.Bicep:
      return 'Biceps';
    case TargetedBodyPart.FullBody:
      return 'Full Body';
    default:
      throw Exception;
  }
}

String setTypeToStringConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return 'Regular Sets';
    case SetType.Drop:
      return 'Drop Sets';
    case SetType.Super:
      return 'Supersets';
    case SetType.Tri:
      return 'Tri-sets';
    case SetType.Giant:
      return 'Giant sets';
    default:
      throw Exception;
  }
}

int setTypeToExerciseCountConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return 1;
    case SetType.Drop:
      return 1;
    case SetType.Super:
      return 2;
    case SetType.Tri:
      return 3;
    case SetType.Giant:
      return 4;
    default:
      throw Exception('setTypeToExerciseCountConverter(), setType is ' + setType.toString());
  }
}

Widget targetedBodyPartToImageConverter(TargetedBodyPart targetedBodyPart) {
  double scale = 30;
  switch (targetedBodyPart) {
    case TargetedBodyPart.Abs:
      return Image.asset(
        'assets/abs-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Arm:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Back:
      return Image.asset(
        'assets/back-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Chest:
      return Image.asset(
        'assets/chest-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Leg:
      return Image.asset(
        'assets/leg-96.png',
        scale: scale,
      );
    case TargetedBodyPart.Shoulder:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
    default:
      return Image.asset(
        'assets/muscle-96.png',
        scale: scale,
      );
  }
}

String getTodayDate() {
  return dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
}

//class RoutinesContext extends InheritedWidget {
//  List<Routine> _routines;
//
//  List<Routine> get routines => _routines;
//
//  set routines(List<Routine> routines) {
//    _routines = routines;
//  }
//
//  List<Routine> _recRoutines;
//
//  List<Routine> get recRoutines => _recRoutines;
//
//  set recRoutines(List<Routine> routines) {
//    _recRoutines = routines;
//  }
//
//  Routine _curRoutine;
//  Routine get curRoutine => _curRoutine;
//
//  set curRoutine(Routine routine) {
//    _curRoutine = routine;
//  }
//
//  Future<List<Routine>> getAllRoutines() async {
//    return DBProvider.db.getAllRoutines();
//  }
//
//  Future<List<Routine>> getAllRecRoutines() async {
//    return DBProvider.db.getAllRecRoutines();
//  }
//
//  RoutinesContext._({
//    //@required this.routines,
//    Key key,
//    Widget child,
//  }) : super(key: key, child: child);
//
//  static Widget around(Widget child, {Key key}) {
//    return _RoutinesContextWrapper(
//      child: child,
//      key: key,
//    );
//  }
//
//  static RoutinesContext of(BuildContext context) {
//    return context.inheritFromWidgetOfExactType(RoutinesContext);
//  }
//
//  @override
//  bool updateShouldNotify(RoutinesContext oldWidget) {
//    return true;
//  }
//}
//
//class _RoutinesContextWrapper extends StatefulWidget {
//  final Widget child;
//
//  _RoutinesContextWrapper({Key key, this.child}) : super(key: key);
//
//  @override
//  State<StatefulWidget> createState() => _RoutinesContextWrapperState();
//}
//
//class _RoutinesContextWrapperState extends State<_RoutinesContextWrapper> {
//  List<Routine> routines = new List<Routine>();
//  String _error;
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return RoutinesContext._(
//      //routines: routines,
//      child: widget.child,
//    );
//  }
//}

class StringHelper {
  static String weightToString(double weight) {
    if (weight - weight.truncate() != 0)
      return weight.toStringAsFixed(1);
    else
      return weight.toStringAsFixed(0);
  }
}
