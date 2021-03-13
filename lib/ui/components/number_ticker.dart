import 'package:flutter/material.dart';

///A controller for updating the single digit displayed by [DigitTicker]
class _DigitTickerController extends ValueNotifier {
  int _number;

  _DigitTickerController({int num = 0}) : super(num) {
    assert(num <= 9 && num >= 0, 'Number must be in the range of [0, 10).');
    this._number = num;
  }

  int get number => _number;

  set number(int num) {
    this._number = num;
    super.value = num;
  }
}

///A widget for displaying a single digit.
class _DigitTicker extends StatelessWidget {
  ///The color of background.
  final Color backgroundColor;

  ///The curve of scrolling animation.
  final Curve curve;

  ///The duration of animation.
  final Duration duration;

  ///The initial number to be displayed.
  final int initialNumber;

  ///The scrollController.
  final ScrollController scrollController;

  ///The textStyle of number displayed.
  final TextStyle textStyle;

  ///The controller of this widget.
  final _DigitTickerController controller;

  _DigitTicker(
      {this.backgroundColor = Colors.transparent,
        this.curve = Curves.ease,
        this.controller,
        this.textStyle,
        this.initialNumber,
        this.duration})
      : scrollController = ScrollController(
      initialScrollOffset: textStyle.fontSize * (4 / 3) * initialNumber),
        assert(controller != null, 'Controller cannot be null.'),
        assert(initialNumber != null, 'Initial number cannot be null.'),
        assert(initialNumber <= 9),
        assert(initialNumber >= 0),
        super(key: Key(controller.toString())) {
    controller.addListener(onValueChanged);
  }

  ///Scrolls to the positions of the new number.
  void onValueChanged() {
    if (this.scrollController.hasClients) {
      scrollController.animateTo(
          controller.number * textStyle.fontSize * (4 / 3),
          duration: duration,
          curve: curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        height: textStyle.fontSize * (4 / 3),
        width: textStyle.fontSize * (7 / 10),
        child: Stack(
          children: [
            ListView(
              controller: scrollController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                for (var i in List.generate(10, (index) => index))
                  Container(
                    height: textStyle.fontSize * (4 / 3),
                    child: Center(
                      child: Text("$i", style: textStyle),
                    ),
                  )
              ],
            ),
          ],
        ));
  }
}

class NumberTickerController extends ValueNotifier {
  double _number;

  NumberTickerController() : super(0) {
    this._number = 0;
  }

  double get number => _number;

  set number(double num) {
    if(num < 0) num = 0;
    this._number = num;
    super.value = num;
  }
}

///A widget for displaying the realtime change of a number.
class NumberTicker extends StatefulWidget {
  ///The color of background.
  final Color backgroundColor;

  ///The curve of scrolling animation.
  final Curve curve;

  ///The initial number to be displayed, default is 0.
  final double initialNumber;

  ///The duration of animation.
  final Duration duration;

  ///The number of digits after decimal point.
  final int fractionDigits;

  ///The controller of this widget.
  final NumberTickerController controller;

  ///The text style of the number.
  final TextStyle textStyle;

  NumberTicker(
      {this.backgroundColor = Colors.transparent,
        this.curve = Curves.ease,
        this.controller,
        this.textStyle = const TextStyle(color: Colors.black, fontSize: 12),
        this.initialNumber,
        this.duration = const Duration(milliseconds: 300),
        this.fractionDigits = 0})
      : assert(controller != null, 'Controller cannot be null.'),
        assert(initialNumber != null, 'Initial number cannot be null.'),
        assert(duration != null, 'Duration cannot be null.'), super(key: UniqueKey()) {
    this.controller.number = initialNumber;
  }

  @override
  _NumberTickerState createState() => _NumberTickerState();
}

///The state of [NumberTicker].
class _NumberTickerState extends State<NumberTicker>
    with SingleTickerProviderStateMixin {
  ///The animation controller for animating the removed or added [DigitTicker].
  AnimationController animationController;

  ///The number this widget currently displaying.
  double currentNum;

  ///The string representation of the [currentNum].
  String currentNumString;

  ///The index of decimal point in the [currentNum].
  int decimalIndex;

  ///The indicator of whether the new number is longer or shorter than the current one.
  bool shorter = false, longer = false;

  ///The list of [_DigitTickerController].
  List<_DigitTickerController> digitControllers = [];

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    var num = widget.initialNumber;
    currentNum = num;
    var numString = num.toStringAsFixed(widget.fractionDigits);

    currentNumString = numString;

    for (int i = 0; i < numString.length; i++) {
      var digit = numString.codeUnitAt(i) - 48;

      if (digit >= 0) {
        digitControllers.insert(i, _DigitTickerController(num: digit));
      } else {
        decimalIndex = i;
        digitControllers.insert(i, null);
      }
    }

    widget.controller.addListener(onNumberChanged);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (shorter) digitControllers.removeLast();

          this.longer = false;
          this.shorter = false;
        });
        animationController.value = 0;
      }
    });

    super.initState();
  }

  ///Updates the number when notified.
  onNumberChanged() {
    if (animationController.isAnimating) {
      animationController.notifyStatusListeners(AnimationStatus.completed);
    }
    var num = widget.controller.number;
    var numString = num.toStringAsFixed(widget.fractionDigits);

    bool shorter = false;
    bool longer = false;

    if (numString.length < currentNumString.length) {
      shorter = true;
    } else if (numString.length > currentNumString.length) {
      digitControllers.insert(0, _DigitTickerController(num: 1));

      longer = true;
    }

    int startIndex = 0;

    if (longer) {
      startIndex = 1;
    }

    for (int i = startIndex; i < numString.length; i++) {
      var digit = numString.codeUnitAt(i) - 48;
      var oldDigit = longer
          ? currentNumString.codeUnitAt(i - 1) - 48
          : currentNumString.codeUnitAt(i) - 48;

      if (digit >= 0 && digit != oldDigit) {
        digitControllers[i].number = digit;
      } else {}
    }

    currentNumString = numString;
    currentNum = num;

    if (shorter || longer) {
      animationController.forward();
    }
    this.shorter = shorter;
    this.longer = longer;
  }

  @override
  Widget build(BuildContext context) {
    var width = widget.textStyle.fontSize * (8 / 10);
    return AnimatedBuilder(
        animation: animationController,
        builder: (_, __) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: widget.backgroundColor,
                  width: longer ? (animationController.value) * width : width,
                  child: digitControllers.first == null
                      ? Text(' ')
                      : _DigitTicker(
                      backgroundColor: widget.backgroundColor,
                      controller: digitControllers.first,
                      curve: widget.curve,
                      duration: widget.duration,
                      textStyle: widget.textStyle,
                      initialNumber: currentNumString.codeUnitAt(0) - 48),
                ),
                for (int i = 1; i < digitControllers.length - 1; i++)
                  digitControllers[i] == null
                      ? Text(' ')
                      : _DigitTicker(
                      backgroundColor: widget.backgroundColor,
                      controller: digitControllers[i],
                      curve: widget.curve,
                      duration: widget.duration,
                      textStyle: widget.textStyle,
                      initialNumber: i == currentNumString.length
                          ? 0
                          : (currentNumString.codeUnitAt(i) - 48)),
                if (digitControllers.length > 1)
                  Container(
                    width: shorter
                        ? (1 - animationController.value) * width
                        : width,
                    child: digitControllers.last == null
                        ? Text(' ')
                        : _DigitTicker(
                        backgroundColor: widget.backgroundColor,
                        controller: digitControllers.last,
                        curve: widget.curve,
                        duration: widget.duration,
                        textStyle: widget.textStyle,
                        initialNumber: currentNumString
                            .codeUnitAt(currentNumString.length - 1) -
                            48),
                  )
              ],
            ),
          );
        });
  }
}
