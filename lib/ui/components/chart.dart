import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'package:workout_planner/models/routine.dart';

class StackedAreaLineChart extends StatelessWidget {
  final bool animate;
  final Exercise exercise;

  StackedAreaLineChart(this.exercise, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
//  factory StackedAreaLineChart.withSampleData() {
//    return new StackedAreaLineChart(
//      _createSampleData(),
//      // Disable animations for image tests.
//      animate: true,
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(_createData(),
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate);
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<LinearWeightCompleted, int>> _createData() {
    List<charts.Series<LinearWeightCompleted, int>> seriesData =
        List<charts.Series<LinearWeightCompleted, int>>();
//    for(var date in exercise.exHistory.keys){
//      List<LinearWeightCompleted> weightCompletedList = List<LinearWeightCompleted>(exercise.sets);
//      for(int i =0; i<weightCompletedList.length;i++){
//        print(exercise.exHistory[date].toString().split('/')[i]);
//        double tempWeight = double.parse(exercise.exHistory[date].toString().split('/')[i]);
//        print("temp weight is ${tempWeight.toString()}");
//        weightCompletedList[i] = LinearWeightCompleted(i, tempWeight.toInt());
//      }
//      seriesData.add(
//          charts.Series<LinearWeightCompleted, int>(
//            id: date,
//            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//            domainFn: (LinearWeightCompleted weightCompleted, _) => weightCompleted.month,
//            measureFn: (LinearWeightCompleted weightCompleted, _) => weightCompleted.weight,
//            data: weightCompletedList,
//          )
//      );
//    }

    List<LinearWeightCompleted> weightCompletedList =
        List<LinearWeightCompleted>(exercise.exHistory.length);
    for (int i = 0; i < weightCompletedList.length; i++) {
      //print(exercise.exHistory[date].toString().split('/')[i]);
      print(exercise.exHistory.values.toString());
      print(exercise.exHistory.values.toString().split('/')[0]);
      double tempWeight = _getMaxWeight(exercise.exHistory.values.toList()[i]);
      //print("temp weight is ${tempWeight.toString()}");
      weightCompletedList[i] = LinearWeightCompleted(i, tempWeight.toInt());
    }
    seriesData.add(charts.Series<LinearWeightCompleted, int>(
      id: 'Test',
      colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
      domainFn: (LinearWeightCompleted weightCompleted, _) =>
          weightCompleted.month,
      measureFn: (LinearWeightCompleted weightCompleted, _) =>
          weightCompleted.weight,
      data: weightCompletedList,
    ));

    return seriesData;
  }

  double _getMaxWeight(String weightsStr) {
    List<double> weights =
        weightsStr.split('/').map((str) => double.parse(str)).toList();
    double max = 0;
    for (var weight in weights) {
      if (weight > max) max = weight;
    }
    return max;
  }
}

/// Sample linear data type.
class LinearWeightCompleted {
  final int month;
  final int weight;

  LinearWeightCompleted(this.month, this.weight);
}

class DonutAutoLabelChart extends StatelessWidget {
  final List<Routine> routines;
  final bool animate;

  DonutAutoLabelChart(this.routines, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutAutoLabelChart.withSampleData() {
    return new DonutAutoLabelChart(
      null,
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(_createData(),
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        //
        // [ArcLabelDecorator] will automatically position the label inside the
        // arc if the label will fit. If the label will not fit, it will draw
        // outside of the arc with a leader line. Labels can always display
        // inside or outside using [LabelPosition].
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer:  charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [ charts.ArcLabelDecorator()]));
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<LinearRecords, int>> _createData() {
    final data = [
      new LinearRecords('Abs', 0, _getTotalCount(MainTargetedBodyPart.Abs)),
      new LinearRecords('Arms', 1, _getTotalCount(MainTargetedBodyPart.Arm)),
      new LinearRecords('Back', 2, _getTotalCount(MainTargetedBodyPart.Back)),
      new LinearRecords('Chest', 3, _getTotalCount(MainTargetedBodyPart.Chest)),
      new LinearRecords('Legs', 4, _getTotalCount(MainTargetedBodyPart.Leg)),
      new LinearRecords(
          'Shoulders', 5, _getTotalCount(MainTargetedBodyPart.Shoulder)),
      new LinearRecords(
          'Full Body', 6, _getTotalCount(MainTargetedBodyPart.FullBody)),
    ];

    return [
      new charts.Series<LinearRecords, int>(
        id: 'Sales',
        domainFn: (LinearRecords sales, _) => sales.index,
        measureFn: (LinearRecords sales, _) => sales.totalCount,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearRecords row, _) => '${row.label}',
      )
    ];
  }

  int _getTotalCount(MainTargetedBodyPart mt) {
    int totalCount = 0;
    for (var routine in routines) {
      if (routine.mainTargetedBodyPart == mt) {
        totalCount += routine.completionCount;
      }
    }
    return totalCount;
  }
}

class LinearRecords {
  final String label;
  final int index;
  final int totalCount;

  LinearRecords(this.label, this.index, this.totalCount);
}
