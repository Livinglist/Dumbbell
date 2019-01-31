import 'dart:async';

import 'package:flutter/material.dart';
import 'model.dart';
import 'category.dart';

class RecommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Abs",),
              Tab(text: "Arms",),
              Tab(text: "Back",),
              Tab(text: "Chest",),
              Tab(text: "Legs",),
              Tab(text: "Shoulders",),
              Tab(text: "Full Body",),
            ],
          ),
          title: Text("Dev's favorite routines"),
        ),
        body: TabBarView(
          children: [
            _tabChild(MainTargetedBodyPart.Abs),
            _tabChild(MainTargetedBodyPart.Arm),
            _tabChild(MainTargetedBodyPart.Back),
            _tabChild(MainTargetedBodyPart.Chest),
            _tabChild(MainTargetedBodyPart.Leg),
            _tabChild(MainTargetedBodyPart.Shoulder),
            _tabChild(MainTargetedBodyPart.FullBody),
          ],
        ),
      ),
    );
  }

  Widget _tabChild(MainTargetedBodyPart mainTargetedBodyPart){
    return RoutineOverviewListView(mainTargetedBodyPart: mainTargetedBodyPart,);
  }
}

class RoutineOverviewListViewState extends State<RoutineOverviewListView> {
  @override
  Widget build(BuildContext context) {
    final RoutinesContext roc = RoutinesContext.of(context);
    final List<Routine> routines = RoutinesContext.of(context).routines;
    // TODO: implement build
    return Scaffold(
      body: _buildCategories(),
    );
  }

  Widget _buildCategories() {
    final RoutinesContext roc = RoutinesContext.of(context);
    List<Routine> routines = RoutinesContext.of(context).routines;
    List<Routine> desiredRoutines;

    return FutureBuilder<List<Routine>>(
      future: RoutinesContext.of(context).getAllRecRoutines(),
      builder: (BuildContext context, AsyncSnapshot<List<Routine>> snapshot){
        print("inside the recPage: "+(snapshot.data == null).toString());
        if(snapshot.hasData){
          RoutinesContext.of(context).recRoutines = snapshot.data;
          desiredRoutines = snapshot.data.where((routine)=>routine.mainTargetedBodyPart == widget.mainTargetedBodyPart).toList();
          routines = RoutinesContext.of(context).routines;
          return ListView.builder(
            itemCount: desiredRoutines.length,
            itemBuilder: (context, i) {
                return LongPressDraggable(
                  maxSimultaneousDrags: 1,
                  axis: Axis.vertical,
                  feedback: Text('Not implemented yet.'),
                  child: _buildRow(desiredRoutines[i]),
                  childWhenDragging: _buildRow(desiredRoutines[i]),
                );
            },
          );
        }else{
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(

            ),
          );
        }
      },
    );
  }

  Widget _buildRow(Routine routine) {
    return RoutineOverview(
      routine: routine,
      isRecRoutine: true,
    );
  }
}

class RoutineOverviewListView extends StatefulWidget {
  MainTargetedBodyPart mainTargetedBodyPart;

  RoutineOverviewListView({@required this.mainTargetedBodyPart});

  @override
  RoutineOverviewListViewState createState() =>
      new RoutineOverviewListViewState();
}

