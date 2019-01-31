import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'main.dart';
import 'model.dart';

const String API_KEY = "AIzaSyAmlHXgh8yL823yam0Cwo060R01L7YDFeU";
const TextStyle DefaultTextStyle = TextStyle(color: Colors.white);

class StatisticsPageState extends State<StatisticsPage> {
  DateTime _currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: Colors.grey[800],
      ),
      body: _mainLayout(),
    );
  }

  Widget _mainLayout() {
    var routines = RoutinesContext.of(context).routines;
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 6, bottom: 3, left: 8, right: 8),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
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
          padding: EdgeInsets.only(top: 3, bottom: 3, left: 8, right: 8),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              elevation: 12,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 4, bottom: 4),
                      child: Text(
                        'You have completed ' + StatisticsPageHelper.getTotalWorkoutCount(routines).toString() + ' times',
                        style: DefaultTextStyle,
                      ), //_buildExerciseListView(_part)
                    ),
                  ],
                ),
              )),
        ),
        FutureBuilder(
          future: _getFirstRunDate(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Card(
                color: Colors.red,
                child: Text(
                  'You have been using this app since ' + snapshot.data,
                  style: DefaultTextStyle,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  Future<String> _getFirstRunDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(FirstRunDateKey) ?? 'damn';
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

class StatisticsPageHelper{
  static int getTotalWorkoutCount(List<Routine> routines){
    int total = 0;
    for(var i in routines){
      total += i.completionCount;
    }
    return total;
  }
}
