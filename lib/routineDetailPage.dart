import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'model.dart';
import 'partDetailPageWidgets.dart';
import 'routineEditPage.dart';
import 'routineStepPage.dart';
import 'database/database.dart';
//import 'package:esys_flutter_share/esys_flutter_share.dart';

class RoutineDetailPage extends StatefulWidget {
  bool isRecRoutine;

  RoutineDetailPage({Key key, this.isRecRoutine}) : super(key: key) {
    if (isRecRoutine == null) isRecRoutine = false;
  }

  @override
  State<StatefulWidget> createState() => new RoutineDetailPageState();
}

class RoutineDetailPageState extends State<RoutineDetailPage> {
  Routine curRoutine;
  GlobalKey globalKey = new GlobalKey();
  ScrollController _scrollController = new ScrollController();
  String _dataString;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final List<Routine> routines = RoutinesContext.of(context).routines;
    curRoutine = RoutinesContext.of(context).curRoutine;
    _dataString = '-r' + jsonEncode(curRoutine.toMap());
    return Scaffold(
      appBar: AppBar(
        title: Text('Routine Overview'),
        backgroundColor: Colors.grey[800],
        actions: widget.isRecRoutine
            ? <Widget>[]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Center(
                                        child: RepaintBoundary(
                                      key: globalKey,
                                      child: QrImage(
                                        data: _dataString,
                                        size: 300,
                                        version: 35,
                                        onError: (ex) {
                                          print("[QR] ERROR - $ex");
                                          setState(() {});
                                        },
                                      ),
                                    )),
                                    Center(
                                      child: ButtonBar(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          RaisedButton(
                                            child: Text('Save'),
                                            onPressed: null,
                                          ),
                                          RaisedButton(
                                              child: Text('Send'),
                                              onPressed: () {})
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                  },
                ),
                Builder(
                  builder: (context) => IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          //Navigator.pop(context);
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => RoutineEditPage(
                                        addOrEdit: AddOrEdit.Edit,
                                      )));
                        },
                      ),
                )
              ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: _columnBuilder(),
      ),
      floatingActionButton: widget.isRecRoutine
          ? Builder(
              builder: (context) => Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: FloatingActionButton.extended(
                        backgroundColor: Colors.grey[800],
                        heroTag: null,
                        onPressed: () {
                          routines.add(curRoutine);
                          DBProvider.db.newRoutine(curRoutine);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Added to my routines.'),
                          ));
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add to my routines')),
                  ),
            )
          : FloatingActionButton.extended(
              icon: Icon(Icons.play_arrow),
              label: Text('Start this routine'),
              onPressed: () {
                setState(() {
                  //routine.completionCount++;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return RoutineStepPage();
                  }));
                });
              }),
    );
  }

  Widget _columnBuilder() {
    List<Widget> _exerciseDetails = <Widget>[];
    _exerciseDetails.add(RoutineDescriptionCard(routine: curRoutine));
    _exerciseDetails.addAll(curRoutine.parts.map((part) => Builder(
          builder: (context) => PartCard(
                onDelete: () {},
                onPartTap: () {
                  showGeneralDialog(
                      context: context,
                      pageBuilder: (BuildContext buildContext, Animation<double> animation,
                          Animation<double> secondaryAnimation) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 72, horizontal: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(8))),
                          color: Colors.grey[600],
                          child: Column(
                            children: <Widget>[],
                          ),
                        ),
                      ),
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                    barrierColor: Colors.black87,
                    transitionDuration: const Duration(milliseconds: 200),
                  );
                },
                part: part,
              ),
        )));
    _exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));

    return new Column(children: _exerciseDetails);
  }

//  Future<void> _captureAndSharePng() async {
//    try {
//      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
//      var image = await boundary.toImage();
//      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//      Uint8List pngBytes = byteData.buffer.asUint8List();
//
//      final tempDir = await getTemporaryDirectory();
//      final file = await new File('${tempDir.path}/image.png').create();
//      await file.writeAsBytes(pngBytes);
//
//      //final channel = const MethodChannel('channel:me.alfian.share/share');
//      //channel.invokeMethod('shareFile', 'image.png');
//
//      await EsysFlutterShare.shareImage('myImageTest.png', byteData, 'my image title');
//
//    } catch(e) {
//      print(e.toString());
//    }
//  }

//  Future _shareImage() async {
//    try {
//      final ByteData bytes = await rootBundle.load('assets/abs-96.png');
//      await EsysFlutterShare.shareImage(
//          'myImageTest.png', bytes, 'my image title');
//    } catch (e) {
//      print('error: $e');
//    }
//  }

}

//------------------------------Abandoned---------------------------------

class WorkoutCount extends StatelessWidget {
  WorkoutCount({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Material(
        //elevation: 10,
/*      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(50)
      ),*/
        //shape: new CircleBorder(side: new BorderSide(color: Colors.yellow)),
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.transparent),
            borderRadius: new BorderRadius.circular(10)),
        color: Colors.green,
        elevation: 3,
        child: Ink(
          //width: 100,
          /*decoration: new BoxDecoration(
            color: Colors.green,
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(40.0),
                topRight: const Radius.circular(40.0))
        ),*/
          color: Colors.transparent,
          height: 150,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              borderRadius: new BorderRadius.circular(10),
              highlightColor: Colors.green,
              splashColor: Colors.green,
              // We can use either the () => function() or the () { function(); }
              // syntax.
              child: Padding(
                padding:
                    EdgeInsets.only(left: 30, top: 12, right: 0, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('Plan name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 0.5,
                              color: Colors.black38,
                            ),
                          ],
                        )
                        /*DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: 2, color: Colors.white),*/
                        ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 80, top: 0, right: 0, bottom: 0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '13',
                              style:
                                  TextStyle(fontSize: 72, color: Colors.white),
                            ),
                            Text(
                              'completion counts',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
