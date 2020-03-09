import 'package:flutter/material.dart';

import 'package:workout_planner/ui/components/routine_overview_card.dart';
import 'package:workout_planner/bloc/routines_bloc.dart';

class RecommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        //backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
//            labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
//            unselectedLabelStyle: TextStyle(color: Colors.black, fontSize: 12),
//            indicator: ShapeDecoration(shape: StadiumBorder(), color: Colors.black),
            tabs: [
              Tab(
                text: 'Abs',
              ),
              Tab(
                text: "Arms",
              ),
              Tab(
                text: "Back",
              ),
              Tab(
                text: "Chest",
              ),
              Tab(
                text: "Legs",
              ),
              Tab(
                text: "Shoulders",
              ),
              Tab(
                text: "Full Body",
              ),
            ],
          ),
          title: Text(
            "Recommendations",
          ),
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

//  Positioned(
//  child: Transform.translate(
//  offset: Offset(0, -140),
//  child: Container(
//  height: MediaQuery.of(context).size.height + 140,
//  width: MediaQuery.of(context).size.width,
//  // Add box decoration
//  color: Colors.pink,
//  ),
//  )
////                child: Container(
////                    height: MediaQuery.of(context).size.height + 340,
////                    width: MediaQuery.of(context).size.width,
////                    // Add box decoration
////                    decoration: BoxDecoration(
////                      // Box decoration takes a gradient
////                      gradient: LinearGradient(
////                        // Where the linear gradient begins and ends
////                        begin: Alignment.topRight,
////                        end: Alignment.bottomLeft,
////                        // Add one stop for each color. Stops should increase from 0 to 1
////                        stops: [0.1, 0.5, 0.6, 0.9],
////                        colors: [
////                          // Colors are easy thanks to Flutter's Colors class.
////                          Colors.yellow[500],
////                          Colors.yellow[300],
////                          Colors.yellow[200],
////                          Colors.yellow[50],
////                        ],
////                      ),
////                    )),
//  ),

  Widget _tabChild(MainTargetedBodyPart mainTargetedBodyPart) {
    return RoutineOverviewListView(
      mainTargetedBodyPart: mainTargetedBodyPart,
    );
  }
}

class RoutineOverviewListView extends StatelessWidget {
  final MainTargetedBodyPart mainTargetedBodyPart;

  RoutineOverviewListView({@required this.mainTargetedBodyPart});

  @override
  Widget build(BuildContext context) {
//    final RoutinesContext roc = RoutinesContext.of(context);
//    final List<Routine> routines = RoutinesContext.of(context).routines;
    routinesBloc.fetchAllRecRoutines();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildCategories(),
    );
  }

  Widget _buildCategories() {
    List<Routine> desiredRoutines;

    return StreamBuilder(
      stream: routinesBloc.allRecRoutines,
      builder: (_, AsyncSnapshot<List<Routine>> snapshot) {
        if (snapshot.hasData) {
          desiredRoutines = snapshot.data.where((routine) => routine.mainTargetedBodyPart == mainTargetedBodyPart).toList();
          return ListView.builder(
            itemCount: desiredRoutines.length,
            itemBuilder: (context, i) {
              return _buildRow(desiredRoutines[i]);
            },
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
      },
    );

//    return FutureBuilder<List<Routine>>(
//      future: RoutinesContext.of(context).getAllRecRoutines(),
//      builder: (BuildContext context, AsyncSnapshot<List<Routine>> snapshot){
//        print("inside the recPage: "+(snapshot.data == null).toString());
//        if(snapshot.hasData){
//          RoutinesContext.of(context).recRoutines = snapshot.data;
//          desiredRoutines = snapshot.data.where((routine)=>routine.mainTargetedBodyPart == widget.mainTargetedBodyPart).toList();
//          routines = RoutinesContext.of(context).routines;
//          return ListView.builder(
//            itemCount: desiredRoutines.length,
//            itemBuilder: (context, i) {
//                return _buildRow(desiredRoutines[i]);
//            },
//          );
//        }else{
//          return Container(
//            alignment: Alignment.center,
//            child: CircularProgressIndicator(
//
//            ),
//          );
//        }
//      },
//    );
  }

  Widget _buildRow(Routine routine) {
    return RoutineOverview(
      routine: routine,
      isRecRoutine: true,
    );
  }
}
