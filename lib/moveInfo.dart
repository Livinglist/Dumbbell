import 'package:flutter/material.dart';

class MoveInfo extends StatelessWidget{
  final Color color = Colors.greenAccent;

  @override
  Widget build(BuildContext context) {
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
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              borderRadius: new BorderRadius.circular(10),
              highlightColor: color,
              splashColor: color,
              // We can use either the () => function() or the () { function(); }
              // syntax.
              onTap: () {
                print('I was tapped!');
              },
              child: Padding(
                padding:
                EdgeInsets.only(left: 30, top: 30, right: 0, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                        'test',
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
                      padding: new EdgeInsets.only(
                          left: 0, top: 20, right: 20, bottom: 30),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            size: 60,
                          ),
                        ],
                      ),

                    ),
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