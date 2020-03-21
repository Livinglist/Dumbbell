import 'package:flutter/material.dart';

import 'package:workout_planner/utils/routine_helpers.dart';

import 'package:workout_planner/models/routine.dart';

class PartEditPage extends StatefulWidget {
  final Part part;
  final AddOrEdit addOrEdit;
  final Routine curRoutine;

  PartEditPage({@required this.addOrEdit, this.part, this.curRoutine});

  @override
  State<StatefulWidget> createState() => _PartEditPageState();
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

class _PartEditPageState extends State<PartEditPage> {
  final addtionalNotesTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Routine curRoutine;
  List<TextEditingController> textControllers = List<TextEditingController>();
  int radioValueTargetedBodyPart = 0;
  int radioValueSetType = 0;
  bool additionalNotesIsExpanded;
  bool isNewlyCreated = false;
  List<Item> items;
  List<Exercise> tempExs = List<Exercise>();
  List<Widget> _widgets;
  SetType setType;

  ///the widgets that are gonna be displayed in the expansionPanel of exercise detail
  List<bool> enabledList = <bool>[true, false, false, false];

  @override
  void initState() {
    ///copy the content of exercises of the Part
    additionalNotesIsExpanded = false;

    addtionalNotesTextEditingController.text = widget.part.additionalNotes;

    //Determine whether or not the exercise is newly created.
    if (widget.part.exercises.length == 0) {
      for (int i = 0; i < 4; i++) {
        var exCopy = Exercise(name: null, weight: null, sets: null, reps: null, exHistory: {});
        tempExs.add(exCopy);
      }
      isNewlyCreated = true;
    } else {
      //if the part is an existing part that's been editing, then copy the whole thing to _tempExs
      for (int i = 0; i < 4; i++) {
        if (i < widget.part.exercises.length) {
          var ex = widget.part.exercises[i];
          var exCopy = Exercise(name: ex.name, weight: ex.weight, sets: ex.sets, reps: ex.reps, workoutType: ex.workoutType, exHistory: ex.exHistory);
          tempExs.add(exCopy);
        } else {
          tempExs.add(Exercise(name: null, weight: null, sets: null, reps: null, exHistory: {}));
        }
      }
      isNewlyCreated = false;
    }

    setType = isNewlyCreated ? SetType.Regular : widget.part.setType;

    if (true) {
      switch (widget.part.targetedBodyPart) {
        case TargetedBodyPart.Abs:
          radioValueTargetedBodyPart = 0;
          break;
        case TargetedBodyPart.Arm:
          radioValueTargetedBodyPart = 1;
          break;
        case TargetedBodyPart.Back:
          radioValueTargetedBodyPart = 2;
          break;
        case TargetedBodyPart.Chest:
          radioValueTargetedBodyPart = 3;
          break;
        case TargetedBodyPart.Leg:
          radioValueTargetedBodyPart = 4;
          break;
        case TargetedBodyPart.Shoulder:
          radioValueTargetedBodyPart = 5;
          break;
        case TargetedBodyPart.Bicep:
          radioValueTargetedBodyPart = 6;
          break;
        case TargetedBodyPart.Tricep:
          radioValueTargetedBodyPart = 7;
          break;
        case TargetedBodyPart.FullBody:
          radioValueTargetedBodyPart = 8;
          break;
      }

      switch (widget.part.setType) {
        case SetType.Regular:
          radioValueSetType = 0;
          break;
        case SetType.Drop:
          radioValueSetType = 1;
          break;
        case SetType.Super:
          radioValueSetType = 2;
          break;
        case SetType.Tri:
          radioValueSetType = 3;
          break;
        case SetType.Giant:
          radioValueSetType = 4;
          break;
      }

      for (int i = 0; i < 16; i++) {
        textControllers.add(TextEditingController());
      }

      for (int i = 0, j = 0; i < 16; i++, j += 4) {
        if (i < widget.part.exercises.length) {
          textControllers[j].text = widget.part.exercises[i].name;
          textControllers[j + 1].text = widget.part.exercises[i].weight.toString();
          textControllers[j + 2].text = widget.part.exercises[i].sets.toString();
          textControllers[j + 3].text = widget.part.exercises[i].reps;
        } else {}
      }
    }

    //_widgets = buildSetDetails(isNewlyCreated ? SetType.Regular : widget.part.setType);

    items = <Item>[
      Item(isExpanded: true, header: 'Targeted Body Part', callback: buildTargetedBodyPartRadioList, iconpic: Icon(Icons.accessibility_new)),
      Item(isExpanded: false, header: 'Type of Set', callback: buildSetTypeList, iconpic: Icon(Icons.blur_linear)),
      Item(isExpanded: true, header: 'Details', callback: buildSetDetailsList, iconpic: Icon(Icons.fitness_center))
    ];

    super.initState();
  }

  Future<bool> onWillPop() {
     return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Your editing will not be saved.'),
            actions: <Widget>[
              FlatButton(
                onPressed: ()=>Navigator.of(context).pop(false),
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
     ).then((value){
       if(value == null || value == false){
         return false;
       }else{
         Navigator.pop(context, widget.part);
         return true;
       }
     });
  }

  Widget buildTargetedBodyPartRadioList() {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            RadioListTile(value: 0, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Abs')),
            RadioListTile(value: 1, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Arm')),
            RadioListTile(value: 2, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Back')),
            RadioListTile(value: 3, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Chest')),
            RadioListTile(value: 4, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Leg')),
            RadioListTile(value: 5, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Shoulder')),
            RadioListTile(value: 6, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Bicep')),
            RadioListTile(value: 7, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Tricep')),
            RadioListTile(value: 8, groupValue: radioValueTargetedBodyPart, onChanged: onRadioValueChanged, title: Text('Full Body')),
          ])),
    );
  }

  Widget buildSetTypeList() {
    return Material(
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            RadioListTile(value: 0, groupValue: radioValueSetType, onChanged: onRadioSetTypeValueChanged, title: Text('Regular Sets')),
            RadioListTile(value: 1, groupValue: radioValueSetType, onChanged: onRadioSetTypeValueChanged, title: Text('Drop Sets')),
            RadioListTile(value: 2, groupValue: radioValueSetType, onChanged: onRadioSetTypeValueChanged, title: Text('Super Sets')),
            RadioListTile(value: 3, groupValue: radioValueSetType, onChanged: onRadioSetTypeValueChanged, title: Text('Tri-Sets')),
            RadioListTile(value: 4, groupValue: radioValueSetType, onChanged: onRadioSetTypeValueChanged, title: Text('Giant Sets')),
          ])),
    );
  }

  ///Build the expansion panel for detailed information on exercises
  Widget buildSetDetailsList() {
    return Material(child: Padding(padding: EdgeInsets.all(16.0), child: Column(children: buildSetDetails())));
  }

  List<Widget> buildSetDetails() {
    const count = 4;

    List<Widget> widgets = List<Widget>();

    int exCount = setTypeToExerciseCountConverter(setType);

    for (int i = 0; i < 4; i++) {
      if (i < exCount) {
        enabledList[i] = true;
      } else {
        enabledList[i] = false;
      }
    }

    //setType will not be passed in when initializing this page
    for (int i = 0, j = 0; i < count; i++, j += 4) {
      if (enabledList[i]) {
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
                  value: tempExs[i].workoutType == WorkoutType.Cardio,
                  onChanged: (res) {
                    setState(() {
                      tempExs[i].workoutType = res ? WorkoutType.Cardio : WorkoutType.Weight;
                      //_widgets = buildSetDetails(setType); //TODO: fuck this shit
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
            controller: textControllers[j],
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
              } else {
                tempExs[i].name = textControllers[j].text;
                return null;
              }
            },
          ),
        ));
        widgets.add(Row(
          children: <Widget>[
            Flexible(
              child: Builder(
                  builder: (context) => TextFormField(
                        controller: textControllers[j + 1],
                        onFieldSubmitted: (str) {},
                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                        decoration: InputDecoration(labelText: 'Weight'),
                        validator: (str) {
                          if (str.isEmpty) {
                            tempExs[i].weight = 0;
                            return null;
                          } else if (str.contains(RegExp(r"(,|-)"))) {
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
                              double tempWeight = double.parse(textControllers[j + 1].text);
                              //the weight below 20 doesn't need floating point, it's just unnecessary
                              if (tempWeight < 20) {
                                tempExs[i].weight = tempWeight;
                              } else {
                                tempExs[i].weight = tempWeight.floorToDouble();
                              }

                              return null;
                            } catch (Exception) {}
                          }
                          return null;
                        },
                      )),
            ),
            Flexible(
              child: TextFormField(
                controller: textControllers[2],
                //before: _textControllers[j + 2],
                onFieldSubmitted: (str) {},
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(labelText: 'Sets'),
                validator: (str) {
                  if (str.isEmpty) {
                    tempExs[i].sets = 1; //number of sets must be none zero
                    return null;
                  } else if (str.contains(RegExp(r"(,|\.|-)"))) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Sets can only contain numbers."),
                    ));
                    return "Numbers only";
                  } else {
                    tempExs[i].sets = int.parse(textControllers[2].text); //before: _textControllers[j + 2],
                    return null;
                  }
                },
              ),
            ),
            Flexible(
              child: TextFormField(
                controller: textControllers[j + 3],
                onFieldSubmitted: (str) {},
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(labelText: tempExs[i].workoutType == WorkoutType.Weight ? 'Reps' : 'Seconds'),
                validator: (str) {
                  if (str.isEmpty)
                    tempExs[i].reps = '';
                  else
                    tempExs[i].reps = textControllers[j + 3].text;
                  return null;
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

  ListView listView;
  ScrollController scrollController;

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
      controller: scrollController,
      children: [
        Form(
            key: formKey,
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
                  additionalNotesIsExpanded = !additionalNotesIsExpanded;
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
                    isExpanded: additionalNotesIsExpanded,
                    body: Material(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: TextField(
                          controller: addtionalNotesTextEditingController,
                          onTap: () {
                            scrollController.animateTo(scrollController.position.maxScrollExtent,
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
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Criteria Selection"),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    widget.part.targetedBodyPart = PartEditPageHelper.radioValueToTargetedBodyPartConverter(radioValueTargetedBodyPart);
                    widget.part.setType = PartEditPageHelper.radioValueToSetTypeConverter(radioValueSetType);
                    widget.part.exercises = List<Exercise>();
                    for (int i = 0; i < enabledList.where((res) => res).length; i++) {
                      widget.part.exercises.add(Exercise(
                          name: tempExs[i].name,
                          weight: tempExs[i].weight,
                          sets: tempExs[i].sets,
                          reps: tempExs[i].reps,
                          workoutType: tempExs[i].workoutType,
                          exHistory: tempExs[i].exHistory));
                    }
                    widget.part.additionalNotes = addtionalNotesTextEditingController.text;
                    Navigator.pop(context, widget.part);
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
      onWillPop: onWillPop,
      child: scaffold,
    );
  }

  void onRadioValueChanged(int value) {
    setState(() {
      radioValueTargetedBodyPart = value;
    });
  }

  void onRadioSetTypeValueChanged(int value) {
    setState(() {
      radioValueSetType = value;
      setType = PartEditPageHelper.radioValueToSetTypeConverter(value);
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
