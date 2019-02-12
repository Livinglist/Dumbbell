import 'package:flutter/material.dart';

import 'chart.dart';
import 'customWidgets/customExpansionTile.dart' as custom;
import 'model.dart';
import 'theme.dart';

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
        //body: _historyColumnBuilder(part),
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

//  Widget _historyColumnBuilder(Part part) {
//    List<Widget> _widgets = List<Widget>();
//    for (var ex in part.exercises) {
//      _widgets.add(Padding(
//        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//        child: Text(
//          ex.name,
//          textAlign: TextAlign.center,
//          style: TextStyle(color: Colors.black),
//        ),
//      ));
//      _widgets.add(Padding(
//        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//        child: Container(
//          height: 200,
//          child: ListView.separated(
//              itemBuilder: (context, i) {
//                return ListTile(
//                  title: Text(ex.exHistory.keys.toList()[i]),
//                  subtitle: Text(ex.exHistory.values.toList()[i]),
//                );
//                return Text(
//                  ex.exHistory.keys.toList()[i] +
//                      ' ' +
//                      ex.exHistory.values.toList()[i],
//                  style: TextStyle(color: Colors.white),
//                );
//              },
//              separatorBuilder: (BuildContext context, int index) => Divider(),
//              itemCount: ex.exHistory.length),
//        ),
//      ));
//      _widgets.add(Padding(padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),child: Container(height: 200, child: StackedAreaLineChart(ex)),));
//    }
//
//    return ListView(children: _widgets);
//  }
}

class TabChild extends StatelessWidget {
  final Exercise exercise;
  final Color foregroundColor;

  TabChild(this.exercise, this.foregroundColor);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
