import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/ui/calender_page.dart';

import 'package:workout_planner/ui/components/chart.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

const String API_KEY = "AIzaSyAmlHXgh8yL823yam0Cwo060R01L7YDFeU";
const TextStyle defaultTextStyle = TextStyle();

class StatisticsPage extends StatefulWidget {
  StatisticsPage();

  @override
  State<StatefulWidget> createState() {
    return _StatisticsPageState();
  }
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: routinesBloc.allRoutines,
        builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverSafeArea(sliver: buildMainLayout(snapshot.data)),
                CalenderPage(routines: snapshot.data),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildMainLayout(List<Routine> routines) {
    var totalCount = getTotalWorkoutCount(routines);
    var ratio = _getRatio(routines);
    print(routines);
    print(ratio);
    return SliverGrid.count(
      crossAxisCount: 2,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: 'You have been using this app since ${firebaseProvider.firstRunDate}',
                          style: defaultTextStyle,
                        ),
                        TextSpan(text: '\n\nIt has been\n', style: defaultTextStyle),
                        TextSpan(
                            text: DateTime.now().difference(DateTime.parse(firebaseProvider.firstRunDate)).inDays.toString(),
                            style: TextStyle(fontSize: 36)),
                        TextSpan(text: '\ndays'),
                      ], style: TextStyle(fontFamily: 'Staa'))),
                    ),
                  ],
                ),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: 4, left: 8, right: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(text: 'Total Completion\n'),
                    TextSpan(text: totalCount.toString(), style: TextStyle(fontSize: getFontSize(totalCount.toString())))
                  ], style: TextStyle(fontFamily: 'Staa')),
                ),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: totalCount == 0 ? Container() : DonutAutoLabelChart(routines),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 13.0,
                  animation: true,
                  percent: ratio,
                  center: Text(
                    "${(ratio * 100).toStringAsFixed(0)}%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
                  ),
                  header: Text(
                    "Goal of this week",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.white),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.grey,
                ),
              )),
        )
      ],
    );
  }

  double _getRatio(List<Routine> routines) {
    int totalShare = 0;
    int share = 0;

    //get the date of Monday of this week
    int weekday = DateTime.now().weekday;
    DateTime mondayDate;
    mondayDate = DateTime.now().subtract(Duration(days: weekday - 1));
    mondayDate = DateTime(mondayDate.year, mondayDate.month, mondayDate.day);

    for (var routine in routines) {
      print(routine.routineName);
      print(routine.weekdays);
      totalShare += routine.weekdays.length;
    }
    print(totalShare);

    for (var routine in routines.where((routine) => routine.weekdays.isNotEmpty)) {
      for (var weekday in routine.weekdays) {
        for (int ts in routine.routineHistory) {
          var date = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
          if (date.weekday == weekday && (date.isAfter(mondayDate) || date.compareTo(mondayDate) == 0)) {
            share++;
            break;
          }
        }
      }
    }
    return totalShare == 0 ? 0 : share / totalShare;
  }

  double getFontSize(String displayText) {
    if (displayText.length <= 2)
      return 120;
    else
      return 72;
  }

  static int getTotalWorkoutCount(List<Routine> routines) {
    int total = 0;
    for (var i in routines) {
      total += i.completionCount;
    }
    return total;
  }
}
