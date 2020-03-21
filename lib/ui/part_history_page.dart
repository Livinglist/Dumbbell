import 'package:flutter/material.dart';

import 'package:workout_planner/ui/components/chart.dart';
import 'package:workout_planner/ui/components/custom_expansion_tile.dart' as custom;
import 'package:workout_planner/ui/theme.dart';

import 'package:workout_planner/models/routine.dart';

class PartHistoryPage extends StatelessWidget {
  final Part part;

  PartHistoryPage(this.part);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: part.exercises.length,
      child: Scaffold(
        backgroundColor: Colors.grey[500],
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            tabs: _getTabs(part),
          ),
          title: Text("History"),
        ),
        body: TabBarView(
          children: _getTabChildren(part),
        ),
      ),
    );
  }

  List<Widget> _getTabs(Part part) {
    List<Widget> widgets = List<Widget>();

    for (var ex in part.exercises) {
      widgets.add(Tab(
        text: ex.name,
      ));
    }

    return widgets;
  }

  List<Widget> _getTabChildren(Part part) {
    List<Widget> widgets = List<Widget>();

    for (var ex in part.exercises) {
      widgets.add(TabChild(ex, setTypeToThemeColorConverter(part.setType)));
    }

    return widgets;
  }

  ///for reference
  Color setTypeToThemeColorConverter(SetType setType) {
    switch (setType) {
      case SetType.Regular:
        return ThemeRegular.accentColor;
      case SetType.Drop:
        return ThemeDrop.accentColor;
      case SetType.Super:
        return ThemeSuper.accentColor;
      case SetType.Tri:
        return ThemeTri.accentColor;
      case SetType.Giant:
        return ThemeGiant.accentColor;
      default:
        throw Exception('Inside setTypeToThemeConverter');
    }
  }
}

class TabChild extends StatelessWidget {
  final Exercise exercise;
  final Color foregroundColor;

  TabChild(this.exercise, this.foregroundColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child:
                Container(height: 200, child: StackedAreaLineChart(exercise)),
          ),
          Expanded(
              child: HistoryExpansionTile(exercise.exHistory, Colors.blue)),
        ],
      ),
    );
  }
}

class Year {
  final String year;
  final List<String> dates = List<String>();

  Year(this.year)
      : assert(year.length == 4 && year[0] == '2' && year[1] == '0');
}

class HistoryExpansionTile extends StatelessWidget {
  final Map exHistory;
  final Color foregroundColor;

  HistoryExpansionTile(this.exHistory, this.foregroundColor)
      : assert(exHistory != null),
        assert(foregroundColor != null);

  @override
  Widget build(BuildContext context) {
    //List<String> years = List<String>();
    var years = List<Year>();
    for (var date in exHistory.keys) {
      if (years.isEmpty) {
        years.add(Year(date.toString().split('-').first));
        years.last.dates.add(date);
      } else {
        if (date.toString()[2] != years.last.year[2] ||
            date.toString()[3] != years.last.year[3]) {
          years.add(Year(date.toString().split('-').first));
        } else {
          years.last.dates.add(date);
        }
      }
    }

    // TODO: implement build
    return ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, i) {
          return custom.ExpansionTile(
            foregroundColor: foregroundColor,
            title: Text(years[i].year),
            children: _listViewBuilder(years[i].dates, exHistory),
          );
        });
  }

  List<Widget> _listViewBuilder(List<String> dates, Map exHistory) {
    List<Widget> listTiles = List<Widget>();
    for (var date in dates) {
      listTiles.add(ListTile(
        leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[350],
            ),
            child: Center(
              child: Text(
                (dates.indexOf(date) + 1).toString(),
                style: TextStyle(fontSize: 16),
              ),
            )),
        title: Text(date),
        subtitle: Text(exHistory[date]),
      ));
      listTiles.add(Divider());
    }
    listTiles.removeLast();
    return listTiles;
  }
}
