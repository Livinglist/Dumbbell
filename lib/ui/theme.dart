import 'package:flutter/material.dart';

// TODO: delete this useless class
abstract class CustomTheme {
  static Color accentColor = Colors.blueAccent;
}

abstract class ThemeRegular extends CustomTheme {
  static final Color accentColor = Colors.blue[200];
}

abstract class ThemeDrop extends CustomTheme {
  static final Color accentColor = Colors.grey.shade400;
}

abstract class ThemeSuper extends CustomTheme {
  static final Color accentColor = Colors.tealAccent;
}

abstract class ThemeTri extends CustomTheme {
  static final Color accentColor = Colors.pinkAccent;
}

abstract class ThemeGiant extends CustomTheme {
  static final Color accentColor = Colors.red[200];
}
