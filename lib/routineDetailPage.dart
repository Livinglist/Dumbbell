import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'database/database.dart';
import 'database/firestore.dart';
import 'main.dart';
import 'model.dart';
import 'partDetailPageWidgets.dart';
import 'partHistoryPage.dart';
import 'routineEditPage.dart';
import 'routineStepPage.dart';

class RoutineDetailPage extends StatefulWidget {
  bool isRecRoutine;

  RoutineDetailPage({Key key, this.isRecRoutine}) : super(key: key) {
    if (isRecRoutine == null) isRecRoutine = false;
  }

  @override
  State<StatefulWidget> createState() => new RoutineDetailPageState();
}

class RoutineDetailPageState extends State<RoutineDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  Routine curRoutine;
  GlobalKey globalKey = GlobalKey();
  String _dataString;
  String _routineStr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Routine> routines = RoutinesContext.of(context).routines;
    curRoutine = RoutinesContext.of(context).curRoutine;
    //_dataString = '-r' + jsonEncode(curRoutine.toMap());
    _dataString = '-r' + FirestoreHelper.generateId(curRoutine);
    _routineStr = json.encode(curRoutine.toMap());
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: widget.isRecRoutine ? 180 : 280.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      centerTitle: true,
                      title: Text(
                          mainTargetedBodyPartToStringConverter(
                              curRoutine.mainTargetedBodyPart),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          )),
                      background: Padding(
                        padding: EdgeInsets.only(
                            top: 72, bottom: 0, left: 48, right: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(curRoutine.routineName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontFamily: 'Staa',
                                    color: Colors.white,
                                    fontSize:
                                    _getFontSize(curRoutine.routineName),
                                  )),
                            ),
                            widget.isRecRoutine
                                ? Container()
                                : Text(
                              'You have done this workout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                            widget.isRecRoutine
                                ? Container()
                                : Text(
                              curRoutine.completionCount.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 36, color: Colors.white),
                            ),
                            widget.isRecRoutine
                                ? Container()
                                : Text(
                              'times',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                            widget.isRecRoutine
                                ? Container()
                                : Text(
                              'since',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                            widget.isRecRoutine
                                ? Container()
                                : Text(
                              '${curRoutine.createdDate
                                  .toString()
                                  .split(' ')
                                  .first}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      )),
                  actions: widget.isRecRoutine
                      ? <Widget>[]
                      : <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () async {
                        ///update the database
                        Firestore.instance
                            .collection("userShares")
                            .document(_dataString.replaceFirst("-r", ""))
                            .setData({
                          "id": _dataString.replaceFirst("-r", ""),
                          "routine": jsonEncode(curRoutine.toMap())
                        });

//                               await Firestore.instance.collection("userShares").add({
//                                "id": _dataString.replaceFirst("-r", ""),
//                                "routine":json.encode(Routine.copyFromRoutineWithoutHistory(curRoutine).toMap())
//                              });

//                              Firestore.instance.runTransaction((transaction) async {
//                                DocumentSnapshot freshSnap = await transaction.get(Firestore.instance.collection("userShares").document("test2"));
//
//
//                                await transaction.update(freshSnap.reference, {
//                                  "id": _dataString.replaceFirst("-r", ""),
//                                  "routine":json.encode(curRoutine.toMap())
//                                });
//
//
//                              });

                        ///show qr code
                        showDialog(
                            context: context,
                            builder: (context) =>
                                Dialog(
                                  child: Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Center(
                                            child: RepaintBoundary(
                                              key: globalKey,
                                              child: QrImage(
                                                data: _dataString,
                                                //TODO: generete the string for sharing routine
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
                                            mainAxisSize:
                                            MainAxisSize.min,
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
                          IconButton(
                            icon: Icon(Icons.calendar_view_day),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (buildContext) {
                                    return ModalBottomSheet(
                                      curRoutine.weekdays,
                                      checkedCallback: _updateWorkWeekdays,
                                    );
                                  });
                            },
                          ),
                    Builder(
                      builder: (context) =>
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              //Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          RoutineEditPage(
                                            addOrEdit: AddOrEdit.Edit,
                                          )));
                            },
                          ),
                    )
                  ],
                )
              ];
            },
            body: SingleChildScrollView(
              child: _columnBuilder(),
            )),
        floatingActionButton: widget.isRecRoutine
            ? Builder(
          builder: (context) =>
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.blueGrey[700],
                    heroTag: null,
                    onPressed: () {
                      routines.add(curRoutine);
                      DBProvider.db.newRoutine(curRoutine);
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
                    icon: Icon(Icons.add),
                    label: Text('Add to my routines')),
              ),
        )
            : Builder(
          builder: (context) =>
              FloatingActionButton.extended(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Start this routine'),
                  backgroundColor: curRoutine.parts.isEmpty
                      ? Colors.grey[400]
                      : Colors.blue,
                  onPressed: () {
                    setState(() {
                      if (curRoutine.parts.isEmpty) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.yellow,
                          content: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.report,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "No exercises found.",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ));
                      } else {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) {
                              return RoutineStepPage(
                                  celebrateCallback: _showCelebrateDialog);
                            }));
                      }
                    });
                  }),
        ));
  }

  void _updateWorkWeekdays(List<int> checkedWeekdays) {
    curRoutine.weekdays.clear();
    curRoutine.weekdays.addAll(checkedWeekdays);
    DBProvider.db.updateRoutine(curRoutine);
  }

  void _showSyncFailSnackbar() {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.yellow,
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(
              Icons.report,
              color: Colors.black,
            ),
          ),
          Text(
            "SYNC FAILED DUE TO NETWORK CONNECTION",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    ));
  }

  Future<void> _showCelebrateDialog() async {
    final String tempDateStr = dateTimeToStringConverter(DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day));

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      _showSyncFailSnackbar();
    } else {
      ///update user data if signed in
      if (currentUser != null) {
        await FirestoreHelper().handleUpload(
            RoutinesContext
                .of(context)
                .routines, failCallback: () {
          _showSyncFailSnackbar();
        });
      }

      ///get the dailyData
      if (dailyRank == 0) {
        var db = Firestore.instance;
        var snapshot =
        await db.collection("dailyData").document(tempDateStr).get();

        if (snapshot.exists) {
          snapshot.reference
              .setData({"totalCount": snapshot["totalCount"] + 1});
          dailyRank = snapshot["totalCount"] + 1;

          dailyRankInfo =
              DateTime.now().toUtc().toString() + '/' + dailyRank.toString();
          setDailyRankInfo(dailyRankInfo);
        } else {
          var res = await db
              .collection("dailyData")
              .document(tempDateStr)
              .setData({"totalCount": 1});
          dailyRankInfo =
              DateTime.now().toUtc().toString() + '/' + dailyRank.toString();
          setDailyRankInfo(dailyRankInfo);
        }
      }
    }

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
            child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.orange,
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 20.0,
                    )
                    ]),
                child: Padding(padding: EdgeInsets.all(8),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Well done!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "+1",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ))
            ));
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _columnBuilder() {
    List<Widget> _exerciseDetails = <Widget>[];
    //_exerciseDetails.add(RoutineDescriptionCard(routine: curRoutine));
    _exerciseDetails.addAll(curRoutine.parts.map((part) =>
        Builder(
          builder: (context) =>
              PartCard(
                onDelete: () {},
                onPartTap: widget.isRecRoutine
                    ? () {}
                    : () =>
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PartHistoryPage(part))),
                part: part,
              ),
        )));
    _exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));

    return new Column(children: _exerciseDetails);
  }

  double _getFontSize(String str) {
    if (str.length > 56) {
      return 14;
    } else if (str.length > 17) {
      return 16;
    } else {
      return 24;
    }
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

typedef void WeekdaysCheckedCallback(List<int> selectedWeekdays);

class ModalBottomSheet extends StatefulWidget {
  final List<int> checkedWeekDays;
  WeekdaysCheckedCallback checkedCallback;

  ModalBottomSheet(this.checkedWeekDays, {this.checkedCallback});

  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet>
    with SingleTickerProviderStateMixin {
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<IconData> weekDayIcons = [
    Icons.looks_one,
    Icons.looks_two,
    Icons.looks_3,
    Icons.looks_4,
    Icons.looks_5,
    Icons.looks_6,
    Icons.looks
  ];
  final List<bool> _isCheckedList = List<bool>(7);
  var heightOfModalBottomSheet = 100.0;

  @override
  void initState() {
    for (int i = 1; i <= 7; i++) {
      if (widget.checkedWeekDays.contains(i))
        _isCheckedList[i - 1] = true;
      else
        _isCheckedList[i - 1] = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (buildContext, index) {
                  if (index == 0) return Container();
                  return Divider();
                },
                itemBuilder: (buildContext, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: const Text('Choose weekday(s) for this routine'),
                    );
                  }
                  index = index - 1;
                  return CheckboxListTile(
                    title: Text(weekDays[index]),
                    value: _isCheckedList[index],
                    onChanged: (val) {
                      setState(() {
                        _isCheckedList[index] = val;
                        _returnCheckedWeekdays();
                      });
                    },
                    secondary: Icon(weekDayIcons[index]),
                  );
                })));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _returnCheckedWeekdays() {
    List<int> selectedWeekdays = List<int>();
    for (int i = 0; i < _isCheckedList.length; i++) {
      if (_isCheckedList[i]) {
        selectedWeekdays.add(i + 1);
      }
    }
    widget.checkedCallback(selectedWeekdays);
  }
}
