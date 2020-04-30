import 'package:flutter/cupertino.dart';

class CupertinoListTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  const CupertinoListTile({Key key, this.leading, this.title, this.subtitle, this.trailing}) : super(key: key);

  @override
  _StatefulStateCupertino createState() => _StatefulStateCupertino();
}

class _StatefulStateCupertino extends State<CupertinoListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              widget.leading,
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.title,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 25,
                      )),
                  Text(widget.subtitle,
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 20,
                      )),
                ],
              ),
            ],
          ),
          widget.trailing,
        ],
      ),
    );
  }
}
