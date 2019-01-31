import 'package:flutter/material.dart';
import 'model.dart';

class PartEditPage extends StatelessWidget {
  Part part;
  AddOrEdit addOrEdit;
  Routine curRoutine;
  PartEditPage({@required this.addOrEdit, this.part, this.curRoutine});

  @override
  Widget build(BuildContext context) {
    print("ok in the Parteditpage");
    return Criterias(
      addOrEdit: addOrEdit,
      part: part,
      curRoutine: curRoutine,
    );
  }
}

class Criterias extends StatefulWidget {
  final Part part;
  AddOrEdit addOrEdit;
  Routine curRoutine;

  Criterias({@required this.addOrEdit, this.part, this.curRoutine});

  CriteriaState createState() => new CriteriaState();
}

typedef Widget MaterialCallback();

class NewItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  final MaterialCallback callback;
  NewItem(
      {this.isExpanded, this.header, this.body, this.iconpic, this.callback});
}

double discretevalue = 2.0;
double hospitaldiscretevalue = 25.0;

class CriteriaState extends State<Criterias> {
  final _nameTextEditingController = new TextEditingController();
  final _addtionalNotesTextEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Icon _setPartsIcon;
  String _setPartLabelText;
  Routine curRoutine;
  List<TextEditingController> _textControllers =
      new List<TextEditingController>();
  int _radioValue1 = 0;
  int _radioValueSetType = 0;
  bool _additionalNotesIsExpanded;
  bool _isNewlyCreated = false;
  List<NewItem> items;
  List<Exercise> _tempExs = new List<Exercise>();
  List<Widget>
      _widgets; //the widgets thats gonna be displayed in the expansionPanel of exercise detail
  List<bool> _enabledList = <bool>[true, false, false, false];
  WorkoutType _workoutType;

  @override
  void initState() {
    //copy the content of exercises of the Part
    _setPartsIcon = widget.part.workoutType == WorkoutType.Weight
        ? Icon(Icons.fitness_center)
        : Icon(Icons.timer);
    _workoutType = widget.part.workoutType;
    _setPartLabelText =
        widget.part.workoutType == WorkoutType.Weight ? 'Reps' : 'Seconds';
    _additionalNotesIsExpanded = false;
    _addtionalNotesTextEditingController.text = widget.part.additionalNotes;
    if (widget.part.exercises.length == 0) {
      //this means this is a newly created part!!!
      //widget.part.exercises.add(new Exercise(name: null, weight: null, sets: null, reps: null));
      for (int i = 0; i < 4; i++) {
        var exCopy =
            new Exercise(name: null, weight: null, sets: null, reps: null);
        _tempExs.add(exCopy);
      }
      _isNewlyCreated = true;
    } else {
      //if the part is an existing part that's been editing, then copy the whole thing to _tempExs
      for (int i = 0; i < 4; i++) {
        if (i < widget.part.exercises.length) {
          var ex = widget.part.exercises[i];
          var exCopy = new Exercise(
              name: ex.name, weight: ex.weight, sets: ex.sets, reps: ex.reps);
          _tempExs.add(exCopy);
        } else {
          _tempExs.add(
              new Exercise(name: null, weight: null, sets: null, reps: null));
        }
      }
      _isNewlyCreated = false;
    }

    if (true) {
      switch (widget.part.targetedBodyPart) {
        case TargetedBodyPart.Abs:
          _radioValue1 = 0;
          break;
        case TargetedBodyPart.Arm:
          _radioValue1 = 1;
          break;
        case TargetedBodyPart.Back:
          _radioValue1 = 2;
          break;
        case TargetedBodyPart.Chest:
          _radioValue1 = 3;
          break;
        case TargetedBodyPart.Leg:
          _radioValue1 = 4;
          break;
        case TargetedBodyPart.Shoulder:
          _radioValue1 = 5;
          break;
        case TargetedBodyPart.Bicep:
          _radioValue1 = 6;
          break;
        case TargetedBodyPart.Tricep:
          _radioValue1 = 7;
          break;
        case TargetedBodyPart.FullBody:
          _radioValue1 = 8;
          break;
      }

      switch (widget.part.setType) {
        case SetType.Regular:
          _radioValueSetType = 0;
          break;
        case SetType.Drop:
          _radioValueSetType = 1;
          break;
        case SetType.Super:
          _radioValueSetType = 2;
          break;
        case SetType.Tri:
          _radioValueSetType = 3;
          break;
        case SetType.Giant:
          _radioValueSetType = 4;
          break;
      }

      for (int i = 0; i < 16; i++) {
        _textControllers.add(new TextEditingController());
      }

      for (int i = 0, j = 0; i < 16; i++, j += 4) {
        if (i < widget.part.exercises.length) {
          _textControllers[j].text = widget.part.exercises[i].name;
          _textControllers[j + 1].text = widget.part.exercises[i].weight;
          _textControllers[j + 2].text = widget.part.exercises[i].sets;
          _textControllers[j + 3].text = widget.part.exercises[i].reps;
        } else {}
      }
    }
    _widgets = _getChildrenSetParts(
        _isNewlyCreated ? SetType.Regular : widget.part.setType);
    items = <NewItem>[
      new NewItem(
          isExpanded: true,
          header: 'Targeted Body Part',
          callback: _materialTargetedBodyPart,
          iconpic: new Icon(Icons.accessibility_new)),
      new NewItem(
        isExpanded: false,
        header: 'Type of Set',
        callback: _materialSetType,
        iconpic: Icon(Icons.blur_linear),
      ),
      new NewItem(
          isExpanded: true,
          header: 'Details',
          callback: _materialSetParts,
          iconpic: _setPartsIcon),
    ];
    print('servived the init process');

    super.initState();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Your editing will not be saved.'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      if (widget.addOrEdit == AddOrEdit.Add)
                        widget.curRoutine.parts.removeLast();
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _materialTargetedBodyPart() {
    return new Material(
      child: Padding(
          padding: new EdgeInsets.all(12.0),
          child: new Column(children: <Widget>[
            RadioListTile(
              value: 0,
              groupValue: _radioValue1,
              onChanged: _handleRadioValueChanged,
              title: Text('Abs'),
            ),
            //put the children here
            RadioListTile(
              value: 1,
              groupValue: _radioValue1,
              onChanged: _handleRadioValueChanged,
              title: Text('Arm'),
            ),
            RadioListTile(
                value: 2,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Back')),
            RadioListTile(
                value: 3,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Chest')),
            RadioListTile(
                value: 4,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Leg')),
            RadioListTile(
                value: 5,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Shoulder')),
            RadioListTile(
                value: 6,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Bicep')),
            RadioListTile(
                value: 7,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Tricep')),
            RadioListTile(
                value: 8,
                groupValue: _radioValue1,
                onChanged: _handleRadioValueChanged,
                title: Text('Full Body')),
          ])),
    );
  }

  Widget _materialSetType() {
    return new Material(
      child: Padding(
          padding: new EdgeInsets.all(12.0),
          child: new Column(children: <Widget>[
            //put the children here
            RadioListTile(
              value: 0,
              groupValue: _radioValueSetType,
              onChanged: _handleRadioSetTypeValueChanged,
              title: Text('Regular Sets'),
            ),
            RadioListTile(
                value: 1,
                groupValue: _radioValueSetType,
                onChanged: _handleRadioSetTypeValueChanged,
                title: Text('Drop Sets')),
            RadioListTile(
                value: 2,
                groupValue: _radioValueSetType,
                onChanged: _handleRadioSetTypeValueChanged,
                title: Text('Super Sets')),
            RadioListTile(
                value: 3,
                groupValue: _radioValueSetType,
                onChanged: _handleRadioSetTypeValueChanged,
                title: Text('Tri-Sets')),
            RadioListTile(
                value: 4,
                groupValue: _radioValueSetType,
                onChanged: _handleRadioSetTypeValueChanged,
                title: Text('Giant Sets')),
          ])),
    );
  }

  ///expansion panel for detailed information on exercises
  Widget _materialSetParts() {
    print("callback works??!!");
    return new Material(
      child: Padding(
          padding: new EdgeInsets.all(16.0),
          child: new Column(children: _widgets)),
    );
  }

  List<Widget> _getChildrenSetParts([SetType setType]) {
    const count = 4;
    List<Widget> widgets = new List<Widget>();
    int exCount = setTypeToExerciseCountConverter(setType);

    for (int i = 0; i < 4; i++) {
      if (i < exCount) {
        _enabledList[i] = true;
      } else {
        _enabledList[i] = false;
      }
    }

    if (true) {
      //setType will not be passed in when initializing this page
      widgets.add(Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
            child: Text('Weight training', textAlign: TextAlign.center,)),
            Expanded(
              child: Switch(
                value: _workoutType == WorkoutType.Cardio,
                onChanged: (res) {
                  setState(() {
                    _workoutType = res ? WorkoutType.Cardio : WorkoutType.Weight;
                    _setPartLabelText =
                    _workoutType == WorkoutType.Weight ? 'Reps' : 'Seconds';
                    _widgets = _getChildrenSetParts(setType);//TODO: fuck this shit
                    print(_setPartLabelText);
                  });
                },
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.redAccent,
              ),
            ),
            Expanded(
              child: Text('Cardio training',textAlign: TextAlign.center,),
            )
          ],
        ),
      ));

      for (int i = 0, j = 0; i < count; i++, j += 4) {
        widgets.add(_enabledList[i]
            ? Text('Exercise ' + (i + 1).toString())
            : Container());
        widgets.add(_enabledList[i]
            ? TextFormField(
                controller: _textControllers[j],
                onFieldSubmitted: (str) {
                  setState(() {
                    //widget.part.exercises[i].name = str;
                  });
                },
                decoration: InputDecoration(labelText: 'Name'),
                validator: (str) {
                  if (str.isEmpty)
                    return 'Please enter the name of exercise';
                  else
                    _tempExs[i].name = _textControllers[j].text;
                },
              )
            : Container());
        widgets.add(_enabledList[i]
            ? Row(
                children: <Widget>[
                  Flexible(
                    child: Builder(
                        builder: (context) => TextFormField(
                              controller: _textControllers[j + 1],
                              onFieldSubmitted: (str) {},
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: false, decimal: false),
                              decoration: InputDecoration(labelText: 'Weight'),
                              validator: (str) {
                                if (str.isEmpty)
                                  _tempExs[i].weight = '0';
                                else if (str.contains(RegExp(r"(,|\.|-)"))) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Weight can only contain numbers."),
                                  ));
                                  return "Numbers only";
                                } else
                                  _tempExs[i].weight =
                                      _textControllers[j + 1].text;
                              },
                            )),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _textControllers[j + 2],
                      onFieldSubmitted: (str) {},
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      decoration: InputDecoration(labelText: 'Sets'),
                      validator: (str) {
                        if (str.isEmpty)
                          _tempExs[i].sets = '0';
                        else if (str.contains(RegExp(r"(,|\.|-)"))) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Sets can only contain numbers."),
                          ));
                          return "Numbers only";
                        } else
                          _tempExs[i].sets = _textControllers[j + 2].text;
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _textControllers[j + 3],
                      onFieldSubmitted: (str) {},
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      decoration: InputDecoration(labelText: _setPartLabelText),
                      validator: (str) {
                        if (str.isEmpty)
                          _tempExs[i].reps = '';
                        else
                          _tempExs[i].reps = _textControllers[j + 3].text;
                      },
                    ),
                  )
                ],
              )
            : Container());
        widgets.add(_enabledList[i]
            ? Container(
                //serve as divider
                height: 24,
              )
            : Container());
      }
      return widgets;
    }
  }

  ListView listView;
  ScrollController _scrollController;

  Widget build(BuildContext context) {
    curRoutine = RoutinesContext.of(context).curRoutine;
    print("Inside build:::"+_setPartLabelText);
    var _expansionPanelChildren = items.map((NewItem item) {
      return new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return new ListTile(
              leading: item.iconpic,
              title: new Text(
                item.header,
                textAlign: TextAlign.left,
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ));
        },
        isExpanded: item.isExpanded,
        body: item.callback(),
      );
    }).toList();

    listView = new ListView(
      controller: _scrollController,
      children: [
        Form(
            key: _formKey,
            child: Padding(
              //Targeted Body Part, Type of set, Details
              padding: new EdgeInsets.all(12.0),
              child: new ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      items[index].isExpanded = !items[index].isExpanded;
                    });
                  },
                  children: _expansionPanelChildren),
            )),
        Padding(
            //Additional notes
            padding: new EdgeInsets.all(12),
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _additionalNotesIsExpanded = !_additionalNotesIsExpanded;
                });
              },
              children: <ExpansionPanel>[
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return isExpanded
                          ? new ListTile(
                              leading: Icon(Icons.assignment),
                              subtitle: Text(
                                  'Remind yourself what to pay attention to while doing these exercises'),
                              title: Text(
                                'Additional Notes',
                                style: new TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : new ListTile(
                              leading: Icon(Icons.assignment),
                              title: Text(
                                'Additional Notes',
                                style: new TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                    },
                    isExpanded: _additionalNotesIsExpanded,
                    body: Material(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: TextField(
                          controller: _addtionalNotesTextEditingController,
                          onTap: () {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ))
              ],
            ))
      ],
    );

    Scaffold scaffold = new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.grey[800],
        title: new Text("Criteria Selection"),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    widget.part.workoutType = _workoutType;
                    widget.part.targetedBodyPart = PartEditPageHelper
                        .radioValueToTargetedBodyPartConverter(_radioValue1);
                    widget.part.setType =
                        PartEditPageHelper.radioValueToSetTypeConverter(
                            _radioValueSetType);
                    widget.part.exercises = new List<Exercise>();
                    for (int i = 0;
                        i < _enabledList.where((res) => res).length;
                        i++) {
                      widget.part.exercises.add(new Exercise(
                          name: _tempExs[i].name,
                          weight: _tempExs[i].weight,
                          sets: _tempExs[i].sets,
                          reps: _tempExs[i].reps));
                    }
                    widget.part.additionalNotes =
                        _addtionalNotesTextEditingController.text;
                    Navigator.pop(context);
                  } else {}
                },
              );
            },
          )
        ],
      ),
      body: listView,
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: scaffold,
    );
  }

  void _handleRadioValueChanged(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  void _handleRadioSetTypeValueChanged(int value) {
    setState(() {
      _radioValueSetType = value;
      _widgets = _getChildrenSetParts(PartEditPageHelper.radioValueToSetTypeConverter(value));
    });
  }
}

class PartEditPageHelper {
  static SetType radioValueToSetTypeConverter(int radioValue) {
    switch (radioValue) {
      case 0:
        return SetType.Regular;
      case 1:
        return SetType.Drop;
      case 2:
        return SetType.Super;
      case 3:
        return SetType.Tri;
      case 4:
        return SetType.Giant;
      default:
        throw Exception('Inside _radioValueToSetTypeConverter');
    }
  }

  static TargetedBodyPart radioValueToTargetedBodyPartConverter(
      int radioValue) {
    switch (radioValue) {
      case 0:
        return TargetedBodyPart.Abs;
      case 1:
        return TargetedBodyPart.Arm;
      case 2:
        return TargetedBodyPart.Back;
      case 3:
        return TargetedBodyPart.Chest;
      case 4:
        return TargetedBodyPart.Leg;
      case 5:
        return TargetedBodyPart.Shoulder;
      case 6:
        return TargetedBodyPart.Bicep;
      case 7:
        return TargetedBodyPart.Tricep;
      case 8:
        return TargetedBodyPart.FullBody;
      default:
        throw Exception(
            'Inside _radioValueToTargetedBodyPartConverter, radioValue: ${radioValue.toString()}');
    }
  }
}
