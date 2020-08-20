import 'package:flutter/material.dart';

import 'package:workout_planner/models/routine.dart';

enum AddOrEdit { add, edit }

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
      throw Exception('Unmatched main targetedBodyPart: $targetedBodyPart');
  }
}

Color setTypeToColorConverter(SetType setType) {
  switch (setType) {
    case SetType.Regular:
      return Colors.orangeAccent;
    case SetType.Drop:
      return Colors.grey;
    case SetType.Super:
      return Colors.orange;
    case SetType.Tri:
      return Colors.deepOrange;
    case SetType.Giant:
      return Colors.red;
    default:
      return Colors.orange;
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

int getTimestampNow() {
  return DateTime.now().millisecondsSinceEpoch;
  //return dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
}

class StringHelper {
  static String weightToString(double weight) {
    if (weight - weight.truncate() != 0)
      return weight.toStringAsFixed(1);
    else
      return weight.toStringAsFixed(0);
  }
}
