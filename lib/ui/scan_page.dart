import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

import 'package:workout_planner/ui/routine_overview_card.dart';
import 'package:workout_planner/resource/db_provider.dart';
import 'components//custom_snack_bars.dart';
import 'package:workout_planner/models/routine.dart';

class ScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  String barcode = "";
  Routine routine;

  @override
  initState() {
    textEditingController.addListener((){

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: new Text('Scan'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  color: Colors.blueGrey,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: input,
                    child: Text('Enter routine ID')),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  color: Colors.blueGrey,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scan,
                    child: Text('Scan QR code')),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
                child: isValidRoutineJsonStr(barcode)
                    ? FutureBuilder(
                        future: getRoutineOverView(barcode),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data as RoutineOverview;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : Container(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                child: isValidRoutineJsonStr(barcode)
                    ? Builder(
                        builder: (context) => RaisedButton(
                          color: Colors.blueGrey,
                              textColor: Colors.white,
                              splashColor: Colors.blueGrey,
                              onPressed: () {
                                DBProvider.db.newRoutine(routine);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.done),
                                    ),
                                    Text('Added to my routines.'),
                                  ],
                                )));
                              },
                              child: const Text('Add to my routines'),
                            ),
                      )
                    : Container(),
              ),
            ],
          ),
        ));
  }

  Future input() async{
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
    } else {
      showDialog(
          context: context, builder: (_){
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  onSubmitted: (str){
                    Navigator.pop(context);
                    setState(() {
                      barcode = '-r'+str;
                    });
                  },
                  controller: textEditingController,
                  decoration: InputDecoration(hintText: 'Routine ID'),
                ),
              ),
            ),
          ),
        );
      });
    }
  }

  Future scan() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
    } else {
      QRCodeReader().scan().then((str) {
        setState(() {
          barcode = str;
        });
      });
    }
  }

  bool isValidRoutineJsonStr(String str) {
    if (str == "" || str == null)
      return false;
    else if (str.startsWith('-r')) {
      return true;
    } else
      return false;
  }

  Future<RoutineOverview> getRoutineOverView(String str) async {
    var snapshot = await Firestore.instance
        .collection("userShares")
        .document(barcode.replaceFirst("-r", ""))
        .get();
    String routineStr = snapshot['routine'];
    routine = Routine.fromMap(jsonDecode(routineStr.replaceFirst('-r', '')));
    return RoutineOverview(
      routine: routine,
    );
  }
}
