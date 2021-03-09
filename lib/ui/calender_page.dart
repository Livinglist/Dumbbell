import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:workout_planner/models/routine.dart';
import 'package:workout_planner/ui/components/routine_card.dart';
import 'package:workout_planner/utils/date_time_extension.dart';

class CalenderPage extends StatefulWidget {
  final List<Routine> routines;

  CalenderPage({@required this.routines});

  @override
  State<StatefulWidget> createState() => CalenderPageState();
}

class CalenderPageState extends State<CalenderPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  Map<String, Routine> dateToRoutineMap;

  @override
  void initState() {
    super.initState();

    dateToRoutineMap = getWorkoutDates(widget.routines);
  }

  void showBottomSheet(Routine routine) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Container(color: Colors.transparent, width: MediaQuery.of(context).size.width, child: RoutineCard(routine: routine)),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 13,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: buildMonthRow(),
    );
  }

  List<Widget> buildMonthRow() {
    List<Widget> widgets = List<Widget>();

    widgets.add(Text(' '));

    for (int i = 1; i <= 12; i++) {
      widgets.add(Center(child: Text(intToMonth(i), style: TextStyle(fontSize: 10, color: Colors.black))));
    }

    widgets.addAll(buildDayRows());

    return widgets;
  }

  List<Widget> buildDayRows() {
    List<Widget> widgets = List<Widget>();

    for (int i = 1; i <= 31; i++) {
      widgets.add(Center(child: Text(i.toString(), style: TextStyle(fontSize: 12, color: Colors.black))));
      for (int j = 1; j <= 12; j++) {
        DateTime date = DateTime(DateTime.now().year, j, i);
        String dateStr = date.toSimpleString();
        widgets.add(Material(
          elevation: 4,
          child: Container(
            child: GestureDetector(onTap: () {
              if (isWorkoutDay(j, i)) {
                showBottomSheet(dateToRoutineMap[dateStr]);
              }
            }),
            decoration: BoxDecoration(
                color: isWorkoutDay(j, i) ? Colors.grey : Colors.transparent,
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.grey[500], width: 0.3)),
          ),
        ));
      }
    }

    for (int i = 1; i <= 31; i++) {
      widgets.add(Container());
      for (int j = 1; j <= 1; j++) {
        widgets.add(Container());
      }
    }

    return widgets;
  }

  bool isWorkoutDay(int month, int day) {
    DateTime date = DateTime(DateTime.now().year, month, day);
    String dateStr = date.toString().split(' ').first;
    return dateToRoutineMap.keys.contains(dateStr);
  }

  String intToMonth(int i) {
    switch (i) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        throw Exception('Inside _intToMonth()');
    }
  }

  Map<String, Routine> getWorkoutDates(List<Routine> routines) {
    Map<String, Routine> dates = {};

    for (var routine in routines) {
      if (routine.routineHistory.isNotEmpty) {
        for (var timestamp in routine.routineHistory) {
          var d = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
          dates[d.toSimpleString()] = routine;
        }
      }
    }

    print(dates);
    return dates;
  }
}
