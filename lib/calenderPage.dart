import 'package:flutter/material.dart';

import 'category.dart';
import 'model.dart';

class CalenderPage extends StatefulWidget {
  //final List<String> dates;
  final Map<String, Routine> dates;

  CalenderPage(this.dates);

  @override
  State<StatefulWidget> createState() => CalenderPageState();
}

class CalenderPageState extends State<CalenderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  VoidCallback _showBottomSheetCallback;

  void _showBottomSheet(Routine routine) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: RoutineOverview(routine: routine),
              ));
        });
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('This Year'),
      ),
      body: GridView.count(
        controller: _scrollController,
        crossAxisCount: 13,
        children: _buildMonthRow(),
      ),
    );
  }

  List<Widget> _buildMonthRow() {
    List<Widget> widgets = List<Widget>();

    widgets.add(Text(' '));

    for (int i = 1; i <= 12; i++) {
      widgets.add(Center(child: Text(_intToMonth(i))));
    }

    widgets.addAll(_buildDayRows());

    return widgets;
  }

  List<Widget> _buildDayRows() {
    List<Widget> widgets = List<Widget>();

    for (int i = 1; i <= 31; i++) {
      widgets.add(Center(child: Text(i.toString())));
      for (int j = 1; j <= 12; j++) {
        DateTime date = DateTime(DateTime
            .now()
            .year, j, i);
        String dateStr = date
            .toString()
            .split(' ')
            .first;
        widgets.add(Container(
          child: GestureDetector(onTap: () {
            if (_isWorkoutDay(j, i)) {
              _showBottomSheet(widget.dates[dateStr]);
            }
          }),
          decoration: BoxDecoration(
              color: _isWorkoutDay(j, i) ? mainTargetedBodyPartToColorConverter(
                  widget.dates[dateStr].mainTargetedBodyPart) : Colors
                  .transparent,
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.grey[500], width: 0.3)),
        ));
      }
    }
    return widgets;
  }

  bool _isWorkoutDay(int month, int day) {
    DateTime date = DateTime(DateTime.now().year, month, day);
    String dateStr = date.toString().split(' ').first;
    return widget.dates.keys.contains(dateStr);
  }

  String _intToMonth(int i) {
    switch (i) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        throw Exception('Inside _intToMonth()');
    }
  }
}
