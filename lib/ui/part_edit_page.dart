import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';

import 'package:workout_planner/models/routine.dart';

class PartEditPage extends StatefulWidget {
  final Part part;
  final AddOrEdit addOrEdit;
  final Routine curRoutine;
  
  PartEditPage({@required this.addOrEdit, this.part, this.curRoutine});

  @override
  State<StatefulWidget> createState() => PartEditPageState();
}

typedef Widget MaterialCallback();

class Item {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  final MaterialCallback callback;
  Item({this.isExpanded, this.header, this.body, this.iconpic, this.callback});
}

double discretevalue = 2.0;
double hospitaldiscretevalue = 25.0;

class PartEditPageState extends State<PartEditPage> {
  final _addtionalNotesTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Routine curRoutine;
  List<TextEditingController> _textControllers = List<TextEditingController>();
  int _radioValue1 = 0;
  int _radioValueSetType = 0;
  bool _additionalNotesIsExpanded;
  bool _islyCreated = false;
  List<Item> items;
  List<Exercise> _tempExs = List<Exercise>();
  List<Widget> _widgets;

  ///the widgets thats gonna be displayed in the expansionPanel of exercise detail
  List<bool> _enabledList = <bool>[true, false, false, false];

  @override
  void initState() {
    ///copy the content of exercises of the Part
    _additionalNotesIsExpanded = false;
    _addtionalNotesTextEditingController.text = widget.part.additionalNotes;
    if (widget.part.exercises.length == 0) {
      ///this means this is a ly created part!!!
      ///widget.part.exercises.add( Exercise(name: null, weight: null, sets: null, reps: null));
      for (int i = 0; i < 4; i++) {
        var exCopy = Exercise(name: null, weight: null, sets: null, reps: null, exHistory: {});
        _tempExs.add(exCopy);
      }
      _islyCreated = true;
    } else {
      ///if the part is an existing part that's been editing, then copy the whole thing to _tempExs
      for (int i = 0; i < 4; i++) {
        if (i < widget.part.exercises.length) {
          var ex = widget.part.exercises[i];
          var exCopy = Exercise(name: ex.name, weight: ex.weight, sets: ex.sets, reps: ex.reps, workoutType: ex.workoutType, exHistory: ex.exHistory);
          _tempExs.add(exCopy);
        } else {
          _tempExs.add(Exercise(name: null, weight: null, sets: null, reps: null, exHistory: {}));
        }
      }
      _islyCreated = false;
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
        _textControllers.add(TextEditingController());
      }

      for (int i = 0, j = 0; i < 16; i++, j += 4) {
        if (i < widget.part.exercises.length) {
          _textControllers[j].text = widget.part.exercises[i].name;
          _textControllers[j + 1].text = widget.part.exercises[i].weight.toString();
          _textControllers[j + 2].text = widget.part.exercises[i].sets.toString();
          _textControllers[j + 3].text = widget.part.exercises[i].reps;
        } else {}
      }
    }
    _widgets = _getChildrenSetParts(_islyCreated ? SetType.Regular : widget.part.setType);
    items = <Item>[
      Item(isExpanded: true, header: 'Targeted Body Part', callback: _materialTargetedBodyPart, iconpic: Icon(Icons.accessibility_new)),
      Item(
        isExpanded: false,
        header: 'Type of Set',
        callback: _materialSetType,
        iconpic: Icon(Icons.blur_linear),
      ),
      Item(isExpanded: true, header: 'Details', callback: _materialSetParts, iconpic: Icon(Icons.fitness_center)),
    ];

    super.initState();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Your editing will not be saved.'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (widget.addOrEdit == AddOrEdit.add) widget.curRoutine.parts.removeLast();
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _materialTargetedBodyPart() {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
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
            RadioListTile(value: 2, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Back')),
            RadioListTile(value: 3, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Chest')),
            RadioListTile(value: 4, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Leg')),
            RadioListTile(value: 5, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Shoulder')),
            RadioListTile(value: 6, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Bicep')),
            RadioListTile(value: 7, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Tricep')),
            RadioListTile(value: 8, groupValue: _radioValue1, onChanged: _handleRadioValueChanged, title: Text('Full Body')),
          ])),
    );
  }

  Widget _materialSetType() {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            //put the children here
            RadioListTile(
              value: 0,
              groupValue: _radioValueSetType,
              onChanged: _handleRadioSetTypeValueChanged,
              title: Text('Regular Sets'),
            ),
            RadioListTile(value: 1, groupValue: _radioValueSetType, onChanged: _handleRadioSetTypeValueChanged, title: Text('Drop Sets')),
            RadioListTile(value: 2, groupValue: _radioValueSetType, onChanged: _handleRadioSetTypeValueChanged, title: Text('Super Sets')),
            RadioListTile(value: 3, groupValue: _radioValueSetType, onChanged: _handleRadioSetTypeValueChanged, title: Text('Tri-Sets')),
            RadioListTile(value: 4, groupValue: _radioValueSetType, onChanged: _handleRadioSetTypeValueChanged, title: Text('Giant Sets')),
          ])),
    );
  }

  ///expansion panel for detailed information on exercises
  Widget _materialSetParts() {
    print("callback works??!!");
    return Material(
      child: Padding(padding: EdgeInsets.all(16.0), child: Column(children: _widgets)),
    );
  }

  List<Widget> _getChildrenSetParts([SetType setType]) {
    const count = 4;
    List<Widget> widgets = List<Widget>();
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
      for (int i = 0, j = 0; i < count; i++, j += 4) {
        if (_enabledList[i]) {
          widgets.add(Text('Exercise ' + (i + 1).toString()));
          widgets.add(Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    child: Text(
                  'Rep',
                  textAlign: TextAlign.center,
                )),
                Expanded(
                  child: Switch(
                    value: _tempExs[i].workoutType == WorkoutType.Cardio,
                    onChanged: (res) {
                      setState(() {
                        _tempExs[i].workoutType = res ? WorkoutType.Cardio : WorkoutType.Weight;
//                        _setPartLabelText = _workoutType == WorkoutType.Weight
//                            ? 'Reps'
//                            : 'Seconds';
                        _widgets = _getChildrenSetParts(setType); //TODO: fuck this shit
                      });
                    },
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.redAccent,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sec',
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ));
          widgets.add(Builder(
            builder: (context) => TextFormField(
                  controller: _textControllers[j],
                  onFieldSubmitted: (str) {
                    setState(() {
                      //widget.part.exercises[i].name = str;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (str) {
                    if (str.isEmpty) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.report),
                            ),
                            Text("Name cannot be blank.")
                          ],
                        ),
                      ));
                      return 'Please enter the name of exercise';
                    } else
                      _tempExs[i].name = _textControllers[j].text;
                  },
                ),
          ));
          widgets.add(Row(
            children: <Widget>[
              Flexible(
                child: Builder(
                    builder: (context) => TextFormField(
                          controller: _textControllers[j + 1],
                          onFieldSubmitted: (str) {},
                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                          decoration: InputDecoration(labelText: 'Weight'),
                          validator: (str) {
                            if (str.isEmpty)
                              _tempExs[i].weight = 0;
                            else if (str.contains(RegExp(r"(,|-)"))) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.report),
                                    ),
                                    Text("Weight can only contain numbers.")
                                  ],
                                ),
                              ));
                              return "Numbers only";
                            } else {
                              try {
                                double tempWeight = double.parse(_textControllers[j + 1].text);
                                //the weight below 20 doesn't need floating point, it's just unnecessary
                                if (tempWeight < 20) {
                                  _tempExs[i].weight = tempWeight;
                                } else {
                                  _tempExs[i].weight = tempWeight.floorToDouble();
                                }
                              } catch (Exception) {}
                            }
                          },
                        )),
              ),
              Flexible(
                child: TextFormField(
                  controller: _textControllers[2],
                  //before: _textControllers[j + 2],
                  onFieldSubmitted: (str) {},
                  keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                  decoration: InputDecoration(labelText: 'Sets'),
                  validator: (str) {
                    if (str.isEmpty)
                      _tempExs[i].sets = 1; //number of sets must be none zero
                    else if (str.contains(RegExp(r"(,|\.|-)"))) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Sets can only contain numbers."),
                      ));
                      return "Numbers only";
                    } else
                      _tempExs[i].sets = int.parse(_textControllers[2].text); //before: _textControllers[j + 2],
                  },
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: _textControllers[j + 3],
                  onFieldSubmitted: (str) {},
                  keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                  decoration: InputDecoration(labelText: _tempExs[i].workoutType == WorkoutType.Weight ? 'Reps' : 'Seconds'),
                  validator: (str) {
                    if (str.isEmpty)
                      _tempExs[i].reps = '';
                    else
                      _tempExs[i].reps = _textControllers[j + 3].text;
                  },
                ),
              )
            ],
          ));
          widgets.add(Container(
            //serve as divider
            height: 24,
          ));
        }
      }
      return widgets;
    }
  }

  ListView listView;
  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    var _expansionPanelChildren = items.map((Item item) {
      return ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
              leading: item.iconpic,
              title: Text(
                item.header,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ));
        },
        isExpanded: item.isExpanded,
        body: item.callback(),
      );
    }).toList();

    listView = ListView(
      controller: _scrollController,
      children: [
        Form(
            key: _formKey,
            child: Padding(
              //Targeted Body Part, Type of set, Details
              padding: EdgeInsets.all(12.0),
              child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      items[index].isExpanded = !items[index].isExpanded;
                    });
                  },
                  children: _expansionPanelChildren),
            )),
        Padding(
            //Additional notes
            padding: EdgeInsets.all(12),
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
                          ? ListTile(
                              leading: Icon(Icons.assignment),
                              subtitle: Text('Remind yourself what to pay attention to while doing these exercises'),
                              title: Text(
                                'Additional Notes',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : ListTile(
                              leading: Icon(Icons.assignment),
                              title: Text(
                                'Additional Notes',
                                style: TextStyle(
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
                            _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ))
              ],
            ))
      ],
    );

    Scaffold scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Criteria Selection"),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    widget.part.targetedBodyPart = PartEditPageHelper.radioValueToTargetedBodyPartConverter(_radioValue1);
                    widget.part.setType = PartEditPageHelper.radioValueToSetTypeConverter(_radioValueSetType);
                    widget.part.exercises = List<Exercise>();
                    for (int i = 0; i < _enabledList.where((res) => res).length; i++) {
                      widget.part.exercises.add(Exercise(
                          name: _tempExs[i].name,
                          weight: _tempExs[i].weight,
                          sets: _tempExs[i].sets,
                          reps: _tempExs[i].reps,
                          workoutType: _tempExs[i].workoutType,
                          exHistory: _tempExs[i].exHistory));
                    }
                    widget.part.additionalNotes = _addtionalNotesTextEditingController.text;
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

  static TargetedBodyPart radioValueToTargetedBodyPartConverter(int radioValue) {
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
        throw Exception('Inside _radioValueToTargetedBodyPartConverter, radioValue: ${radioValue.toString()}');
    }
  }
}
