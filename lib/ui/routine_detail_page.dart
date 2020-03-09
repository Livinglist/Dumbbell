import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'package:workout_planner/resource/db_provider.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
import 'package:workout_planner/main.dart';
import 'package:workout_planner/utils/routine_helpers.dart';
import 'package:workout_planner/ui/components/part_detail_page_widgets.dart';
import 'package:workout_planner/ui/part_history_page.dart';
import 'package:workout_planner/ui/routine_edit_page.dart';
import 'package:workout_planner/ui/routine_step_page.dart';
import 'package:workout_planner/ui/components//custom_snack_bars.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class RoutineDetailPage extends StatefulWidget {
  final bool isRecRoutine;

  RoutineDetailPage({Key key, this.isRecRoutine = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();

  GlobalKey globalKey = GlobalKey();
  String dataString;
  Routine routine;

  @override
  void initState() {
    dataString = '-r' + FirebaseProvider.generateId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final List<Routine> routines = RoutinesContext.of(context).routines;
    //routine = RoutinesContext.of(context).curRoutine;
    //_dataString = '-r' + jsonEncode(routine.toMap());

    return StreamBuilder(
      stream: routinesBloc.currentRoutine,
      builder: (_, AsyncSnapshot<Routine> snapshot) {
        if (snapshot.hasData) {
          routine = snapshot.data;
          return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: _buildBodyForIOS(),
              floatingActionButton: widget.isRecRoutine
                  ? Builder(
                      builder: (context) => Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: FloatingActionButton.extended(
                                backgroundColor: Colors.deepOrange,
                                heroTag: null,
                                onPressed: () {
//                            routines.add(routine);
//                            DBProvider.db.newRoutine(routine);
                                  routinesBloc.addRoutine(routine);
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
                      builder: (context) => FloatingActionButton.extended(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Start this routine', style: TextStyle(fontFamily: 'Staa'),),
                          backgroundColor: routine.parts.isEmpty ? Colors.grey[400] : Colors.deepOrange,
                          onPressed: () {
                            setState(() {
                              if (routine.parts.isEmpty) {
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
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return RoutineStepPage(routine: routine, celebrateCallback: showCelebrateDialog);
                                }));
                              }
                            });
                          }),
                    ));
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildBodyForAndroid() {
    return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: widget.isRecRoutine ? 180 : 280.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                  title: Text(mainTargetedBodyPartToStringConverter(routine.mainTargetedBodyPart),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Padding(
                    padding: EdgeInsets.only(top: 72, bottom: 0, left: 48, right: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(routine.routineName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              softWrap: true,
                              style: TextStyle(
                                fontFamily: 'Staa',
                                color: Colors.white,
                                fontSize: getFontSize(routine.routineName),
                              )),
                        ),
                        widget.isRecRoutine
                            ? Container()
                            : Text(
                                'You have done this workout',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                        widget.isRecRoutine
                            ? Container()
                            : Text(
                                routine.completionCount.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 36, color: Colors.white),
                              ),
                        widget.isRecRoutine
                            ? Container()
                            : Text(
                                'times',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                        widget.isRecRoutine
                            ? Container()
                            : Text(
                                'since',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                        widget.isRecRoutine
                            ? Container()
                            : Text(
                                '${routine.createdDate.toString().split(' ').first}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                      ],
                    ),
                  )),
              actions: widget.isRecRoutine
                  ? <Widget>[]
                  : <Widget>[
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: onSharePressed,
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_view_day),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (buildContext) {
                                return ModalBottomSheet(
                                  routine.weekdays,
                                  checkedCallback: updateWorkWeekdays,
                                );
                              });
                        },
                      ),
                      Builder(
                        builder: (context) => IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                //Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RoutineEditPage(
                                              addOrEdit: AddOrEdit.edit,
                                          mainTargetedBodyPart: routine.mainTargetedBodyPart,
                                            )));
                              },
                            ),
                      )
                    ],
            )
          ];
        },
        body: SingleChildScrollView(
          child: columnBuilderForAndroid(),
        ));
  }

  Widget _buildBodyForIOS() {
    return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: true,
              actions: widget.isRecRoutine
                  ? <Widget>[]
                  : <Widget>[
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: onSharePressed,
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_view_day),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (buildContext) {
                                return ModalBottomSheet(
                                  routine.weekdays,
                                  checkedCallback: updateWorkWeekdays,
                                );
                              });
                        },
                      ),
                      Builder(
                        builder: (context) => IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                //Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RoutineEditPage(
                                              addOrEdit: AddOrEdit.edit,
                                          mainTargetedBodyPart: routine.mainTargetedBodyPart,
                                            )));
                              },
                            ),
                      )
                    ],
            )
          ];
        },
        body: SingleChildScrollView(
          child: columnBuilderForIOS(),
        ));
  }

  Future onSharePressed() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      scaffoldKey.currentState.showSnackBar(noNetworkSnackBar);
    } else {
      ///update the database
      Firestore.instance
          .collection("userShares")
          .document(dataString.replaceFirst("-r", ""))
          .setData({"id": dataString.replaceFirst("-r", ""), "routine": jsonEncode(Routine.copyFromRoutineWithoutHistory(routine).toMap())});

      ///show qr code
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
                          data: dataString,
                          //TODO: generete the string for sharing routine
                          size: 300,
                          version: 5,
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
                              onPressed: () async {
                                Navigator.pop(context);
                                //var permission = PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
                                //print("permission status is " + permission.toString());
                                PermissionHandler().requestPermissions(<PermissionGroup>[
                                  PermissionGroup.storage, // 在这里添加需要的权限
                                ]);

                                final QrPainter painter = QrPainter(
                                  data: dataString,
                                  color: Color(0xff222222),
                                  emptyColor: Color(0xffffffff),
                                  version: 4,
                                  gapless: true,
                                );
                                final ByteData imageData = await painter.toImageData(300.0);
                                ImageGallerySaver.save(imageData.buffer.asUint8List()).whenComplete(() {
                                  scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text('Saved to gallery.'),
                                    action: SnackBarAction(label: 'Dismiss', onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()),
                                  ));
                                });
//                            File file = File('test_image.png');
//                            file = await file.writeAsBytes(imageData.buffer.asUint8List());
                                //final int len = await file.length();
                                ///TODO: finish this function
                              },
                            ),
                            RaisedButton(
                                child: Text('Send'),
                                onPressed: () async {
                                  Share.share("Check out my routine: ${dataString.replaceFirst("-r", "")}");
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
    }
  }

  void updateWorkWeekdays(List<int> checkedWeekdays) {
    routine.weekdays.clear();
    routine.weekdays.addAll(checkedWeekdays);
    DBProvider.db.updateRoutine(routine);
  }

  void showSyncFailSnackbar() {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(
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

  Future showCelebrateDialog() async {
    final String tempDateStr = dateTimeToStringConverter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    final celebrateStrs = <String>['Well done!', 'WOW', 'Great job!', 'Nailed it', 'Pumped', 'Nooice!'];

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      showSyncFailSnackbar();
    } else {
      ///update user data if signed in
      if (firebaseProvider.currentUser != null) {
        ///TODO: debug this
        routinesBloc.allRoutines.first.then((routines) async {
          await firebaseProvider.handleUpload(routines, failCallback: () {
            showSyncFailSnackbar();
          });
        });
      }

      ///get the dailyData
      if (firebaseProvider.dailyRank == 0) {
        var db = Firestore.instance;
        var snapshot = await db.collection("dailyData").document(tempDateStr).get();

        if (snapshot.exists) {
          snapshot.reference.setData({"totalCount": snapshot["totalCount"] + 1});
          firebaseProvider.dailyRank = snapshot["totalCount"] + 1;

          firebaseProvider.dailyRankInfo = DateTime.now().toUtc().toString() + '/' + firebaseProvider.dailyRank.toString();
          setDailyRankInfo(firebaseProvider.dailyRankInfo);
        } else {
          await db.collection("dailyData").document(tempDateStr).setData({"totalCount": 1});
          firebaseProvider.dailyRankInfo = DateTime.now().toUtc().toString() + '/' + firebaseProvider.dailyRank.toString();
          setDailyRankInfo(firebaseProvider.dailyRankInfo);
        }
      }
    }

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
            child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor, boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20.0,
                  )
                ]),
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            celebrateStrs[Random().nextInt(celebrateStrs.length)],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                    ))));
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Column columnBuilderForAndroid() {
    List<Widget> exerciseDetails = <Widget>[];
    //_exerciseDetails.add(RoutineDescriptionCard(routine: routine));
    exerciseDetails.addAll(this.routine.parts.map((part) => Builder(
          builder: (context) => PartCard(
                onDelete: () {},
                onPartTap:
                    widget.isRecRoutine ? () {} : () => Navigator.push(context, MaterialPageRoute(builder: (context) => PartHistoryPage(part))),
                part: part,
              ),
        )));
    exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));
    return Column(children: exerciseDetails);
  }

  Column columnBuilderForIOS() {
    List<Widget> exerciseDetails = <Widget>[];
    //_exerciseDetails.add(RoutineDescriptionCard(routine: routine));
    exerciseDetails.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        elevation: 12,
        color: Colors.orange,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(routine.routineName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: 'Staa',
                    fontSize: getFontSize(routine.routineName),
                  )),
            ),
            widget.isRecRoutine
                ? Container()
                : Text(
                    'You have done this workout',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
            widget.isRecRoutine
                ? Container()
                : Text(
                    routine.completionCount.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, color: Colors.black),
                  ),
            widget.isRecRoutine
                ? Container()
                : Text(
                    'times',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
            widget.isRecRoutine
                ? Container()
                : Text(
                    'since',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
            widget.isRecRoutine
                ? Container()
                : Text(
                    '${routine.createdDate.toString().split(' ').first}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    ));
    exerciseDetails.addAll(this.routine.parts.map((part) => Builder(
          builder: (context) => PartCard(
                onDelete: () {},
                onPartTap:
                    widget.isRecRoutine ? () {} : () => Navigator.push(context, MaterialPageRoute(builder: (context) => PartHistoryPage(part))),
                part: part,
              ),
        )));
    exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));
    return Column(children: exerciseDetails);
  }

  double getFontSize(String str) {
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
  final WeekdaysCheckedCallback checkedCallback;

  ModalBottomSheet(this.checkedWeekDays, {this.checkedCallback});

  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> with SingleTickerProviderStateMixin {
  final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<IconData> weekDayIcons = [Icons.looks_one, Icons.looks_two, Icons.looks_3, Icons.looks_4, Icons.looks_5, Icons.looks_6, Icons.looks];
  final List<bool> isCheckedList = List<bool>(7);
  var heightOfModalBottomSheet = 100.0;

  @override
  void initState() {
    for (int i = 1; i <= 7; i++) {
      if (widget.checkedWeekDays.contains(i))
        isCheckedList[i - 1] = true;
      else
        isCheckedList[i - 1] = false;
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
                    value: isCheckedList[index],
                    onChanged: (val) {
                      setState(() {
                        isCheckedList[index] = val;
                        returnCheckedWeekdays();
                      });
                    },
                    secondary: Icon(weekDayIcons[index]),
                  );
                })));
  }

  void returnCheckedWeekdays() {
    List<int> selectedWeekdays = List<int>();
    for (int i = 0; i < isCheckedList.length; i++) {
      if (isCheckedList[i]) {
        selectedWeekdays.add(i + 1);
      }
    }
    widget.checkedCallback(selectedWeekdays);
  }
}
