import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:workout_planner/ui/components/chart.dart';
import 'package:workout_planner/main.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

const String API_KEY = "AIzaSyAmlHXgh8yL823yam0Cwo060R01L7YDFeU";
const TextStyle DefaultTextStyle = TextStyle(color: Colors.white);

class StatisticsPageState extends State<StatisticsPage> {
  double _ratio;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Statistics'),
      ),
      body: _mainLayout(),
    );
  }

  Widget _mainLayout() {
    final routines = widget.routines;
    var totalCount = StatisticsPageHelper.getTotalWorkoutCount(routines);
    _ratio = _getRatio();
    return GridView.count(
      crossAxisCount: 2,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 4, bottom: 4),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: 'You have been using this app since ' +
                              firstRunDate,
                          style: DefaultTextStyle,
                        ),
                        TextSpan(
                            text: '\n\nIt has been\n', style: DefaultTextStyle),
                        TextSpan(
                            text: DateTime.now()
                                .difference(DateTime.parse(firstRunDate))
                                .inDays
                                .toString(),
                            style: TextStyle(fontSize: 36)),
                        TextSpan(text: '\ndays', style: DefaultTextStyle),
                      ])),
//                      child: Text(
//                        'You have been using this app since ' + firstRunDate,
//                        style: DefaultTextStyle,
//                      ), //_buildExerciseListView(_part)
                    ),
                  ],
                ),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 4, bottom: 4),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(text: 'Total Completion\n'),
                          TextSpan(
                              text: totalCount.toString(),
                              style:
                                  TextStyle(fontSize: _getFontSize(totalCount.toString())))
                        ]),
                      ),
//                    child: Text(
//                      'You have completed ' + StatisticsPageHelper.getTotalWorkoutCount(routines).toString() + ' times',
//                      style: DefaultTextStyle,
//                    ), //_buildExerciseListView(_part)
                    ),
                  ],
                ),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: totalCount == 0
                    ? Container()
                    : DonutAutoLabelChart(routines),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 13.0,
                  animation: true,
                  percent: _ratio,
                  center: Text(
                    "${(_ratio * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white),
                  ),
                  header: Text(
                    "Goal of this week",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        color: Colors.white),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blue,
                ),
              )),
        )
      ],
    );
//        FutureBuilder(
//          future: _getFirstRunDate(),
//          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//            if (snapshot.hasData) {
//              return Card(
//                color: Colors.red,
//                child: Text(
//                  'You have been using this app since ' + snapshot.data,
//                  style: DefaultTextStyle,
//                ),
//              );
//            } else {
//              return Container();
//            }
//          },
//        ),
  }

  double _getRatio() {
    final routines = widget.routines;
    int totalShare = 0;
    int share = 0;

    //get the date of Monday of this week
    int weekday = DateTime.now().weekday;
    DateTime mondayDate;
    mondayDate = DateTime.now().subtract(Duration(days: weekday - 1));
    mondayDate = DateTime(mondayDate.year, mondayDate.month, mondayDate.day);

    for (var routine in routines) {
      totalShare += routine.weekdays.length;
    }

    for (var routine
        in routines.where((routine) => routine.weekdays.isNotEmpty)) {
      for (var weekday in routine.weekdays) {
        for (var dateStr in routine.routineHistory) {
          var date = DateTime.parse(dateStr);
          if (date.weekday == weekday &&
              (date.isAfter(mondayDate) || date.compareTo(mondayDate) == 0)) {
            share++;
          }
        }
      }
    }
    return totalShare == 0 ? 0 : share / totalShare;
  }

  double _getFontSize(String displayText) {
    if (displayText.length <= 2)
      return 120;
    else
      return 72;
  }
}

class StatisticsPage extends StatefulWidget {
  final List<Routine> routines;

  StatisticsPage({@required this.routines});

  @override
  State<StatefulWidget> createState() {
    return new StatisticsPageState();
  }
}

class StatisticsPageHelper {
  static int getTotalWorkoutCount(List<Routine> routines) {
    int total = 0;
    for (var i in routines) {
      total += i.completionCount;
    }
    return total;
  }
}

class Calender extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return null;
  }
}

class CalenderState extends State<Calender> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
