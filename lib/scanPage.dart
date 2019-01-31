import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'model.dart';
import 'category.dart';
import 'database/database.dart';

class ScanPage extends StatefulWidget {
  @override
  ScanPageState createState() => new ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  String barcode = "";
  Routine _routine;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.grey[800],
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
                    color: Colors.grey[800],
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scan,
                    child: const Text('Scan QR code')),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
//                child: Text(barcode, textAlign: TextAlign.center,),
                child: _isValidRoutineJsonStr(barcode)
                    ? _getRoutineOverView(barcode)
                    : Container(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
//                child: Text(barcode, textAlign: TextAlign.center,),
                child: _isValidRoutineJsonStr(barcode)
                    ? Builder(
                        builder: (context) => RaisedButton(
                              color: Colors.grey[800],
                              textColor: Colors.white,
                              splashColor: Colors.blueGrey,
                              onPressed: () {
                                RoutinesContext.of(context)
                                    .routines
                                    .add(_routine);
                                DBProvider.db.newRoutine(_routine);
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('Added to my routines')));
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

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  bool _isValidRoutineJsonStr(String str) {
    if (str == "")
      return false;
    else if (str.startsWith('-r')) {
      return true;
    } else
      return false;
  }

  RoutineOverview _getRoutineOverView(String str) {
    _routine = Routine.fromMap(jsonDecode(str.replaceFirst('-r', '')));
    return RoutineOverview(
      routine: _routine,
    );
  }
}
