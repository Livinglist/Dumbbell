import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:workout_planner/resource/db_provider.dart';
import 'package:workout_planner/resource/firebase_provider.dart';
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

class _RoutineDetailPageState extends State<RoutineDetailPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();

  AnimationController animationController;

  GlobalKey globalKey = GlobalKey();
  String dataString;
  Routine routine;

  @override
  void initState() {
    dataString = '-r' + FirebaseProvider.generateId();

    animationController = AnimationController(vsync: this, lowerBound: 0, upperBound: 1, duration: Duration(milliseconds: 300));

    routinesBloc.fetchAllRoutines();

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
          return CupertinoPageScaffold(
              key: scaffoldKey,
              navigationBar: CupertinoNavigationBar(
                  middle: Text(mainTargetedBodyPartToStringConverter(routine.mainTargetedBodyPart)),
                  previousPageTitle: 'Routines',
                  trailing: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.isRecRoutine == false)
                        Transform.translate(
                          offset: Offset(36, -6),
                          child: CupertinoButton(
                            child: Icon(Icons.calendar_view_day),
                            onPressed: () {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (buildContext) {
                                    return Container(
                                      height: 600,
                                      child: WeekdayModalBottomSheet(
                                        routine.weekdays,
                                        checkedCallback: updateWorkWeekdays,
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      if (widget.isRecRoutine == false)
                        Transform.translate(
                          offset: Offset(24, -6),
                          child: CupertinoButton(
                            child: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => RoutineEditPage(
                                            addOrEdit: AddOrEdit.edit,
                                            mainTargetedBodyPart: routine.mainTargetedBodyPart,
                                          )));
                            },
                          ),
                        ),
                      if (widget.isRecRoutine == false)
                        Transform.translate(
                          offset: Offset(12, -6),
                          child: CupertinoButton(
                            child: Icon(Icons.play_arrow),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      fullscreenDialog: true,
                                      builder: (_) => RoutineStepPage(
                                          routine: routine,
                                          onBackPressed: () {
                                            Navigator.pop(context);
                                          })
                                  ));
                            },
                          ),
                        ),
                      if (widget.isRecRoutine)
                        Transform.translate(
                          offset: Offset(12, -6),
                          child: CupertinoButton(
                              child: AnimatedIcon(
                                icon: AnimatedIcons.add_event,
                                progress: animationController,
                              ),
                              onPressed: onAddRecPressed),
                        ),
                    ],
                  )),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverSafeArea(
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(buildColumn()),
                    ),
                  )
                ],
              ));
        } else {
          return Container();
        }
      },
    );
  }

  void onAddRecPressed() {
    showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Add to your routines?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        }).then((val) {
      if (val != null && val) {
        routinesBloc.addRoutine(routine);
        animationController.forward();
      }
    });
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

                                PermissionHandler().requestPermissions(<PermissionGroup>[
                                  PermissionGroup.storage,
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

  void showSyncFailSnackBar() {
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

  List<Widget> buildColumn() {
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
            onPartTap: widget.isRecRoutine ? () {} : () => Navigator.push(context, MaterialPageRoute(builder: (context) => PartHistoryPage(part))),
            part: part,
          ),
        )));
    exerciseDetails.add(Container(
      color: Colors.transparent,
      height: 60,
    ));
    return exerciseDetails;
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
}

typedef void WeekdaysCheckedCallback(List<int> selectedWeekdays);

class WeekdayModalBottomSheet extends StatefulWidget {
  final List<int> checkedWeekDays;
  final WeekdaysCheckedCallback checkedCallback;

  WeekdayModalBottomSheet(this.checkedWeekDays, {this.checkedCallback});

  _WeekdayModalBottomSheetState createState() => _WeekdayModalBottomSheetState();
}

class _WeekdayModalBottomSheetState extends State<WeekdayModalBottomSheet> with SingleTickerProviderStateMixin {
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
    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
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
                    checkColor: Colors.white,
                    activeColor: Colors.orange,
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
