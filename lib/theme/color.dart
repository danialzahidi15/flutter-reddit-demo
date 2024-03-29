import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/enum/enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class RedditColor {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
      titleTextStyle: TextStyle(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
    backgroundColor: drawerColor, // will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
      titleTextStyle: TextStyle(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMethod _mode;
  ThemeNotifier({ThemeMethod mode = ThemeMethod.dark})
      : _mode = mode,
        super(RedditColor.darkModeAppTheme) {
    getTheme();
  }

  ThemeMethod get mode => _mode;

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMethod.light;
      state = RedditColor.darkModeAppTheme;
    } else {
      _mode = ThemeMethod.dark;
      state = RedditColor.lightModeAppTheme;
    }
  }

  void toggleTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (_mode == ThemeMethod.dark) {
      _mode = ThemeMethod.light;
      state = RedditColor.lightModeAppTheme;
      preferences.setString('theme', 'light');
    } else {
      _mode = ThemeMethod.dark;
      state = RedditColor.darkModeAppTheme;
      preferences.setString('theme', 'dark');
    }
  }
}
