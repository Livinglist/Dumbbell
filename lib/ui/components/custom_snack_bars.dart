import 'package:flutter/material.dart';

final noNetworkSnackBar = SnackBar(
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
        "NO NETWORK CONNECTION",
        style: TextStyle(color: Colors.black),
      ),
    ],
  ),
);

//class NoNetworkSnackBar extends SnackBar {
//  @override
//  Widget build(BuildContext context) {
//    return SnackBar(
//      backgroundColor: Colors.yellow,
//      content: Row(
//        children: <Widget>[
//          Padding(
//            padding: EdgeInsets.only(right: 4),
//            child: Icon(
//              Icons.report,
//              color: Colors.black,
//            ),
//          ),
//          Text(
//            "NO NETWORK CONNECTION",
//            style: TextStyle(color: Colors.black),
//          ),
//        ],
//      ),
//    );
//  }
//}
