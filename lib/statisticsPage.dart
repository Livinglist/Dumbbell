import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chart.dart';
import 'main.dart';
import 'model.dart';

//import 'package:googleapis/sheets/v4.dart';
//import 'package:googleapis_auth/auth_io.dart';


const String API_KEY = "AIzaSyAmlHXgh8yL823yam0Cwo060R01L7YDFeU";
const TextStyle DefaultTextStyle = TextStyle(color: Colors.white);

class StatisticsPageState extends State<StatisticsPage> {
  DateTime _currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: _mainLayout(),
    );
  }

  Widget _mainLayout() {
    var routines = RoutinesContext.of(context).routines;
    var totalCount =
    StatisticsPageHelper.getTotalWorkoutCount(routines).toString();
    return GridView.count(
      crossAxisCount: 2,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme
                  .of(context)
                  .primaryColor,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 4, bottom: 4),
                      child: Text(
                        'You have been using this app since ' + firstRunDate,
                        style: DefaultTextStyle,
                      ), //_buildExerciseListView(_part)
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
              color: Theme
                  .of(context)
                  .primaryColor,
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
                              text: totalCount,
                              style:
                              TextStyle(fontSize: _getFontSize(totalCount)))
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
              color: Theme
                  .of(context)
                  .primaryColor,
              child: Center(
                child: DonutAutoLabelChart(routines),
              )),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Theme
                  .of(context)
                  .primaryColor,
              child: Center(
                child: CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 13.0,
                  animation: true,
                  percent: 0.7,
                  center: new Text(
                    "70.0%",
                    style:
                    new TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white),
                  ),
                  header: new Text(
                    "Goal of this week",
                    style:
                    new TextStyle(fontWeight: FontWeight.bold,
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

  Future<String> _getFirstRunDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(FirstRunDateKey) ?? 'damn';
  }

  double _getFontSize(String displayText) {
    if (displayText.length <= 2)
      return 120;
    else
      return 72;
  }

//  void testApi(){
//    GetSpreadsheetByDataFilterRequest byDataFilterRequest = new GetSpreadsheetByDataFilterRequest();
//    DataFilter dataFilter = new DataFilter();
//    byDataFilterRequest.dataFilters = <DataFilter>[dataFilter];
//    //ClientId clientId = new ClientId(identifier, secret);
//    //ClientId.serviceAccount(identifier);
//    //SpreadsheetsResourceApi spreadsheetsResourceApi = new SpreadsheetsResourceApi();
//    SheetsApi sheetsApi = new SheetsApi(client);
//    String spreadsheetId = "1iL0JgVD79G3bGg71D3ikXuYQDKqjf9OkwNojx6k-cp0";
//    sheetsApi.spreadsheets.get(spreadsheetId, ranges: <String>['A:A1']).then((spreadSheet){
//
//    });
//  }
}

class StatisticsPage extends StatefulWidget {
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
